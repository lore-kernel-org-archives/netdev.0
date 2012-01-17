From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch] inetpeer: initialize ->redirect_genid in inet_getpeer()
Date: Tue, 17 Jan 2012 21:57:08 +0100
Message-ID: <1326833828.2606.5.camel@edumazet-laptop>
References: <20120117204843.GA20999@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:38654 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753396Ab2AQU5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 15:57:17 -0500
In-Reply-To: <20120117204843.GA20999@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 17 janvier 2012 =C3=A0 23:48 +0300, Dan Carpenter a =C3=A9crit=
 :
> kmemcheck complains that ->redirect_genid doesn't get initialized.
> Presumably it should be set to zero.
>=20
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>=20
> diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
> index 86f13c67..49ce5f4 100644
> --- a/net/ipv4/inetpeer.c
> +++ b/net/ipv4/inetpeer.c
> @@ -447,6 +447,7 @@ relookup:
>  		p->rate_last =3D 0;
>  		p->pmtu_expires =3D 0;
>  		p->pmtu_orig =3D 0;
> +		p->redirect_genid =3D 0;
>  		memset(&p->redirect_learned, 0, sizeof(p->redirect_learned));
> =20
>=20

We dont really care, since we force redirect_learned.a4 to be 0

Only place we care is in ip_rt_redirect() and its done properly there.

Lets shutup kmemcheck.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
