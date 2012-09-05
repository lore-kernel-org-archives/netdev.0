From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH 08/10] net/macb: macb_get_drvinfo: add GEM/MACB suffix to differentiate revision
Date: Wed, 5 Sep 2012 11:00:53 +0200
Message-ID: <fc701a2ed18198b7a671c55f1e65725f1709509c.1346775479.git.nicolas.ferre@atmel.com>
References: <cover.1346775479.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <davem@davemloft.net>,
	<havard@skinnemoen.net>, <nicolas.ferre@atmel.com>,
	<plagnioj@jcrosoft.com>, <jamie@jamieiles.com>,
	<linux-kernel@vger.kernel.org>, <patrice.vilchez@atmel.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1346775479.git.nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add an indication about which revision of the hardware we are running in
info->driver string.

Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index bd331fd..c7c39f1 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1313,6 +1313,10 @@ static void macb_get_drvinfo(struct net_device *dev,
 	struct macb *bp = netdev_priv(dev);
 
 	strcpy(info->driver, bp->pdev->dev.driver->name);
+	if (macb_is_gem(bp))
+		strcat(info->driver, " GEM");
+	else
+		strcat(info->driver, " MACB");
 	strcpy(info->version, "$Revision: 1.14 $");
 	strcpy(info->bus_info, dev_name(&bp->pdev->dev));
 }
-- 
1.7.10
