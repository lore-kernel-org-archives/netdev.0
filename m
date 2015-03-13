From: Ameen Ali <ameenali023@gmail.com>
Subject: [PATCH 9/9] tulip_core.c : out-of-bounds check.
Date: Fri, 13 Mar 2015 16:15:52 +0200
Message-ID: <1426256152-5522-1-git-send-email-ameenali023@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ameen Ali <ameenali023@gmail.com>
To: grundler@parisc-linux.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Array index 'j' is used before limits check.

Suggest put limit check before index use.

Signed-off-by : <Ameenali023@gmail.com>
---
 drivers/net/ethernet/dec/tulip/tulip_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index 3b42556..ed41559 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -589,7 +589,7 @@ static void tulip_tx_timeout(struct net_device *dev)
 			       (unsigned int)tp->rx_ring[i].buffer1,
 			       (unsigned int)tp->rx_ring[i].buffer2,
 			       buf[0], buf[1], buf[2]);
-			for (j = 0; buf[j] != 0xee && j < 1600; j++)
+			for (j = 0; ((j < 1600) && buf[j] != 0xee); j++)
 				if (j < 100)
 					pr_cont(" %02x", buf[j]);
 			pr_cont(" j=%d\n", j);
-- 
2.1.0
