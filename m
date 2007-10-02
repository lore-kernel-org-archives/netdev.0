From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [2/11] pasemi_mac: fix bug in receive buffer dma mapping
Date: Tue, 2 Oct 2007 16:25:14 -0500
Message-ID: <20071002212514.GC2282@lixom.net>
References: <20071002212421.GA2282@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:46623 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755362AbXJBVVM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 17:21:12 -0400
Content-Disposition: inline
In-Reply-To: <20071002212421.GA2282@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pasemi_mac: fix bug in receive buffer dma mapping

skb->len isn't actually set to the size of the allocated skb, so don't
try to use it when figuring out how much to map.

(This hasn't surfaced as a real bug because we effectively disable
translation for the interface, but it still needs fixing for the future)


Signed-off-by: Olof Johansson <olof@lixom.net>

Index: k.org/drivers/net/pasemi_mac.c
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.c
+++ k.org/drivers/net/pasemi_mac.c
@@ -396,7 +396,7 @@ static void pasemi_mac_replenish_rx_ring
 		if (unlikely(!skb))
 			break;
 
-		dma = pci_map_single(mac->dma_pdev, skb->data, skb->len,
+		dma = pci_map_single(mac->dma_pdev, skb->data, BUF_SIZE,
 				     PCI_DMA_FROMDEVICE);
 
 		if (unlikely(dma_mapping_error(dma))) {
