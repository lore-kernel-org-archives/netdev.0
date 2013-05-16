From: Wolfram Sang <wsa@the-dreams.de>
Subject: [PATCH 13/33] drivers/net/ethernet/renesas: don't check resource with devm_ioremap_resource
Date: Thu, 16 May 2013 13:15:41 +0200
Message-ID: <1368702961-4325-14-git-send-email-wsa@the-dreams.de>
References: <1368702961-4325-1-git-send-email-wsa@the-dreams.de>
Cc: Wolfram Sang <wsa@the-dreams.de>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sauhun.de ([89.238.76.85]:56127 "EHLO pokefinder.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752553Ab3EPLO5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 May 2013 07:14:57 -0400
In-Reply-To: <1368702961-4325-1-git-send-email-wsa@the-dreams.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

devm_ioremap_resource does sanity checks on the given resource. No need to
duplicate this in the driver.

Signed-off-by: Wolfram Sang <wsa@the-dreams.de>
---
 drivers/net/ethernet/renesas/sh_eth.c |    5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 33dc6f2..42e9dd0 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2745,11 +2745,6 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
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
