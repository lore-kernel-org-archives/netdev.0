From: Greentime Hu <green.hu@gmail.com>
Subject: [PATCH v5] net: ethernet: faraday: To support device tree usage.
Date: Wed, 17 May 2017 15:28:19 +0800
Message-ID: <20170517072810.GA4324@app09>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: green.hu@gmail.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, andrew@lunn.ch, arnd@arndb.de,
        jiri@resnulli.us, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, robh+dt@kernel.org, mark.rutland@arm.com,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To support device tree usage for ftmac100.

Signed-off-by: Greentime Hu <green.hu@gmail.com>
---
Changes in v5:
  - Nothing changed in this patch and I have committed faraday,ftmac.txt.
Changes in v4:
  - Use the same binding document to describe the same faraday ethernet controller and add faraday to vendor-prefixes.txt.
Changes in v3:
  - Nothing changed in this patch but I have committed andestech to vendor-prefixes.txt.
Changes in v2:
  - Change atmac100_of_ids to ftmac100_of_ids
---
 drivers/net/ethernet/faraday/ftmac100.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/faraday/ftmac100.c b/drivers/net/ethernet/faraday/ftmac100.c
index 6ac336b..1536356 100644
--- a/drivers/net/ethernet/faraday/ftmac100.c
+++ b/drivers/net/ethernet/faraday/ftmac100.c
@@ -1174,11 +1174,17 @@ static int ftmac100_remove(struct platform_device *pdev)
 	return 0;
 }
 
+static const struct of_device_id ftmac100_of_ids[] = {
+	{ .compatible = "andestech,atmac100" },
+	{ }
+};
+
 static struct platform_driver ftmac100_driver = {
 	.probe		= ftmac100_probe,
 	.remove		= ftmac100_remove,
 	.driver		= {
 		.name	= DRV_NAME,
+		.of_match_table = ftmac100_of_ids
 	},
 };
 
@@ -1202,3 +1208,4 @@ static void __exit ftmac100_exit(void)
 MODULE_AUTHOR("Po-Yu Chuang <ratbert@faraday-tech.com>");
 MODULE_DESCRIPTION("FTMAC100 driver");
 MODULE_LICENSE("GPL");
+MODULE_DEVICE_TABLE(of, ftmac100_of_ids);
-- 
1.7.9.5
