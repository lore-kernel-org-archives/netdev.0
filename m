From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: phy: Fix return value check in xgmiitorgmii_probe()
Date: Mon, 15 Aug 2016 22:34:57 +0000
Message-ID: <1471300497-15066-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyj.lk@gmail.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: f.fainelli@gmail.com, michal.simek@xilinx.com,
	soren.brinkmann@xilinx.com, appana.durga.rao@xilinx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33326 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932164AbcHOWfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 18:35:07 -0400
Received: by mail-pf0-f194.google.com with SMTP id i6so4361239pfe.0
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 15:35:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of error, the function of_parse_phandle() returns NULL
pointer not ERR_PTR(). The IS_ERR() test in the return value check
should be replaced with NULL test.

Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>
---
 drivers/net/phy/xilinx_gmii2rgmii.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/xilinx_gmii2rgmii.c b/drivers/net/phy/xilinx_gmii2rgmii.c
index 8e980ad..cad6e19 100644
--- a/drivers/net/phy/xilinx_gmii2rgmii.c
+++ b/drivers/net/phy/xilinx_gmii2rgmii.c
@@ -67,7 +67,7 @@ int xgmiitorgmii_probe(struct mdio_device *mdiodev)
 		return -ENOMEM;
 
 	phy_node = of_parse_phandle(np, "phy-handle", 0);
-	if (IS_ERR(phy_node)) {
+	if (!phy_node) {
 		dev_err(dev, "Couldn't parse phy-handle\n");
 		return -ENODEV;
 	}
