From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] mlx4: use dev_kfree_skb() instead of
 dev_kfree_skb_any()
Date: Mon, 17 Sep 2012 09:29:34 +0200
Message-ID: <1347866974.26523.53.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>, Ying Cai <ycai@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:59417 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751367Ab2IQH3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 03:29:41 -0400
Received: by bkwj10 with SMTP id j10so2292473bkw.19
        for <netdev@vger.kernel.org>; Mon, 17 Sep 2012 00:29:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Since commit e22979d96a5 (mlx4_en: Moving to Interrupts for TX
completions), we no longer can free TX skb from hard IRQ, but only from
normal softirq or process context.

Therefore, we can directly call dev_kfree_skb() from
mlx4_en_free_tx_desc() like other conventional NAPI drivers.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Cc: Or Gerlitz <ogerlitz@mellanox.com>
Cc: Ying Cai <ycai@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 10bba09..e182762 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -266,7 +266,7 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 		}
 
 	}
-	dev_kfree_skb_any(skb);
+	dev_kfree_skb(skb);
 	return tx_info->nr_txbb;
 }
 
