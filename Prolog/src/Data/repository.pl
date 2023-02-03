:- module(repository, [
    connect_repo/0,
    findPersonas/1,
    findUsuarios/1,
    findOrCreateUser/2,
    incrementUserScore/1
]).
:- ensure_loaded( library(prosqlite) ).

connect_repo :- sqlite_connect('wai', c, as_predicates(true)).

/*
    Clausulas para consulta e organizacao dos personagens
*/
findPersonas(Personas) :- 
    findPersonas(Personas, 1).

findPersonas(Personas, ID) :-
    personas(ID, Nome, Sexo, CorCabelo, Etnia, CorOlhos, Acessorio)
    -> Next is ID+1,
    findPersonas(Tail, Next),
    Personas = [[ID, Nome, Sexo, CorCabelo, Etnia, CorOlhos, Acessorio] | Tail] ; Personas = [].

/*
    Clausulas para consulta dos jogadores
*/
findUsuarios(Usuarios) :- 
    findUsuarios(Usuarios, 1).

findUsuarios(Usuarios, ID) :-
    usuarios(ID, Nome, Pontuacao)
    -> Next is ID+1,
    findUsuarios(Tail, Next),
    Usuarios = [[Nome, Pontuacao] | Tail] ; Usuarios = [].

/*
    Clausulas para consulta e criacao de jogadores
*/
findOrCreateUser(Name, User) :- 
    usuarios(_, Name, Pontuacao)
    -> User = [Name, Pontuacao];
    sqlite_format_query(c, 'INSERT INTO usuarios(nome, pontos) VALUES ("~w", 0);'-Name, _),
    usuarios(_, Name, Pontuacao),
    User = [Name, Pontuacao].

/*
    Clausula para incrementar pontuacao dos jogadores
*/
incrementUserScore(Name) :-
    usuarios(_, Name, _) ->
    sqlite_format_query(c, 'UPDATE usuarios SET pontos=pontos+1 WHERE nome="~w";'-Name, _).
