From: Wolfram Sang <wsa@the-dreams.de>
Subject: [RFC 17/42] drivers/net/ethernet/renesas: don't check resource with devm_ioremap_resource
Date: Fri, 10 May 2013 10:17:02 +0200
Message-ID: <1368173847-5661-18-git-send-email-wsa@the-dreams.de>
References: <1368173847-5661-1-git-send-email-wsa@the-dreams.de>
Cc: Wolfram Sang <wsa@the-dreams.de>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368173847-5661-1-git-send-email-wsa@the-dreams.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

devm_ioremap_resource does sanity checks on the given resource. No need to
duplicate this in the driver.

Signed-off-by: Wolfram Sang <wsa@the-dreams.de>
---
 drivers/net/ethernet/renesas/sh_eth.c |   14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 33dc6f2..6175839 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2661,14 +2661,6 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	struct sh_eth_private *mdp = NULL;
 	struct sh_eth_plat_data *pd = pdev->dev.platform_data;
 
-	/* get base addr */
-	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	if (unlikely(res == NULL)) {
-		dev_err(&pdev->dev, "invalid resource\n");
-		ret = -EINVAL;
-		goto out;
-	}
-
 	ndev = alloc_etherdev(sizeof(struct sh_eth_private));
 	if (!ndev) {
 		ret = -ENOMEM;
@@ -2697,6 +2689,7 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	mdp = netdev_priv(ndev);
 	mdp->num_tx_ring = TX_RING_SIZE;
 	mdp->num_rx_ring = RX_RING_SIZE;
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	mdp->addr = devm_ioremap_resource(&pdev->dev, res);
 	if (IS_ERR(mdp->addr)) {
 		ret = PTR_ERR(mdp->addr);
@@ -2745,11 +2738,6 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	if (mdp->cd->tsu) {
 		struct resource *rtsu;
 		rtsu = platform_get_resource(pdev, IORESOURCE_MEM, 1);
-		if (!rtsu) {
-			dev_err(&pdev->dev, "Not found TSU resource\n");
-			ret = -ENODEV;
-			goto out_release;
-		}
 		mdp->tsu_addr = devm_ioremap_resource(&pdev->dev, rtsu);
 		if (IS_ERR(mdp->tsu_addr)) {
 			ret = PTR_ERR(mdp->tsu_addr);
-- 
1.7.10.4
