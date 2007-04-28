From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sis900: Allocate rx replacement buffer before rx operation
Date: Sat, 28 Apr 2007 18:24:36 -0400
Message-ID: <20070428222436.GC24300@hmsreliant.homelinux.net>
References: <20070420135458.GB16191@hmsreliant.homelinux.net> <462E33A8.5060107@garzik.org> <20070426174736.GC6000@localhost.localdomain> <4632927C.7010801@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, venza@brownhat.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4669 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161232AbXD1WZK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 18:25:10 -0400
Content-Disposition: inline
In-Reply-To: <4632927C.7010801@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
> >index a6a0f09..7e44939 100644
> >--- a/drivers/net/sis900.c
> >+++ b/drivers/net/sis900.c
> >@@ -1754,6 +1754,7 @@ static int sis900_rx(struct net_device *net_dev)
> > 			sis_priv->rx_ring[entry].cmdsts = RX_BUF_SIZE;
> > 		} else {
> > 			struct sk_buff * skb;
> >+			struct sk_buff * rx_skb;
> > 
> > 			pci_unmap_single(sis_priv->pci_dev,
> > 				sis_priv->rx_ring[entry].bufptr, RX_BUF_SIZE,
> >@@ -1787,10 +1788,10 @@ static int sis900_rx(struct net_device *net_dev)
> > 			}
> > 
> > 			/* give the socket buffer to upper layers */
> >-			skb = sis_priv->rx_skbuff[entry];
> >-			skb_put(skb, rx_size);
> >-			skb->protocol = eth_type_trans(skb, net_dev);
> >-			netif_rx(skb);
> >+			rx_skb = sis_priv->rx_skbuff[entry];
> >+			skb_put(rx_skb, rx_size);
> >+			skb->protocol = eth_type_trans(rx_skb, net_dev);
> 
> applied this, and the one-line fix to this
> 
Thanks Jeff, sorry again for the headache.  I'll be more careful in the future
Neil

