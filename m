From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: freescale: fix potential null pointer dereference
Date: Tue, 30 May 2017 17:38:43 -0500
Message-ID: <20170530223842.GA11915@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add NULL check before dereferencing pointer _id_ in order to avoid
a potential NULL pointer dereference.

Addresses-Coverity-ID: 1397995
Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 drivers/net/ethernet/freescale/fsl_pq_mdio.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index 446c7b3..a10de1e 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -381,7 +381,7 @@ static int fsl_pq_mdio_probe(struct platform_device *pdev)
 {
 	const struct of_device_id *id =
 		of_match_device(fsl_pq_mdio_match, &pdev->dev);
-	const struct fsl_pq_mdio_data *data = id->data;
+	const struct fsl_pq_mdio_data *data;
 	struct device_node *np = pdev->dev.of_node;
 	struct resource res;
 	struct device_node *tbi;
@@ -389,6 +389,13 @@ static int fsl_pq_mdio_probe(struct platform_device *pdev)
 	struct mii_bus *new_bus;
 	int err;
 
+	if (!id) {
+		dev_err(&pdev->dev, "Failed to match device\n");
+		return -ENODEV;
+	}
+
+	data = id->data;
+
 	dev_dbg(&pdev->dev, "found %s compatible node\n", id->compatible);
 
 	new_bus = mdiobus_alloc_size(sizeof(*priv));
-- 
2.5.0
