From: Greentime Hu <green.hu@gmail.com>
Subject: [PATCH v4] net: ethernet: faraday: To support device tree usage.
Date: Thu, 5 Jan 2017 18:23:53 +0800
Message-ID: <20170105102345.GA25774@app09>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: f.fainelli@gmail.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, andrew@lunn.ch,
        linux-kernel@vger.kernel.org, jiri@resnulli.us,
        jonas.jensen@gmail.com, davem@davemloft.net, arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Greentime Hu <green.hu@gmail.com>
---
Changes in v4:
  - Use the same binding document to describe the same faraday ethernet controller and add faraday to vendor-prefixes.txt.
Changes in v3:
  - Nothing changed in this patch but I have committed andestech to vendor-prefixes.txt.
Changes in v2:
  - Change atmac100_of_ids to ftmac100_of_ids
      
---
 .../net/{moxa,moxart-mac.txt => faraday,ftmac.txt} |    7 +++++--
 .../devicetree/bindings/vendor-prefixes.txt        |    1 +
 drivers/net/ethernet/faraday/ftmac100.c            |    7 +++++++
 3 files changed, 13 insertions(+), 2 deletions(-)
 rename Documentation/devicetree/bindings/net/{moxa,moxart-mac.txt => faraday,ftmac.txt} (68%)

diff --git a/Documentation/devicetree/bindings/net/moxa,moxart-mac.txt b/Documentation/devicetree/bindings/net/faraday,ftmac.txt
similarity index 68%
rename from Documentation/devicetree/bindings/net/moxa,moxart-mac.txt
rename to Documentation/devicetree/bindings/net/faraday,ftmac.txt
index 583418b..be4f55e 100644
--- a/Documentation/devicetree/bindings/net/moxa,moxart-mac.txt
+++ b/Documentation/devicetree/bindings/net/faraday,ftmac.txt
@@ -1,8 +1,11 @@
-MOXA ART Ethernet Controller
+Faraday Ethernet Controller
 
 Required properties:
 
-- compatible : Must be "moxa,moxart-mac"
+- compatible : Must contain "faraday,ftmac", as well as one of
+		the SoC specific identifiers:
+		"andestech,atmac100"
+		"moxa,moxart-mac"
 - reg : Should contain register location and length
 - interrupts : Should contain the mac interrupt number
 
diff --git a/Documentation/devicetree/bindings/vendor-prefixes.txt b/Documentation/devicetree/bindings/vendor-prefixes.txt
index 16d3b5e..489c336 100644
--- a/Documentation/devicetree/bindings/vendor-prefixes.txt
+++ b/Documentation/devicetree/bindings/vendor-prefixes.txt
@@ -102,6 +102,7 @@ everest	Everest Semiconductor Co. Ltd.
 everspin	Everspin Technologies, Inc.
 excito	Excito
 ezchip	EZchip Semiconductor
+faraday	Faraday Technology Corporation
 fcs	Fairchild Semiconductor
 firefly	Firefly
 focaltech	FocalTech Systems Co.,Ltd
diff --git a/drivers/net/ethernet/faraday/ftmac100.c b/drivers/net/ethernet/faraday/ftmac100.c
index dce5f7b..5d70ee9 100644
--- a/drivers/net/ethernet/faraday/ftmac100.c
+++ b/drivers/net/ethernet/faraday/ftmac100.c
@@ -1172,11 +1172,17 @@ static int __exit ftmac100_remove(struct platform_device *pdev)
 	return 0;
 }
 
+static const struct of_device_id ftmac100_of_ids[] = {
+	{ .compatible = "andestech,atmac100" },
+	{ }
+};
+
 static struct platform_driver ftmac100_driver = {
 	.probe		= ftmac100_probe,
 	.remove		= __exit_p(ftmac100_remove),
 	.driver		= {
 		.name	= DRV_NAME,
+		.of_match_table = ftmac100_of_ids
 	},
 };
 
@@ -1200,3 +1206,4 @@ static void __exit ftmac100_exit(void)
 MODULE_AUTHOR("Po-Yu Chuang <ratbert@faraday-tech.com>");
 MODULE_DESCRIPTION("FTMAC100 driver");
 MODULE_LICENSE("GPL");
+MODULE_DEVICE_TABLE(of, ftmac100_of_ids);
-- 
1.7.9.5
