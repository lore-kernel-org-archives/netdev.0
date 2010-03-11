From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 07/27] drivers/char/of: don't use deprecated field in
	of_platform_driver
Date: Thu, 11 Mar 2010 11:22:26 -0700
Message-ID: <20100311182226.13103.62140.stgit__32308.4903568544$1268331778$gmane$org@angua>
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
	with ESMTP id S934076Ab0CKSWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:22:33 -0500
In-Reply-To: <20100311181604.13103.30088.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.name, .match_table and .owner are duplicated in both of_platform_driver
and device_driver, so the of_platform_driver copies will be removed soon.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/char/hw_random/n2-drv.c            |    7 +++++--
 drivers/char/hw_random/pasemi-rng.c        |    7 +++++--
 drivers/char/ipmi/ipmi_si_intf.c           |    7 +++++--
 drivers/char/xilinx_hwicap/xilinx_hwicap.c |    5 ++---
 4 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/drivers/char/hw_random/n2-drv.c b/drivers/char/hw_random/n2-drv.c
index 4d05003..c82a571 100644
--- a/drivers/char/hw_random/n2-drv.c
+++ b/drivers/char/hw_random/n2-drv.c
@@ -751,8 +751,11 @@ static const struct of_device_id n2rng_match[] = {
 MODULE_DEVICE_TABLE(of, n2rng_match);
 
 static struct of_platform_driver n2rng_driver = {
-	.name		= "n2rng",
-	.match_table	= n2rng_match,
+	.driver = {
+		.name = "n2rng",
+		.owner = THIS_MODULE,
+		.of_match_table = n2rng_match,
+	},
 	.probe		= n2rng_probe,
 	.remove		= __devexit_p(n2rng_remove),
 };
diff --git a/drivers/char/hw_random/pasemi-rng.c b/drivers/char/hw_random/pasemi-rng.c
index b213855..261ba8f 100644
--- a/drivers/char/hw_random/pasemi-rng.c
+++ b/drivers/char/hw_random/pasemi-rng.c
@@ -140,8 +140,11 @@ static struct of_device_id rng_match[] = {
 };
 
 static struct of_platform_driver rng_driver = {
-	.name		= "pasemi-rng",
-	.match_table	= rng_match,
+	.driver = {
+		.name = "pasemi-rng",
+		.owner = THIS_MODULE,
+		.of_match_table = rng_match,
+	},
 	.probe		= rng_probe,
 	.remove		= rng_remove,
 };
diff --git a/drivers/char/ipmi/ipmi_si_intf.c b/drivers/char/ipmi/ipmi_si_intf.c
index 45305f2..012e63b 100644
--- a/drivers/char/ipmi/ipmi_si_intf.c
+++ b/drivers/char/ipmi/ipmi_si_intf.c
@@ -2492,8 +2492,11 @@ static struct of_device_id ipmi_match[] =
 };
 
 static struct of_platform_driver ipmi_of_platform_driver = {
-	.name		= "ipmi",
-	.match_table	= ipmi_match,
+	.driver = {
+		.name = "ipmi",
+		.owner = THIS_MODULE,
+		.of_match_table = ipmi_match,
+	},
 	.probe		= ipmi_of_probe,
 	.remove		= __devexit_p(ipmi_of_remove),
 };
diff --git a/drivers/char/xilinx_hwicap/xilinx_hwicap.c b/drivers/char/xilinx_hwicap/xilinx_hwicap.c
index 4846d50..1fb8665 100644
--- a/drivers/char/xilinx_hwicap/xilinx_hwicap.c
+++ b/drivers/char/xilinx_hwicap/xilinx_hwicap.c
@@ -811,13 +811,12 @@ static const struct of_device_id __devinitconst hwicap_of_match[] = {
 MODULE_DEVICE_TABLE(of, hwicap_of_match);
 
 static struct of_platform_driver hwicap_of_driver = {
-	.owner = THIS_MODULE,
-	.name = DRIVER_NAME,
-	.match_table = hwicap_of_match,
 	.probe = hwicap_of_probe,
 	.remove = __devexit_p(hwicap_of_remove),
 	.driver = {
 		.name = DRIVER_NAME,
+		.owner = THIS_MODULE,
+		.of_match_table = hwicap_of_match,
 	},
 };
 

