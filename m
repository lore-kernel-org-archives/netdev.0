From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH] net: sh_eth: Use u32 for 32-bit register data
Date: Thu, 15 Jan 2015 11:54:28 +0100
Message-ID: <1421319268-22831-1-git-send-email-geert+renesas@glider.be>
Cc: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>,
	netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace "unsigned long" by "u32" when handling 32-bit register data.

A.o., this saves 11 * 36 bytes in the static sh_eth_cpu_data structures
when compiling for 64-bit.

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
This is against net-next

 drivers/net/ethernet/renesas/sh_eth.c | 14 +++++++-------
 drivers/net/ethernet/renesas/sh_eth.h | 30 ++++++++++++++----------------
 2 files changed, 21 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 8d227d919e194847..67103b012b8eef5e 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -594,7 +594,7 @@ static struct sh_eth_cpu_data sh7757_data = {
 static void sh_eth_chip_reset_giga(struct net_device *ndev)
 {
 	int i;
-	unsigned long mahr[2], malr[2];
+	u32 mahr[2], malr[2];
 
 	/* save MAHR and MALR */
 	for (i = 0; i < 2; i++) {
@@ -988,7 +988,7 @@ static void read_mac_address(struct net_device *ndev, unsigned char *mac)
 	}
 }
 
-static unsigned long sh_eth_get_edtrr_trns(struct sh_eth_private *mdp)
+static u32 sh_eth_get_edtrr_trns(struct sh_eth_private *mdp)
 {
 	if (sh_eth_is_gether(mdp) || sh_eth_is_rz_fast_ether(mdp))
 		return EDTRR_TRNS_GETHER;
@@ -1521,7 +1521,7 @@ static void sh_eth_rcv_snd_enable(struct net_device *ndev)
 }
 
 /* error control function */
-static void sh_eth_error(struct net_device *ndev, int intr_status)
+static void sh_eth_error(struct net_device *ndev, u32 intr_status)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	u32 felic_stat;
@@ -1637,7 +1637,7 @@ static irqreturn_t sh_eth_interrupt(int irq, void *netdev)
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	struct sh_eth_cpu_data *cd = mdp->cd;
 	irqreturn_t ret = IRQ_NONE;
-	unsigned long intr_status, intr_enable;
+	u32 intr_status, intr_enable;
 
 	spin_lock(&mdp->lock);
 
@@ -1663,7 +1663,7 @@ static irqreturn_t sh_eth_interrupt(int irq, void *netdev)
 			__napi_schedule(&mdp->napi);
 		} else {
 			netdev_warn(ndev,
-				    "ignoring interrupt, status 0x%08lx, mask 0x%08lx.\n",
+				    "ignoring interrupt, status 0x%08x, mask 0x%08x.\n",
 				    intr_status, intr_enable);
 		}
 	}
@@ -1696,7 +1696,7 @@ static int sh_eth_poll(struct napi_struct *napi, int budget)
 						  napi);
 	struct net_device *ndev = napi->dev;
 	int quota = budget;
-	unsigned long intr_status;
+	u32 intr_status;
 
 	for (;;) {
 		intr_status = sh_eth_read(ndev, EESR);
@@ -2067,7 +2067,7 @@ static void sh_eth_tx_timeout(struct net_device *ndev)
 
 	netif_err(mdp, timer, ndev,
 		  "transmit timed out, status %8.8x, resetting...\n",
-		  (int)sh_eth_read(ndev, EESR));
+		  sh_eth_read(ndev, EESR));
 
 	/* tx_errors count up */
 	ndev->stats.tx_errors++;
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index 71f5de1171bd93d0..7bfaf1c81ea2c210 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -459,21 +459,21 @@ struct sh_eth_cpu_data {
 
 	/* mandatory initialize value */
 	int register_type;
-	unsigned long eesipr_value;
+	u32 eesipr_value;
 
 	/* optional initialize value */
-	unsigned long ecsr_value;
-	unsigned long ecsipr_value;
-	unsigned long fdr_value;
-	unsigned long fcftr_value;
-	unsigned long rpadir_value;
+	u32 ecsr_value;
+	u32 ecsipr_value;
+	u32 fdr_value;
+	u32 fcftr_value;
+	u32 rpadir_value;
 
 	/* interrupt checking mask */
-	unsigned long tx_check;
-	unsigned long eesr_err_check;
+	u32 tx_check;
+	u32 eesr_err_check;
 
 	/* Error mask */
-	unsigned long trscer_err_mask;
+	u32 trscer_err_mask;
 
 	/* hardware features */
 	unsigned long irq_flags; /* IRQ configuration flags */
@@ -542,7 +542,7 @@ static inline void sh_eth_soft_swap(char *src, int len)
 #endif
 }
 
-static inline void sh_eth_write(struct net_device *ndev, unsigned long data,
+static inline void sh_eth_write(struct net_device *ndev, u32 data,
 				int enum_index)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -550,8 +550,7 @@ static inline void sh_eth_write(struct net_device *ndev, unsigned long data,
 	iowrite32(data, mdp->addr + mdp->reg_offset[enum_index]);
 }
 
-static inline unsigned long sh_eth_read(struct net_device *ndev,
-					int enum_index)
+static inline u32 sh_eth_read(struct net_device *ndev, int enum_index)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 
@@ -564,14 +563,13 @@ static inline void *sh_eth_tsu_get_offset(struct sh_eth_private *mdp,
 	return mdp->tsu_addr + mdp->reg_offset[enum_index];
 }
 
-static inline void sh_eth_tsu_write(struct sh_eth_private *mdp,
-				unsigned long data, int enum_index)
+static inline void sh_eth_tsu_write(struct sh_eth_private *mdp, u32 data,
+				    int enum_index)
 {
 	iowrite32(data, mdp->tsu_addr + mdp->reg_offset[enum_index]);
 }
 
-static inline unsigned long sh_eth_tsu_read(struct sh_eth_private *mdp,
-					int enum_index)
+static inline u32 sh_eth_tsu_read(struct sh_eth_private *mdp, int enum_index)
 {
 	return ioread32(mdp->tsu_addr + mdp->reg_offset[enum_index]);
 }
-- 
1.9.1

