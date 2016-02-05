From: Sebastian Frias <sf84@laposte.net>
Subject: [PATCH v2] net: ethernet: support "fixed-link" DT key/node on nb8800
 driver
Date: Fri, 05 Feb 2016 14:49:43 +0100
Message-ID: <56B4A877.4020800@laposte.net>
References: <56B4A445.7080402@laposte.net> <yw1x1t8ri8dz.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>
To: =?windows-1252?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpoutz25.laposte.net ([194.117.213.100]:58056 "EHLO
	smtp.laposte.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753169AbcBENtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 08:49:46 -0500
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout013 (Postfix) with ESMTP id 8F14E103C9E
	for <netdev@vger.kernel.org>; Fri,  5 Feb 2016 14:49:44 +0100 (CET)
Received: from lpn-prd-vrin001 (lpn-prd-vrin001.laposte [10.128.63.2])
	by lpn-prd-vrout013 (Postfix) with ESMTP id 89E3B1034DE
	for <netdev@vger.kernel.org>; Fri,  5 Feb 2016 14:49:44 +0100 (CET)
Received: from lpn-prd-vrin001 (localhost [127.0.0.1])
	by lpn-prd-vrin001 (Postfix) with ESMTP id 775F0365406
	for <netdev@vger.kernel.org>; Fri,  5 Feb 2016 14:49:44 +0100 (CET)
In-Reply-To: <yw1x1t8ri8dz.fsf@unicorn.mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sebastian Frias <sf84@laposte.net>
---
  drivers/net/ethernet/aurora/nb8800.c | 15 ++++++++++++---
  1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/aurora/nb8800.c 
b/drivers/net/ethernet/aurora/nb8800.c
index ecc4a33..dd7bedc 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -1462,9 +1462,18 @@ static int nb8800_probe(struct platform_device *pdev)

  	priv->phy_node = of_parse_phandle(pdev->dev.of_node, "phy-handle", 0);
  	if (!priv->phy_node) {
-		dev_err(&pdev->dev, "no PHY specified\n");
-		ret = -ENODEV;
-		goto err_free_bus;
+		if (of_phy_is_fixed_link(pdev->dev.of_node)) {
+			ret = of_phy_register_fixed_link(pdev->dev.of_node);
+			if (ret < 0) {
+				dev_err(&pdev->dev, "bad fixed-link spec\n");
+				goto err_free_bus;
+			}
+			priv->phy_node = of_node_get(pdev->dev.of_node);
+		} else {
+			dev_err(&pdev->dev, "no PHY specified\n");
+			ret = -ENODEV;
+			goto err_free_bus;
+		}
  	}

  	priv->mii_bus = bus;
-- 
2.1.4
