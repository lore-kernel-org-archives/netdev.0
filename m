From: raj@tardy.usa.hp.com (Rick Jones)
Subject: [PATCH net-next] mlx4_en: Convert the normal skb free path to dev_consume_skb_any()
Date: Wed,  3 Sep 2014 09:18:00 -0700 (PDT)
Message-ID: <20140903161800.301F629002CD@tardy>
Cc: <amirv@mellanox.com>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3425.houston.hp.com ([15.201.208.53]:28774 "EHLO
	g4t3425.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753294AbaICQSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 12:18:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Rick Jones <rick.jones2@hp.com>

It would appear the mlx4_en driver was still making a call to
dev_kfree_skb_any() where dev_consume_skb_any() would be more
appropriate.  This should make dropped packet profiling/tracking
easier/better over a NIC driven by mlx4_en.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

Compile tested only


diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index dae3da6..bc8f51c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -319,7 +319,7 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 			}
 		}
 	}
-	dev_kfree_skb_any(skb);
+	dev_consume_skb_any(skb);
 	return tx_info->nr_txbb;
 }
 
