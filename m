From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH] r6040: fix wrong assignment in r6040_free_txbufs
Date: Wed, 24 Sep 2008 21:16:40 +0200
Message-ID: <200809242116.40855.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:52380 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751517AbYIXTQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 15:16:55 -0400
Received: by ug-out-1314.google.com with SMTP id k3so31442ugf.37
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2008 12:16:53 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jeff, Francois,

This is 2.6.27 material but should be applied to your -next branch as well. Thank you.
--
From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH] r6040: fix wrong assignment in r6040_free_txbufs

This patch fixes a wrong assignment in r6040_free_txbufs
on a receive skb pointer while we should actually do this
on the transmit skb pointer.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 396f0e4..5aff7c8 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -261,7 +261,7 @@ static void r6040_free_txbufs(struct net_device *dev)
 				le32_to_cpu(lp->tx_insert_ptr->buf),
 				MAX_BUF_SIZE, PCI_DMA_TODEVICE);
 			dev_kfree_skb(lp->tx_insert_ptr->skb_ptr);
-			lp->rx_insert_ptr->skb_ptr = NULL;
+			lp->tx_insert_ptr->skb_ptr = NULL;
 		}
 		lp->tx_insert_ptr = lp->tx_insert_ptr->vndescp;
 	}

