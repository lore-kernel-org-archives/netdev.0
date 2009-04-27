From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 2/2] mlx4_en: Handle page allocation failure during receive
Date: Mon, 27 Apr 2009 09:42:57 +0300
Message-ID: <49F553F1.7010701@mellanox.co.il>
References: <49EC859C.700@mellanox.co.il> <49EC87AB.1070009@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:50217 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754927AbZD0Gn7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Apr 2009 02:43:59 -0400
In-Reply-To: <49EC87AB.1070009@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we failed to allocate new fragments for receive buffer,
the packet should be dropped and packets should be reused.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_rx.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 0cbb78c..7942c4d 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -610,6 +610,10 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 		used_frags = mlx4_en_complete_rx_desc(priv, rx_desc, skb_frags,
 						      skb_shinfo(skb)->frags,
 						      page_alloc, length);
+		if (unlikely(!used_frags)) {
+			kfree_skb(skb);
+			return NULL;
+		}
 		skb_shinfo(skb)->nr_frags = used_frags;

 		/* Copy headers into the skb linear buffer */
-- 


