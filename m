From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ppp: fix pptp double release_sock in pptp_bind()
Date: Wed, 07 Dec 2011 05:59:54 +0100
Message-ID: <1323233994.2690.29.camel@edumazet-laptop>
References: <20111207014712.GB25869@dztty>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dmitry Kozlov <xeb@mail.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Djalal Harouni <tixxdz@opendz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111207014712.GB25869@dztty>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 07 d=C3=A9cembre 2011 =C3=A0 02:47 +0100, Djalal Harouni a =
=C3=A9crit :
> Signed-off-by: Djalal Harouni <tixxdz@opendz.org>
> ---
>  drivers/net/ppp/pptp.c |    4 +---
>  1 files changed, 1 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
> index 89f829f..f8a6853 100644
> --- a/drivers/net/ppp/pptp.c
> +++ b/drivers/net/ppp/pptp.c
> @@ -423,10 +423,8 @@ static int pptp_bind(struct socket *sock, struct=
 sockaddr *uservaddr,
>  	lock_sock(sk);
> =20
>  	opt->src_addr =3D sp->sa_addr.pptp;
> -	if (add_chan(po)) {
> -		release_sock(sk);
> +	if (add_chan(po))
>  		error =3D -EBUSY;
> -	}
> =20
>  	release_sock(sk);
>  	return error;

Nice catch !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
