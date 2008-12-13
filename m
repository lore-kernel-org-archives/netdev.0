From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] hp100: use roundup instead of open coding
Date: Sat, 13 Dec 2008 21:35:29 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0812132133560.4160@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1040192094-1229196929=:4160"
Cc: Netdev <netdev@vger.kernel.org>, Jeff Garzik <jeff@garzik.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33838 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277AbYLMTfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 14:35:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1040192094-1229196929=:4160
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 drivers/net/hp100.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hp100.c b/drivers/net/hp100.c
index 1f86240..ebe7651 100644
--- a/drivers/net/hp100.c
+++ b/drivers/net/hp100.c
@@ -1212,7 +1212,7 @@ static int hp100_init_rxpdl(struct net_device *dev,
 	*(pdlptr + 2) = (u_int) virt_to_whatever(dev, pdlptr);	/* Address Frag 1 */
 	*(pdlptr + 3) = 4;	/* Length  Frag 1 */
 
-	return ((((MAX_RX_FRAG * 2 + 2) + 3) / 4) * 4);
+	return roundup(MAX_RX_FRAG * 2 + 2, 4);
 }
 
 
@@ -1227,7 +1227,7 @@ static int hp100_init_txpdl(struct net_device *dev,
 	ringptr->pdl_paddr = virt_to_whatever(dev, pdlptr);	/* +1 */
 	ringptr->skb = (void *) NULL;
 
-	return ((((MAX_TX_FRAG * 2 + 2) + 3) / 4) * 4);
+	return roundup(MAX_TX_FRAG * 2 + 2, 4);
 }
 
 /*
@@ -1256,7 +1256,7 @@ static int hp100_build_rx_pdl(hp100_ring_t * ringptr,
 	/* Note: This depends on the alloc_skb functions allocating more
 	 * space than requested, i.e. aligning to 16bytes */
 
-	ringptr->skb = dev_alloc_skb(((MAX_ETHER_SIZE + 2 + 3) / 4) * 4);
+	ringptr->skb = dev_alloc_skb(roundup(MAX_ETHER_SIZE + 2, 4));
 
 	if (NULL != ringptr->skb) {
 		/*
@@ -1279,7 +1279,7 @@ static int hp100_build_rx_pdl(hp100_ring_t * ringptr,
 #ifdef HP100_DEBUG_BM
 		printk("hp100: %s: build_rx_pdl: PDH@0x%x, skb->data (len %d) at 0x%x\n",
 				     dev->name, (u_int) ringptr->pdl,
-				     ((MAX_ETHER_SIZE + 2 + 3) / 4) * 4,
+				     roundup(MAX_ETHER_SIZE + 2, 4),
 				     (unsigned int) ringptr->skb->data);
 #endif
 
-- 
1.5.2.2

---696208474-1040192094-1229196929=:4160--
