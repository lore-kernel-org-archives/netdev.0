From: Greentime Hu <green.hu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v4] net: ethernet: faraday: To support device tree usage.
Date: Tue, 24 Jan 2017 16:46:14 +0800
Message-ID: <20170124084606.GA11764@app09>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
        arnd-r2nGTMty4D4@public.gmane.org, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We also use the same binding document to describe the same faraday ethernet
controller and add faraday to vendor-prefixes.txt.

Signed-off-by: Greentime Hu <green.hu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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
 MODULE_AUTHOR("Po-Yu Chuang <ratbert-w0jeGXs5+AWXmMXjJBpWqg@public.gmane.org>");
 MODULE_DESCRIPTION("FTMAC100 driver");
 MODULE_LICENSE("GPL");
+MODULE_DEVICE_TABLE(of, ftmac100_of_ids);
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
