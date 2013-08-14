From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: [PATCH RESEND 1/8] net: fsl_pq_mdio: use platform_{get,set}_drvdata()
Date: Wed, 14 Aug 2013 11:39:26 +0800
Message-ID: <520AFBEE.7030903@huawei.com>
References: <5208E215.6030007@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5208E215.6030007@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


We can use the wrapper functions platform_{get,set}_drvdata() instead of
dev_{get,set}_drvdata() with &pdev->dev, it is convenient for user.

Also, unnecessary dev_set_drvdata() is removed, because the driver core
clears the driver data to NULL after device_release or on probe failure.

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/net/ethernet/freescale/fsl_pq_mdio.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index c93a056..995a3ab 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -409,7 +409,7 @@ static int fsl_pq_mdio_probe(struct platform_device *pdev)
 	priv->regs = priv->map + data->mii_offset;

 	new_bus->parent = &pdev->dev;
-	dev_set_drvdata(&pdev->dev, new_bus);
+	platform_set_drvdata(pdev, new_bus);

 	if (data->get_tbipa) {
 		for_each_child_of_node(np, tbi) {
@@ -468,7 +468,6 @@ static int fsl_pq_mdio_remove(struct platform_device *pdev)

 	mdiobus_unregister(bus);

-	dev_set_drvdata(device, NULL);

 	iounmap(priv->map);
 	mdiobus_free(bus);
-- 
1.7.1
