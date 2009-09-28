From: Bernard Pidoux <bernard.pidoux@upmc.fr>
Subject: Re: [PATCH] ax25: Add missing dev_put in ax25_setsockopt
Date: Mon, 28 Sep 2009 19:46:06 +0200
Message-ID: <4AC0F65E.9040401@upmc.fr>
References: <20090921201157.GA5460@del.dom.local> <4ABA9058.3010605@free.fr> <20090928071211.GA8658@ff.dom.local> <20090928125313.GA14250@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	Bernard Pidoux F6BVP <f6bvp@free.fr>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams <linux-hams@vger.kernel.org>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:33682 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751599AbZI1Rq3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2009 13:46:29 -0400
In-Reply-To: <20090928125313.GA14250@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi take this one too. Hi.
Applied.

Thanks Ralf.

Bernard

Ralf Baechle a =E9crit :
> ax25_setsockopt SO_BINDTODEVICE is missing a dev_put call in case of
> success.  Re-order code to fix this bug.  While at it also reformat t=
wo
> lines of code to comply with the Linux coding style.
>=20
> Initial patch by Jarek Poplawski <jarkao2@gmail.com>.
>=20
> Reported-by: Bernard Pidoux F6BVP <f6bvp@free.fr>
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
>=20
> ---
> Counter-proposal.  Reordering all the code avoids the need for a 2nd =
dev_put
> and is more readable.
>=20
>    Ralf
>=20
>  net/ax25/af_ax25.c |   19 ++++++++++---------
>  1 files changed, 10 insertions(+), 9 deletions(-)
>=20
> diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
> index fbcac76..4102de1 100644
> --- a/net/ax25/af_ax25.c
> +++ b/net/ax25/af_ax25.c
> @@ -641,15 +641,10 @@ static int ax25_setsockopt(struct socket *sock,=
 int level, int optname,
> =20
>  	case SO_BINDTODEVICE:
>  		if (optlen > IFNAMSIZ)
> -			optlen=3DIFNAMSIZ;
> -		if (copy_from_user(devname, optval, optlen)) {
> -		res =3D -EFAULT;
> -			break;
> -		}
> +			optlen =3D IFNAMSIZ;
> =20
> -		dev =3D dev_get_by_name(&init_net, devname);
> -		if (dev =3D=3D NULL) {
> -			res =3D -ENODEV;
> +		if (copy_from_user(devname, optval, optlen)) {
> +			res =3D -EFAULT;
>  			break;
>  		}
> =20
> @@ -657,12 +652,18 @@ static int ax25_setsockopt(struct socket *sock,=
 int level, int optname,
>  		   (sock->state !=3D SS_UNCONNECTED ||
>  		    sk->sk_state =3D=3D TCP_LISTEN)) {
>  			res =3D -EADDRNOTAVAIL;
> -			dev_put(dev);
> +			break;
> +		}
> +
> +		dev =3D dev_get_by_name(&init_net, devname);
> +		if (!dev) {
> +			res =3D -ENODEV;
>  			break;
>  		}
> =20
>  		ax25->ax25_dev =3D ax25_dev_ax25dev(dev);
>  		ax25_fillin_cb(ax25, ax25->ax25_dev);
> +		dev_put(dev);
>  		break;
> =20
>  	default:
>=20

