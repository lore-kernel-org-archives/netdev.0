From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] bcm63xx_enet: timeout off by one in do_mdio_op()
Date: Mon, 21 Sep 2009 22:08:48 +0200
Message-ID: <4AB7DD50.6030409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: mbizon@freebox.fr, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f206.google.com ([209.85.219.206]:50741 "EHLO
	mail-ew0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128AbZIUUBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2009 16:01:22 -0400
Received: by ewy2 with SMTP id 2so1312123ewy.17
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2009 13:01:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

`while (limit-- >= 0)' reaches -2 after the loop upon timeout.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
Small chance to occur, probably.

diff --git a/drivers/net/bcm63xx_enet.c b/drivers/net/bcm63xx_enet.c
index 09d2709..ba29dc3 100644
--- a/drivers/net/bcm63xx_enet.c
+++ b/drivers/net/bcm63xx_enet.c
@@ -90,7 +90,7 @@ static int do_mdio_op(struct bcm_enet_priv *priv, unsigned int data)
 		if (enet_readl(priv, ENET_IR_REG) & ENET_IR_MII)
 			break;
 		udelay(1);
-	} while (limit-- >= 0);
+	} while (limit-- > 0);
 
 	return (limit < 0) ? 1 : 0;
 }
