From: Bernard Pidoux F6BVP <f6bvp@free.fr>
Subject: Re: [PATCH] ax25: Fix possible oops in ax25_make_new
Date: Mon, 28 Sep 2009 12:47:07 +0200
Message-ID: <4AC0942B.9000309@free.fr>
References: <20090921201157.GA5460@del.dom.local> <4ABA9058.3010605@free.fr> <20090925131038.GA14778@ff.dom.local> <20090925134052.GA1661@linux-mips.org> <20090927205701.GA7205@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	David Miller <davem@davemloft.net>,
	Bernard Pidoux <bernard.pidoux@upmc.fr>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams <linux-hams@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20090927205701.GA7205@del.dom.local>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Applied.
Thanks.

Bernard

Jarek Poplawski a =E9crit :
> In ax25_make_new, if kmemdup of digipeat returns an error, there woul=
d
> be an oops in sk_free while calling sk_destruct, because sk_protinfo
> is NULL at the moment; move sk->sk_destruct initialization after this=
=2E
>=20
> BTW of reported-by: Bernard Pidoux F6BVP <f6bvp@free.fr>
>=20
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> ---
>=20
>  net/ax25/af_ax25.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
> index fbcac76..9884639 100644
> --- a/net/ax25/af_ax25.c
> +++ b/net/ax25/af_ax25.c
> @@ -900,7 +900,6 @@ struct sock *ax25_make_new(struct sock *osk, stru=
ct ax25_dev *ax25_dev)
> =20
>  	sock_init_data(NULL, sk);
> =20
> -	sk->sk_destruct =3D ax25_free_sock;
>  	sk->sk_type     =3D osk->sk_type;
>  	sk->sk_priority =3D osk->sk_priority;
>  	sk->sk_protocol =3D osk->sk_protocol;
> @@ -938,6 +937,7 @@ struct sock *ax25_make_new(struct sock *osk, stru=
ct ax25_dev *ax25_dev)
>  	}
> =20
>  	sk->sk_protinfo =3D ax25;
> +	sk->sk_destruct =3D ax25_free_sock;
>  	ax25->sk    =3D sk;
> =20
>  	return sk;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-hams"=
 in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20

--
To unsubscribe from this list: send the line "unsubscribe linux-hams" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
