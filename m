From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 15/27] drivers/spi/of: don't use deprecated field in
	of_platform_driver
Date: Thu, 11 Mar 2010 11:23:11 -0700
Message-ID: <20100311182310.13103.62043.stgit__20515.5812589966$1268332861$gmane$org@angua>
References: <20100311181604.13103.30088.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:36134 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934170Ab0CKSXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:23:15 -0500
In-Reply-To: <20100311181604.13103.30088.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.name, .match_table and .owner are duplicated in both of_platform_driver
and device_driver, so the of_platform_driver copies will be removed soon.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/spi/mpc52xx_psc_spi.c |    4 +---
 drivers/spi/mpc52xx_spi.c     |    8 +++++---
 drivers/spi/spi_mpc8xxx.c     |    7 +++++--
 drivers/spi/spi_ppc4xx.c      |    2 +-
 drivers/spi/xilinx_spi_of.c   |    2 +-
 5 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/drivers/spi/mpc52xx_psc_spi.c b/drivers/spi/mpc52xx_psc_spi.c
index f12cfd9..babd529 100644
--- a/drivers/spi/mpc52xx_psc_spi.c
+++ b/drivers/spi/mpc52xx_psc_spi.c
@@ -513,14 +513,12 @@ static const struct of_device_id mpc52xx_psc_spi_of_match[] = {
 MODULE_DEVICE_TABLE(of, mpc52xx_psc_spi_of_match);
 
 static struct of_platform_driver mpc52xx_psc_spi_of_driver = {
-	.owner = THIS_MODULE,
-	.name = "mpc52xx-psc-spi",
-	.match_table = mpc52xx_psc_spi_of_match,
 	.probe = mpc52xx_psc_spi_of_probe,
 	.remove = __exit_p(mpc52xx_psc_spi_of_remove),
 	.driver = {
 		.name = "mpc52xx-psc-spi",
 		.owner = THIS_MODULE,
+		.of_match_table = mpc52xx_psc_spi_of_match,
 	},
 };
 
diff --git a/drivers/spi/mpc52xx_spi.c b/drivers/spi/mpc52xx_spi.c
index 907c39a..792ffb9 100644
--- a/drivers/spi/mpc52xx_spi.c
+++ b/drivers/spi/mpc52xx_spi.c
@@ -557,9 +557,11 @@ static const struct of_device_id mpc52xx_spi_match[] __devinitconst = {
 MODULE_DEVICE_TABLE(of, mpc52xx_spi_match);
 
 static struct of_platform_driver mpc52xx_spi_of_driver = {
-	.owner = THIS_MODULE,
-	.name = "mpc52xx-spi",
-	.match_table = mpc52xx_spi_match,
+	.driver = {
+		.name = "mpc52xx-spi",
+		.owner = THIS_MODULE,
+		.of_match_table = mpc52xx_spi_match,
+	},
 	.probe = mpc52xx_spi_probe,
 	.remove = __exit_p(mpc52xx_spi_remove),
 };
diff --git a/drivers/spi/spi_mpc8xxx.c b/drivers/spi/spi_mpc8xxx.c
index 38b9c32..fd90c30 100644
--- a/drivers/spi/spi_mpc8xxx.c
+++ b/drivers/spi/spi_mpc8xxx.c
@@ -1311,8 +1311,11 @@ static const struct of_device_id of_mpc8xxx_spi_match[] = {
 MODULE_DEVICE_TABLE(of, of_mpc8xxx_spi_match);
 
 static struct of_platform_driver of_mpc8xxx_spi_driver = {
-	.name		= "mpc8xxx_spi",
-	.match_table	= of_mpc8xxx_spi_match,
+	.driver = {
+		.name = "mpc8xxx_spi",
+		.owner = THIS_MODULE,
+		.of_match_table = of_mpc8xxx_spi_match,
+	},
 	.probe		= of_mpc8xxx_spi_probe,
 	.remove		= __devexit_p(of_mpc8xxx_spi_remove),
 };
diff --git a/drivers/spi/spi_ppc4xx.c b/drivers/spi/spi_ppc4xx.c
index 6d8d402..fa6f01c 100644
--- a/drivers/spi/spi_ppc4xx.c
+++ b/drivers/spi/spi_ppc4xx.c
@@ -586,12 +586,12 @@ static const struct of_device_id spi_ppc4xx_of_match[] = {
 MODULE_DEVICE_TABLE(of, spi_ppc4xx_of_match);
 
 static struct of_platform_driver spi_ppc4xx_of_driver = {
-	.match_table = spi_ppc4xx_of_match,
 	.probe = spi_ppc4xx_of_probe,
 	.remove = __exit_p(spi_ppc4xx_of_remove),
 	.driver = {
 		.name = DRIVER_NAME,
 		.owner = THIS_MODULE,
+		.of_match_table = spi_ppc4xx_of_match,
 	},
 };
 
diff --git a/drivers/spi/xilinx_spi_of.c b/drivers/spi/xilinx_spi_of.c
index ed34a8d..416a8cd 100644
--- a/drivers/spi/xilinx_spi_of.c
+++ b/drivers/spi/xilinx_spi_of.c
@@ -108,12 +108,12 @@ static const struct of_device_id xilinx_spi_of_match[] = {
 MODULE_DEVICE_TABLE(of, xilinx_spi_of_match);
 
 static struct of_platform_driver xilinx_spi_of_driver = {
-	.match_table = xilinx_spi_of_match,
 	.probe = xilinx_spi_of_probe,
 	.remove = __exit_p(xilinx_spi_of_remove),
 	.driver = {
 		.name = "xilinx-xps-spi",
 		.owner = THIS_MODULE,
+		.of_match_table = xilinx_spi_of_match,
 	},
 };
 

