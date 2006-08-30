From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [RFC IPv6] Disabling IPv6 autoconf
Date: Wed, 30 Aug 2006 12:26:20 +0900 (JST)
Message-ID: <20060830.122620.104743748.yoshfuji@linux-ipv6.org>
References: <200608291659.49876.hasso@estpak.ee>
	<E1GIDgg-00043h-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hasso@estpak.ee, pb@bieringer.de, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:10510 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1750846AbWH3DY2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 23:24:28 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <E1GIDgg-00043h-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <E1GIDgg-00043h-00@gondolin.me.apana.org.au> (at Wed, 30 Aug 2006 10:12:10 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> Hasso Tepper <hasso@estpak.ee> wrote:
> >
> >> You can disable it in /proc/sys/net/ipv6/conf/default/... and then
> >> reenable it on the interfaces that you actually want.
> > 
> > You can't do that either (ie. reenable) in initscripts before link is up.
> 
> As soon as you do ifconfig ethX up it'll appear in /proc/sys and
> you can reenable it.

The point is:

 - Until we have live address(es), we do not create inet6_dev{} for that
   device.
 - We do NOT run DAD until the link is ready (netif_carrier_ok()).

This means, we do NOT have any addresses until the link is once up,
and thus, because the sysctl entries live in inet6_dev{}, we do not
install net.ipv6.conf.ethX from values of net.ipv6.conf.default until
then.

Maybe, we can install inet6_dev{} without any IPv6 addresses when we
are bringing up the device before we start DAD.

--yoshfuji
