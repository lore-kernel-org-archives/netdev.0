From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 06/27] drivers/block/of: don't use deprecated field in
	of_platform_driver
Date: Thu, 11 Mar 2010 11:22:21 -0700
Message-ID: <20100311182220.13103.76284.stgit__38820.750572677$1268332983$gmane$org@angua>
References: <20100311181604.13103.30088.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:52515 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934085Ab0CKSWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:22:33 -0500
In-Reply-To: <20100311181604.13103.30088.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.name, .match_table and .owner are duplicated in both of_platform_driver
and device_driver, so the of_platform_driver copies will be removed soon.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/ata/pata_of_platform.c |    7 +++++--
 drivers/ata/sata_fsl.c         |    7 +++++--
 drivers/block/xsysace.c        |    5 ++---
 3 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/ata/pata_of_platform.c b/drivers/ata/pata_of_platform.c
index 19da29f..5a1b82c 100644
--- a/drivers/ata/pata_of_platform.c
+++ b/drivers/ata/pata_of_platform.c
@@ -91,8 +91,11 @@ static struct of_device_id pata_of_platform_match[] = {
 MODULE_DEVICE_TABLE(of, pata_of_platform_match);
 
 static struct of_platform_driver pata_of_platform_driver = {
-	.name		= "pata_of_platform",
-	.match_table	= pata_of_platform_match,
+	.driver = {
+		.name = "pata_of_platform",
+		.owner = THIS_MODULE,
+		.of_match_table = pata_of_platform_match,
+	},
 	.probe		= pata_of_platform_probe,
 	.remove		= __devexit_p(pata_of_platform_remove),
 };
diff --git a/drivers/ata/sata_fsl.c b/drivers/ata/sata_fsl.c
index ce4136e..463fb9c 100644
--- a/drivers/ata/sata_fsl.c
+++ b/drivers/ata/sata_fsl.c
@@ -1426,8 +1426,11 @@ static struct of_device_id fsl_sata_match[] = {
 MODULE_DEVICE_TABLE(of, fsl_sata_match);
 
 static struct of_platform_driver fsl_sata_driver = {
-	.name		= "fsl-sata",
-	.match_table	= fsl_sata_match,
+	.driver = {
+		.name = "fsl-sata",
+		.owner = THIS_MODULE,
+		.of_match_table = fsl_sata_match,
+	},
 	.probe		= sata_fsl_probe,
 	.remove		= sata_fsl_remove,
 #ifdef CONFIG_PM
diff --git a/drivers/block/xsysace.c b/drivers/block/xsysace.c
index e1c95e2..cffcd71 100644
--- a/drivers/block/xsysace.c
+++ b/drivers/block/xsysace.c
@@ -1237,13 +1237,12 @@ static const struct of_device_id ace_of_match[] __devinitconst = {
 MODULE_DEVICE_TABLE(of, ace_of_match);
 
 static struct of_platform_driver ace_of_driver = {
-	.owner = THIS_MODULE,
-	.name = "xsysace",
-	.match_table = ace_of_match,
 	.probe = ace_of_probe,
 	.remove = __devexit_p(ace_of_remove),
 	.driver = {
 		.name = "xsysace",
+		.owner = THIS_MODULE,
+		.of_match_table = ace_of_match,
 	},
 };
 

