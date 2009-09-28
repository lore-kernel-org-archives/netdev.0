From: Bernard Pidoux F6BVP <f6bvp@free.fr>
Subject: Re: [PATCH] ax25: Add missing dev_put in ax25_setsockopt
Date: Mon, 28 Sep 2009 12:48:25 +0200
Message-ID: <4AC09479.6040402@free.fr>
References: <20090921201157.GA5460@del.dom.local> <4ABA9058.3010605@free.fr> <20090928071211.GA8658@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Bernard Pidoux <bernard.pidoux@upmc.fr>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams <linux-hams@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:34428 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751755AbZI1Ksd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2009 06:48:33 -0400
In-Reply-To: <20090928071211.GA8658@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I had noticed dev_put(dev) was missing but never found where to insert =
it !
Patch applied.
Thank you.

Bernard


Jarek Poplawski a =E9crit :
> There is no dev_put ending positive SO_BINDTODEVICE call in
> ax25_setsockopt and no matching dev_put later. This ref isn't used by
> ax25_cb's because it's handled with up and down device events.
>=20
> BTW of reported-by: Bernard Pidoux F6BVP <f6bvp@free.fr>
>=20
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> ---
>=20
>  net/ax25/af_ax25.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
> index fbcac76..3eee8eb 100644
> --- a/net/ax25/af_ax25.c
> +++ b/net/ax25/af_ax25.c
> @@ -663,6 +663,7 @@ static int ax25_setsockopt(struct socket *sock, i=
nt level, int optname,
> =20
>  		ax25->ax25_dev =3D ax25_dev_ax25dev(dev);
>  		ax25_fillin_cb(ax25, ax25->ax25_dev);
> +		dev_put(dev);
>  		break;
> =20
>  	default:
> --
> To unsubscribe from this list: send the line "unsubscribe linux-hams"=
 in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20

