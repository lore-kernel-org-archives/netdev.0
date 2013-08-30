From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 02/31] net: bfin_mac: use dev_get_platdata()
Date: Fri, 30 Aug 2013 13:50:48 +0900
Message-ID: <003201cea53c$7f2b0670$7d811350$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:12296 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752498Ab3H3Eut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 00:50:49 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB00LYUUSJ86K0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 13:50:48 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/adi/bfin_mac.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index e904b38..e66684a 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -1647,12 +1647,12 @@ static int bfin_mac_probe(struct platform_device *pdev)
 
 	setup_mac_addr(ndev->dev_addr);
 
-	if (!pdev->dev.platform_data) {
+	if (!dev_get_platdata(&pdev->dev)) {
 		dev_err(&pdev->dev, "Cannot get platform device bfin_mii_bus!\n");
 		rc = -ENODEV;
 		goto out_err_probe_mac;
 	}
-	pd = pdev->dev.platform_data;
+	pd = dev_get_platdata(&pdev->dev);
 	lp->mii_bus = platform_get_drvdata(pd);
 	if (!lp->mii_bus) {
 		dev_err(&pdev->dev, "Cannot get mii_bus!\n");
@@ -1660,7 +1660,7 @@ static int bfin_mac_probe(struct platform_device *pdev)
 		goto out_err_probe_mac;
 	}
 	lp->mii_bus->priv = ndev;
-	mii_bus_data = pd->dev.platform_data;
+	mii_bus_data = dev_get_platdata(&pd->dev);
 
 	rc = mii_probe(ndev, mii_bus_data->phy_mode);
 	if (rc) {
-- 
1.7.10.4
