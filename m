From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH v2 1/1] drivers: net: cpsw: Add support for new CPSW IP version
Date: Mon, 5 Aug 2013 17:30:05 +0530
Message-ID: <1375704005-3856-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-omap@vger.kernel.org>,
	<balbi@ti.com>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The new IP version has a minor changes and the offsets are same as the
previous version, so adding new IP version support in the driver.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
Reviewed-by: Felipe Balbi <balbi@ti.com>
---
Changes from intial version
* changed the implementation to introduce new version intead of falling to
  latest version when it is unknown version.

---
 drivers/net/ethernet/ti/cpsw.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index db6933e..cd95671 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -82,6 +82,7 @@ do {								\
 
 #define CPSW_VERSION_1		0x19010a
 #define CPSW_VERSION_2		0x19010c
+#define CPSW_VERSION_3		0x19010f
 
 #define HOST_PORT_NUM		0
 #define SLIVER_SIZE		0x40
@@ -991,6 +992,7 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 		slave_write(slave, TX_PRIORITY_MAPPING, CPSW1_TX_PRI_MAP);
 		break;
 	case CPSW_VERSION_2:
+	case CPSW_VERSION_3:
 		slave_write(slave, TX_PRIORITY_MAPPING, CPSW2_TX_PRI_MAP);
 		break;
 	}
@@ -2015,6 +2017,7 @@ static int cpsw_probe(struct platform_device *pdev)
 		dma_params.desc_mem_phys = 0;
 		break;
 	case CPSW_VERSION_2:
+	case CPSW_VERSION_3:
 		priv->host_port_regs = ss_regs + CPSW2_HOST_PORT_OFFSET;
 		priv->cpts->reg      = ss_regs + CPSW2_CPTS_OFFSET;
 		priv->hw_stats	     = ss_regs + CPSW2_HW_STATS;
-- 
1.8.4.rc0.11.g35f5eaa

