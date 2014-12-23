From: Kedareswara rao Appana <appana.durga.rao-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] net: xilinx: Remove unnecessary temac_property in the driver
Date: Tue, 23 Dec 2014 18:07:55 +0530
Message-ID: <072fa5b149374b09b3f6d5d767714d3e@BN1AFFO11FD010.protection.gbl>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kedareswara rao Appana <appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
To: <anirudh-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, <John.Linn-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	<michal.simek-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, <soren.brinkmann-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	<grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This property is no longer used in the code yet the code looks for it in the device tree.
It does not cause an error if it's not in the tree.

Signed-off-by: Kedareswara rao Appana <appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/xilinx/xilinx_axienet.h      |    2 --
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c |    4 ----
 2 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet.h b/drivers/net/ethernet/xilinx/xilinx_axienet.h
index 44b8d2b..4c9b4fa 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet.h
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet.h
@@ -388,7 +388,6 @@ struct axidma_bd {
  * @dma_err_tasklet: Tasklet structure to process Axi DMA errors
  * @tx_irq:	Axidma TX IRQ number
  * @rx_irq:	Axidma RX IRQ number
- * @temac_type:	axienet type to identify between soft and hard temac
  * @phy_type:	Phy type to identify between MII/GMII/RGMII/SGMII/1000 Base-X
  * @options:	AxiEthernet option word
  * @last_link:	Phy link state in which the PHY was negotiated earlier
@@ -431,7 +430,6 @@ struct axienet_local {
 
 	int tx_irq;
 	int rx_irq;
-	u32 temac_type;
 	u32 phy_type;
 
 	u32 options;			/* Current options word */
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 4ea2d4e..c18a0c6 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -1555,10 +1555,6 @@ static int axienet_of_probe(struct platform_device *op)
 		if ((be32_to_cpup(p)) >= 0x4000)
 			lp->jumbo_support = 1;
 	}
-	p = (__be32 *) of_get_property(op->dev.of_node, "xlnx,temac-type",
-				       NULL);
-	if (p)
-		lp->temac_type = be32_to_cpup(p);
 	p = (__be32 *) of_get_property(op->dev.of_node, "xlnx,phy-type", NULL);
 	if (p)
 		lp->phy_type = be32_to_cpup(p);
-- 
1.7.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
