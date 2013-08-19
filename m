From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: [PATCH v4 3/7] net: fec_mpc52xx_phy: use platform_{get,set}_drvdata()
Date: Mon, 19 Aug 2013 19:59:16 +0800
Message-ID: <52120894.9020805@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the wrapper functions for getting and setting the driver data using
platform_device instead of using dev_{get,set}_drvdata() with &of->dev,
so we can directly pass a struct platform_device.

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/net/ethernet/freescale/fec_mpc52xx_phy.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx_phy.c b/drivers/net/ethernet/freescale/fec_mpc52xx_phy.c
index 360a578..eb44797 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx_phy.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx_phy.c
@@ -123,8 +123,7 @@ static int mpc52xx_fec_mdio_probe(struct platform_device *of)

 static int mpc52xx_fec_mdio_remove(struct platform_device *of)
 {
-	struct device *dev = &of->dev;
-	struct mii_bus *bus = dev_get_drvdata(dev);
+	struct mii_bus *bus = platform_get_drvdata(of);
 	struct mpc52xx_fec_mdio_priv *priv = bus->priv;

 	mdiobus_unregister(bus);
-- 
1.7.1
