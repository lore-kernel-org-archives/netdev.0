From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: [RFC v2 net-next 5/5] gianfar_ethtool: coding style and whitespace cleanups
Date: Tue,  5 Jun 2012 09:07:16 +0200
Message-ID: <1338880036-11533-6-git-send-email-jan.ceuleers@computer.org>
References: <1338880036-11533-1-git-send-email-jan.ceuleers@computer.org>
Cc: Jiajun Wu <b06378@freescale.com>, Joe Perches <joe@perches.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay007.isp.belgacom.be ([195.238.6.173]:49554 "EHLO
	mailrelay007.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751392Ab2FEHKB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 03:10:01 -0400
In-Reply-To: <1338880036-11533-1-git-send-email-jan.ceuleers@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jan Ceuleers <jan.ceuleers@computer.org>
---
 drivers/net/ethernet/freescale/gianfar_ethtool.c |  420 ++++++++++++----------
 1 file changed, 224 insertions(+), 196 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 8a02557..8971921 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -46,18 +46,24 @@
 #include "gianfar.h"
 
 extern void gfar_start(struct net_device *dev);
-extern int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit);
+extern int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue,
+			      int rx_work_limit);
 
 #define GFAR_MAX_COAL_USECS 0xffff
 #define GFAR_MAX_COAL_FRAMES 0xff
 static void gfar_fill_stats(struct net_device *dev, struct ethtool_stats *dummy,
-		     u64 * buf);
+			    u64 *buf);
 static void gfar_gstrings(struct net_device *dev, u32 stringset, u8 * buf);
-static int gfar_gcoalesce(struct net_device *dev, struct ethtool_coalesce *cvals);
-static int gfar_scoalesce(struct net_device *dev, struct ethtool_coalesce *cvals);
-static void gfar_gringparam(struct net_device *dev, struct ethtool_ringparam *rvals);
-static int gfar_sringparam(struct net_device *dev, struct ethtool_ringparam *rvals);
-static void gfar_gdrvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo);
+static int gfar_gcoalesce(struct net_device *dev,
+			  struct ethtool_coalesce *cvals);
+static int gfar_scoalesce(struct net_device *dev,
+			  struct ethtool_coalesce *cvals);
+static void gfar_gringparam(struct net_device *dev,
+			    struct ethtool_ringparam *rvals);
+static int gfar_sringparam(struct net_device *dev,
+			   struct ethtool_ringparam *rvals);
+static void gfar_gdrvinfo(struct net_device *dev,
+			  struct ethtool_drvinfo *drvinfo);
 
 static const char stat_gstrings[][ETH_GSTRING_LEN] = {
 	"rx-dropped-by-kernel",
@@ -130,14 +136,15 @@ static void gfar_gstrings(struct net_device *dev, u32 stringset, u8 * buf)
 		memcpy(buf, stat_gstrings, GFAR_STATS_LEN * ETH_GSTRING_LEN);
 	else
 		memcpy(buf, stat_gstrings,
-				GFAR_EXTRA_STATS_LEN * ETH_GSTRING_LEN);
+		       GFAR_EXTRA_STATS_LEN * ETH_GSTRING_LEN);
 }
 
 /* Fill in an array of 64-bit statistics from various sources.
  * This array will be appended to the end of the ethtool_stats
  * structure, and returned to user space
  */
-static void gfar_fill_stats(struct net_device *dev, struct ethtool_stats *dummy, u64 * buf)
+static void gfar_fill_stats(struct net_device *dev, struct ethtool_stats *dummy,
+			    u64 *buf)
 {
 	int i;
 	struct gfar_private *priv = netdev_priv(dev);
@@ -174,8 +181,8 @@ static int gfar_sset_count(struct net_device *dev, int sset)
 }
 
 /* Fills in the drvinfo structure with some basic info */
-static void gfar_gdrvinfo(struct net_device *dev, struct
-	      ethtool_drvinfo *drvinfo)
+static void gfar_gdrvinfo(struct net_device *dev,
+			  struct ethtool_drvinfo *drvinfo)
 {
 	strncpy(drvinfo->driver, DRV_NAME, GFAR_INFOSTR_LEN);
 	strncpy(drvinfo->version, gfar_driver_version, GFAR_INFOSTR_LEN);
@@ -226,7 +233,8 @@ static int gfar_reglen(struct net_device *dev)
 }
 
 /* Return a dump of the GFAR register space */
-static void gfar_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *regbuf)
+static void gfar_get_regs(struct net_device *dev, struct ethtool_regs *regs,
+			  void *regbuf)
 {
 	int i;
 	struct gfar_private *priv = netdev_priv(dev);
@@ -239,7 +247,8 @@ static void gfar_get_regs(struct net_device *dev, struct ethtool_regs *regs, voi
 
 /* Convert microseconds to ethernet clock ticks, which changes
  * depending on what speed the controller is running at */
-static unsigned int gfar_usecs2ticks(struct gfar_private *priv, unsigned int usecs)
+static unsigned int gfar_usecs2ticks(struct gfar_private *priv,
+				     unsigned int usecs)
 {
 	unsigned int count;
 
@@ -263,7 +272,8 @@ static unsigned int gfar_usecs2ticks(struct gfar_private *priv, unsigned int use
 }
 
 /* Convert ethernet clock ticks to microseconds */
-static unsigned int gfar_ticks2usecs(struct gfar_private *priv, unsigned int ticks)
+static unsigned int gfar_ticks2usecs(struct gfar_private *priv,
+				     unsigned int ticks)
 {
 	unsigned int count;
 
@@ -288,7 +298,8 @@ static unsigned int gfar_ticks2usecs(struct gfar_private *priv, unsigned int tic
 
 /* Get the coalescing parameters, and put them in the cvals
  * structure.  */
-static int gfar_gcoalesce(struct net_device *dev, struct ethtool_coalesce *cvals)
+static int gfar_gcoalesce(struct net_device *dev,
+			  struct ethtool_coalesce *cvals)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar_priv_rx_q *rx_queue = NULL;
@@ -353,7 +364,8 @@ static int gfar_gcoalesce(struct net_device *dev, struct ethtool_coalesce *cvals
  * Both cvals->*_usecs and cvals->*_frames have to be > 0
  * in order for coalescing to be active
  */
-static int gfar_scoalesce(struct net_device *dev, struct ethtool_coalesce *cvals)
+static int gfar_scoalesce(struct net_device *dev,
+			  struct ethtool_coalesce *cvals)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	int i = 0;
@@ -364,7 +376,8 @@ static int gfar_scoalesce(struct net_device *dev, struct ethtool_coalesce *cvals
 	/* Set up rx coalescing */
 	/* As of now, we will enable/disable coalescing for all
 	 * queues together in case of eTSEC2, this will be modified
-	 * along with the ethtool interface */
+	 * along with the ethtool interface
+	 */
 	if ((cvals->rx_coalesce_usecs == 0) ||
 	    (cvals->rx_max_coalesced_frames == 0)) {
 		for (i = 0; i < priv->num_rx_queues; i++)
@@ -433,7 +446,8 @@ static int gfar_scoalesce(struct net_device *dev, struct ethtool_coalesce *cvals
 /* Fills in rvals with the current ring parameters.  Currently,
  * rx, rx_mini, and rx_jumbo rings are the same size, as mini and
  * jumbo are ignored by the driver */
-static void gfar_gringparam(struct net_device *dev, struct ethtool_ringparam *rvals)
+static void gfar_gringparam(struct net_device *dev,
+			    struct ethtool_ringparam *rvals)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar_priv_tx_q *tx_queue = NULL;
@@ -459,8 +473,10 @@ static void gfar_gringparam(struct net_device *dev, struct ethtool_ringparam *rv
 /* Change the current ring parameters, stopping the controller if
  * necessary so that we don't mess things up while we're in
  * motion.  We wait for the ring to be clean before reallocating
- * the rings. */
-static int gfar_sringparam(struct net_device *dev, struct ethtool_ringparam *rvals)
+ * the rings.
+ */
+static int gfar_sringparam(struct net_device *dev,
+			   struct ethtool_ringparam *rvals)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	int err = 0, i = 0;
@@ -486,7 +502,8 @@ static int gfar_sringparam(struct net_device *dev, struct ethtool_ringparam *rva
 		unsigned long flags;
 
 		/* Halt TX and RX, and process the frames which
-		 * have already been received */
+		 * have already been received
+		 */
 		local_irq_save(flags);
 		lock_tx_qs(priv);
 		lock_rx_qs(priv);
@@ -499,7 +516,7 @@ static int gfar_sringparam(struct net_device *dev, struct ethtool_ringparam *rva
 
 		for (i = 0; i < priv->num_rx_queues; i++)
 			gfar_clean_rx_ring(priv->rx_queue[i],
-					priv->rx_queue[i]->rx_ring_size);
+					   priv->rx_queue[i]->rx_ring_size);
 
 		/* Now we take down the rings to rebuild them */
 		stop_gfar(dev);
@@ -509,7 +526,8 @@ static int gfar_sringparam(struct net_device *dev, struct ethtool_ringparam *rva
 	for (i = 0; i < priv->num_rx_queues; i++) {
 		priv->rx_queue[i]->rx_ring_size = rvals->rx_pending;
 		priv->tx_queue[i]->tx_ring_size = rvals->tx_pending;
-		priv->tx_queue[i]->num_txbdfree = priv->tx_queue[i]->tx_ring_size;
+		priv->tx_queue[i]->num_txbdfree =
+			priv->tx_queue[i]->tx_ring_size;
 	}
 
 	/* Rebuild the rings with the new size */
@@ -535,7 +553,8 @@ int gfar_set_features(struct net_device *dev, netdev_features_t features)
 
 	if (dev->flags & IFF_UP) {
 		/* Halt TX and RX, and process the frames which
-		 * have already been received */
+		 * have already been received
+		 */
 		local_irq_save(flags);
 		lock_tx_qs(priv);
 		lock_rx_qs(priv);
@@ -548,7 +567,7 @@ int gfar_set_features(struct net_device *dev, netdev_features_t features)
 
 		for (i = 0; i < priv->num_rx_queues; i++)
 			gfar_clean_rx_ring(priv->rx_queue[i],
-					priv->rx_queue[i]->rx_ring_size);
+					   priv->rx_queue[i]->rx_ring_size);
 
 		/* Now we take down the rings to rebuild them */
 		stop_gfar(dev);
@@ -564,12 +583,14 @@ int gfar_set_features(struct net_device *dev, netdev_features_t features)
 static uint32_t gfar_get_msglevel(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
+
 	return priv->msg_enable;
 }
 
 static void gfar_set_msglevel(struct net_device *dev, uint32_t data)
 {
 	struct gfar_private *priv = netdev_priv(dev);
+
 	priv->msg_enable = data;
 }
 
@@ -614,14 +635,14 @@ static void ethflow_to_filer_rules (struct gfar_private *priv, u64 ethflow)
 
 	if (ethflow & RXH_L2DA) {
 		fcr = RQFCR_PID_DAH |RQFCR_CMP_NOMATCH |
-			RQFCR_HASH | RQFCR_AND | RQFCR_HASHTBL_0;
+		      RQFCR_HASH | RQFCR_AND | RQFCR_HASHTBL_0;
 		priv->ftp_rqfpr[priv->cur_filer_idx] = fpr;
 		priv->ftp_rqfcr[priv->cur_filer_idx] = fcr;
 		gfar_write_filer(priv, priv->cur_filer_idx, fcr, fpr);
 		priv->cur_filer_idx = priv->cur_filer_idx - 1;
 
 		fcr = RQFCR_PID_DAL | RQFCR_AND | RQFCR_CMP_NOMATCH |
-				RQFCR_HASH | RQFCR_AND | RQFCR_HASHTBL_0;
+		      RQFCR_HASH | RQFCR_AND | RQFCR_HASHTBL_0;
 		priv->ftp_rqfpr[priv->cur_filer_idx] = fpr;
 		priv->ftp_rqfcr[priv->cur_filer_idx] = fcr;
 		gfar_write_filer(priv, priv->cur_filer_idx, fcr, fpr);
@@ -630,7 +651,7 @@ static void ethflow_to_filer_rules (struct gfar_private *priv, u64 ethflow)
 
 	if (ethflow & RXH_VLAN) {
 		fcr = RQFCR_PID_VID | RQFCR_CMP_NOMATCH | RQFCR_HASH |
-				RQFCR_AND | RQFCR_HASHTBL_0;
+		      RQFCR_AND | RQFCR_HASHTBL_0;
 		gfar_write_filer(priv, priv->cur_filer_idx, fcr, fpr);
 		priv->ftp_rqfpr[priv->cur_filer_idx] = fpr;
 		priv->ftp_rqfcr[priv->cur_filer_idx] = fcr;
@@ -639,7 +660,7 @@ static void ethflow_to_filer_rules (struct gfar_private *priv, u64 ethflow)
 
 	if (ethflow & RXH_IP_SRC) {
 		fcr = RQFCR_PID_SIA | RQFCR_CMP_NOMATCH | RQFCR_HASH |
-			RQFCR_AND | RQFCR_HASHTBL_0;
+		      RQFCR_AND | RQFCR_HASHTBL_0;
 		priv->ftp_rqfpr[priv->cur_filer_idx] = fpr;
 		priv->ftp_rqfcr[priv->cur_filer_idx] = fcr;
 		gfar_write_filer(priv, priv->cur_filer_idx, fcr, fpr);
@@ -648,7 +669,7 @@ static void ethflow_to_filer_rules (struct gfar_private *priv, u64 ethflow)
 
 	if (ethflow & (RXH_IP_DST)) {
 		fcr = RQFCR_PID_DIA | RQFCR_CMP_NOMATCH | RQFCR_HASH |
-			RQFCR_AND | RQFCR_HASHTBL_0;
+		      RQFCR_AND | RQFCR_HASHTBL_0;
 		priv->ftp_rqfpr[priv->cur_filer_idx] = fpr;
 		priv->ftp_rqfcr[priv->cur_filer_idx] = fcr;
 		gfar_write_filer(priv, priv->cur_filer_idx, fcr, fpr);
@@ -657,7 +678,7 @@ static void ethflow_to_filer_rules (struct gfar_private *priv, u64 ethflow)
 
 	if (ethflow & RXH_L3_PROTO) {
 		fcr = RQFCR_PID_L4P | RQFCR_CMP_NOMATCH | RQFCR_HASH |
-			RQFCR_AND | RQFCR_HASHTBL_0;
+		      RQFCR_AND | RQFCR_HASHTBL_0;
 		priv->ftp_rqfpr[priv->cur_filer_idx] = fpr;
 		priv->ftp_rqfcr[priv->cur_filer_idx] = fcr;
 		gfar_write_filer(priv, priv->cur_filer_idx, fcr, fpr);
@@ -666,7 +687,7 @@ static void ethflow_to_filer_rules (struct gfar_private *priv, u64 ethflow)
 
 	if (ethflow & RXH_L4_B_0_1) {
 		fcr = RQFCR_PID_SPT | RQFCR_CMP_NOMATCH | RQFCR_HASH |
-			RQFCR_AND | RQFCR_HASHTBL_0;
+		      RQFCR_AND | RQFCR_HASHTBL_0;
 		priv->ftp_rqfpr[priv->cur_filer_idx] = fpr;
 		priv->ftp_rqfcr[priv->cur_filer_idx] = fcr;
 		gfar_write_filer(priv, priv->cur_filer_idx, fcr, fpr);
@@ -675,7 +696,7 @@ static void ethflow_to_filer_rules (struct gfar_private *priv, u64 ethflow)
 
 	if (ethflow & RXH_L4_B_2_3) {
 		fcr = RQFCR_PID_DPT | RQFCR_CMP_NOMATCH | RQFCR_HASH |
-			RQFCR_AND | RQFCR_HASHTBL_0;
+		      RQFCR_AND | RQFCR_HASHTBL_0;
 		priv->ftp_rqfpr[priv->cur_filer_idx] = fpr;
 		priv->ftp_rqfcr[priv->cur_filer_idx] = fcr;
 		gfar_write_filer(priv, priv->cur_filer_idx, fcr, fpr);
@@ -683,7 +704,8 @@ static void ethflow_to_filer_rules (struct gfar_private *priv, u64 ethflow)
 	}
 }
 
-static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow, u64 class)
+static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow,
+				       u64 class)
 {
 	unsigned int last_rule_idx = priv->cur_filer_idx;
 	unsigned int cmp_rqfpr;
@@ -694,9 +716,9 @@ static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow, u
 	int ret = 1;
 
 	local_rqfpr = kmalloc(sizeof(unsigned int) * (MAX_FILER_IDX + 1),
-		GFP_KERNEL);
+			      GFP_KERNEL);
 	local_rqfcr = kmalloc(sizeof(unsigned int) * (MAX_FILER_IDX + 1),
-		GFP_KERNEL);
+			      GFP_KERNEL);
 	if (!local_rqfpr || !local_rqfcr) {
 		pr_err("Out of memory\n");
 		ret = 0;
@@ -726,9 +748,9 @@ static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow, u
 		local_rqfpr[j] = priv->ftp_rqfpr[i];
 		local_rqfcr[j] = priv->ftp_rqfcr[i];
 		j--;
-		if ((priv->ftp_rqfcr[i] == (RQFCR_PID_PARSE |
-			RQFCR_CLE |RQFCR_AND)) &&
-			(priv->ftp_rqfpr[i] == cmp_rqfpr))
+		if ((priv->ftp_rqfcr[i] ==
+		     (RQFCR_PID_PARSE | RQFCR_CLE | RQFCR_AND)) &&
+		    (priv->ftp_rqfpr[i] == cmp_rqfpr))
 			break;
 	}
 
@@ -743,12 +765,12 @@ static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow, u
 	 */
 	for (l = i+1; l < MAX_FILER_IDX; l++) {
 		if ((priv->ftp_rqfcr[l] & RQFCR_CLE) &&
-			!(priv->ftp_rqfcr[l] & RQFCR_AND)) {
+		    !(priv->ftp_rqfcr[l] & RQFCR_AND)) {
 			priv->ftp_rqfcr[l] = RQFCR_CLE | RQFCR_CMP_EXACT |
-				RQFCR_HASHTBL_0 | RQFCR_PID_MASK;
+					     RQFCR_HASHTBL_0 | RQFCR_PID_MASK;
 			priv->ftp_rqfpr[l] = FPR_FILER_MASK;
 			gfar_write_filer(priv, l, priv->ftp_rqfcr[l],
-				priv->ftp_rqfpr[l]);
+					 priv->ftp_rqfpr[l]);
 			break;
 		}
 
@@ -773,7 +795,7 @@ static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow, u
 		priv->ftp_rqfpr[priv->cur_filer_idx] = local_rqfpr[k];
 		priv->ftp_rqfcr[priv->cur_filer_idx] = local_rqfcr[k];
 		gfar_write_filer(priv, priv->cur_filer_idx,
-				local_rqfcr[k], local_rqfpr[k]);
+				 local_rqfcr[k], local_rqfpr[k]);
 		if (!priv->cur_filer_idx)
 			break;
 		priv->cur_filer_idx = priv->cur_filer_idx - 1;
@@ -785,7 +807,8 @@ err:
 	return ret;
 }
 
-static int gfar_set_hash_opts(struct gfar_private *priv, struct ethtool_rxnfc *cmd)
+static int gfar_set_hash_opts(struct gfar_private *priv,
+			      struct ethtool_rxnfc *cmd)
 {
 	/* write the filer rules here */
 	if (!gfar_ethflow_to_filer_table(priv, cmd->data, cmd->flow_type))
@@ -810,10 +833,10 @@ static int gfar_check_filer_hardware(struct gfar_private *priv)
 		i &= RCTRL_PRSDEP_MASK | RCTRL_PRSFM;
 		if (i == (RCTRL_PRSDEP_MASK | RCTRL_PRSFM)) {
 			netdev_info(priv->ndev,
-					"Receive Queue Filtering enabled\n");
+				    "Receive Queue Filtering enabled\n");
 		} else {
 			netdev_warn(priv->ndev,
-					"Receive Queue Filtering disabled\n");
+				    "Receive Queue Filtering disabled\n");
 			return -EOPNOTSUPP;
 		}
 	}
@@ -823,16 +846,17 @@ static int gfar_check_filer_hardware(struct gfar_private *priv)
 		i &= RCTRL_PRSDEP_MASK;
 		if (i == RCTRL_PRSDEP_MASK) {
 			netdev_info(priv->ndev,
-					"Receive Queue Filtering enabled\n");
+				    "Receive Queue Filtering enabled\n");
 		} else {
 			netdev_warn(priv->ndev,
-					"Receive Queue Filtering disabled\n");
+				    "Receive Queue Filtering disabled\n");
 			return -EOPNOTSUPP;
 		}
 	}
 
 	/* Sets the properties for arbitrary filer rule
-	 * to the first 4 Layer 4 Bytes */
+	 * to the first 4 Layer 4 Bytes
+	 */
 	regs->rbifx = 0xC0C1C2C3;
 	return 0;
 }
@@ -870,14 +894,14 @@ static void gfar_set_mask(u32 mask, struct filer_table *tab)
 static void gfar_set_parse_bits(u32 value, u32 mask, struct filer_table *tab)
 {
 	gfar_set_mask(mask, tab);
-	tab->fe[tab->index].ctrl = RQFCR_CMP_EXACT | RQFCR_PID_PARSE
-			| RQFCR_AND;
+	tab->fe[tab->index].ctrl = RQFCR_CMP_EXACT | RQFCR_PID_PARSE |
+				   RQFCR_AND;
 	tab->fe[tab->index].prop = value;
 	tab->index++;
 }
 
 static void gfar_set_general_attribute(u32 value, u32 mask, u32 flag,
-		struct filer_table *tab)
+				       struct filer_table *tab)
 {
 	gfar_set_mask(mask, tab);
 	tab->fe[tab->index].ctrl = RQFCR_CMP_EXACT | RQFCR_AND | flag;
@@ -885,8 +909,7 @@ static void gfar_set_general_attribute(u32 value, u32 mask, u32 flag,
 	tab->index++;
 }
 
-/*
- * For setting a tuple of value and mask of type flag
+/* For setting a tuple of value and mask of type flag
  * Example:
  * IP-Src = 10.0.0.0/255.0.0.0
  * value: 0x0A000000 mask: FF000000 flag: RQFPR_IPV4
@@ -901,7 +924,7 @@ static void gfar_set_general_attribute(u32 value, u32 mask, u32 flag,
  * Further the all masks are one-padded for better hardware efficiency.
  */
 static void gfar_set_attribute(u32 value, u32 mask, u32 flag,
-		struct filer_table *tab)
+			       struct filer_table *tab)
 {
 	switch (flag) {
 		/* 3bit */
@@ -959,7 +982,8 @@ static void gfar_set_attribute(u32 value, u32 mask, u32 flag,
 
 /* Translates value and mask for UDP, TCP or SCTP */
 static void gfar_set_basic_ip(struct ethtool_tcpip4_spec *value,
-		struct ethtool_tcpip4_spec *mask, struct filer_table *tab)
+			      struct ethtool_tcpip4_spec *mask,
+			      struct filer_table *tab)
 {
 	gfar_set_attribute(value->ip4src, mask->ip4src, RQFCR_PID_SIA, tab);
 	gfar_set_attribute(value->ip4dst, mask->ip4dst, RQFCR_PID_DIA, tab);
@@ -970,97 +994,92 @@ static void gfar_set_basic_ip(struct ethtool_tcpip4_spec *value,
 
 /* Translates value and mask for RAW-IP4 */
 static void gfar_set_user_ip(struct ethtool_usrip4_spec *value,
-		struct ethtool_usrip4_spec *mask, struct filer_table *tab)
+			     struct ethtool_usrip4_spec *mask,
+			     struct filer_table *tab)
 {
 	gfar_set_attribute(value->ip4src, mask->ip4src, RQFCR_PID_SIA, tab);
 	gfar_set_attribute(value->ip4dst, mask->ip4dst, RQFCR_PID_DIA, tab);
 	gfar_set_attribute(value->tos, mask->tos, RQFCR_PID_TOS, tab);
 	gfar_set_attribute(value->proto, mask->proto, RQFCR_PID_L4P, tab);
 	gfar_set_attribute(value->l4_4_bytes, mask->l4_4_bytes, RQFCR_PID_ARB,
-			tab);
+			   tab);
 
 }
 
 /* Translates value and mask for ETHER spec */
 static void gfar_set_ether(struct ethhdr *value, struct ethhdr *mask,
-		struct filer_table *tab)
+			   struct filer_table *tab)
 {
 	u32 upper_temp_mask = 0;
 	u32 lower_temp_mask = 0;
+
 	/* Source address */
 	if (!is_broadcast_ether_addr(mask->h_source)) {
-
 		if (is_zero_ether_addr(mask->h_source)) {
 			upper_temp_mask = 0xFFFFFFFF;
 			lower_temp_mask = 0xFFFFFFFF;
 		} else {
-			upper_temp_mask = mask->h_source[0] << 16
-					| mask->h_source[1] << 8
-					| mask->h_source[2];
-			lower_temp_mask = mask->h_source[3] << 16
-					| mask->h_source[4] << 8
-					| mask->h_source[5];
+			upper_temp_mask = mask->h_source[0] << 16 |
+					  mask->h_source[1] << 8  |
+					  mask->h_source[2];
+			lower_temp_mask = mask->h_source[3] << 16 |
+					  mask->h_source[4] << 8  |
+					  mask->h_source[5];
 		}
 		/* Upper 24bit */
-		gfar_set_attribute(
-				value->h_source[0] << 16 | value->h_source[1]
-						<< 8 | value->h_source[2],
-				upper_temp_mask, RQFCR_PID_SAH, tab);
+		gfar_set_attribute(value->h_source[0] << 16 |
+				   value->h_source[1] << 8  |
+				   value->h_source[2],
+				   upper_temp_mask, RQFCR_PID_SAH, tab);
 		/* And the same for the lower part */
-		gfar_set_attribute(
-				value->h_source[3] << 16 | value->h_source[4]
-						<< 8 | value->h_source[5],
-				lower_temp_mask, RQFCR_PID_SAL, tab);
+		gfar_set_attribute(value->h_source[3] << 16 |
+				   value->h_source[4] << 8  |
+				   value->h_source[5],
+				   lower_temp_mask, RQFCR_PID_SAL, tab);
 	}
 	/* Destination address */
 	if (!is_broadcast_ether_addr(mask->h_dest)) {
-
 		/* Special for destination is limited broadcast */
-		if ((is_broadcast_ether_addr(value->h_dest)
-				&& is_zero_ether_addr(mask->h_dest))) {
+		if ((is_broadcast_ether_addr(value->h_dest) &&
+		    is_zero_ether_addr(mask->h_dest))) {
 			gfar_set_parse_bits(RQFPR_EBC, RQFPR_EBC, tab);
 		} else {
-
 			if (is_zero_ether_addr(mask->h_dest)) {
 				upper_temp_mask = 0xFFFFFFFF;
 				lower_temp_mask = 0xFFFFFFFF;
 			} else {
-				upper_temp_mask = mask->h_dest[0] << 16
-						| mask->h_dest[1] << 8
-						| mask->h_dest[2];
-				lower_temp_mask = mask->h_dest[3] << 16
-						| mask->h_dest[4] << 8
-						| mask->h_dest[5];
+				upper_temp_mask = mask->h_dest[0] << 16 |
+						  mask->h_dest[1] << 8  |
+						  mask->h_dest[2];
+				lower_temp_mask = mask->h_dest[3] << 16 |
+						  mask->h_dest[4] << 8  |
+						  mask->h_dest[5];
 			}
 
 			/* Upper 24bit */
-			gfar_set_attribute(
-					value->h_dest[0] << 16
-							| value->h_dest[1] << 8
-							| value->h_dest[2],
-					upper_temp_mask, RQFCR_PID_DAH, tab);
+			gfar_set_attribute(value->h_dest[0] << 16 |
+					   value->h_dest[1] << 8  |
+					   value->h_dest[2],
+					   upper_temp_mask, RQFCR_PID_DAH, tab);
 			/* And the same for the lower part */
-			gfar_set_attribute(
-					value->h_dest[3] << 16
-							| value->h_dest[4] << 8
-							| value->h_dest[5],
-					lower_temp_mask, RQFCR_PID_DAL, tab);
+			gfar_set_attribute(value->h_dest[3] << 16 |
+					   value->h_dest[4] << 8  |
+					   value->h_dest[5],
+					   lower_temp_mask, RQFCR_PID_DAL, tab);
 		}
 	}
 
 	gfar_set_attribute(value->h_proto, mask->h_proto, RQFCR_PID_ETY, tab);
-
 }
 
 /* Convert a rule to binary filter format of gianfar */
 static int gfar_convert_to_filer(struct ethtool_rx_flow_spec *rule,
-		struct filer_table *tab)
+				 struct filer_table *tab)
 {
 	u32 vlan = 0, vlan_mask = 0;
 	u32 id = 0, id_mask = 0;
 	u32 cfi = 0, cfi_mask = 0;
 	u32 prio = 0, prio_mask = 0;
-
 	u32 old_index = tab->index;
 
 	/* Check if vlan is wanted */
@@ -1076,13 +1095,16 @@ static int gfar_convert_to_filer(struct ethtool_rx_flow_spec *rule,
 		id_mask = rule->m_ext.vlan_tci & VLAN_VID_MASK;
 		cfi = rule->h_ext.vlan_tci & VLAN_CFI_MASK;
 		cfi_mask = rule->m_ext.vlan_tci & VLAN_CFI_MASK;
-		prio = (rule->h_ext.vlan_tci & VLAN_PRIO_MASK) >> VLAN_PRIO_SHIFT;
-		prio_mask = (rule->m_ext.vlan_tci & VLAN_PRIO_MASK) >> VLAN_PRIO_SHIFT;
+		prio = (rule->h_ext.vlan_tci & VLAN_PRIO_MASK) >>
+		       VLAN_PRIO_SHIFT;
+		prio_mask = (rule->m_ext.vlan_tci & VLAN_PRIO_MASK) >>
+			    VLAN_PRIO_SHIFT;
 
 		if (cfi == VLAN_TAG_PRESENT && cfi_mask == VLAN_TAG_PRESENT) {
 			vlan |= RQFPR_CFI;
 			vlan_mask |= RQFPR_CFI;
-		} else if (cfi != VLAN_TAG_PRESENT && cfi_mask == VLAN_TAG_PRESENT) {
+		} else if (cfi != VLAN_TAG_PRESENT &&
+			   cfi_mask == VLAN_TAG_PRESENT) {
 			vlan_mask |= RQFPR_CFI;
 		}
 	}
@@ -1090,34 +1112,36 @@ static int gfar_convert_to_filer(struct ethtool_rx_flow_spec *rule,
 	switch (rule->flow_type & ~FLOW_EXT) {
 	case TCP_V4_FLOW:
 		gfar_set_parse_bits(RQFPR_IPV4 | RQFPR_TCP | vlan,
-				RQFPR_IPV4 | RQFPR_TCP | vlan_mask, tab);
+				    RQFPR_IPV4 | RQFPR_TCP | vlan_mask, tab);
 		gfar_set_basic_ip(&rule->h_u.tcp_ip4_spec,
-				&rule->m_u.tcp_ip4_spec, tab);
+				  &rule->m_u.tcp_ip4_spec, tab);
 		break;
 	case UDP_V4_FLOW:
 		gfar_set_parse_bits(RQFPR_IPV4 | RQFPR_UDP | vlan,
-				RQFPR_IPV4 | RQFPR_UDP | vlan_mask, tab);
+				    RQFPR_IPV4 | RQFPR_UDP | vlan_mask, tab);
 		gfar_set_basic_ip(&rule->h_u.udp_ip4_spec,
-				&rule->m_u.udp_ip4_spec, tab);
+				  &rule->m_u.udp_ip4_spec, tab);
 		break;
 	case SCTP_V4_FLOW:
 		gfar_set_parse_bits(RQFPR_IPV4 | vlan, RQFPR_IPV4 | vlan_mask,
-				tab);
+				    tab);
 		gfar_set_attribute(132, 0, RQFCR_PID_L4P, tab);
-		gfar_set_basic_ip((struct ethtool_tcpip4_spec *) &rule->h_u,
-				(struct ethtool_tcpip4_spec *) &rule->m_u, tab);
+		gfar_set_basic_ip((struct ethtool_tcpip4_spec *)&rule->h_u,
+				  (struct ethtool_tcpip4_spec *)&rule->m_u,
+				  tab);
 		break;
 	case IP_USER_FLOW:
 		gfar_set_parse_bits(RQFPR_IPV4 | vlan, RQFPR_IPV4 | vlan_mask,
-				tab);
+				    tab);
 		gfar_set_user_ip((struct ethtool_usrip4_spec *) &rule->h_u,
-				(struct ethtool_usrip4_spec *) &rule->m_u, tab);
+				 (struct ethtool_usrip4_spec *) &rule->m_u,
+				 tab);
 		break;
 	case ETHER_FLOW:
 		if (vlan)
 			gfar_set_parse_bits(vlan, vlan_mask, tab);
 		gfar_set_ether((struct ethhdr *) &rule->h_u,
-				(struct ethhdr *) &rule->m_u, tab);
+			       (struct ethhdr *) &rule->m_u, tab);
 		break;
 	default:
 		return -1;
@@ -1152,7 +1176,9 @@ static int gfar_convert_to_filer(struct ethtool_rx_flow_spec *rule,
 		tab->fe[tab->index - 1].ctrl |= RQFCR_CLE;
 	}
 
-	/* In rare cases the cache can be full while there is free space in hw */
+	/* In rare cases the cache can be full while there is
+	 * free space in hw
+	 */
 	if (tab->index > MAX_FILER_CACHE_IDX - 1)
 		return -EBUSY;
 
@@ -1161,7 +1187,7 @@ static int gfar_convert_to_filer(struct ethtool_rx_flow_spec *rule,
 
 /* Copy size filer entries */
 static void gfar_copy_filer_entries(struct gfar_filer_entry dst[0],
-		struct gfar_filer_entry src[0], s32 size)
+				    struct gfar_filer_entry src[0], s32 size)
 {
 	while (size > 0) {
 		size--;
@@ -1171,10 +1197,12 @@ static void gfar_copy_filer_entries(struct gfar_filer_entry dst[0],
 }
 
 /* Delete the contents of the filer-table between start and end
- * and collapse them */
+ * and collapse them
+ */
 static int gfar_trim_filer_entries(u32 begin, u32 end, struct filer_table *tab)
 {
 	int length;
+
 	if (end > MAX_FILER_CACHE_IDX || end < begin)
 		return -EINVAL;
 
@@ -1200,14 +1228,14 @@ static int gfar_trim_filer_entries(u32 begin, u32 end, struct filer_table *tab)
 
 /* Make space on the wanted location */
 static int gfar_expand_filer_entries(u32 begin, u32 length,
-		struct filer_table *tab)
+				     struct filer_table *tab)
 {
-	if (length == 0 || length + tab->index > MAX_FILER_CACHE_IDX || begin
-			> MAX_FILER_CACHE_IDX)
+	if (length == 0 || length + tab->index > MAX_FILER_CACHE_IDX ||
+	    begin > MAX_FILER_CACHE_IDX)
 		return -EINVAL;
 
 	gfar_copy_filer_entries(&(tab->fe[begin + length]), &(tab->fe[begin]),
-			tab->index - length + 1);
+				tab->index - length + 1);
 
 	tab->index += length;
 	return 0;
@@ -1215,9 +1243,10 @@ static int gfar_expand_filer_entries(u32 begin, u32 length,
 
 static int gfar_get_next_cluster_start(int start, struct filer_table *tab)
 {
-	for (; (start < tab->index) && (start < MAX_FILER_CACHE_IDX - 1); start++) {
-		if ((tab->fe[start].ctrl & (RQFCR_AND | RQFCR_CLE))
-				== (RQFCR_AND | RQFCR_CLE))
+	for (; (start < tab->index) && (start < MAX_FILER_CACHE_IDX - 1);
+	     start++) {
+		if ((tab->fe[start].ctrl & (RQFCR_AND | RQFCR_CLE)) ==
+		    (RQFCR_AND | RQFCR_CLE))
 			return start;
 	}
 	return -1;
@@ -1225,16 +1254,16 @@ static int gfar_get_next_cluster_start(int start, struct filer_table *tab)
 
 static int gfar_get_next_cluster_end(int start, struct filer_table *tab)
 {
-	for (; (start < tab->index) && (start < MAX_FILER_CACHE_IDX - 1); start++) {
-		if ((tab->fe[start].ctrl & (RQFCR_AND | RQFCR_CLE))
-				== (RQFCR_CLE))
+	for (; (start < tab->index) && (start < MAX_FILER_CACHE_IDX - 1);
+	     start++) {
+		if ((tab->fe[start].ctrl & (RQFCR_AND | RQFCR_CLE)) ==
+		    (RQFCR_CLE))
 			return start;
 	}
 	return -1;
 }
 
-/*
- * Uses hardwares clustering option to reduce
+/* Uses hardwares clustering option to reduce
  * the number of filer table entries
  */
 static void gfar_cluster_filer(struct filer_table *tab)
@@ -1244,8 +1273,7 @@ static void gfar_cluster_filer(struct filer_table *tab)
 	while ((i = gfar_get_next_cluster_start(++i, tab)) != -1) {
 		j = i;
 		while ((j = gfar_get_next_cluster_start(++j, tab)) != -1) {
-			/*
-			 * The cluster entries self and the previous one
+			/* The cluster entries self and the previous one
 			 * (a mask) must be identical!
 			 */
 			if (tab->fe[i].ctrl != tab->fe[j].ctrl)
@@ -1260,21 +1288,21 @@ static void gfar_cluster_filer(struct filer_table *tab)
 			jend = gfar_get_next_cluster_end(j, tab);
 			if (jend == -1 || iend == -1)
 				break;
-			/*
-			 * First we make some free space, where our cluster
+
+			/* First we make some free space, where our cluster
 			 * element should be. Then we copy it there and finally
 			 * delete in from its old location.
 			 */
-
-			if (gfar_expand_filer_entries(iend, (jend - j), tab)
-					== -EINVAL)
+			if (gfar_expand_filer_entries(iend, (jend - j), tab) ==
+			    -EINVAL)
 				break;
 
 			gfar_copy_filer_entries(&(tab->fe[iend + 1]),
-					&(tab->fe[jend + 1]), jend - j);
+						&(tab->fe[jend + 1]), jend - j);
 
 			if (gfar_trim_filer_entries(jend - 1,
-					jend + (jend - j), tab) == -EINVAL)
+						    jend + (jend - j),
+						    tab) == -EINVAL)
 				return;
 
 			/* Mask out cluster bit */
@@ -1285,8 +1313,9 @@ static void gfar_cluster_filer(struct filer_table *tab)
 
 /* Swaps the masked bits of a1<>a2 and b1<>b2 */
 static void gfar_swap_bits(struct gfar_filer_entry *a1,
-		struct gfar_filer_entry *a2, struct gfar_filer_entry *b1,
-		struct gfar_filer_entry *b2, u32 mask)
+			   struct gfar_filer_entry *a2,
+			   struct gfar_filer_entry *b1,
+			   struct gfar_filer_entry *b2, u32 mask)
 {
 	u32 temp[4];
 	temp[0] = a1->ctrl & mask;
@@ -1305,13 +1334,12 @@ static void gfar_swap_bits(struct gfar_filer_entry *a1,
 	b2->ctrl |= temp[2];
 }
 
-/*
- * Generate a list consisting of masks values with their start and
+/* Generate a list consisting of masks values with their start and
  * end of validity and block as indicator for parts belonging
  * together (glued by ANDs) in mask_table
  */
 static u32 gfar_generate_mask_table(struct gfar_mask_entry *mask_table,
-		struct filer_table *tab)
+				    struct filer_table *tab)
 {
 	u32 i, and_index = 0, block_index = 1;
 
@@ -1327,13 +1355,13 @@ static u32 gfar_generate_mask_table(struct gfar_mask_entry *mask_table,
 			and_index++;
 		}
 		/* cluster starts and ends will be separated because they should
-		 * hold their position */
+		 * hold their position
+		 */
 		if (tab->fe[i].ctrl & RQFCR_CLE)
 			block_index++;
 		/* A not set AND indicates the end of a depended block */
 		if (!(tab->fe[i].ctrl & RQFCR_AND))
 			block_index++;
-
 	}
 
 	mask_table[and_index - 1].end = i - 1;
@@ -1341,14 +1369,13 @@ static u32 gfar_generate_mask_table(struct gfar_mask_entry *mask_table,
 	return and_index;
 }
 
-/*
- * Sorts the entries of mask_table by the values of the masks.
+/* Sorts the entries of mask_table by the values of the masks.
  * Important: The 0xFF80 flags of the first and last entry of a
  * block must hold their position (which queue, CLusterEnable, ReJEct,
  * AND)
  */
 static void gfar_sort_mask_table(struct gfar_mask_entry *mask_table,
-		struct filer_table *temp_table, u32 and_index)
+				 struct filer_table *temp_table, u32 and_index)
 {
 	/* Pointer to compare function (_asc or _desc) */
 	int (*gfar_comp)(const void *, const void *);
@@ -1359,16 +1386,16 @@ static void gfar_sort_mask_table(struct gfar_mask_entry *mask_table,
 	gfar_comp = &gfar_comp_desc;
 
 	for (i = 0; i < and_index; i++) {
-
 		if (prev != mask_table[i].block) {
 			old_first = mask_table[start].start + 1;
 			old_last = mask_table[i - 1].end;
 			sort(mask_table + start, size,
-					sizeof(struct gfar_mask_entry),
-					gfar_comp, &gfar_swap);
+			     sizeof(struct gfar_mask_entry),
+			     gfar_comp, &gfar_swap);
 
 			/* Toggle order for every block. This makes the
-			 * thing more efficient! */
+			 * thing more efficient!
+			 */
 			if (gfar_comp == gfar_comp_desc)
 				gfar_comp = &gfar_comp_asc;
 			else
@@ -1378,12 +1405,11 @@ static void gfar_sort_mask_table(struct gfar_mask_entry *mask_table,
 			new_last = mask_table[i - 1].end;
 
 			gfar_swap_bits(&temp_table->fe[new_first],
-					&temp_table->fe[old_first],
-					&temp_table->fe[new_last],
-					&temp_table->fe[old_last],
-					RQFCR_QUEUE | RQFCR_CLE |
-						RQFCR_RJE | RQFCR_AND
-					);
+				       &temp_table->fe[old_first],
+				       &temp_table->fe[new_last],
+				       &temp_table->fe[old_last],
+				       RQFCR_QUEUE | RQFCR_CLE |
+				       RQFCR_RJE | RQFCR_AND);
 
 			start = i;
 			size = 0;
@@ -1391,11 +1417,9 @@ static void gfar_sort_mask_table(struct gfar_mask_entry *mask_table,
 		size++;
 		prev = mask_table[i].block;
 	}
-
 }
 
-/*
- * Reduces the number of masks needed in the filer table to save entries
+/* Reduces the number of masks needed in the filer table to save entries
  * This is done by sorting the masks of a depended block. A depended block is
  * identified by gluing ANDs or CLE. The sorting order toggles after every
  * block. Of course entries in scope of a mask must change their location with
@@ -1410,13 +1434,14 @@ static int gfar_optimize_filer_masks(struct filer_table *tab)
 	s32 ret = 0;
 
 	/* We need a copy of the filer table because
-	 * we want to change its order */
+	 * we want to change its order
+	 */
 	temp_table = kmemdup(tab, sizeof(*temp_table), GFP_KERNEL);
 	if (temp_table == NULL)
 		return -ENOMEM;
 
 	mask_table = kcalloc(MAX_FILER_CACHE_IDX / 2 + 1,
-			sizeof(struct gfar_mask_entry), GFP_KERNEL);
+			     sizeof(struct gfar_mask_entry), GFP_KERNEL);
 
 	if (mask_table == NULL) {
 		ret = -ENOMEM;
@@ -1428,7 +1453,8 @@ static int gfar_optimize_filer_masks(struct filer_table *tab)
 	gfar_sort_mask_table(mask_table, temp_table, and_index);
 
 	/* Now we can copy the data from our duplicated filer table to
-	 * the real one in the order the mask table says */
+	 * the real one in the order the mask table says
+	 */
 	for (i = 0; i < and_index; i++) {
 		size = mask_table[i].end - mask_table[i].start + 1;
 		gfar_copy_filer_entries(&(tab->fe[j]),
@@ -1437,7 +1463,8 @@ static int gfar_optimize_filer_masks(struct filer_table *tab)
 	}
 
 	/* And finally we just have to check for duplicated masks and drop the
-	 * second ones */
+	 * second ones
+	 */
 	for (i = 0; i < tab->index && i < MAX_FILER_CACHE_IDX; i++) {
 		if (tab->fe[i].ctrl == 0x80) {
 			previous_mask = i++;
@@ -1448,7 +1475,8 @@ static int gfar_optimize_filer_masks(struct filer_table *tab)
 		if (tab->fe[i].ctrl == 0x80) {
 			if (tab->fe[i].prop == tab->fe[previous_mask].prop) {
 				/* Two identical ones found!
-				 * So drop the second one! */
+				 * So drop the second one!
+				 */
 				gfar_trim_filer_entries(i, i, tab);
 			} else
 				/* Not identical! */
@@ -1463,7 +1491,7 @@ end:	kfree(temp_table);
 
 /* Write the bit-pattern from software's buffer to hardware registers */
 static int gfar_write_filer_table(struct gfar_private *priv,
-		struct filer_table *tab)
+				  struct filer_table *tab)
 {
 	u32 i = 0;
 	if (tab->index > MAX_FILER_IDX - 1)
@@ -1473,13 +1501,15 @@ static int gfar_write_filer_table(struct gfar_private *priv,
 	lock_rx_qs(priv);
 
 	/* Fill regular entries */
-	for (; i < MAX_FILER_IDX - 1 && (tab->fe[i].ctrl | tab->fe[i].ctrl); i++)
+	for (; i < MAX_FILER_IDX - 1 && (tab->fe[i].ctrl | tab->fe[i].ctrl);
+	     i++)
 		gfar_write_filer(priv, i, tab->fe[i].ctrl, tab->fe[i].prop);
 	/* Fill the rest with fall-troughs */
 	for (; i < MAX_FILER_IDX - 1; i++)
 		gfar_write_filer(priv, i, 0x60, 0xFFFFFFFF);
 	/* Last entry must be default accept
-	 * because that's what people expect */
+	 * because that's what people expect
+	 */
 	gfar_write_filer(priv, i, 0x20, 0x0);
 
 	unlock_rx_qs(priv);
@@ -1488,21 +1518,21 @@ static int gfar_write_filer_table(struct gfar_private *priv,
 }
 
 static int gfar_check_capability(struct ethtool_rx_flow_spec *flow,
-		struct gfar_private *priv)
+				 struct gfar_private *priv)
 {
 
 	if (flow->flow_type & FLOW_EXT)	{
 		if (~flow->m_ext.data[0] || ~flow->m_ext.data[1])
 			netdev_warn(priv->ndev,
-					"User-specific data not supported!\n");
+				    "User-specific data not supported!\n");
 		if (~flow->m_ext.vlan_etype)
 			netdev_warn(priv->ndev,
-					"VLAN-etype not supported!\n");
+				    "VLAN-etype not supported!\n");
 	}
 	if (flow->flow_type == IP_USER_FLOW)
 		if (flow->h_u.usr_ip4_spec.ip_ver != ETH_RX_NFC_IP4)
 			netdev_warn(priv->ndev,
-					"IP-Version differing from IPv4 not supported!\n");
+				    "IP-Version differing from IPv4 not supported!\n");
 
 	return 0;
 }
@@ -1520,15 +1550,18 @@ static int gfar_process_filer_changes(struct gfar_private *priv)
 		return -ENOMEM;
 
 	/* Now convert the existing filer data from flow_spec into
-	 * filer tables binary format */
+	 * filer tables binary format
+	 */
 	list_for_each_entry(j, &priv->rx_list.list, list) {
 		ret = gfar_convert_to_filer(&j->fs, tab);
 		if (ret == -EBUSY) {
-			netdev_err(priv->ndev, "Rule not added: No free space!\n");
+			netdev_err(priv->ndev,
+				   "Rule not added: No free space!\n");
 			goto end;
 		}
 		if (ret == -1) {
-			netdev_err(priv->ndev, "Rule not added: Unsupported Flow-type!\n");
+			netdev_err(priv->ndev,
+				   "Rule not added: Unsupported Flow-type!\n");
 			goto end;
 		}
 	}
@@ -1540,9 +1573,9 @@ static int gfar_process_filer_changes(struct gfar_private *priv)
 	gfar_optimize_filer_masks(tab);
 
 	pr_debug("\n\tSummary:\n"
-		"\tData on hardware: %d\n"
-		"\tCompression rate: %d%%\n",
-		tab->index, 100 - (100 * tab->index) / i);
+		 "\tData on hardware: %d\n"
+		 "\tCompression rate: %d%%\n",
+		 tab->index, 100 - (100 * tab->index) / i);
 
 	/* Write everything to hardware */
 	ret = gfar_write_filer_table(priv, tab);
@@ -1551,7 +1584,8 @@ static int gfar_process_filer_changes(struct gfar_private *priv)
 		goto end;
 	}
 
-end:	kfree(tab);
+end:
+	kfree(tab);
 	return ret;
 }
 
@@ -1569,7 +1603,7 @@ static void gfar_invert_masks(struct ethtool_rx_flow_spec *flow)
 }
 
 static int gfar_add_cls(struct gfar_private *priv,
-		struct ethtool_rx_flow_spec *flow)
+			struct ethtool_rx_flow_spec *flow)
 {
 	struct ethtool_flow_spec_container *temp, *comp;
 	int ret = 0;
@@ -1591,7 +1625,6 @@ static int gfar_add_cls(struct gfar_private *priv,
 		list_add(&temp->list, &priv->rx_list.list);
 		goto process;
 	} else {
-
 		list_for_each_entry(comp, &priv->rx_list.list, list) {
 			if (comp->fs.location > flow->location) {
 				list_add_tail(&temp->list, &comp->list);
@@ -1599,8 +1632,8 @@ static int gfar_add_cls(struct gfar_private *priv,
 			}
 			if (comp->fs.location == flow->location) {
 				netdev_err(priv->ndev,
-						"Rule not added: ID %d not free!\n",
-					flow->location);
+					   "Rule not added: ID %d not free!\n",
+					   flow->location);
 				ret = -EBUSY;
 				goto clean_mem;
 			}
@@ -1642,7 +1675,6 @@ static int gfar_del_cls(struct gfar_private *priv, u32 loc)
 	}
 
 	return ret;
-
 }
 
 static int gfar_get_cls(struct gfar_private *priv, struct ethtool_rxnfc *cmd)
@@ -1663,7 +1695,7 @@ static int gfar_get_cls(struct gfar_private *priv, struct ethtool_rxnfc *cmd)
 }
 
 static int gfar_get_cls_all(struct gfar_private *priv,
-		struct ethtool_rxnfc *cmd, u32 *rule_locs)
+			    struct ethtool_rxnfc *cmd, u32 *rule_locs)
 {
 	struct ethtool_flow_spec_container *comp;
 	u32 i = 0;
@@ -1714,7 +1746,7 @@ static int gfar_set_nfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
 }
 
 static int gfar_get_nfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
-		u32 *rule_locs)
+			u32 *rule_locs)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	int ret = 0;
@@ -1748,23 +1780,19 @@ static int gfar_get_ts_info(struct net_device *dev,
 	struct gfar_private *priv = netdev_priv(dev);
 
 	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER)) {
-		info->so_timestamping =
-			SOF_TIMESTAMPING_RX_SOFTWARE |
-			SOF_TIMESTAMPING_SOFTWARE;
+		info->so_timestamping = SOF_TIMESTAMPING_RX_SOFTWARE |
+					SOF_TIMESTAMPING_SOFTWARE;
 		info->phc_index = -1;
 		return 0;
 	}
-	info->so_timestamping =
-		SOF_TIMESTAMPING_TX_HARDWARE |
-		SOF_TIMESTAMPING_RX_HARDWARE |
-		SOF_TIMESTAMPING_RAW_HARDWARE;
+	info->so_timestamping = SOF_TIMESTAMPING_TX_HARDWARE |
+				SOF_TIMESTAMPING_RX_HARDWARE |
+				SOF_TIMESTAMPING_RAW_HARDWARE;
 	info->phc_index = gfar_phc_index;
-	info->tx_types =
-		(1 << HWTSTAMP_TX_OFF) |
-		(1 << HWTSTAMP_TX_ON);
-	info->rx_filters =
-		(1 << HWTSTAMP_FILTER_NONE) |
-		(1 << HWTSTAMP_FILTER_ALL);
+	info->tx_types = (1 << HWTSTAMP_TX_OFF) |
+			 (1 << HWTSTAMP_TX_ON);
+	info->rx_filters = (1 << HWTSTAMP_FILTER_NONE) |
+			   (1 << HWTSTAMP_FILTER_ALL);
 	return 0;
 }
 
-- 
1.7.9.5
