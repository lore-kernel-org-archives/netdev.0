From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 19/27] drivers/pcmcia/of: don't use deprecated field in
	of_platform_driver
Date: Thu, 11 Mar 2010 11:23:33 -0700
Message-ID: <20100311182332.13103.33898.stgit__45521.9774660238$1268331863$gmane$org@angua>
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
	with ESMTP id S934205Ab0CKSXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:23:35 -0500
In-Reply-To: <20100311181604.13103.30088.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.name, .match_table and .owner are duplicated in both of_platform_driver
and device_driver, so the of_platform_driver copies will be removed soon.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/pcmcia/electra_cf.c  |    7 +++++--
 drivers/pcmcia/m8xx_pcmcia.c |    7 +++++--
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/pcmcia/electra_cf.c b/drivers/pcmcia/electra_cf.c
index a4d821f..4ea8530 100644
--- a/drivers/pcmcia/electra_cf.c
+++ b/drivers/pcmcia/electra_cf.c
@@ -356,8 +356,11 @@ static const struct of_device_id electra_cf_match[] = {
 MODULE_DEVICE_TABLE(of, electra_cf_match);
 
 static struct of_platform_driver electra_cf_driver = {
-	.name	   = (char *)driver_name,
-	.match_table    = electra_cf_match,
+	.driver = {
+		.name = (char *)driver_name,
+		.owner = THIS_MODULE,
+		.of_match_table = electra_cf_match,
+	},
 	.probe	  = electra_cf_probe,
 	.remove   = electra_cf_remove,
 };
diff --git a/drivers/pcmcia/m8xx_pcmcia.c b/drivers/pcmcia/m8xx_pcmcia.c
index 61c2159..af60745 100644
--- a/drivers/pcmcia/m8xx_pcmcia.c
+++ b/drivers/pcmcia/m8xx_pcmcia.c
@@ -1314,8 +1314,11 @@ static const struct of_device_id m8xx_pcmcia_match[] = {
 MODULE_DEVICE_TABLE(of, m8xx_pcmcia_match);
 
 static struct of_platform_driver m8xx_pcmcia_driver = {
-	.name = driver_name,
-	.match_table = m8xx_pcmcia_match,
+	.driver = {
+		.name = driver_name,
+		.owner = THIS_MODULE,
+		.match_table = m8xx_pcmcia_match,
+	},
 	.probe = m8xx_probe,
 	.remove = m8xx_remove,
 	.suspend = m8xx_suspend,

