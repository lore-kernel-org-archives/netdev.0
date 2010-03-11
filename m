From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 16/27] drivers/scsi/of: don't use deprecated field in
	of_platform_driver
Date: Thu, 11 Mar 2010 11:23:16 -0700
Message-ID: <20100311182316.13103.87138.stgit__42127.4364031435$1268332771$gmane$org@angua>
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
	with ESMTP id S934176Ab0CKSXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:23:19 -0500
In-Reply-To: <20100311181604.13103.30088.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.name, .match_table and .owner are duplicated in both of_platform_driver
and device_driver, so the of_platform_driver copies will be removed soon.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/scsi/qlogicpti.c |    7 +++++--
 drivers/scsi/sun_esp.c   |    7 +++++--
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/scsi/qlogicpti.c b/drivers/scsi/qlogicpti.c
index 7374fbe..16dc12e 100644
--- a/drivers/scsi/qlogicpti.c
+++ b/drivers/scsi/qlogicpti.c
@@ -1456,8 +1456,11 @@ static const struct of_device_id qpti_match[] = {
 MODULE_DEVICE_TABLE(of, qpti_match);
 
 static struct of_platform_driver qpti_sbus_driver = {
-	.name		= "qpti",
-	.match_table	= qpti_match,
+	.driver = {
+		.name = "qpti",
+		.owner = THIS_MODULE,
+		.of_match_table = qpti_match,
+	},
 	.probe		= qpti_sbus_probe,
 	.remove		= __devexit_p(qpti_sbus_remove),
 };
diff --git a/drivers/scsi/sun_esp.c b/drivers/scsi/sun_esp.c
index 4369b76..10ba30a 100644
--- a/drivers/scsi/sun_esp.c
+++ b/drivers/scsi/sun_esp.c
@@ -632,8 +632,11 @@ static const struct of_device_id esp_match[] = {
 MODULE_DEVICE_TABLE(of, esp_match);
 
 static struct of_platform_driver esp_sbus_driver = {
-	.name		= "esp",
-	.match_table	= esp_match,
+	.driver = {
+		.name = "esp",
+		.owner = THIS_MODULE,
+		.of_match_table = esp_match,
+	},
 	.probe		= esp_sbus_probe,
 	.remove		= __devexit_p(esp_sbus_remove),
 };

