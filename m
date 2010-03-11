From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 11/27] drivers/macintosh/of: don't use deprecated field in
	of_platform_driver
Date: Thu, 11 Mar 2010 11:22:48 -0700
Message-ID: <20100311182248.13103.6111.stgit__46953.7320117981$1268332877$gmane$org@angua>
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
	with ESMTP id S934107Ab0CKSWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:22:51 -0500
In-Reply-To: <20100311181604.13103.30088.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.name, .match_table and .owner are duplicated in both of_platform_driver
and device_driver, so the of_platform_driver copies will be removed soon.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/macintosh/smu.c              |    7 +++++--
 drivers/macintosh/therm_pm72.c       |    7 +++++--
 drivers/macintosh/therm_windtunnel.c |    7 +++++--
 3 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/drivers/macintosh/smu.c b/drivers/macintosh/smu.c
index f96feeb..4e912b2 100644
--- a/drivers/macintosh/smu.c
+++ b/drivers/macintosh/smu.c
@@ -670,8 +670,11 @@ static const struct of_device_id smu_platform_match[] =
 
 static struct of_platform_driver smu_of_platform_driver =
 {
-	.name 		= "smu",
-	.match_table	= smu_platform_match,
+	.driver = {
+		.name = "smu",
+		.owner = THIS_MODULE,
+		.of_match_table = smu_platform_match,
+	},
 	.probe		= smu_platform_probe,
 };
 
diff --git a/drivers/macintosh/therm_pm72.c b/drivers/macintosh/therm_pm72.c
index f5b0f9e..c99f937 100644
--- a/drivers/macintosh/therm_pm72.c
+++ b/drivers/macintosh/therm_pm72.c
@@ -2221,8 +2221,11 @@ static const struct of_device_id fcu_match[] =
 
 static struct of_platform_driver fcu_of_platform_driver = 
 {
-	.name 		= "temperature",
-	.match_table	= fcu_match,
+	.driver = {
+		.name = "temperature",
+		.owner = THIS_MODULE,
+		.of_match_table = fcu_match,
+	},
 	.probe		= fcu_of_probe,
 	.remove		= fcu_of_remove
 };
diff --git a/drivers/macintosh/therm_windtunnel.c b/drivers/macintosh/therm_windtunnel.c
index 7fb8b4d..dc6a47a 100644
--- a/drivers/macintosh/therm_windtunnel.c
+++ b/drivers/macintosh/therm_windtunnel.c
@@ -464,8 +464,11 @@ static const struct of_device_id therm_of_match[] = {{
 };
 
 static struct of_platform_driver therm_of_driver = {
-	.name		= "temperature",
-	.match_table	= therm_of_match,
+	.driver = {
+		.name = "temperature",
+		.owner = THIS_MODULE,
+		.of_match_table = therm_of_match,
+	},
 	.probe		= therm_of_probe,
 	.remove		= therm_of_remove,
 };

