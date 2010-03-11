From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 04/27] drivers/video/of: don't use deprecated field in
	of_platform_driver
Date: Thu, 11 Mar 2010 11:22:10 -0700
Message-ID: <20100311182209.13103.95923.stgit__36596.6452555314$1268332997$gmane$org@angua>
References: <20100311181604.13103.30088.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:58040 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934111Ab0CKSWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:22:30 -0500
In-Reply-To: <20100311181604.13103.30088.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.name, .match_table and .owner are duplicated in both of_platform_driver
and device_driver, so the of_platform_driver copies will be removed soon.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/video/bw2.c               |    7 +++++--
 drivers/video/cg14.c              |    7 +++++--
 drivers/video/cg3.c               |    7 +++++--
 drivers/video/cg6.c               |    7 +++++--
 drivers/video/ffb.c               |    7 +++++--
 drivers/video/fsl-diu-fb.c        |    8 +++++---
 drivers/video/leo.c               |    7 +++++--
 drivers/video/mb862xx/mb862xxfb.c |    8 +++++---
 drivers/video/p9100.c             |    7 +++++--
 drivers/video/platinumfb.c        |    7 +++++--
 drivers/video/tcx.c               |    7 +++++--
 drivers/video/xilinxfb.c          |    5 ++---
 12 files changed, 57 insertions(+), 27 deletions(-)

diff --git a/drivers/video/bw2.c b/drivers/video/bw2.c
index b0b147c..05d6663 100644
--- a/drivers/video/bw2.c
+++ b/drivers/video/bw2.c
@@ -377,8 +377,11 @@ static const struct of_device_id bw2_match[] = {
 MODULE_DEVICE_TABLE(of, bw2_match);
 
 static struct of_platform_driver bw2_driver = {
-	.name		= "bw2",
-	.match_table	= bw2_match,
+	.driver = {
+		.name = "bw2",
+		.owner = THIS_MODULE,
+		.of_match_table = bw2_match,
+	},
 	.probe		= bw2_probe,
 	.remove		= __devexit_p(bw2_remove),
 };
diff --git a/drivers/video/cg14.c b/drivers/video/cg14.c
index fe45a3b..5634131 100644
--- a/drivers/video/cg14.c
+++ b/drivers/video/cg14.c
@@ -597,8 +597,11 @@ static const struct of_device_id cg14_match[] = {
 MODULE_DEVICE_TABLE(of, cg14_match);
 
 static struct of_platform_driver cg14_driver = {
-	.name		= "cg14",
-	.match_table	= cg14_match,
+	.driver = {
+		.name = "cg14",
+		.owner = THIS_MODULE,
+		.of_match_table = cg14_match,
+	},
 	.probe		= cg14_probe,
 	.remove		= __devexit_p(cg14_remove),
 };
diff --git a/drivers/video/cg3.c b/drivers/video/cg3.c
index b2319fa..a807823 100644
--- a/drivers/video/cg3.c
+++ b/drivers/video/cg3.c
@@ -464,8 +464,11 @@ static const struct of_device_id cg3_match[] = {
 MODULE_DEVICE_TABLE(of, cg3_match);
 
 static struct of_platform_driver cg3_driver = {
-	.name		= "cg3",
-	.match_table	= cg3_match,
+	.driver = {
+		.name = "cg3",
+		.owner = THIS_MODULE,
+		.of_match_table = cg3_match,
+	},
 	.probe		= cg3_probe,
 	.remove		= __devexit_p(cg3_remove),
 };
diff --git a/drivers/video/cg6.c b/drivers/video/cg6.c
index 978c15f..ecfcf69 100644
--- a/drivers/video/cg6.c
+++ b/drivers/video/cg6.c
@@ -857,8 +857,11 @@ static const struct of_device_id cg6_match[] = {
 MODULE_DEVICE_TABLE(of, cg6_match);
 
 static struct of_platform_driver cg6_driver = {
-	.name		= "cg6",
-	.match_table	= cg6_match,
+	.driver = {
+		.name = "cg6",
+		.owner = THIS_MODULE,
+		.of_match_table = cg6_match,
+	},
 	.probe		= cg6_probe,
 	.remove		= __devexit_p(cg6_remove),
 };
diff --git a/drivers/video/ffb.c b/drivers/video/ffb.c
index be0c982..d1a9515 100644
--- a/drivers/video/ffb.c
+++ b/drivers/video/ffb.c
@@ -1054,8 +1054,11 @@ static const struct of_device_id ffb_match[] = {
 MODULE_DEVICE_TABLE(of, ffb_match);
 
 static struct of_platform_driver ffb_driver = {
-	.name		= "ffb",
-	.match_table	= ffb_match,
+	.driver = {
+		.name = "ffb",
+		.owner = THIS_MODULE,
+		.of_match_table = ffb_match,
+	},
 	.probe		= ffb_probe,
 	.remove		= __devexit_p(ffb_remove),
 };
diff --git a/drivers/video/fsl-diu-fb.c b/drivers/video/fsl-diu-fb.c
index 4637bcb..94ac2c0 100644
--- a/drivers/video/fsl-diu-fb.c
+++ b/drivers/video/fsl-diu-fb.c
@@ -1646,9 +1646,11 @@ static struct of_device_id fsl_diu_match[] = {
 MODULE_DEVICE_TABLE(of, fsl_diu_match);
 
 static struct of_platform_driver fsl_diu_driver = {
-	.owner  	= THIS_MODULE,
-	.name   	= "fsl_diu",
-	.match_table    = fsl_diu_match,
+	.driver = {
+		.name = "fsl_diu",
+		.owner = THIS_MODULE,
+		.of_match_table = fsl_diu_match,
+	},
 	.probe  	= fsl_diu_probe,
 	.remove 	= fsl_diu_remove,
 	.suspend	= fsl_diu_suspend,
diff --git a/drivers/video/leo.c b/drivers/video/leo.c
index e145e2d..cf79cb7 100644
--- a/drivers/video/leo.c
+++ b/drivers/video/leo.c
@@ -664,8 +664,11 @@ static const struct of_device_id leo_match[] = {
 MODULE_DEVICE_TABLE(of, leo_match);
 
 static struct of_platform_driver leo_driver = {
-	.name		= "leo",
-	.match_table	= leo_match,
+	.driver = {
+		.name = "leo",
+		.owner = THIS_MODULE,
+		.of_match_table = leo_match,
+	},
 	.probe		= leo_probe,
 	.remove		= __devexit_p(leo_remove),
 };
diff --git a/drivers/video/mb862xx/mb862xxfb.c b/drivers/video/mb862xx/mb862xxfb.c
index fabb0c5..664665c 100644
--- a/drivers/video/mb862xx/mb862xxfb.c
+++ b/drivers/video/mb862xx/mb862xxfb.c
@@ -731,9 +731,11 @@ static struct of_device_id __devinitdata of_platform_mb862xx_tbl[] = {
 };
 
 static struct of_platform_driver of_platform_mb862xxfb_driver = {
-	.owner		= THIS_MODULE,
-	.name		= DRV_NAME,
-	.match_table	= of_platform_mb862xx_tbl,
+	.driver = {
+		.name = DRV_NAME,
+		.owner = THIS_MODULE,
+		.of_match_table = of_platform_mb862xx_tbl,
+	},
 	.probe		= of_platform_mb862xx_probe,
 	.remove		= __devexit_p(of_platform_mb862xx_remove),
 };
diff --git a/drivers/video/p9100.c b/drivers/video/p9100.c
index 7fa4ab0..cf67b99 100644
--- a/drivers/video/p9100.c
+++ b/drivers/video/p9100.c
@@ -354,8 +354,11 @@ static const struct of_device_id p9100_match[] = {
 MODULE_DEVICE_TABLE(of, p9100_match);
 
 static struct of_platform_driver p9100_driver = {
-	.name		= "p9100",
-	.match_table	= p9100_match,
+	.driver = {
+		.name = "p9100",
+		.owner = THIS_MODULE,
+		.of_match_table = p9100_match,
+	},
 	.probe		= p9100_probe,
 	.remove		= __devexit_p(p9100_remove),
 };
diff --git a/drivers/video/platinumfb.c b/drivers/video/platinumfb.c
index 0a366d8..af04cca 100644
--- a/drivers/video/platinumfb.c
+++ b/drivers/video/platinumfb.c
@@ -680,8 +680,11 @@ static struct of_device_id platinumfb_match[] =
 
 static struct of_platform_driver platinum_driver = 
 {
-	.name 		= "platinumfb",
-	.match_table	= platinumfb_match,
+	.driver = {
+		.name = "platinumfb",
+		.owner = THIS_MODULE,
+		.of_match_table = platinumfb_match,
+	},
 	.probe		= platinumfb_probe,
 	.remove		= platinumfb_remove,
 };
diff --git a/drivers/video/tcx.c b/drivers/video/tcx.c
index 45b8835..1140dd0 100644
--- a/drivers/video/tcx.c
+++ b/drivers/video/tcx.c
@@ -513,8 +513,11 @@ static const struct of_device_id tcx_match[] = {
 MODULE_DEVICE_TABLE(of, tcx_match);
 
 static struct of_platform_driver tcx_driver = {
-	.name		= "tcx",
-	.match_table	= tcx_match,
+	.driver = {
+		.name = "tcx",
+		.owner = THIS_MODULE,
+		.of_match_table = tcx_match,
+	},
 	.probe		= tcx_probe,
 	.remove		= __devexit_p(tcx_remove),
 };
diff --git a/drivers/video/xilinxfb.c b/drivers/video/xilinxfb.c
index ed7c8d0..d7654ab 100644
--- a/drivers/video/xilinxfb.c
+++ b/drivers/video/xilinxfb.c
@@ -491,13 +491,12 @@ static struct of_device_id xilinxfb_of_match[] __devinitdata = {
 MODULE_DEVICE_TABLE(of, xilinxfb_of_match);
 
 static struct of_platform_driver xilinxfb_of_driver = {
-	.owner = THIS_MODULE,
-	.name = DRIVER_NAME,
-	.match_table = xilinxfb_of_match,
 	.probe = xilinxfb_of_probe,
 	.remove = __devexit_p(xilinxfb_of_remove),
 	.driver = {
 		.name = DRIVER_NAME,
+		.owner = THIS_MODULE,
+		.of_match_table = xilinxfb_of_match,
 	},
 };
 

