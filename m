From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 RESEND 3/6] net: calxedaxgmac: use relaxed i/o
 accessors in rx and tx paths
Date: Thu, 01 Nov 2012 11:21:41 -0400 (EDT)
Message-ID: <20121101.112141.2093388998181270335.davem@davemloft.net>
References: <1351766464-27354-1-git-send-email-robherring2@gmail.com>
	<1351766464-27354-4-git-send-email-robherring2@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	rob.herring@calxeda.com
To: robherring2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60198 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761867Ab2KAPVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 11:21:45 -0400
In-Reply-To: <1351766464-27354-4-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Herring <robherring2@gmail.com>
Date: Thu,  1 Nov 2012 05:41:01 -0500

> From: Rob Herring <rob.herring@calxeda.com>
> 
> The standard readl/writel accessors involve a spinlock and cache sync
> operation on ARM platforms with an outer cache. Only DMA triggering
> accesses need this, so use the relaxed variants instead.
> 
> Signed-off-by: Rob Herring <rob.herring@calxeda.com>
> ---
>  drivers/net/ethernet/calxeda/Kconfig |    2 +-
>  drivers/net/ethernet/calxeda/xgmac.c |   12 ++++++------
>  2 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/ethernet/calxeda/Kconfig b/drivers/net/ethernet/calxeda/Kconfig
> index aba435c..6a4ddf6 100644
> --- a/drivers/net/ethernet/calxeda/Kconfig
> +++ b/drivers/net/ethernet/calxeda/Kconfig
> @@ -1,6 +1,6 @@
>  config NET_CALXEDA_XGMAC
>  	tristate "Calxeda 1G/10G XGMAC Ethernet driver"
> -	depends on HAS_IOMEM
> +	depends on HAS_IOMEM && ARM
>  	select CRC32
>  	help
>  	  This is the driver for the XGMAC Ethernet IP block found on Calxeda

This is a regression.  Now I can't built test this driver on x86
or sparc.

I'm not applying this series.  You can argue until the cows come home
about why you absolutley have to add this restriction, but I simply
don't care, this issue is too important to me.
