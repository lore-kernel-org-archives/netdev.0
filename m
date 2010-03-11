From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 10/27] drivers/input/of: don't use deprecated field in
	of_platform_driver
Date: Thu, 11 Mar 2010 11:22:43 -0700
Message-ID: <20100311182243.13103.2307.stgit__105.036635841493$1268331859$gmane$org@angua>
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
	with ESMTP id S934145Ab0CKSWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:22:47 -0500
In-Reply-To: <20100311181604.13103.30088.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.name, .match_table and .owner are duplicated in both of_platform_driver
and device_driver, so the of_platform_driver copies will be removed soon.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/input/misc/sparcspkr.c      |   14 ++++++++++----
 drivers/input/serio/i8042-sparcio.h |    7 +++++--
 drivers/input/serio/xilinx_ps2.c    |    7 +++++--
 3 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/drivers/input/misc/sparcspkr.c b/drivers/input/misc/sparcspkr.c
index b064419..11ad153 100644
--- a/drivers/input/misc/sparcspkr.c
+++ b/drivers/input/misc/sparcspkr.c
@@ -258,8 +258,11 @@ static const struct of_device_id bbc_beep_match[] = {
 };
 
 static struct of_platform_driver bbc_beep_driver = {
-	.name		= "bbcbeep",
-	.match_table	= bbc_beep_match,
+	.driver = {
+		.name = "bbcbeep",
+		.owner = THIS_MODULE,
+		.of_match_table = bbc_beep_match,
+	},
 	.probe		= bbc_beep_probe,
 	.remove		= __devexit_p(bbc_remove),
 	.shutdown	= sparcspkr_shutdown,
@@ -337,8 +340,11 @@ static const struct of_device_id grover_beep_match[] = {
 };
 
 static struct of_platform_driver grover_beep_driver = {
-	.name		= "groverbeep",
-	.match_table	= grover_beep_match,
+	.driver = {
+		.name = "groverbeep",
+		.owner = THIS_MODULE,
+		.of_match_table = grover_beep_match,
+	},
 	.probe		= grover_beep_probe,
 	.remove		= __devexit_p(grover_remove),
 	.shutdown	= sparcspkr_shutdown,
diff --git a/drivers/input/serio/i8042-sparcio.h b/drivers/input/serio/i8042-sparcio.h
index 29e1769..04e32f2 100644
--- a/drivers/input/serio/i8042-sparcio.h
+++ b/drivers/input/serio/i8042-sparcio.h
@@ -96,8 +96,11 @@ static const struct of_device_id sparc_i8042_match[] = {
 MODULE_DEVICE_TABLE(of, sparc_i8042_match);
 
 static struct of_platform_driver sparc_i8042_driver = {
-	.name		= "i8042",
-	.match_table	= sparc_i8042_match,
+	.driver = {
+		.name = "i8042",
+		.owner = THIS_MODULE,
+		.of_match_table = sparc_i8042_match,
+	},
 	.probe		= sparc_i8042_probe,
 	.remove		= __devexit_p(sparc_i8042_remove),
 };
diff --git a/drivers/input/serio/xilinx_ps2.c b/drivers/input/serio/xilinx_ps2.c
index f154153..e787053 100644
--- a/drivers/input/serio/xilinx_ps2.c
+++ b/drivers/input/serio/xilinx_ps2.c
@@ -361,8 +361,11 @@ static const struct of_device_id xps2_of_match[] __devinitconst = {
 MODULE_DEVICE_TABLE(of, xps2_of_match);
 
 static struct of_platform_driver xps2_of_driver = {
-	.name		= DRIVER_NAME,
-	.match_table	= xps2_of_match,
+	.driver = {
+		.name = DRIVER_NAME,
+		.owner = THIS_MODULE,
+		.of_match_table = xps2_of_match,
+	},
 	.probe		= xps2_of_probe,
 	.remove		= __devexit_p(xps2_of_remove),
 };

