From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/3] net: irda: pxaficp_ir: use sched_clock() for
 time management
Date: Tue, 15 Sep 2015 16:40:25 -0700 (PDT)
Message-ID: <20150915.164025.1543038793305792029.davem@davemloft.net>
References: <1442058324-9760-1-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, petr.cvek@tul.cz, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, arnd@arndb.de
To: robert.jarzmik@free.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442058324-9760-1-git-send-email-robert.jarzmik@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Jarzmik <robert.jarzmik@free.fr>
Date: Sat, 12 Sep 2015 13:45:22 +0200

> Instead of using directly the OS timer through direct register access,
> use the standard sched_clock(), which will end up in OSCR reading
> anyway.
> 
> This is a first step for direct access register removal and machine
> specific code removal from this driver.
> 
> Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>

What is the granularity of the OSCR register?

If it is not nanoseconds, then you need to adjust calculations
such as this one:

> @@ -549,7 +548,7 @@ static int pxa_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
>  		skb_copy_from_linear_data(skb, si->dma_tx_buff, skb->len);
>  
>  		if (mtt)
> -			while ((unsigned)(readl_relaxed(OSCR) - si->last_oscr)/4 < mtt)
> +			while ((sched_clock() - si->last_clk) / 4 < mtt)
>  				cpu_relax();
