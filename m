From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v7 2/3] net: Add Keystone NetCP ethernet driver
Date: Thu, 11 Dec 2014 10:34:57 -0800
Message-ID: <1418322897.18092.37.camel@perches.com>
References: <5488BB96.9070609@ti.com>
	 <20141210.204110.618599360537141819.davem@davemloft.net>
	 <5489A6CD.20909@ti.com>
	 <20141211.120104.312460507509497826.davem@davemloft.net>
	 <5489D196.4070703@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, robh+dt@kernel.org,
	grant.likely@linaro.org, WingMan Kwok <w-kwok2@ti.com>
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5489D196.4070703@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-12-11 at 12:17 -0500, Murali Karicheri wrote:
> On 12/11/2014 12:01 PM, David Miller wrote:
> > From: Murali Karicheri<m-karicheri2@ti.com>
> > Date: Thu, 11 Dec 2014 09:14:37 -0500
> >
> >> BTW, could you provide any suggestions that would help us merge this
> >> series to upstream? This has been sitting on this list for a while
> >> now.
> >
> > You simply have to continue going through the review and revision
> > process until people no longer find problems with your changes.
> >
> > This could take several more weeks, you simply must be patient.
> 
> Ok. Thanks. That is encouraging to hear!

Perhaps these trivial things might be considered

(uncompiled)
---
 drivers/net/ethernet/ti/netcp_core.c     |  2 +-
 drivers/net/ethernet/ti/netcp_ethss.c    | 83 +++++++++++++++++---------------
 drivers/net/ethernet/ti/netcp_xgbepcsr.c | 48 +++++++++---------
 3 files changed, 71 insertions(+), 62 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 60ad299..8f38fe8 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1094,7 +1094,7 @@ static void netcp_tx_notify(void *arg)
 	napi_schedule(&netcp->tx_napi);
 }
 
-static struct knav_dma_desc*
+static struct knav_dma_desc *
 netcp_tx_map_skb(struct sk_buff *skb, struct netcp_intf *netcp)
 {
 	struct knav_dma_desc *desc, *ndesc, *pdesc;
diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index 036b886..3757957 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -486,21 +486,29 @@ struct netcp_ethtool_stat {
 	int offset;
 };
 
-#define GBE_STATSA_INFO(field)		"GBE_A:"#field, GBE_STATSA_MODULE,\
-				FIELD_SIZEOF(struct gbe_hw_stats, field), \
-				offsetof(struct gbe_hw_stats, field)
-
-#define GBE_STATSB_INFO(field)		"GBE_B:"#field, GBE_STATSB_MODULE,\
-				FIELD_SIZEOF(struct gbe_hw_stats, field), \
-				offsetof(struct gbe_hw_stats, field)
-
-#define GBE_STATSC_INFO(field)		"GBE_C:"#field, GBE_STATSC_MODULE,\
-				FIELD_SIZEOF(struct gbe_hw_stats, field), \
-				offsetof(struct gbe_hw_stats, field)
-
-#define GBE_STATSD_INFO(field)		"GBE_D:"#field, GBE_STATSD_MODULE,\
-				FIELD_SIZEOF(struct gbe_hw_stats, field), \
-				offsetof(struct gbe_hw_stats, field)
+#define GBE_STATSA_INFO(field)						\
+	.desc = "GBE_A:"#field,						\
+	.type = GBE_STATSA_MODULE,					\
+	.size = FIELD_SIZEOF(struct gbe_hw_stats, field),		\
+	.offset = offsetof(struct gbe_hw_stats, field)
+
+#define GBE_STATSB_INFO(field)						\
+	.desc = "GBE_B:"#field,						\
+	.type = GBE_STATSB_MODULE,					\
+	.size = FIELD_SIZEOF(struct gbe_hw_stats, field),		\
+	.offset = offsetof(struct gbe_hw_stats, field)
+
+#define GBE_STATSC_INFO(field)						\
+	.desc = "GBE_C:"#field,						\
+	.type = GBE_STATSC_MODULE,					\
+	.size = FIELD_SIZEOF(struct gbe_hw_stats, field),		\
+	.offset = offsetof(struct gbe_hw_stats, field)
+
+#define GBE_STATSD_INFO(field)						\
+	.desc = "GBE_D:"#field,						\
+	.type = GBE_STATSD_MODULE,					\
+	.size = FIELD_SIZEOF(struct gbe_hw_stats, field),		\
+	.offset = offsetof(struct gbe_hw_stats, field)
 
 static const struct netcp_ethtool_stat gbe13_et_stats[] = {
 	/* GBE module A */
@@ -645,17 +653,23 @@ static const struct netcp_ethtool_stat gbe13_et_stats[] = {
 	{GBE_STATSD_INFO(rx_dma_overruns)},
 };
 
-#define XGBE_STATS0_INFO(field)	"GBE_0:"#field, XGBE_STATS0_MODULE, \
-				FIELD_SIZEOF(struct xgbe_hw_stats, field), \
-				offsetof(struct xgbe_hw_stats, field)
+#define XGBE_STATS0_INFO(field)						\
+	.desc = "GBE_0:"#field,						\
+	.type = GBE_STATS0_MODULE,					\
+	.size = FIELD_SIZEOF(struct gbe_hw_stats, field),		\
+	.offset = offsetof(struct gbe_hw_stats, field)
 
-#define XGBE_STATS1_INFO(field)	"GBE_1:"#field, XGBE_STATS1_MODULE, \
-				FIELD_SIZEOF(struct xgbe_hw_stats, field), \
-				offsetof(struct xgbe_hw_stats, field)
+#define XGBE_STATS1_INFO(field)						\
+	.desc = "GBE_1:"#field,						\
+	.type = GBE_STATS1_MODULE,					\
+	.size = FIELD_SIZEOF(struct gbe_hw_stats, field),		\
+	.offset = offsetof(struct gbe_hw_stats, field)
 
-#define XGBE_STATS2_INFO(field)	"GBE_2:"#field, XGBE_STATS2_MODULE, \
-				FIELD_SIZEOF(struct xgbe_hw_stats, field), \
-				offsetof(struct xgbe_hw_stats, field)
+#define XGBE_STATS2_INFO(field)
+	.desc = "GBE_2:"#field,						\
+	.type = GBE_STATS2_MODULE,					\
+	.size = FIELD_SIZEOF(struct gbe_hw_stats, field),		\
+	.offset = offsetof(struct gbe_hw_stats, field)
 
 static const struct netcp_ethtool_stat xgbe10_et_stats[] = {
 	/* GBE module 0 */
@@ -883,11 +897,11 @@ static void gbe_update_stats_ver14(struct gbe_priv *gbe_dev, uint64_t *data)
 			case GBE_STATSA_MODULE:
 			case GBE_STATSC_MODULE:
 				base = gbe_statsa;
-			break;
+				break;
 			case GBE_STATSB_MODULE:
 			case GBE_STATSD_MODULE:
 				base  = gbe_statsb;
-			break;
+				break;
 			}
 
 			p = base + gbe_dev->et_stats[j].offset;
@@ -1639,11 +1653,8 @@ static void init_secondary_ports(struct gbe_priv *gbe_dev,
 
 	for_each_child_of_node(node, port) {
 		slave = devm_kzalloc(dev, sizeof(*slave), GFP_KERNEL);
-		if (!slave) {
-			dev_err(dev, "memomry alloc failed for secondary port(%s), skipping...\n",
-				port->name);
+		if (!slave)
 			continue;
-		}
 
 		if (init_slave(gbe_dev, slave, port)) {
 			dev_err(dev, "Failed to initialize secondary port(%s), skipping...\n",
@@ -1763,10 +1774,8 @@ static int set_xgbe_ethss10_priv(struct gbe_priv *gbe_dev,
 					  XGBE10_NUM_STAT_ENTRIES *
 					  XGBE10_NUM_SLAVES * sizeof(u64),
 					  GFP_KERNEL);
-	if (!gbe_dev->hw_stats) {
-		dev_err(gbe_dev->dev, "hw_stats memory allocation failed\n");
+	if (!gbe_dev->hw_stats)
 		return -ENOMEM;
-	}
 
 	gbe_dev->ss_version = XGBE_SS_VERSION_10;
 	gbe_dev->sgmii_port_regs = gbe_dev->ss_regs +
@@ -1836,10 +1845,8 @@ static int set_gbe_ethss14_priv(struct gbe_priv *gbe_dev,
 					  GBE13_NUM_HW_STAT_ENTRIES *
 					  GBE13_NUM_SLAVES * sizeof(u64),
 					  GFP_KERNEL);
-	if (!gbe_dev->hw_stats) {
-		dev_err(gbe_dev->dev, "hw_stats memory allocation failed\n");
+	if (!gbe_dev->hw_stats)
 		return -ENOMEM;
-	}
 
 	gbe_dev->ss_version = GBE_SS_VERSION_14;
 	gbe_dev->sgmii_port_regs = regs + GBE13_SGMII_MODULE_OFFSET;
@@ -1995,10 +2002,10 @@ static int gbe_probe(struct netcp_device *netcp_device, struct device *dev,
 		dev_err(gbe_dev->dev, "error initializing ale engine\n");
 		ret = -ENODEV;
 		goto quit;
-	} else {
-		dev_dbg(gbe_dev->dev, "Created a gbe ale engine\n");
 	}
 
+	dev_dbg(gbe_dev->dev, "Created a gbe ale engine\n");
+
 	/* initialize host port */
 	gbe_init_host_port(gbe_dev);
 
diff --git a/drivers/net/ethernet/ti/netcp_xgbepcsr.c b/drivers/net/ethernet/ti/netcp_xgbepcsr.c
index 33571ac..d93a6a4 100644
--- a/drivers/net/ethernet/ti/netcp_xgbepcsr.c
+++ b/drivers/net/ethernet/ti/netcp_xgbepcsr.c
@@ -14,6 +14,9 @@
  * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  */
+
+#define pr_fmt(fmt) "XGBE: " fmt
+
 #include "netcp.h"
 
 /* XGBE registers */
@@ -43,7 +46,7 @@ struct serdes_cfg {
 	u32 mask;
 };
 
-static struct serdes_cfg cfg_phyb_1p25g_156p25mhz_cmu0[] = {
+static const struct serdes_cfg cfg_phyb_1p25g_156p25mhz_cmu0[] = {
 	{0x0000, 0x00800002, 0x00ff00ff},
 	{0x0014, 0x00003838, 0x0000ffff},
 	{0x0060, 0x1c44e438, 0xffffffff},
@@ -54,7 +57,7 @@ static struct serdes_cfg cfg_phyb_1p25g_156p25mhz_cmu0[] = {
 	{0x0000, 0x00000003, 0x000000ff},
 };
 
-static struct serdes_cfg cfg_phyb_10p3125g_156p25mhz_cmu1[] = {
+static const struct serdes_cfg cfg_phyb_10p3125g_156p25mhz_cmu1[] = {
 	{0x0c00, 0x00030002, 0x00ff00ff},
 	{0x0c14, 0x00005252, 0x0000ffff},
 	{0x0c28, 0x80000000, 0xff000000},
@@ -76,7 +79,7 @@ static struct serdes_cfg cfg_phyb_10p3125g_156p25mhz_cmu1[] = {
 	{0x0c00, 0x00000003, 0x000000ff},
 };
 
-static struct serdes_cfg cfg_phyb_10p3125g_16bit_lane[] = {
+static const struct serdes_cfg cfg_phyb_10p3125g_16bit_lane[] = {
 	{0x0204, 0x00000080, 0x000000ff},
 	{0x0208, 0x0000920d, 0x0000ffff},
 	{0x0204, 0xfc000000, 0xff000000},
@@ -106,7 +109,7 @@ static struct serdes_cfg cfg_phyb_10p3125g_16bit_lane[] = {
 	{0x03cc, 0x00000000, 0x000000ff},
 };
 
-static struct serdes_cfg cfg_phyb_10p3125g_comlane[] = {
+static const struct serdes_cfg cfg_phyb_10p3125g_comlane[] = {
 	{0x0a00, 0x00000800, 0x0000ff00},
 	{0x0a84, 0x00000000, 0x000000ff},
 	{0x0a8c, 0x00130000, 0x00ff0000},
@@ -124,7 +127,7 @@ static struct serdes_cfg cfg_phyb_10p3125g_comlane[] = {
 	{0x0ac0, 0x0000008b, 0x000000ff},
 };
 
-static struct serdes_cfg cfg_cm_c1_c2[] = {
+static const struct serdes_cfg cfg_cm_c1_c2[] = {
 	{0x0208, 0x00000000, 0x00000f00},
 	{0x0208, 0x00000000, 0x0000001f},
 	{0x0204, 0x00000000, 0x00040000},
@@ -185,8 +188,8 @@ static void netcp_xgbe_serdes_com_enable(void __iomem *serdes_regs)
 	}
 }
 
-static void netcp_xgbe_serdes_lane_enable(
-			void __iomem *serdes_regs, int lane)
+static void netcp_xgbe_serdes_lane_enable(void __iomem *serdes_regs,
+					  int lane)
 {
 	/* Set Lane Control Rate */
 	writel(0xe0e9e038, serdes_regs + 0x1fe0 + (4 * lane));
@@ -230,7 +233,7 @@ static int netcp_xgbe_wait_pll_locked(void __iomem *sw_regs)
 		cpu_relax();
 	} while (true);
 
-	pr_err("XGBE serdes not locked: time out.\n");
+	pr_err("serdes not locked: time out\n");
 	return ret;
 }
 
@@ -292,8 +295,7 @@ static void netcp_xgbe_serdes_reset_cdr(void __iomem *serdes_regs,
 	u32 tmp, dlpf, tbus;
 
 	/*Get the DLPF values */
-	tmp = netcp_xgbe_serdes_read_select_tbus(
-			serdes_regs, lane + 1, 5);
+	tmp = netcp_xgbe_serdes_read_select_tbus(serdes_regs, lane + 1, 5);
 
 	dlpf = tmp >> 2;
 
@@ -302,10 +304,10 @@ static void netcp_xgbe_serdes_reset_cdr(void __iomem *serdes_regs,
 		mdelay(1);
 		reg_rmw(sig_detect_reg, VAL_SH(0, 1), MASK_WID_SH(2, 1));
 	} else {
-		tbus = netcp_xgbe_serdes_read_select_tbus(serdes_regs, lane +
-							  1, 0xe);
+		tbus = netcp_xgbe_serdes_read_select_tbus(serdes_regs,
+							  lane + 1, 0xe);
 
-		pr_debug("XGBE: CDR centered, DLPF: %4d,%d,%d.\n",
+		pr_debug("CDR centered, DLPF: %4d,%d,%d\n",
 			 tmp >> 2, tmp & 3, (tbus >> 2) & 3);
 	}
 }
@@ -340,13 +342,13 @@ static int netcp_xgbe_check_link_status(void __iomem *serdes_regs,
 		case 0:
 			/* if good link lock the signal detect ON! */
 			if (!loss && blk_lock) {
-				pr_debug("XGBE PCSR Linked Lane: %d\n", i);
+				pr_debug("PCSR Linked Lane: %d\n", i);
 				reg_rmw(sig_detect_reg, VAL_SH(3, 1),
 					MASK_WID_SH(2, 1));
 				current_state[i] = 1;
 			} else if (!blk_lock) {
 				/* if no lock, then reset CDR */
-				pr_debug("XGBE PCSR Recover Lane: %d\n", i);
+				pr_debug("PCSR Recover Lane: %d\n", i);
 				netcp_xgbe_serdes_reset_cdr(serdes_regs,
 							    sig_detect_reg, i);
 			}
@@ -361,10 +363,10 @@ static int netcp_xgbe_check_link_status(void __iomem *serdes_regs,
 			break;
 
 		case 2:
-			if (blk_lock)
+			if (blk_lock) {
 				/* Nope just noise */
 				current_state[i] = 1;
-			else {
+			} else {
 				/* Lost the block lock, reset CDR if it is
 				 * not centered and go back to sync state
 				 */
@@ -375,7 +377,7 @@ static int netcp_xgbe_check_link_status(void __iomem *serdes_regs,
 			break;
 
 		default:
-			pr_err("XGBE: unknown current_state[%d] %d\n",
+			pr_err("unknown current_state[%d] %d\n",
 			       i, current_state[i]);
 			break;
 		}
@@ -417,19 +419,19 @@ static int netcp_xgbe_serdes_check_lane(void __iomem *serdes_regs,
 			break;
 
 		if (lane_down[0])
-			pr_debug("XGBE: detected link down on lane 0\n");
+			pr_debug("detected link down on lane 0\n");
 
 		if (lane_down[1])
-			pr_debug("XGBE: detected link down on lane 1\n");
+			pr_debug("detected link down on lane 1\n");
 
 		if (++retries > 1) {
-			pr_debug("XGBE: timeout waiting for serdes link up\n");
+			pr_debug("timeout waiting for serdes link up\n");
 			return -ETIMEDOUT;
 		}
 		mdelay(100);
 	} while (!link_up);
 
-	pr_debug("XGBE: PCSR link is up\n");
+	pr_debug("PCSR link is up\n");
 	return 0;
 }
 
@@ -494,7 +496,7 @@ int netcp_xgbe_serdes_init(void __iomem *serdes_regs, void __iomem *xgbe_regs)
 	/* read COMLANE bits 4:0 */
 	val = readl(serdes_regs + 0xa00);
 	if (val & 0x1f) {
-		pr_debug("XGBE: serdes already in operation - reset\n");
+		pr_debug("serdes already in operation - reset\n");
 		netcp_xgbe_reset_serdes(serdes_regs);
 	}
 	return netcp_xgbe_serdes_config(serdes_regs, xgbe_regs);
