From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 5/6] mlx4_en: Removed redundant check on lso header size
Date: Sun, 21 Jun 2009 11:16:02 +0300
Message-ID: <4A3DEC42.1080607@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tziporet Koren <tziporet@mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:51536 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753336AbZFUH0K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Jun 2009 03:26:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This check that verifies that the LSO header along with control
segment and first data segment do not cross 128 bytes is no longer
required.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_tx.c   |    5 -----
 drivers/net/mlx4/mlx4_en.h |    1 -
 2 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index 99a6a36..08c43f2 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -518,11 +518,6 @@ static int get_real_size(struct sk_buff *skb, struct net_device *dev,
 				return 0;
 			}
 		}
-		if (unlikely(*lso_header_size > MAX_LSO_HDR_SIZE)) {
-			if (netif_msg_tx_err(priv))
-				en_warn(priv, "LSO header size too big\n");
-			return 0;
-		}
 	} else {
 		*lso_header_size = 0;
 		if (!is_inline(skb, NULL))
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index d43a9e4..ad861db 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -99,7 +99,6 @@
 #define RSS_FACTOR		2
 #define TXBB_SIZE		64
 #define HEADROOM		(2048 / TXBB_SIZE + 1)
-#define MAX_LSO_HDR_SIZE	92
 #define STAMP_STRIDE		64
 #define STAMP_DWORDS		(STAMP_STRIDE / 4)
 #define STAMP_SHIFT		31
-- 
1.6.0

