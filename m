From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sky2: incorrect length on receive packets
Date: Tue, 3 Oct 2006 16:39:12 -0700
Message-ID: <20061003163912.1b96bc70@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18318 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932333AbWJCXkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2006 19:40:16 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The previous change to do fragmented receive (post 2.6.18) introduced a bug
where packets are passed up with size set to the size of the receive buffer
not the actual received data.  IP silently trims this so it didn't show up
right away.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/sky2.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- sky2.orig/drivers/net/sky2.c	2006-10-03 16:35:09.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-10-03 16:35:23.000000000 -0700
@@ -1907,7 +1907,7 @@
 		pci_dma_sync_single_for_device(sky2->hw->pdev, re->data_addr,
 					       length, PCI_DMA_FROMDEVICE);
 		re->skb->ip_summed = CHECKSUM_NONE;
-		__skb_put(skb, length);
+		skb_put(skb, length);
 	}
 	return skb;
 }
@@ -1970,7 +1970,7 @@
 	if (skb_shinfo(skb)->nr_frags)
 		skb_put_frags(skb, hdr_space, length);
 	else
-		skb_put(skb, hdr_space);
+		skb_put(skb, length);
 	return skb;
 }
 
