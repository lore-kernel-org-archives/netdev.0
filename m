From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] beyond ARRAY_SIZE of ib->btx_ring
Date: Sun, 22 Feb 2009 02:40:45 +0100
Message-ID: <49A0AD1D.1@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:36903 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091AbZBVBkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2009 20:40:45 -0500
Received: by ey-out-2122.google.com with SMTP id 25so280285eya.37
        for <netdev@vger.kernel.org>; Sat, 21 Feb 2009 17:40:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

// vi drivers/net/sunlance.c +216
struct lance_init_block {
...
        struct lance_tx_desc btx_ring[TX_RING_SIZE];
...
};
This is a bug, isn't it?
--------------------------->8-------------8<------------------------------
Do not go beyond ARRAY_SIZE of ib->btx_ring

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/sunlance.c b/drivers/net/sunlance.c
index 2813732..16c528d 100644
--- a/drivers/net/sunlance.c
+++ b/drivers/net/sunlance.c
@@ -343,7 +343,7 @@ static void lance_init_ring_dvma(struct net_device *dev)
 	ib->phys_addr [5] = dev->dev_addr [4];
 
 	/* Setup the Tx ring entries */
-	for (i = 0; i <= TX_RING_SIZE; i++) {
+	for (i = 0; i < TX_RING_SIZE; i++) {
 		leptr = LANCE_ADDR(aib + libbuff_offset(tx_buf, i));
 		ib->btx_ring [i].tmd0      = leptr;
 		ib->btx_ring [i].tmd1_hadr = leptr >> 16;
@@ -399,7 +399,7 @@ static void lance_init_ring_pio(struct net_device *dev)
 	sbus_writeb(dev->dev_addr[4], &ib->phys_addr[5]);
 
 	/* Setup the Tx ring entries */
-	for (i = 0; i <= TX_RING_SIZE; i++) {
+	for (i = 0; i < TX_RING_SIZE; i++) {
 		leptr = libbuff_offset(tx_buf, i);
 		sbus_writew(leptr,	&ib->btx_ring [i].tmd0);
 		sbus_writeb(leptr >> 16,&ib->btx_ring [i].tmd1_hadr);
