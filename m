From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] drivers/net/smc911x.c: Fix lockdep warning on xmit.
Date: Sun, 02 Nov 2008 08:46:05 -0500
Message-ID: <490DAF1D.20002@garzik.org>
References: <87a5b0800810280506h71fd6508i9474917b0ef0b191@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Will Newton <will.newton@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60734 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753298AbYKBNqJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Nov 2008 08:46:09 -0500
In-Reply-To: <87a5b0800810280506h71fd6508i9474917b0ef0b191@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Will Newton wrote:
>>From 0e3ec7f78e115533e4aca9ac067acbc33eb0a21f Mon Sep 17 00:00:00 2001
> From: Will Newton <will.newton@gmail.com>
> Date: Tue, 28 Oct 2008 10:52:36 +0000
> Subject: [PATCH] drivers/net/smc911x.c: Fix lockdep warning on xmit.
> 
> dev_kfree_skb should not be called with irqs disabled, use dev_kfree_skb_irq
> instead. The warning caused looks like this:
> 
> ======================================================
> [ INFO: hard-safe -> hard-unsafe lock order detected ]
> 2.6.28-rc1 #273
> ------------------------------------------------------
> swapper/0 [HC0[0]:SC1[2]:HE0:SE0] is trying to acquire:
>  (clock-AF_INET){-..+}, at: [<4015c17c>] _sock_def_write_space+0x28/0xd8
> 
> and this task is already holding:
>  (&lp->lock){++..}, at: [<4013f230>] _smc911x_hard_start_xmit+0x30/0x4b8
> which would create a new lock dependency:
>  (&lp->lock){++..} -> (clock-AF_INET){-..+}
> 
> Signed-off-by: Will Newton <will.newton@gmail.com>
> ---
>  drivers/net/smc911x.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
> index f59c777..5051554 100644
> --- a/drivers/net/smc911x.c
> +++ b/drivers/net/smc911x.c
> @@ -499,7 +499,7 @@ static void smc911x_hardware_send_pkt(struct
> net_device *dev)
>  #else
>  	SMC_PUSH_DATA(lp, buf, len);
>  	dev->trans_start = jiffies;
> -	dev_kfree_skb(skb);
> +	dev_kfree_skb_irq(skb);
>  #endif
>  	if (!lp->tx_throttle) {
>  		netif_wake_queue(dev);

applied manually, your patch was corrupted


