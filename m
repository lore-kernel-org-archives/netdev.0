From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch] net/unix: do not forget to autobind in standard case
Date: Tue, 28 Dec 2010 17:44:15 +0100
Message-ID: <1293554655.20573.5.camel@edumazet-laptop>
References: <alpine.LNX.2.01.1012250107330.22521@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41495 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751706Ab0L1QoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Dec 2010 11:44:24 -0500
Received: by wyb28 with SMTP id 28so9420983wyb.19
        for <netdev@vger.kernel.org>; Tue, 28 Dec 2010 08:44:22 -0800 (PST)
In-Reply-To: <alpine.LNX.2.01.1012250107330.22521@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 25 d=C3=A9cembre 2010 =C3=A0 01:08 +0100, Jan Engelhardt a =C3=
=A9crit :
> parent 67514fc40bbec857018cbc689d440282b75551db (v2.6.37-rc1-229-g675=
14fc)
> commit 973bdc63c6aba703dd7b62a6ec7ae4bab7847731
> Author: Jan Engelhardt <jengelh@medozas.de>
> Date:   Sat Dec 25 00:50:59 2010 +0100
>=20
> net/unix: do not forget to autobind in standard case
>=20
> A program using recvmsg on an AF_LOCAL datagram socket does not
> receive the peer's address when the remote has not issued a bind. Thi=
s
> makes it impossible to send messages back. (But the same _does_ work
> in IP.) The cause for this is because autobinding was only done when
> credential passing was requested.
>=20

It would be good you did some research and tell us why current code
tests SOCK_PASSCRED

There must be a reason this restrictive code is here, dont you think ?

> --->8---
>=20
> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
> ---
>  net/unix/af_unix.c |   10 ++++------
>  1 files changed, 4 insertions(+), 6 deletions(-)
>=20
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 7ff31c6..945797c 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -964,8 +964,8 @@ static int unix_dgram_connect(struct socket *sock=
, struct sockaddr *addr,
>  			goto out;
>  		alen =3D err;
> =20
> -		if (test_bit(SOCK_PASSCRED, &sock->flags) &&
> -		    !unix_sk(sk)->addr && (err =3D unix_autobind(sock)) !=3D 0)
> +		if (unix_sk(sk)->addr =3D=3D NULL &&
> +		    (err =3D unix_autobind(sock)) !=3D 0)
>  			goto out;
> =20
>  restart:
> @@ -1063,8 +1063,7 @@ static int unix_stream_connect(struct socket *s=
ock, struct sockaddr *uaddr,
>  		goto out;
>  	addr_len =3D err;
> =20
> -	if (test_bit(SOCK_PASSCRED, &sock->flags) && !u->addr &&
> -	    (err =3D unix_autobind(sock)) !=3D 0)
> +	if (u->addr =3D=3D NULL && (err =3D unix_autobind(sock)) !=3D 0)
>  		goto out;
> =20
>  	timeo =3D sock_sndtimeo(sk, flags & O_NONBLOCK);
> @@ -1419,8 +1418,7 @@ static int unix_dgram_sendmsg(struct kiocb *kio=
cb, struct socket *sock,
>  			goto out;
>  	}
> =20
> -	if (test_bit(SOCK_PASSCRED, &sock->flags) && !u->addr
> -	    && (err =3D unix_autobind(sock)) !=3D 0)
> +	if (u->addr =3D=3D NULL && (err =3D unix_autobind(sock)) !=3D 0)
>  		goto out;
> =20
>  	err =3D -EMSGSIZE;


