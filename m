From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [RFC][PATCH 4/9] e100 driver conversion
Date: Tue, 08 Aug 2006 13:13:40 -0700
Message-ID: <44D8F074.8060001@intel.com>
References: <20060808193325.1396.58813.sendpatchset@lappy> <20060808193405.1396.14701.sendpatchset@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Daniel Phillips <phillips@google.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:43120 "EHLO
	azsmga101-1.ch.intel.com") by vger.kernel.org with ESMTP
	id S1030287AbWHHUOz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 16:14:55 -0400
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20060808193405.1396.14701.sendpatchset@lappy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Zijlstra wrote:
> Update the driver to make use of the netdev_alloc_skb() API and the
> NETIF_F_MEMALLOC feature.

this should be done in two separate patches. I should take care of the netdev_alloc_skb()
part too for e100 (which I've already queued internally), also since ixgb still needs it.

do you have any plans to visit ixgb for this change too?

Cheers,

Auke


> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Daniel Phillips <phillips@google.com>
> 
> ---
>  drivers/net/e100.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6/drivers/net/e100.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/e100.c
> +++ linux-2.6/drivers/net/e100.c
> @@ -1763,7 +1763,7 @@ static inline void e100_start_receiver(s
>  #define RFD_BUF_LEN (sizeof(struct rfd) + VLAN_ETH_FRAME_LEN)
>  static int e100_rx_alloc_skb(struct nic *nic, struct rx *rx)
>  {
> -	if(!(rx->skb = dev_alloc_skb(RFD_BUF_LEN + NET_IP_ALIGN)))
> +	if(!(rx->skb = netdev_alloc_skb(nic->netdev, RFD_BUF_LEN + NET_IP_ALIGN)))
>  		return -ENOMEM;
>  
>  	/* Align, init, and map the RFD. */
> @@ -2143,7 +2143,7 @@ static int e100_loopback_test(struct nic
>  
>  	e100_start_receiver(nic, NULL);
>  
> -	if(!(skb = dev_alloc_skb(ETH_DATA_LEN))) {
> +	if(!(skb = netdev_alloc_skb(nic->netdev, ETH_DATA_LEN))) {
>  		err = -ENOMEM;
>  		goto err_loopback_none;
>  	}
> @@ -2573,6 +2573,7 @@ static int __devinit e100_probe(struct p
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	netdev->poll_controller = e100_netpoll;
>  #endif
> +	netdev->features |= NETIF_F_MEMALLOC;
>  	strcpy(netdev->name, pci_name(pdev));
>  
>  	nic = netdev_priv(netdev);
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
