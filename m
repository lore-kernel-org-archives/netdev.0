From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] lmc: Read outside array bounds
Date: Sun, 26 Jul 2009 00:18:17 +0200
Message-ID: <4A6B84A9.7020506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: khc@pm.waw.pl, netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:49667 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752222AbZGYWPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2009 18:15:43 -0400
Received: by ewy26 with SMTP id 26so2447213ewy.37
        for <netdev@vger.kernel.org>; Sat, 25 Jul 2009 15:15:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

if dev_alloc_skb() fails on the first iteration of the allocation loop, and we
break out of the loop, then we end up writing before the start of the array.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index 45b1822..ac8d5b2 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -1865,7 +1865,7 @@ static void lmc_softreset (lmc_softc_t * const sc) /*fold00*/
             if(skb == NULL){
                 printk(KERN_WARNING "%s: Failed to allocate receiver ring, will try again
", sc->name);
                 sc->failed_ring = 1;
-                break;
+                return;
             }
             else{
                 sc->lmc_rxq[i] = skb;
