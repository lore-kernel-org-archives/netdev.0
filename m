From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] r6040 various bugfixes
Date: Thu, 15 Nov 2007 10:53:04 -0800
Message-ID: <20071115105304.76ef6f29@freepuppy.rosehill>
References: <200711151937.44681.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34669 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751548AbXKOSyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 13:54:45 -0500
In-Reply-To: <200711151937.44681.florian.fainelli@telecomint.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Nov 2007 19:37:43 +0100
Florian Fainelli <florian.fainelli@telecomint.eu> wrote:

> This patch fixes various bugfixes spotted by Stephen, thanks !
> 
> - add functions to allocate/free TX and RX buffers
> - recover from transmit timeout and use the 4 helpers defined below
> - use netdev_alloc_skb instead of dev_alloc_skb
> - do not use a private stats structure to store statistics
> - break each TX/RX error to a separate line for better reading
> - suppress volatiles and make checkpatch happy
> - better control of the timer
> - fix spin_unlock_irq typo in netdev_get_settings
> - fix various typos and spelling in the driver
> 
> Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>

Looks good, thanks:

There is a function to make this easier:
> @@ -756,10 +803,8 @@ r6040_open(struct net_device *dev)
>  	if (lp->switch_sig != ICPLUS_PHY_ID) {
>  		/* set and active a timer process */
>  		init_timer(&lp->timer);
> -		lp->timer.expires = TIMER_WUT;
>  		lp->timer.data = (unsigned long)dev;
>  		lp->timer.function = &r6040_timer;
> -		add_timer(&lp->timer);

Could be:
	setup_timer(&lp->timer, r6040_timer, dev);
	if (lp->switch_sig != ICPLUS_PHY_ID)
		mod_timer(&lp->timer, jiffies + HZ);


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
