From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] X:beyond ARRAY_SIZE of ib->btx_ring
Date: Thu, 21 May 2009 22:28:13 +0200
Message-ID: <4A15B95D.4050200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:64469 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754222AbZEUU2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 16:28:23 -0400
Received: by ewy24 with SMTP id 24so1467596ewy.37
        for <netdev@vger.kernel.org>; Thu, 21 May 2009 13:28:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not go beyond ARRAY_SIZE of ib->btx_ring

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/sunlance.c b/drivers/net/sunlance.c
index 704301a..aa2a4ef 100644
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

