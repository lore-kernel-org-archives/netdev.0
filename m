From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] zorro8390: Fix read buffer overflow in zorro8390_init_one()
Date: Sun, 09 Aug 2009 16:00:25 +0200
Message-ID: <4A7ED679.3020503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:53811 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750942AbZHIN4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Aug 2009 09:56:40 -0400
Received: by ewy10 with SMTP id 10so2496777ewy.37
        for <netdev@vger.kernel.org>; Sun, 09 Aug 2009 06:56:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prevent read from cards[-1] when no card was found.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
is ENODEV appropriate here?

diff --git a/drivers/net/zorro8390.c b/drivers/net/zorro8390.c
index 37c84e3..55502e1 100644
--- a/drivers/net/zorro8390.c
+++ b/drivers/net/zorro8390.c
@@ -120,6 +120,9 @@ static int __devinit zorro8390_init_one(struct zorro_dev *z,
     for (i = ARRAY_SIZE(cards)-1; i >= 0; i--)
 	if (z->id == cards[i].id)
 	    break;
+    if (i < 0)
+        return -ENODEV;
+    
     board = z->resource.start;
     ioaddr = board+cards[i].offset;
     dev = alloc_ei_netdev();
