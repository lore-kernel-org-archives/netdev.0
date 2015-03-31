From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH v2 6/8] net/macb: add the user i/o to ethtool register dump
Date: Tue, 31 Mar 2015 15:02:04 +0200
Message-ID: <1427806926-18887-7-git-send-email-nicolas.ferre@atmel.com>
References: <1427806926-18887-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	<michal.simek@xilinx.com>, <punnaia@xilinx.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427806926-18887-1-git-send-email-nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

User i/o register EMAC_USRIO or GMAC_UR can be found on both macb and gem
flavors of the peripheral. By using the proper accessor, we can add it to the
register dump feature of ethtool.
Increment the version of this API so it can be noticed from user space.

Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---

Changes in v2:
- add ethtool register dump

 drivers/net/ethernet/cadence/macb.c | 2 +-
 drivers/net/ethernet/cadence/macb.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 205f4b86d9da..babe972a7c32 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2037,8 +2037,8 @@ static void macb_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 	regs_buff[10] = macb_tx_dma(&bp->queues[0], tail);
 	regs_buff[11] = macb_tx_dma(&bp->queues[0], head);
 
+	regs_buff[12] = macb_or_gem_readl(bp, USRIO);
 	if (macb_is_gem(bp)) {
-		regs_buff[12] = gem_readl(bp, USRIO);
 		regs_buff[13] = gem_readl(bp, DMACFG);
 	}
 }
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 5f9950e84c5e..fd0a22157a88 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -11,7 +11,7 @@
 #define _MACB_H
 
 #define MACB_GREGS_NBR 16
-#define MACB_GREGS_VERSION 1
+#define MACB_GREGS_VERSION 2
 #define MACB_MAX_QUEUES 8
 
 /* MACB register offsets */
-- 
2.1.3
