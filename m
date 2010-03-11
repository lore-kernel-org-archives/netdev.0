From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 14/27] drivers/serial/of: don't use deprecated field in
	of_platform_driver
Date: Thu, 11 Mar 2010 11:23:05 -0700
Message-ID: <20100311182305.13103.57542.stgit__3009.7950752408$1268332860$gmane$org@angua>
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
	with ESMTP id S934105Ab0CKSXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:23:13 -0500
In-Reply-To: <20100311181604.13103.30088.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.name, .match_table and .owner are duplicated in both of_platform_driver
and device_driver, so the of_platform_driver copies will be removed soon.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/serial/apbuart.c                |    8 ++++----
 drivers/serial/cpm_uart/cpm_uart_core.c |    7 +++++--
 drivers/serial/mpc52xx_uart.c           |    7 ++++---
 drivers/serial/of_serial.c              |    8 +++++---
 drivers/serial/sunhv.c                  |    7 +++++--
 drivers/serial/sunsab.c                 |    7 +++++--
 drivers/serial/sunsu.c                  |    7 +++++--
 drivers/serial/sunzilog.c               |    7 +++++--
 drivers/serial/uartlite.c               |    5 ++---
 drivers/serial/ucc_uart.c               |    8 +++++---
 10 files changed, 45 insertions(+), 26 deletions(-)

diff --git a/drivers/serial/apbuart.c b/drivers/serial/apbuart.c
index 52015d7..0099b86 100644
--- a/drivers/serial/apbuart.c
+++ b/drivers/serial/apbuart.c
@@ -584,12 +584,12 @@ static struct of_device_id __initdata apbuart_match[] = {
 };
 
 static struct of_platform_driver grlib_apbuart_of_driver = {
-	.match_table = apbuart_match,
 	.probe = apbuart_probe,
 	.driver = {
-		   .owner = THIS_MODULE,
-		   .name = "grlib-apbuart",
-		   },
+		.owner = THIS_MODULE,
+		.name = "grlib-apbuart",
+		.of_match_table = apbuart_match,
+	},
 };
 
 
diff --git a/drivers/serial/cpm_uart/cpm_uart_core.c b/drivers/serial/cpm_uart/cpm_uart_core.c
index 300cea7..09962e0 100644
--- a/drivers/serial/cpm_uart/cpm_uart_core.c
+++ b/drivers/serial/cpm_uart/cpm_uart_core.c
@@ -1372,8 +1372,11 @@ static struct of_device_id cpm_uart_match[] = {
 };
 
 static struct of_platform_driver cpm_uart_driver = {
-	.name = "cpm_uart",
-	.match_table = cpm_uart_match,
+	.driver = {
+		.name = "cpm_uart",
+		.owner = THIS_MODULE,
+		.of_match_table = cpm_uart_match,
+	},
 	.probe = cpm_uart_probe,
 	.remove = cpm_uart_remove,
  };
diff --git a/drivers/serial/mpc52xx_uart.c b/drivers/serial/mpc52xx_uart.c
index cb07938..4fb32e3 100644
--- a/drivers/serial/mpc52xx_uart.c
+++ b/drivers/serial/mpc52xx_uart.c
@@ -1464,15 +1464,16 @@ mpc52xx_uart_of_enumerate(void)
 MODULE_DEVICE_TABLE(of, mpc52xx_uart_of_match);
 
 static struct of_platform_driver mpc52xx_uart_of_driver = {
-	.match_table	= mpc52xx_uart_of_match,
 	.probe		= mpc52xx_uart_of_probe,
 	.remove		= mpc52xx_uart_of_remove,
 #ifdef CONFIG_PM
 	.suspend	= mpc52xx_uart_of_suspend,
 	.resume		= mpc52xx_uart_of_resume,
 #endif
-	.driver		= {
-		.name	= "mpc52xx-psc-uart",
+	.driver = {
+		.name = "mpc52xx-psc-uart",
+		.owner = THIS_MODULE,
+		.of_match_table = mpc52xx_uart_of_match,
 	},
 };
 
diff --git a/drivers/serial/of_serial.c b/drivers/serial/of_serial.c
index 18bf39b..4166c23 100644
--- a/drivers/serial/of_serial.c
+++ b/drivers/serial/of_serial.c
@@ -174,11 +174,13 @@ static struct of_device_id __devinitdata of_platform_serial_table[] = {
 };
 
 static struct of_platform_driver of_platform_serial_driver = {
-	.owner = THIS_MODULE,
-	.name = "of_serial",
+	.driver = {
+		.name = "of_serial",
+		.owner = THIS_MODULE,
+		.of_match_table = of_platform_serial_table,
+	},
 	.probe = of_platform_serial_probe,
 	.remove = of_platform_serial_remove,
-	.match_table = of_platform_serial_table,
 };
 
 static int __init of_platform_serial_init(void)
diff --git a/drivers/serial/sunhv.c b/drivers/serial/sunhv.c
index d1eedf1..890f917 100644
--- a/drivers/serial/sunhv.c
+++ b/drivers/serial/sunhv.c
@@ -630,8 +630,11 @@ static const struct of_device_id hv_match[] = {
 MODULE_DEVICE_TABLE(of, hv_match);
 
 static struct of_platform_driver hv_driver = {
-	.name		= "hv",
-	.match_table	= hv_match,
+	.driver = {
+		.name = "hv",
+		.owner = THIS_MODULE,
+		.of_match_table = hv_match,
+	},
 	.probe		= hv_probe,
 	.remove		= __devexit_p(hv_remove),
 };
diff --git a/drivers/serial/sunsab.c b/drivers/serial/sunsab.c
index 2b8b2c2..fdb596c 100644
--- a/drivers/serial/sunsab.c
+++ b/drivers/serial/sunsab.c
@@ -1093,8 +1093,11 @@ static const struct of_device_id sab_match[] = {
 MODULE_DEVICE_TABLE(of, sab_match);
 
 static struct of_platform_driver sab_driver = {
-	.name		= "sab",
-	.match_table	= sab_match,
+	.driver = {
+		.name = "sab",
+		.owner = THIS_MODULE,
+		.of_match_table = sab_match,
+	},
 	.probe		= sab_probe,
 	.remove		= __devexit_p(sab_remove),
 };
diff --git a/drivers/serial/sunsu.c b/drivers/serial/sunsu.c
index 2ab82ed..1f507fe 100644
--- a/drivers/serial/sunsu.c
+++ b/drivers/serial/sunsu.c
@@ -1536,8 +1536,11 @@ static const struct of_device_id su_match[] = {
 MODULE_DEVICE_TABLE(of, su_match);
 
 static struct of_platform_driver su_driver = {
-	.name		= "su",
-	.match_table	= su_match,
+	.driver = {
+		.name = "su",
+		.owner = THIS_MODULE,
+		.of_match_table = su_match,
+	},
 	.probe		= su_probe,
 	.remove		= __devexit_p(su_remove),
 };
diff --git a/drivers/serial/sunzilog.c b/drivers/serial/sunzilog.c
index 20f9be8..34fb8e8 100644
--- a/drivers/serial/sunzilog.c
+++ b/drivers/serial/sunzilog.c
@@ -1491,8 +1491,11 @@ static const struct of_device_id zs_match[] = {
 MODULE_DEVICE_TABLE(of, zs_match);
 
 static struct of_platform_driver zs_driver = {
-	.name		= "zs",
-	.match_table	= zs_match,
+	.driver = {
+		.name = "zs",
+		.owner = THIS_MODULE,
+		.of_match_table = zs_match,
+	},
 	.probe		= zs_probe,
 	.remove		= __devexit_p(zs_remove),
 };
diff --git a/drivers/serial/uartlite.c b/drivers/serial/uartlite.c
index 8fc2583..81073e3 100644
--- a/drivers/serial/uartlite.c
+++ b/drivers/serial/uartlite.c
@@ -610,13 +610,12 @@ static int __devexit ulite_of_remove(struct of_device *op)
 }
 
 static struct of_platform_driver ulite_of_driver = {
-	.owner = THIS_MODULE,
-	.name = "uartlite",
-	.match_table = ulite_of_match,
 	.probe = ulite_of_probe,
 	.remove = __devexit_p(ulite_of_remove),
 	.driver = {
 		.name = "uartlite",
+		.owner = THIS_MODULE,
+		.of_match_table = ulite_of_match,
 	},
 };
 
diff --git a/drivers/serial/ucc_uart.c b/drivers/serial/ucc_uart.c
index 465f2fa..21182fe 100644
--- a/drivers/serial/ucc_uart.c
+++ b/drivers/serial/ucc_uart.c
@@ -1485,9 +1485,11 @@ static struct of_device_id ucc_uart_match[] = {
 MODULE_DEVICE_TABLE(of, ucc_uart_match);
 
 static struct of_platform_driver ucc_uart_of_driver = {
-	.owner  	= THIS_MODULE,
-	.name   	= "ucc_uart",
-	.match_table    = ucc_uart_match,
+	.driver = {
+		.name = "ucc_uart",
+		.owner = THIS_MODULE,
+		.of_match_table    = ucc_uart_match,
+	},
 	.probe  	= ucc_uart_probe,
 	.remove 	= ucc_uart_remove,
 };

