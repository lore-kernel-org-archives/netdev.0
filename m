From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv3 net-next 08/22] net: mvpp2: add hw_version field in "struct mvpp2"
Date: Tue,  7 Mar 2017 16:53:06 +0100
Message-ID: <1488902000-2658-9-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1488902000-2658-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        linux-arm-kernel@lists.infradead.org,
        Russell King <linux@arm.linux.org.uk>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
        Ian Campbell <ijc+devicetree@hellion.org.uk>,
        Pawel Moll <pawel.moll@arm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Kumar Gala <galak@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:32845 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754750AbdCGP4k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 10:56:40 -0500
In-Reply-To: <1488902000-2658-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation to the introduction for the support of PPv2.2 in the
mvpp2 driver, this commit adds a hw_version field to the struct
mvpp2, and uses the .data field of the DT match table to fill it in.

Having the MVPP21 and MVPP22 definitions available will allow to start
adding the necessary conditional code to support PPv2.2.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 2ee066b..27d8838 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -25,6 +25,7 @@
 #include <linux/of_mdio.h>
 #include <linux/of_net.h>
 #include <linux/of_address.h>
+#include <linux/of_device.h>
 #include <linux/phy.h>
 #include <linux/clk.h>
 #include <linux/hrtimer.h>
@@ -643,6 +644,9 @@ struct mvpp2 {
 
 	/* Tclk value */
 	u32 tclk;
+
+	/* HW version */
+	enum { MVPP21, MVPP22 } hw_version;
 };
 
 struct mvpp2_pcpu_stats {
@@ -6429,6 +6433,9 @@ static int mvpp2_probe(struct platform_device *pdev)
 	if (!priv)
 		return -ENOMEM;
 
+	priv->hw_version =
+		(unsigned long)of_device_get_match_data(&pdev->dev);
+
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	priv->base = devm_ioremap_resource(&pdev->dev, res);
 	if (IS_ERR(priv->base))
@@ -6533,7 +6540,10 @@ static int mvpp2_remove(struct platform_device *pdev)
 }
 
 static const struct of_device_id mvpp2_match[] = {
-	{ .compatible = "marvell,armada-375-pp2" },
+	{
+		.compatible = "marvell,armada-375-pp2",
+		.data = (void *)MVPP21,
+	},
 	{ }
 };
 MODULE_DEVICE_TABLE(of, mvpp2_match);
-- 
2.7.4
