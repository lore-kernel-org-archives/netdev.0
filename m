From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 05/11] rrunner: fix DMA sync_single length error
Date: Wed, 20 Jan 2010 12:45:04 -0800
Message-ID: <20100120204559.108948015@vyatta.com>
References: <20100120204459.820265084@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:53912 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753835Ab0ATVWz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 16:22:55 -0500
Content-Disposition: inline; filename=rrunner-dma.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DMA api requires that the full mapping be sync'd when
copying frame. First found by Jarek on sky2.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/rrunner.c	2010-01-20 11:32:54.859390177 -0800
+++ b/drivers/net/rrunner.c	2010-01-20 11:37:40.431004646 -0800
@@ -971,7 +971,7 @@ static void rx_int(struct net_device *de
 				} else {
 					pci_dma_sync_single_for_cpu(rrpriv->pci_dev,
 								    desc->addr.addrlo,
-								    pkt_len,
+								    dev->mtu + HIPPI_HLEN,
 								    PCI_DMA_FROMDEVICE);
 
 					memcpy(skb_put(skb, pkt_len),
@@ -979,7 +979,7 @@ static void rx_int(struct net_device *de
 
 					pci_dma_sync_single_for_device(rrpriv->pci_dev,
 								       desc->addr.addrlo,
-								       pkt_len,
+								       dev->mtu + HIPPI_HLEN,
 								       PCI_DMA_FROMDEVICE);
 				}
 			}else{

-- 

