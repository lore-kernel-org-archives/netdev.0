From: Janusz Wolak <januszwolak@awokados.com.pl>
Subject: [PATCH 2/6] e1000 driver remove checkpatch errors, warnings and checks.
Date: Tue, 13 Oct 2015 23:39:18 +0200
Message-ID: <1444772362-25090-2-git-send-email-januszwolak@awokados.com.pl>
References: <1444772362-25090-1-git-send-email-januszwolak@awokados.com.pl>
Cc: jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Janusz Wolak <januszvdm@gmail.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444772362-25090-1-git-send-email-januszwolak@awokados.com.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Janusz Wolak <januszvdm@gmail.com>

Signed-off-by: Janusz Wolak <januszvdm@gmail.com>
---
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c | 31 ++++++++++++++----------
 1 file changed, 18 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
index 4270ad2..c4ffab4 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
@@ -36,12 +36,12 @@ struct e1000_stats {
 	int stat_offset;
 };
 
-#define E1000_STAT(m)		E1000_STATS, \
+#define E1000_STAT(m)		(E1000_STATS, \
 				sizeof(((struct e1000_adapter *)0)->m), \
-				offsetof(struct e1000_adapter, m)
-#define E1000_NETDEV_STAT(m)	NETDEV_STATS, \
+				offsetof(struct e1000_adapter, m))
+#define E1000_NETDEV_STAT(m)	(NETDEV_STATS, \
 				sizeof(((struct net_device *)0)->m), \
-				offsetof(struct net_device, m)
+				offsetof(struct net_device, m))
 
 static const struct e1000_stats e1000_gstrings_stats[] = {
 	{ "rx_packets", E1000_STAT(stats.gprc) },
@@ -114,7 +114,7 @@ static int e1000_get_settings(struct net_device *netdev,
 				   SUPPORTED_10baseT_Full |
 				   SUPPORTED_100baseT_Half |
 				   SUPPORTED_100baseT_Full |
-				   SUPPORTED_1000baseT_Full|
+				   SUPPORTED_1000baseT_Full |
 				   SUPPORTED_Autoneg |
 				   SUPPORTED_TP);
 		ecmd->advertising = ADVERTISED_TP;
@@ -708,8 +708,7 @@ static bool reg_set_and_check(struct e1000_adapter *adapter, u64 *data, int reg,
 	writel(write & mask, address);
 	read = readl(address);
 	if ((read & mask) != (write & mask)) {
-		e_err(drv, "set/check reg %04X test failed: "
-		      "got 0x%08X expected 0x%08X\n",
+		e_err(drv, "set/check reg %04X test failed: got 0x%08X expected 0x%08X\n",
 		      reg, (read & mask), (write & mask));
 		*data = reg;
 		return true;
@@ -1021,7 +1020,8 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 		ret_val = 2;
 		goto err_nomem;
 	}
-	txdr->next_to_use = txdr->next_to_clean = 0;
+	txdr->next_to_use = 0;
+	txdr->next_to_clean = 0;
 
 	ew32(TDBAL, ((u64)txdr->dma & 0x00000000FFFFFFFF));
 	ew32(TDBAH, ((u64)txdr->dma >> 32));
@@ -1079,7 +1079,8 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 		ret_val = 6;
 		goto err_nomem;
 	}
-	rxdr->next_to_use = rxdr->next_to_clean = 0;
+	rxdr->next_to_use = 0;
+	rxdr->next_to_clean = 0;
 
 	rctl = er32(RCTL);
 	ew32(RCTL, rctl & ~E1000_RCTL_EN);
@@ -1251,7 +1252,7 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 	ctrl_reg &= ~E1000_CTRL_SPD_SEL; /* Clear the speed sel bits */
 	ctrl_reg |= (E1000_CTRL_FRCSPD | /* Set the Force Speed Bit */
 			E1000_CTRL_FRCDPX | /* Set the Force Duplex Bit */
-			E1000_CTRL_SPD_1000 |/* Force Speed to 1000 */
+			E1000_CTRL_SPD_1000 | /* Force Speed to 1000 */
 			E1000_CTRL_FD); /* Force Duplex to FULL */
 
 	if (hw->media_type == e1000_media_type_copper &&
@@ -1293,7 +1294,8 @@ static int e1000_set_phy_loopback(struct e1000_adapter *adapter)
 			 * attempt this 10 times.
 			 */
 			while (e1000_nonintegrated_phy_loopback(adapter) &&
-			       count++ < 10);
+			       count++ < 10)
+				;
 			if (count < 11)
 				return 0;
 		}
@@ -1420,7 +1422,9 @@ static int e1000_run_loopback_test(struct e1000_adapter *adapter)
 	else
 		lc = ((rxdr->count / 64) * 2) + 1;
 
-	k = l = 0;
+	k = 0;
+	l = 0;
+
 	for (j = 0; j <= lc; j++) { /* loop count loop */
 		for (i = 0; i < 64; i++) { /* send the packets */
 			e1000_create_lbtest_frame(txdr->buffer_info[i].skb,
@@ -1796,7 +1800,8 @@ static int e1000_set_coalesce(struct net_device *netdev,
 		return -EINVAL;
 
 	if (ec->rx_coalesce_usecs == 4) {
-		adapter->itr = adapter->itr_setting = 4;
+		adapter->itr = 4;
+		adapter->itr_setting = 4;
 	} else if (ec->rx_coalesce_usecs <= 3) {
 		adapter->itr = 20000;
 		adapter->itr_setting = ec->rx_coalesce_usecs;
-- 
1.9.1
