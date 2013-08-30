From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 23/31] net: cpmac: use dev_get_platdata()
Date: Fri, 30 Aug 2013 14:05:02 +0900
Message-ID: <004701cea53e$7bfe6cb0$73fb4610$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Florian Fainelli' <florian@openwrt.org>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:10793 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752567Ab3H3FFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 01:05:03 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB006ZWVFTTWN0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 14:05:02 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/ti/cpmac.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index 31bbbca..2dc16b6 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -636,7 +636,7 @@ static void cpmac_hw_stop(struct net_device *dev)
 {
 	int i;
 	struct cpmac_priv *priv = netdev_priv(dev);
-	struct plat_cpmac_data *pdata = priv->pdev->dev.platform_data;
+	struct plat_cpmac_data *pdata = dev_get_platdata(&priv->pdev->dev);
 
 	ar7_device_reset(pdata->reset_bit);
 	cpmac_write(priv->regs, CPMAC_RX_CONTROL,
@@ -659,7 +659,7 @@ static void cpmac_hw_start(struct net_device *dev)
 {
 	int i;
 	struct cpmac_priv *priv = netdev_priv(dev);
-	struct plat_cpmac_data *pdata = priv->pdev->dev.platform_data;
+	struct plat_cpmac_data *pdata = dev_get_platdata(&priv->pdev->dev);
 
 	ar7_device_reset(pdata->reset_bit);
 	for (i = 0; i < 8; i++) {
@@ -1118,7 +1118,7 @@ static int cpmac_probe(struct platform_device *pdev)
 	struct net_device *dev;
 	struct plat_cpmac_data *pdata;
 
-	pdata = pdev->dev.platform_data;
+	pdata = dev_get_platdata(&pdev->dev);
 
 	if (external_switch || dumb_switch) {
 		strncpy(mdio_bus_id, "fixed-0", MII_BUS_ID_SIZE); /* fixed phys bus */
-- 
1.7.10.4
