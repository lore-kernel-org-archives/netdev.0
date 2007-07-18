From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Add a network activity LED trigger
Date: Wed, 18 Jul 2007 15:33:57 +0200
Message-ID: <469E16C5.4000102@trash.net>
References: <200707181527.38895.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rpurdie@rpsys.net
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38793 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757705AbXGRNe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 09:34:26 -0400
In-Reply-To: <200707181527.38895.florian.fainelli@telecomint.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Fainelli wrote:
> diff --git a/drivers/leds/Kconfig b/drivers/leds/Kconfig
> index 87d2046..fdc5a8a 100644
> --- a/drivers/leds/Kconfig
> +++ b/drivers/leds/Kconfig
> @@ -128,5 +128,12 @@ config LEDS_TRIGGER_HEARTBEAT
>  	  load average.
>  	  If unsure, say Y.
>  
> +config LEDS_TRIGGER_NETWORK_ACT
> +	tristate "LED Network Activity Trigger"


Module isn't possible, you call the led trigger from net/core/dev.c.


> diff --git a/net/core/dev.c b/net/core/dev.c
> index ee051bb..a3a4115 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -117,6 +117,7 @@
>  #include <linux/err.h>
>  #include <linux/ctype.h>
>  #include <linux/if_arp.h>
> +#include <linux/leds.h>
>  
>  /*
>   *	The list of packet types we will receive (as opposed to discard)
> @@ -1523,6 +1524,7 @@ gso:
>  	 * stops preemption for RCU.
>  	 */
>  	rcu_read_lock_bh();
> +	ledtrig_network_activity();


Besides missing a declaration and not linking without the network
LED config option, its pretty ridiculous to call this for every
packet just to make a led blink.

