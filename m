From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: make WARN_ON in dev_disable_lro() useful
Date: Fri, 22 Apr 2011 07:11:53 +0200
Message-ID: <1303449113.13893.2.camel@edumazet-laptop>
References: <20110421224134.GB7888@rere.qmqm.pl>
	 <20110412144940.GA26043@rere.qmqm.pl>
	 <20110411202630.C079D13909@rere.qmqm.pl>
	 <1302610228.32697.298.camel@lb-tlvb-vladz>
	 <20110412140708.GA21835@rere.qmqm.pl>
	 <1302619012.6750.8.camel@lb-tlvb-vladz>
	 <20110412193823.0823213A65@rere.qmqm.pl>
	 <1303397531.3685.16.camel@edumazet-laptop>
	 <20110421224215.9B8AC13909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:38400 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812Ab1DVFL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 01:11:59 -0400
Received: by wwk4 with SMTP id 4so377488wwk.1
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 22:11:58 -0700 (PDT)
In-Reply-To: <20110421224215.9B8AC13909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 22 avril 2011 =C3=A0 00:42 +0200, Micha=C5=82 Miros=C5=82aw=
 a =C3=A9crit :
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
>  net/core/dev.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 3871bf6..3421184 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1315,7 +1315,8 @@ void dev_disable_lro(struct net_device *dev)
>  		return;
> =20
>  	__ethtool_set_flags(dev, flags & ~ETH_FLAG_LRO);
> -	WARN_ON(dev->features & NETIF_F_LRO);
> +	if (unlikely(dev->features & NETIF_F_LRO))
> +		netdev_WARN(dev, "failed to disable LRO!\n");
>  }
>  EXPORT_SYMBOL(dev_disable_lro);
> =20

Yes, as suggested one month ago
http://permalink.gmane.org/gmane.linux.network/189951

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

BTW, using unlikely() or likely() in slowpath is not exactly useful,
unless its integrated in macro (WARN_... )





