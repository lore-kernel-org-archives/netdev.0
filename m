From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 21/27] drivers/hwmon/of: don't use deprecated field in
	of_platform_driver
Date: Thu, 11 Mar 2010 11:23:44 -0700
Message-ID: <20100311182343.13103.98096.stgit__5692.7157020711$1268332059$gmane$org@angua>
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
	with ESMTP id S934225Ab0CKSXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:23:46 -0500
In-Reply-To: <20100311181604.13103.30088.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.name, .match_table and .owner are duplicated in both of_platform_driver
and device_driver, so the of_platform_driver copies will be removed soon.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/hwmon/ultra45_env.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/hwmon/ultra45_env.c b/drivers/hwmon/ultra45_env.c
index 68e90ab..5da5942 100644
--- a/drivers/hwmon/ultra45_env.c
+++ b/drivers/hwmon/ultra45_env.c
@@ -300,8 +300,11 @@ static const struct of_device_id env_match[] = {
 MODULE_DEVICE_TABLE(of, env_match);
 
 static struct of_platform_driver env_driver = {
-	.name		= "ultra45_env",
-	.match_table	= env_match,
+	.driver = {
+		.name = "ultra45_env",
+		.owner = THIS_MODULE,
+		.of_match_table = env_match,
+	},
 	.probe		= env_probe,
 	.remove		= __devexit_p(env_remove),
 };

