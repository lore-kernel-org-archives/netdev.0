From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000e: Do not allow requeue of freed skb
Date: Sat, 29 Sep 2007 00:50:15 -0400
Message-ID: <46FDD987.7020604@garzik.org>
References: <20070921164115.31055.49849.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hadi@cyberus.ca, krkumar2@in.ibm.com,
	netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53373 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751823AbXI2Eu1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Sep 2007 00:50:27 -0400
In-Reply-To: <20070921164115.31055.49849.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> Returning BUSY will make qdisc_restart enqueue the skb which was already
> freed. The bad skb was correctly freed and we should return NETDEV_TX_OK.
> 
> First spotted by Jeff Garzik on 08/13/07.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000e/netdev.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
> index 372da46..03f7472 100644
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -3537,7 +3537,7 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
>  		/* handle pci_map_single() error in e1000_tx_map */
>  		dev_kfree_skb_any(skb);
>  		spin_unlock_irqrestore(&adapter->tx_queue_lock, irq_flags);
> -		return NETDEV_TX_BUSY;
> +		return NETDEV_TX_OK;

applied


