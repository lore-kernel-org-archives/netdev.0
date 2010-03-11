From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 08/27] drivers/crypto/of: don't use deprecated field in
	of_platform_driver
Date: Thu, 11 Mar 2010 11:22:32 -0700
Message-ID: <20100311182231.13103.47091.stgit__32321.7649980963$1268332992$gmane$org@angua>
References: <20100311181604.13103.30088.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f194.google.com ([209.85.222.194]:61349 "EHLO
	mail-pz0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934126Ab0CKSWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:22:41 -0500
In-Reply-To: <20100311181604.13103.30088.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.name, .match_table and .owner are duplicated in both of_platform_driver
and device_driver, so the of_platform_driver copies will be removed soon.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/crypto/amcc/crypto4xx_core.c |    7 +++++--
 drivers/crypto/talitos.c             |    7 +++++--
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/crypto/amcc/crypto4xx_core.c b/drivers/crypto/amcc/crypto4xx_core.c
index 1c3849f..36b5fb1 100644
--- a/drivers/crypto/amcc/crypto4xx_core.c
+++ b/drivers/crypto/amcc/crypto4xx_core.c
@@ -1280,8 +1280,11 @@ static const struct of_device_id crypto4xx_match[] = {
 };
 
 static struct of_platform_driver crypto4xx_driver = {
-	.name		= "crypto4xx",
-	.match_table	= crypto4xx_match,
+	.driver = {
+		.name = "crypto4xx",
+		.owner = THIS_MODULE,
+		.of_match_table = crypto4xx_match,
+	},
 	.probe		= crypto4xx_probe,
 	.remove		= crypto4xx_remove,
 };
diff --git a/drivers/crypto/talitos.c b/drivers/crypto/talitos.c
index fd529d6..917faf7 100644
--- a/drivers/crypto/talitos.c
+++ b/drivers/crypto/talitos.c
@@ -1967,8 +1967,11 @@ static const struct of_device_id talitos_match[] = {
 MODULE_DEVICE_TABLE(of, talitos_match);
 
 static struct of_platform_driver talitos_driver = {
-	.name = "talitos",
-	.match_table = talitos_match,
+	.driver = {
+		.name = "talitos",
+		.owner = THIS_MODULE,
+		.of_match_table = talitos_match,
+	},
 	.probe = talitos_probe,
 	.remove = talitos_remove,
 };

