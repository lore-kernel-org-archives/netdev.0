From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] ipconfig: Inform user if carrier is not ready
Date: Fri, 14 Sep 2012 07:36:31 +0200
Message-ID: <20120914053631.GA26503@electric-eye.fr.zoreil.com>
References: <5052403B.4040408@gmail.com> <20120913.163134.361379133013906511.davem@davemloft.net> <50524419.4080404@gmail.com> <20120913.164525.1171098883605242394.davem@davemloft.net> <50525758.1090609@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Erwan Velu <erwanaliasr1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40735 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753674Ab2INFy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2012 01:54:28 -0400
Content-Disposition: inline
In-Reply-To: <50525758.1090609@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Erwan Velu <erwanaliasr1@gmail.com> :
[...]
> This patch is just adding a simple message every second telling we are
> waiting the carrier to come up.
> ---
>  net/ipv4/ipconfig.c |    8 ++++++++
>  1 file changed, 8 insertions(+)

The Signed-off-by: line is missing.

> diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
> index 67e8a6b..d9f34b7 100644
> --- a/net/ipv4/ipconfig.c
> +++ b/net/ipv4/ipconfig.c
> @@ -205,6 +205,7 @@ static int __init ic_open_devs(void)
>      struct net_device *dev;
>      unsigned short oflags;
>      unsigned long start;
> +    unsigned int loops=0;

(nit)
	unsigned int loops = 0;

>      last = &ic_first_dev;
>      rtnl_lock();
> @@ -266,6 +267,13 @@ static int __init ic_open_devs(void)
>              if (ic_is_init_dev(dev) && netif_carrier_ok(dev))
>                  goto have_carrier;
> 
> +        loops++;
> +        /* This loop is blocking the boot process until we get the
> carrier or reach the timeout.

Please split it into 80 cols max lines.

[...]
> +         * Every second, we display a short message indicating we
> wait the carrier */

(you can remove this part of the comment)

-- 
Ueimor
