From: Dongpo Li <lidongpo@hisilicon.com>
Subject: [PATCH v2 1/4] net: hix5hd2_gmac: add generic compatible string
Date: Mon, 5 Dec 2016 21:27:58 +0800
Message-ID: <1480944481-118803-2-git-send-email-lidongpo@hisilicon.com>
References: <1480944481-118803-1-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xuejiancheng@hisilicon.com>, <benjamin.chenhao@hisilicon.com>,
        <caizhiyong@hisilicon.com>, <netdev@vger.kernel.org>,
        <devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Dongpo Li <lidongpo@hisilicon.com>
To: <robh+dt@kernel.org>, <mark.rutland@arm.com>,
        <mturquette@baylibre.com>, <sboyd@codeaurora.org>,
        <linux@armlinux.org.uk>, <zhangfei.gao@linaro.org>,
        <yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
        <davem@davemloft.net>, <arnd@arndb.de>, <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:61902 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751786AbcLENf0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 08:35:26 -0500
In-Reply-To: <1480944481-118803-1-git-send-email-lidongpo@hisilicon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The "hix5hd2" is SoC name, add the generic ethernet driver name.
The "hisi-gemac-v1" is the basic version and "hisi-gemac-v2" adds
the SG/TXCSUM/TSO/UFO features.

Signed-off-by: Dongpo Li <lidongpo@hisilicon.com>
---
 .../devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt    |  9 +++++++--
 drivers/net/ethernet/hisilicon/hix5hd2_gmac.c             | 15 +++++++++++----
 2 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
index 75d398b..75920f0 100644
--- a/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
+++ b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
@@ -1,7 +1,12 @@
 Hisilicon hix5hd2 gmac controller
 
 Required properties:
-- compatible: should be "hisilicon,hix5hd2-gmac".
+- compatible: should contain one of the following SoC strings:
+	* "hisilicon,hix5hd2-gemac"
+	* "hisilicon,hi3798cv200-gemac"
+	and one of the following version string:
+	* "hisilicon,hisi-gemac-v1"
+	* "hisilicon,hisi-gemac-v2"
 - reg: specifies base physical address(s) and size of the device registers.
   The first region is the MAC register base and size.
   The second region is external interface control register.
@@ -20,7 +25,7 @@ Required properties:
 
 Example:
 	gmac0: ethernet@f9840000 {
-		compatible = "hisilicon,hix5hd2-gmac";
+		compatible = "hisilicon,hix5hd2-gemac", "hisilicon,hisi-gemac-v1";
 		reg = <0xf9840000 0x1000>,<0xf984300c 0x4>;
 		interrupts = <0 71 4>;
 		#address-cells = <1>;
diff --git a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
index e69a6be..27cb2e6 100644
--- a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
@@ -189,6 +189,10 @@
 #define dma_cnt(n)			((n) >> 5)
 #define dma_byte(n)			((n) << 5)
 
+#define HW_CAP_TSO			BIT(0)
+#define GEMAC_V1			0
+#define GEMAC_V2			(GEMAC_V1 | HW_CAP_TSO)
+
 struct hix5hd2_desc {
 	__le32 buff_addr;
 	__le32 cmd;
@@ -1021,7 +1025,10 @@ static int hix5hd2_dev_remove(struct platform_device *pdev)
 }
 
 static const struct of_device_id hix5hd2_of_match[] = {
-	{.compatible = "hisilicon,hix5hd2-gmac",},
+	{ .compatible = "hisilicon,hisi-gemac-v1", .data = (void *)GEMAC_V1 },
+	{ .compatible = "hisilicon,hisi-gemac-v2", .data = (void *)GEMAC_V2 },
+	{ .compatible = "hisilicon,hix5hd2-gemac", .data = (void *)GEMAC_V1 },
+	{ .compatible = "hisilicon,hi3798cv200-gemac", .data = (void *)GEMAC_V2 },
 	{},
 };
 
@@ -1029,7 +1036,7 @@ MODULE_DEVICE_TABLE(of, hix5hd2_of_match);
 
 static struct platform_driver hix5hd2_dev_driver = {
 	.driver = {
-		.name = "hix5hd2-gmac",
+		.name = "hisi-gemac",
 		.of_match_table = hix5hd2_of_match,
 	},
 	.probe = hix5hd2_dev_probe,
@@ -1038,6 +1045,6 @@ static struct platform_driver hix5hd2_dev_driver = {
 
 module_platform_driver(hix5hd2_dev_driver);
 
-MODULE_DESCRIPTION("HISILICON HIX5HD2 Ethernet driver");
+MODULE_DESCRIPTION("HISILICON Gigabit Ethernet MAC driver");
 MODULE_LICENSE("GPL v2");
-MODULE_ALIAS("platform:hix5hd2-gmac");
+MODULE_ALIAS("platform:hisi-gemac");
-- 
2.8.2
