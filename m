From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 1/1] drivers: net: cpsw: Add support for new CPSW IP version
Date: Wed, 31 Jul 2013 17:42:26 +0530
Message-ID: <1375272746-24446-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-omap@vger.kernel.org>,
	<balbi@ti.com>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:42904 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752493Ab3GaMMw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 08:12:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new IP version has a minor changes and the offsets are same as the previous
version, so instead of adding CPSW version number in the driver, make the driver
to fall through to the latest versions so that the new version of CPSW which has
the same register offsets will work directly without patching the driver.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
Reviewed-by: Felipe Balbi <balbi@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 05a1674..a6b9700 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -799,6 +799,7 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 		slave_write(slave, TX_PRIORITY_MAPPING, CPSW1_TX_PRI_MAP);
 		break;
 	case CPSW_VERSION_2:
+	default:
 		slave_write(slave, TX_PRIORITY_MAPPING, CPSW2_TX_PRI_MAP);
 		break;
 	}
@@ -1180,10 +1181,9 @@ static int cpsw_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 		cpsw_hwtstamp_v1(priv);
 		break;
 	case CPSW_VERSION_2:
+	default:
 		cpsw_hwtstamp_v2(priv);
 		break;
-	default:
-		return -ENOTSUPP;
 	}
 
 	return copy_to_user(ifr->ifr_data, &cfg, sizeof(cfg)) ? -EFAULT : 0;
@@ -1790,6 +1790,7 @@ static int cpsw_probe(struct platform_device *pdev)
 		dma_params.desc_mem_phys = 0;
 		break;
 	case CPSW_VERSION_2:
+	default:
 		priv->host_port_regs = ss_regs + CPSW2_HOST_PORT_OFFSET;
 		priv->cpts->reg       = ss_regs + CPSW2_CPTS_OFFSET;
 		dma_params.dmaregs   = ss_regs + CPSW2_CPDMA_OFFSET;
@@ -1801,10 +1802,6 @@ static int cpsw_probe(struct platform_device *pdev)
 		dma_params.desc_mem_phys =
 			(u32 __force) priv->cpsw_res->start + CPSW2_BD_OFFSET;
 		break;
-	default:
-		dev_err(priv->dev, "unknown version 0x%08x\n", priv->version);
-		ret = -ENODEV;
-		goto clean_cpsw_wr_iores_ret;
 	}
 	for (i = 0; i < priv->data.slaves; i++) {
 		struct cpsw_slave *slave = &priv->slaves[i];
-- 
1.8.4.rc0.11.g35f5eaa
