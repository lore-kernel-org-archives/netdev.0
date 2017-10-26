From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: bcmgenet: Use BUG_ON instead of if condition followed
 by BUG
Date: Thu, 26 Oct 2017 07:16:01 -0500
Message-ID: <20171026121601.GA6113@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use BUG_ON instead of if condition followed by BUG.

Something to notice in this particular case is that unlikely()
is already being called inside BUG_ON macro.

This issue was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 9cebca8..0d1cb06 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1584,8 +1584,7 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
 	for (i = 0; i <= nr_frags; i++) {
 		tx_cb_ptr = bcmgenet_get_txcb(priv, ring);
 
-		if (unlikely(!tx_cb_ptr))
-			BUG();
+		BUG_ON(!tx_cb_ptr);
 
 		if (!i) {
 			/* Transmit single SKB or head of fragment list */
-- 
2.7.4
