From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] tg3: 64bits stats
Date: Mon, 05 Jul 2010 20:35:13 +0200
Message-ID: <1278354913.2877.647.camel@edumazet-laptop>
References: <1278321242.2877.18.camel@edumazet-laptop>
	 <1278345780.2877.376.camel@edumazet-laptop>
	 <1278351070.2087.70.camel@achroite.uk.solarflarecom.com>
	 <1278353230.2877.601.camel@edumazet-laptop>
	 <1278354656.2087.108.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:58035 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752061Ab0GESfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 14:35:18 -0400
Received: by ewy23 with SMTP id 23so1666248ewy.19
        for <netdev@vger.kernel.org>; Mon, 05 Jul 2010 11:35:16 -0700 (PDT)
In-Reply-To: <1278354656.2087.108.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 05 juillet 2010 =C3=A0 19:30 +0100, Ben Hutchings a =C3=A9crit=
 :

> I think you should use a similar approach here as you did in the
> loopback driver, i.e. update private variables in the RX and TX path =
and
> then copy/aggregate them in the implementation ndo_get_stats64 (only
> without the need for percpu stats).
>=20
> If you want to include a seqlock in the driver stats interface, you c=
an
> do that but it's not going to be pretty and we're still going to need
> additional seqlocks for per-queue (or percpy) stats in some drivers.

Yes, I provided one patch but am working on a different one, requiring =
a
new rtnl_link_stats64 param to ndo_get_stats64() methods and
dev_get_stats() as well.

dev->stats64 should not be overwritten without some synchronization, so
just disallow it for the moment...


