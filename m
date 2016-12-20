From: Dongpo Li <lidongpo@hisilicon.com>
Subject: [PATCH 1/2] net: hix5hd2_gmac: fix compatible strings name
Date: Tue, 20 Dec 2016 10:09:28 +0800
Message-ID: <1482199769-106501-2-git-send-email-lidongpo@hisilicon.com>
References: <1482199769-106501-1-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xuejiancheng@hisilicon.com>, <benjamin.chenhao@hisilicon.com>,
        <caizhiyong@hisilicon.com>, <netdev@vger.kernel.org>,
        <devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Dongpo Li <lidongpo@hisilicon.com>
To: <robh+dt@kernel.org>, <mark.rutland@arm.com>,
        <linux@armlinux.org.uk>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <davem@davemloft.net>, <arnd@arndb.de>,
        <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482199769-106501-1-git-send-email-lidongpo@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The SoC hix5hd2 compatible string has the suffix "-gmac" and
we should not change its compatible string.
So we should name all the compatible string with the suffix "-gmac".
Creating a new name suffix "-gemac" is unnecessary.

We also add another SoC compatible string in dt binding documentation
and describe which generic version the SoC belongs to.

Fixes: d0fb6ba75dc0 ("net: hix5hd2_gmac: add generic compatible string")
Signed-off-by: Dongpo Li <lidongpo@hisilicon.com>
---
 .../devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt      | 13 ++++++++-----
 drivers/net/ethernet/hisilicon/hix5hd2_gmac.c               | 13 +++++++------
 2 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
index 063c02d..eea73ad 100644
--- a/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
+++ b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
@@ -2,11 +2,14 @@ Hisilicon hix5hd2 gmac controller
 
 Required properties:
 - compatible: should contain one of the following SoC strings:
-	* "hisilicon,hix5hd2-gemac"
-	* "hisilicon,hi3798cv200-gemac"
+	* "hisilicon,hix5hd2-gmac"
+	* "hisilicon,hi3798cv200-gmac"
+	* "hisilicon,hi3516a-gmac"
 	and one of the following version string:
-	* "hisilicon,hisi-gemac-v1"
-	* "hisilicon,hisi-gemac-v2"
+	* "hisilicon,hisi-gmac-v1"
+	* "hisilicon,hisi-gmac-v2"
+  The version v1 includes SoCs hix5hd2.
+  The version v2 includes SoCs hi3798cv200, hi3516a.
 - reg: specifies base physical address(s) and size of the device registers.
   The first region is the MAC register base and size.
   The second region is external interface control register.
@@ -35,7 +38,7 @@ Required properties:
 
 Example:
 	gmac0: ethernet@f9840000 {
-		compatible = "hisilicon,hi3798cv200-gemac", "hisilicon,hisi-gemac-v2";
+		compatible = "hisilicon,hi3798cv200-gmac", "hisilicon,hisi-gmac-v2";
 		reg = <0xf9840000 0x1000>,<0xf984300c 0x4>;
 		interrupts = <0 71 4>;
 		#address-cells = <1>;
diff --git a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
index ee7e9ce..418ca1f3 100644
--- a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
@@ -1316,10 +1316,11 @@ static int hix5hd2_dev_remove(struct platform_device *pdev)
 }
 
 static const struct of_device_id hix5hd2_of_match[] = {
-	{ .compatible = "hisilicon,hisi-gemac-v1", .data = (void *)GEMAC_V1 },
-	{ .compatible = "hisilicon,hisi-gemac-v2", .data = (void *)GEMAC_V2 },
-	{ .compatible = "hisilicon,hix5hd2-gemac", .data = (void *)GEMAC_V1 },
-	{ .compatible = "hisilicon,hi3798cv200-gemac", .data = (void *)GEMAC_V2 },
+	{ .compatible = "hisilicon,hisi-gmac-v1", .data = (void *)GEMAC_V1 },
+	{ .compatible = "hisilicon,hisi-gmac-v2", .data = (void *)GEMAC_V2 },
+	{ .compatible = "hisilicon,hix5hd2-gmac", .data = (void *)GEMAC_V1 },
+	{ .compatible = "hisilicon,hi3798cv200-gmac", .data = (void *)GEMAC_V2 },
+	{ .compatible = "hisilicon,hi3516a-gmac", .data = (void *)GEMAC_V2 },
 	{},
 };
 
@@ -1327,7 +1328,7 @@ MODULE_DEVICE_TABLE(of, hix5hd2_of_match);
 
 static struct platform_driver hix5hd2_dev_driver = {
 	.driver = {
-		.name = "hisi-gemac",
+		.name = "hisi-gmac",
 		.of_match_table = hix5hd2_of_match,
 	},
 	.probe = hix5hd2_dev_probe,
@@ -1338,4 +1339,4 @@ module_platform_driver(hix5hd2_dev_driver);
 
 MODULE_DESCRIPTION("HISILICON Gigabit Ethernet MAC driver");
 MODULE_LICENSE("GPL v2");
-MODULE_ALIAS("platform:hisi-gemac");
+MODULE_ALIAS("platform:hisi-gmac");
-- 
2.8.2
