From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH 4/5] atl1: eliminate unneeded kill_vid code
Date: Fri, 01 Jun 2007 14:04:20 -0400
Message-ID: <46605FA4.6000107@redhat.com>
References: <20070601164356.673375550@linux-foundation.org> <20070601164705.586224195@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Jeff Garzk <jgarzik@pobox.com>,
	Patrick McHardy <kaber@trash.net>,
	Ben Greear <greearb@candelatech.com>,
	Jay Cliburn <jcliburn@gmail.com>, netdev@vger.kernel.org,
	atl1-devel@lists.sourceforge.net
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60050 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762860AbXFASF0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jun 2007 14:05:26 -0400
In-Reply-To: <20070601164705.586224195@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> This driver has unneeded stubs for VLAN filtering.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> ---
>  drivers/net/atl1/atl1_main.c   |   25 +------------------------
> 
> ---
>  drivers/net/atl1/atl1_main.c |   33 +--------------------------------
>  1 file changed, 1 insertion(+), 32 deletions(-)
> 
> --- a/drivers/net/atl1/atl1_main.c	2007-06-01 09:21:53.000000000 -0700
> +++ b/drivers/net/atl1/atl1_main.c	2007-06-01 09:27:53.000000000 -0700
> @@ -1229,39 +1229,9 @@ static void atl1_vlan_rx_register(struct
>  	spin_unlock_irqrestore(&adapter->lock, flags);
>  }
>  
> -/* FIXME: justify or remove -- CHS */
> -static void atl1_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
> -{
> -	/* We don't do Vlan filtering */
> -	return;
> -}
> -
> -/* FIXME: this looks wrong too -- CHS */
> -static void atl1_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
> -{
> -	struct atl1_adapter *adapter = netdev_priv(netdev);
> -	unsigned long flags;
> -
> -	spin_lock_irqsave(&adapter->lock, flags);
> -	/* atl1_irq_disable(adapter); */
> -	vlan_group_set_device(adapter->vlgrp, vid, NULL);
> -	/* atl1_irq_enable(adapter); */
> -	spin_unlock_irqrestore(&adapter->lock, flags);
> -	/* We don't do Vlan filtering */
> -	return;
> -}
> -
>  static void atl1_restore_vlan(struct atl1_adapter *adapter)
>  {
>  	atl1_vlan_rx_register(adapter->netdev, adapter->vlgrp);
> -	if (adapter->vlgrp) {
> -		u16 vid;
> -		for (vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
> -			if (!vlan_group_get_device(adapter->vlgrp, vid))
> -				continue;
> -			atl1_vlan_rx_add_vid(adapter->netdev, vid);
> -		}
> -	}
>  }
>  
>  static u16 tpd_avail(struct atl1_tpd_ring *tpd_ring)
> @@ -2203,8 +2173,7 @@ static int __devinit atl1_probe(struct p
>  	netdev->poll_controller = atl1_poll_controller;
>  #endif
>  	netdev->vlan_rx_register = atl1_vlan_rx_register;
> -	netdev->vlan_rx_add_vid = atl1_vlan_rx_add_vid;
> -	netdev->vlan_rx_kill_vid = atl1_vlan_rx_kill_vid;
> +
>  	netdev->ethtool_ops = &atl1_ethtool_ops;
>  	adapter->bd_number = cards_found;
>  	adapter->pci_using_64 = pci_using_64;
> 

As the comments indicate, I was going to get around to doing this in my 
Copious Free Time anyway, so:

Acked-By: Chris Snook <csnook@redhat.com>

