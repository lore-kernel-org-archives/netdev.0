From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] 8390 : Replace ei_debug with
 msg_enable/NETIF_MSG_* feature
Date: Wed, 11 Dec 2013 16:34:56 -0500 (EST)
Message-ID: <20131211.163456.285803377239228949.davem@davemloft.net>
References: <1386795818-25828-1-git-send-email-tedheadster@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tedheadster@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59776 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911Ab3LKVe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 16:34:59 -0500
In-Reply-To: <1386795818-25828-1-git-send-email-tedheadster@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Whitehead <tedheadster@gmail.com>
Date: Wed, 11 Dec 2013 16:03:38 -0500

> @@ -133,11 +139,11 @@ struct net_device * __init apne_probe(int unit)
>  	if ( !(AMIGAHW_PRESENT(PCMCIA)) )
>  		return ERR_PTR(-ENODEV);
>  
> -	printk("Looking for PCMCIA ethernet card : ");
> +	printk(KERN_INFO "Looking for PCMCIA ethernet card : ");

"pr_info()"

> @@ -536,8 +546,8 @@ static irqreturn_t apne_interrupt(int irq, void *dev_id)
>          pcmcia_ack_int(pcmcia_intreq);
>          return IRQ_NONE;
>      }
> -    if (ei_debug > 3)
> -        printk("pcmcia intreq = %x\n", pcmcia_intreq);
> +    if (apne_msg_enable & NETIF_MSG_INTR)
> +	printk(KERN_DEBUG "pcmcia intreq = %x\n", pcmcia_intreq);
>      pcmcia_disable_irq();			/* to get rid of the sti() within ei_interrupt */
>      ei_interrupt(irq, dev_id);
>      pcmcia_ack_int(pcmcia_get_intreq());

Maybe "pr_debug()"?
