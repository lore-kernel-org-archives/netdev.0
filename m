From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] xircom_cb should return NETDEV_TX_BUSY when there are
 no	descriptors available
Date: Tue, 05 Feb 2008 13:33:07 -0500
Message-ID: <47A8ABE3.1000807@pobox.com>
References: <20080204175653.GC16952@gateway.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	jamal <hadi@cyberus.ca>
To: Erik Mouw <mouw@nl.linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42467 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750775AbYBESdM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2008 13:33:12 -0500
In-Reply-To: <20080204175653.GC16952@gateway.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Erik Mouw wrote:
> Hi,
> 
> Changes in other networking paths uncovered a bug in the xircom_cb
> driver which made the kernel spew lots of the following error messages:
> 
>   BUG eth1 code -5 qlen 0
> 
> It turned out that the driver returned -EIO when there was no
> descriptor available for sending packets. It should return
> NETDEV_TX_BUSY instead. This was discussed on the netdev list before,
> see http://thread.gmane.org/gmane.linux.network/84603 .
> 
> Signed-off-by: Erik Mouw <mouw@nl.linux.org>
> 
> diff --git a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
> index 8fc7274..6b93d01 100644
> --- a/drivers/net/tulip/xircom_cb.c
> +++ b/drivers/net/tulip/xircom_cb.c
> @@ -441,7 +441,7 @@ static int xircom_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	spin_unlock_irqrestore(&card->lock,flags);
>  	trigger_transmit(card);
>  
> -	return -EIO;
> +	return NETDEV_TX_BUSY;
>  }
>  
>  


applied


