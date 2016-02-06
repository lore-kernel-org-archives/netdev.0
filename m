From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/2] ravb: skip gPTP start/stop on R-Car gen3
Date: Sat, 06 Feb 2016 17:47:22 +0300
Message-ID: <1661604.7YJiO2yUKB@wasted.cogentembedded.com>
References: <15000430.RmSAhz5Ejy@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <15000430.RmSAhz5Ejy@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When adding support for the  R-Car gen3 gPTP active in configuration mode,
some call sites of ravb_ptp_{init|stop}() were missed due to an oversight.
Add  checks for the R-Car gen2 SoCs around these...

Fixes: f5d7837f96e5 ("ravb: ptp: Add CONFIG mode support")
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/ravb_main.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

Index: net/drivers/net/ethernet/renesas/ravb_main.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/ravb_main.c
+++ net/drivers/net/ethernet/renesas/ravb_main.c
@@ -1139,7 +1139,8 @@ static int ravb_set_ringparam(struct net
 	if (netif_running(ndev)) {
 		netif_device_detach(ndev);
 		/* Stop PTP Clock driver */
-		ravb_ptp_stop(ndev);
+		if (priv->chip_id == RCAR_GEN2)
+			ravb_ptp_stop(ndev);
 		/* Wait for DMA stopping */
 		error = ravb_stop_dma(ndev);
 		if (error) {
@@ -1170,7 +1171,8 @@ static int ravb_set_ringparam(struct net
 		ravb_emac_init(ndev);
 
 		/* Initialise PTP Clock driver */
-		ravb_ptp_init(ndev, priv->pdev);
+		if (priv->chip_id == RCAR_GEN2)
+			ravb_ptp_init(ndev, priv->pdev);
 
 		netif_device_attach(ndev);
 	}
@@ -1298,7 +1300,8 @@ static void ravb_tx_timeout_work(struct
 	netif_tx_stop_all_queues(ndev);
 
 	/* Stop PTP Clock driver */
-	ravb_ptp_stop(ndev);
+	if (priv->chip_id == RCAR_GEN2)
+		ravb_ptp_stop(ndev);
 
 	/* Wait for DMA stopping */
 	ravb_stop_dma(ndev);
@@ -1311,7 +1314,8 @@ static void ravb_tx_timeout_work(struct
 	ravb_emac_init(ndev);
 
 	/* Initialise PTP Clock driver */
-	ravb_ptp_init(ndev, priv->pdev);
+	if (priv->chip_id == RCAR_GEN2)
+		ravb_ptp_init(ndev, priv->pdev);
 
 	netif_tx_start_all_queues(ndev);
 }
