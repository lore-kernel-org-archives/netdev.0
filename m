From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 12/27] drivers/mtd/of: don't use deprecated field in
	of_platform_driver
Date: Thu, 11 Mar 2010 11:22:54 -0700
Message-ID: <20100311182253.13103.92479.stgit__23549.378073267$1268332341$gmane$org@angua>
References: <20100311181604.13103.30088.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f198.google.com ([209.85.216.198]:64662 "EHLO
	mail-px0-f198.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755568Ab0CKSbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:31:10 -0500
In-Reply-To: <20100311181604.13103.30088.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.name, .match_table and .owner are duplicated in both of_platform_driver
and device_driver, so the of_platform_driver copies will be removed soon.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/mtd/maps/physmap_of.c    |    7 +++++--
 drivers/mtd/maps/sun_uflash.c    |    7 +++++--
 drivers/mtd/nand/fsl_elbc_nand.c |    5 +++--
 drivers/mtd/nand/fsl_upm.c       |    7 +++++--
 drivers/mtd/nand/ndfc.c          |    5 +++--
 drivers/mtd/nand/pasemi_nand.c   |    7 +++++--
 drivers/mtd/nand/socrates_nand.c |    7 +++++--
 7 files changed, 31 insertions(+), 14 deletions(-)

diff --git a/drivers/mtd/maps/physmap_of.c b/drivers/mtd/maps/physmap_of.c
index 494af8e..997ee62 100644
--- a/drivers/mtd/maps/physmap_of.c
+++ b/drivers/mtd/maps/physmap_of.c
@@ -374,8 +374,11 @@ static struct of_device_id of_flash_match[] = {
 MODULE_DEVICE_TABLE(of, of_flash_match);
 
 static struct of_platform_driver of_flash_driver = {
-	.name		= "of-flash",
-	.match_table	= of_flash_match,
+	.driver = {
+		.name = "of-flash",
+		.owner = THIS_MODULE,
+		.of_match_table = of_flash_match,
+	},
 	.probe		= of_flash_probe,
 	.remove		= of_flash_remove,
 };
diff --git a/drivers/mtd/maps/sun_uflash.c b/drivers/mtd/maps/sun_uflash.c
index 365811d..b27be02 100644
--- a/drivers/mtd/maps/sun_uflash.c
+++ b/drivers/mtd/maps/sun_uflash.c
@@ -148,8 +148,11 @@ static const struct of_device_id uflash_match[] = {
 MODULE_DEVICE_TABLE(of, uflash_match);
 
 static struct of_platform_driver uflash_driver = {
-	.name		= DRIVER_NAME,
-	.match_table	= uflash_match,
+	.driver = {
+		.name = DRIVER_NAME,
+		.owner = THIS_MODULE,
+		.of_match_table = uflash_match,
+	},
 	.probe		= uflash_probe,
 	.remove		= __devexit_p(uflash_remove),
 };
diff --git a/drivers/mtd/nand/fsl_elbc_nand.c b/drivers/mtd/nand/fsl_elbc_nand.c
index 4a60795..f45a8d0 100644
--- a/drivers/mtd/nand/fsl_elbc_nand.c
+++ b/drivers/mtd/nand/fsl_elbc_nand.c
@@ -1078,9 +1078,10 @@ static const struct of_device_id fsl_elbc_match[] = {
 
 static struct of_platform_driver fsl_elbc_ctrl_driver = {
 	.driver = {
-		.name	= "fsl-elbc",
+		.name = "fsl-elbc",
+		.owner = THIS_MODULE,
+		.of_match_table = fsl_elbc_match,
 	},
-	.match_table = fsl_elbc_match,
 	.probe = fsl_elbc_ctrl_probe,
 	.remove = fsl_elbc_ctrl_remove,
 };
diff --git a/drivers/mtd/nand/fsl_upm.c b/drivers/mtd/nand/fsl_upm.c
index 071a60c..8dcbb18 100644
--- a/drivers/mtd/nand/fsl_upm.c
+++ b/drivers/mtd/nand/fsl_upm.c
@@ -356,8 +356,11 @@ static struct of_device_id of_fun_match[] = {
 MODULE_DEVICE_TABLE(of, of_fun_match);
 
 static struct of_platform_driver of_fun_driver = {
-	.name		= "fsl,upm-nand",
-	.match_table	= of_fun_match,
+	.driver = {
+		.name = "fsl,upm-nand",
+		.owner = THIS_MODULE,
+		.of_match_table = of_fun_match,
+	},
 	.probe		= fun_probe,
 	.remove		= __devexit_p(fun_remove),
 };
diff --git a/drivers/mtd/nand/ndfc.c b/drivers/mtd/nand/ndfc.c
index 40b5658..19d94a2 100644
--- a/drivers/mtd/nand/ndfc.c
+++ b/drivers/mtd/nand/ndfc.c
@@ -293,9 +293,10 @@ MODULE_DEVICE_TABLE(of, ndfc_match);
 
 static struct of_platform_driver ndfc_driver = {
 	.driver = {
-		.name	= "ndfc",
+		.name = "ndfc",
+		.owner = THIS_MODULE,
+		.of_match_table = ndfc_match,
 	},
-	.match_table = ndfc_match,
 	.probe = ndfc_probe,
 	.remove = __devexit_p(ndfc_remove),
 };
diff --git a/drivers/mtd/nand/pasemi_nand.c b/drivers/mtd/nand/pasemi_nand.c
index edfc27b..a97e9c9 100644
--- a/drivers/mtd/nand/pasemi_nand.c
+++ b/drivers/mtd/nand/pasemi_nand.c
@@ -221,8 +221,11 @@ MODULE_DEVICE_TABLE(of, pasemi_nand_match);
 
 static struct of_platform_driver pasemi_nand_driver =
 {
-	.name		= (char*)driver_name,
-	.match_table	= pasemi_nand_match,
+	.driver = {
+		.name = (char*)driver_name,
+		.owner = THIS_MODULE,
+		.of_match_table = pasemi_nand_match,
+	},
 	.probe		= pasemi_nand_probe,
 	.remove		= pasemi_nand_remove,
 };
diff --git a/drivers/mtd/nand/socrates_nand.c b/drivers/mtd/nand/socrates_nand.c
index a4519a7..edb9b13 100644
--- a/drivers/mtd/nand/socrates_nand.c
+++ b/drivers/mtd/nand/socrates_nand.c
@@ -301,8 +301,11 @@ static struct of_device_id socrates_nand_match[] =
 MODULE_DEVICE_TABLE(of, socrates_nand_match);
 
 static struct of_platform_driver socrates_nand_driver = {
-	.name		= "socrates_nand",
-	.match_table	= socrates_nand_match,
+	.driver = {
+		.name = "socrates_nand",
+		.owner = THIS_MODULE,
+		.of_match_table = socrates_nand_match,
+	},
 	.probe		= socrates_nand_probe,
 	.remove		= __devexit_p(socrates_nand_remove),
 };

