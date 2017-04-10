From: Myungho Jung <mhjungk@gmail.com>
Subject: [PATCH] p54: add null pointer check before releasing socket buffer
Date: Sun,  9 Apr 2017 22:23:20 -0700
Message-ID: <1491801800-4371-1-git-send-email-mhjungk@gmail.com>
Cc: netdev@vger.kernel.org, Myungho Jung <mhjungk@gmail.com>
To: chunkeey@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36453 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751133AbdDJFYE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 01:24:04 -0400
Received: by mail-pf0-f196.google.com with SMTP id i5so5012845pfc.3
        for <netdev@vger.kernel.org>; Sun, 09 Apr 2017 22:24:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel panic is caused by trying to dereference null pointer. Check if
the pointer is null before freeing space.

Signed-off-by: Myungho Jung <mhjungk@gmail.com>
---
 drivers/net/wireless/intersil/p54/txrx.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/intersil/p54/txrx.c b/drivers/net/wireless/intersil/p54/txrx.c
index 1af7da0..8956061 100644
--- a/drivers/net/wireless/intersil/p54/txrx.c
+++ b/drivers/net/wireless/intersil/p54/txrx.c
@@ -503,7 +503,9 @@ static void p54_rx_eeprom_readback(struct p54_common *priv,
 
 	priv->eeprom = NULL;
 	tmp = p54_find_and_unlink_skb(priv, hdr->req_id);
-	dev_kfree_skb_any(tmp);
+	if (unlikely(!tmp))
+		dev_kfree_skb_any(tmp);
+
 	complete(&priv->eeprom_comp);
 }
 
@@ -597,7 +599,9 @@ static void p54_rx_stats(struct p54_common *priv, struct sk_buff *skb)
 	}
 
 	tmp = p54_find_and_unlink_skb(priv, hdr->req_id);
-	dev_kfree_skb_any(tmp);
+	if (unlikely(!tmp))
+		dev_kfree_skb_any(tmp);
+
 	complete(&priv->stat_comp);
 }
 
-- 
2.7.4
