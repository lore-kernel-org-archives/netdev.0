From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 24/27] sound/of: don't use deprecated fields in
	of_platform_driver
Date: Thu, 11 Mar 2010 11:24:00 -0700
Message-ID: <20100311182400.13103.45617.stgit__42769.0872959376$1268331909$gmane$org@angua>
References: <20100311181604.13103.30088.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f194.google.com ([209.85.222.194]:49500 "EHLO
	mail-pz0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934254Ab0CKSYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:24:03 -0500
In-Reply-To: <20100311181604.13103.30088.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.name, .match_table and .owner are duplicated in both of_platform_driver
and device_driver, so the of_platform_driver copies will be removed soon.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 sound/soc/fsl/mpc5200_psc_ac97.c |    2 +-
 sound/soc/fsl/mpc5200_psc_i2s.c  |    2 +-
 sound/soc/fsl/mpc8610_hpcd.c     |    8 +++++---
 sound/sparc/amd7930.c            |    7 +++++--
 sound/sparc/cs4231.c             |    7 +++++--
 sound/sparc/dbri.c               |    7 +++++--
 6 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/sound/soc/fsl/mpc5200_psc_ac97.c b/sound/soc/fsl/mpc5200_psc_ac97.c
index 3dbc7f7..e2ee220 100644
--- a/sound/soc/fsl/mpc5200_psc_ac97.c
+++ b/sound/soc/fsl/mpc5200_psc_ac97.c
@@ -317,12 +317,12 @@ static struct of_device_id psc_ac97_match[] __devinitdata = {
 MODULE_DEVICE_TABLE(of, psc_ac97_match);
 
 static struct of_platform_driver psc_ac97_driver = {
-	.match_table = psc_ac97_match,
 	.probe = psc_ac97_of_probe,
 	.remove = __devexit_p(psc_ac97_of_remove),
 	.driver = {
 		.name = "mpc5200-psc-ac97",
 		.owner = THIS_MODULE,
+		.of_match_table = psc_ac97_match,
 	},
 };
 
diff --git a/sound/soc/fsl/mpc5200_psc_i2s.c b/sound/soc/fsl/mpc5200_psc_i2s.c
index ce8de90..f6c507c 100644
--- a/sound/soc/fsl/mpc5200_psc_i2s.c
+++ b/sound/soc/fsl/mpc5200_psc_i2s.c
@@ -220,12 +220,12 @@ static struct of_device_id psc_i2s_match[] __devinitdata = {
 MODULE_DEVICE_TABLE(of, psc_i2s_match);
 
 static struct of_platform_driver psc_i2s_driver = {
-	.match_table = psc_i2s_match,
 	.probe = psc_i2s_of_probe,
 	.remove = __devexit_p(psc_i2s_of_remove),
 	.driver = {
 		.name = "mpc5200-psc-i2s",
 		.owner = THIS_MODULE,
+		.of_match_table = psc_i2s_match,
 	},
 };
 
diff --git a/sound/soc/fsl/mpc8610_hpcd.c b/sound/soc/fsl/mpc8610_hpcd.c
index d7e1b9a..511d721 100644
--- a/sound/soc/fsl/mpc8610_hpcd.c
+++ b/sound/soc/fsl/mpc8610_hpcd.c
@@ -579,9 +579,11 @@ static struct of_device_id mpc8610_hpcd_match[] = {
 MODULE_DEVICE_TABLE(of, mpc8610_hpcd_match);
 
 static struct of_platform_driver mpc8610_hpcd_of_driver = {
-	.owner  	= THIS_MODULE,
-	.name   	= "mpc8610_hpcd",
-	.match_table    = mpc8610_hpcd_match,
+	.driver = {
+		.name = "mpc8610_hpcd",
+		.owner = THIS_MODULE,
+		.of_match_table = mpc8610_hpcd_match,
+	},
 	.probe  	= mpc8610_hpcd_probe,
 	.remove 	= mpc8610_hpcd_remove,
 };
diff --git a/sound/sparc/amd7930.c b/sound/sparc/amd7930.c
index 574af56..71221fd 100644
--- a/sound/sparc/amd7930.c
+++ b/sound/sparc/amd7930.c
@@ -1065,8 +1065,11 @@ static const struct of_device_id amd7930_match[] = {
 };
 
 static struct of_platform_driver amd7930_sbus_driver = {
-	.name		= "audio",
-	.match_table	= amd7930_match,
+	.driver = {
+		.name = "audio",
+		.owner = THIS_MODULE,
+		.of_match_table = amd7930_match,
+	},
 	.probe		= amd7930_sbus_probe,
 };
 
diff --git a/sound/sparc/cs4231.c b/sound/sparc/cs4231.c
index 14cb87c..47db872 100644
--- a/sound/sparc/cs4231.c
+++ b/sound/sparc/cs4231.c
@@ -2110,8 +2110,11 @@ static const struct of_device_id cs4231_match[] = {
 MODULE_DEVICE_TABLE(of, cs4231_match);
 
 static struct of_platform_driver cs4231_driver = {
-	.name		= "audio",
-	.match_table	= cs4231_match,
+	.driver = {
+		.name = "audio",
+		.owner = THIS_MODULE,
+		.of_match_table = cs4231_match,
+	},
 	.probe		= cs4231_probe,
 	.remove		= __devexit_p(cs4231_remove),
 };
diff --git a/sound/sparc/dbri.c b/sound/sparc/dbri.c
index 2734c36..6e5d1dd 100644
--- a/sound/sparc/dbri.c
+++ b/sound/sparc/dbri.c
@@ -2686,8 +2686,11 @@ static const struct of_device_id dbri_match[] = {
 MODULE_DEVICE_TABLE(of, dbri_match);
 
 static struct of_platform_driver dbri_sbus_driver = {
-	.name		= "dbri",
-	.match_table	= dbri_match,
+	.driver = {
+		.name = "dbri",
+		.owner = THIS_MODULE,
+		.of_match_table = dbri_match,
+	},
 	.probe		= dbri_probe,
 	.remove		= __devexit_p(dbri_remove),
 };

