From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] ipv4: release dev refcnt early when destroying
 inetdev
Date: Tue, 14 Sep 2010 13:45:29 -0700 (PDT)
Message-ID: <20100914.134529.45905377.davem@davemloft.net>
References: <1284128679.24675.38.camel@edumazet-laptop>
	<4C8A474C.3040502@6wind.com>
	<1284131774.24675.46.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41638
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753835Ab0INUpK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Sep 2010 16:45:10 -0400
In-Reply-To: <1284131774.24675.46.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 10 Sep 2010 17:16:14 +0200

> Le vendredi 10 septembre 2010 =E0 16:57 +0200, Nicolas Dichtel a =E9c=
rit :
>=20
>> Is this not true in IPv6? What is the difference?
>=20
> It might be a bug on ipv6, who knows ?
>=20
> Releasing a reference count, but not setting idev->dev to NULL is=20
> a sign something is wrong...

If anything this is more of a BUG trap than a true correctness patch,
but either way if you want me to apply this please formally submit
this with a proper commit message and signoff, thanks!

> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 5bc893e..26e39bc 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -330,6 +330,7 @@ void in6_dev_finish_destroy(struct inet6_dev *ide=
v)
>  	printk(KERN_DEBUG "in6_dev_finish_destroy: %s\n", dev ? dev->name :=
 "NIL");
>  #endif
>  	dev_put(dev);
> +	idev->dev =3D NULL;
>  	if (!idev->dead) {
>  		pr_warning("Freeing alive inet6 device %p\n", idev);
>  		return;
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
