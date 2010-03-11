From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 26/27] arch/sparc/of: don't use deprecated field in
	of_platform_driver
Date: Thu, 11 Mar 2010 11:24:11 -0700
Message-ID: <20100311182411.13103.41274.stgit__47014.5326610238$1268332758$gmane$org@angua>
References: <20100311181604.13103.30088.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f198.google.com ([209.85.216.198]:61932 "EHLO
	mail-px0-f198.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755715Ab0CKSbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:31:09 -0500
In-Reply-To: <20100311181604.13103.30088.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.name, .match_table and .owner are duplicated in both of_platform_driver
and device_driver, so the of_platform_driver copies will be removed soon.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 arch/sparc/include/asm/parport.h |    7 +++++--
 arch/sparc/kernel/apc.c          |    7 +++++--
 arch/sparc/kernel/auxio_64.c     |    7 ++++---
 arch/sparc/kernel/central.c      |   14 ++++++++------
 arch/sparc/kernel/chmc.c         |    7 +++++--
 arch/sparc/kernel/pci_fire.c     |    7 +++++--
 arch/sparc/kernel/pci_psycho.c   |    7 +++++--
 arch/sparc/kernel/pci_sabre.c    |    7 +++++--
 arch/sparc/kernel/pci_schizo.c   |    7 +++++--
 arch/sparc/kernel/pci_sun4v.c    |    7 +++++--
 arch/sparc/kernel/pmc.c          |    7 +++++--
 arch/sparc/kernel/power.c        |    7 ++++---
 arch/sparc/kernel/time_32.c      |    7 ++++---
 arch/sparc/kernel/time_64.c      |   21 ++++++++++++---------
 14 files changed, 77 insertions(+), 42 deletions(-)

diff --git a/arch/sparc/include/asm/parport.h b/arch/sparc/include/asm/parport.h
index 1bb6a41..c333b8d 100644
--- a/arch/sparc/include/asm/parport.h
+++ b/arch/sparc/include/asm/parport.h
@@ -232,8 +232,11 @@ static const struct of_device_id ecpp_match[] = {
 };
 
 static struct of_platform_driver ecpp_driver = {
-	.name			= "ecpp",
-	.match_table		= ecpp_match,
+	.driver = {
+		.name = "ecpp",
+		.owner = THIS_MODULE,
+		.of_match_table = ecpp_match,
+	},
 	.probe			= ecpp_probe,
 	.remove			= __devexit_p(ecpp_remove),
 };
diff --git a/arch/sparc/kernel/apc.c b/arch/sparc/kernel/apc.c
index 71ec90b..b27476c 100644
--- a/arch/sparc/kernel/apc.c
+++ b/arch/sparc/kernel/apc.c
@@ -174,8 +174,11 @@ static struct of_device_id __initdata apc_match[] = {
 MODULE_DEVICE_TABLE(of, apc_match);
 
 static struct of_platform_driver apc_driver = {
-	.name		= "apc",
-	.match_table	= apc_match,
+	.driver = {
+		.name = "apc",
+		.owner = THIS_MODULE,
+		.of_match_table = apc_match,
+	},
 	.probe		= apc_probe,
 };
 
diff --git a/arch/sparc/kernel/auxio_64.c b/arch/sparc/kernel/auxio_64.c
index bd8421a..ddc8412 100644
--- a/arch/sparc/kernel/auxio_64.c
+++ b/arch/sparc/kernel/auxio_64.c
@@ -132,10 +132,11 @@ static int __devinit auxio_probe(struct of_device *dev, const struct of_device_i
 }
 
 static struct of_platform_driver auxio_driver = {
-	.match_table	= auxio_match,
 	.probe		= auxio_probe,
-	.driver		= {
-		.name	= "auxio",
+	.driver = {
+		.name = "auxio",
+		.owner = THIS_MODULE,
+		.of_match_table = auxio_match,
 	},
 };
 
diff --git a/arch/sparc/kernel/central.c b/arch/sparc/kernel/central.c
index dfc3698..818f62a 100644
--- a/arch/sparc/kernel/central.c
+++ b/arch/sparc/kernel/central.c
@@ -148,10 +148,11 @@ static struct of_device_id __initdata clock_board_match[] = {
 };
 
 static struct of_platform_driver clock_board_driver = {
-	.match_table	= clock_board_match,
 	.probe		= clock_board_probe,
-	.driver		= {
-		.name	= "clock_board",
+	.driver = {
+		.name = "clock_board",
+		.owner = THIS_MODULE,
+		.of_match_table = clock_board_match,
 	},
 };
 
@@ -253,10 +254,11 @@ static struct of_device_id __initdata fhc_match[] = {
 };
 
 static struct of_platform_driver fhc_driver = {
-	.match_table	= fhc_match,
 	.probe		= fhc_probe,
-	.driver		= {
-		.name	= "fhc",
+	.driver = {
+		.name = "fhc",
+		.owner = THIS_MODULE,
+		.of_match_table = fhc_match,
 	},
 };
 
diff --git a/arch/sparc/kernel/chmc.c b/arch/sparc/kernel/chmc.c
index 9368796..870cb65 100644
--- a/arch/sparc/kernel/chmc.c
+++ b/arch/sparc/kernel/chmc.c
@@ -811,8 +811,11 @@ static const struct of_device_id us3mc_match[] = {
 MODULE_DEVICE_TABLE(of, us3mc_match);
 
 static struct of_platform_driver us3mc_driver = {
-	.name		= "us3mc",
-	.match_table	= us3mc_match,
+	.driver = {
+		.name = "us3mc",
+		.owner = THIS_MODULE,
+		.of_match_table = us3mc_match,
+	},
 	.probe		= us3mc_probe,
 	.remove		= __devexit_p(us3mc_remove),
 };
diff --git a/arch/sparc/kernel/pci_fire.c b/arch/sparc/kernel/pci_fire.c
index ff844ba..51cfa09 100644
--- a/arch/sparc/kernel/pci_fire.c
+++ b/arch/sparc/kernel/pci_fire.c
@@ -508,8 +508,11 @@ static struct of_device_id __initdata fire_match[] = {
 };
 
 static struct of_platform_driver fire_driver = {
-	.name		= DRIVER_NAME,
-	.match_table	= fire_match,
+	.driver = {
+		.name = DRIVER_NAME,
+		.owner = THIS_MODULE,
+		.of_match_table = fire_match,
+	},
 	.probe		= fire_probe,
 };
 
diff --git a/arch/sparc/kernel/pci_psycho.c b/arch/sparc/kernel/pci_psycho.c
index e675e21..558a705 100644
--- a/arch/sparc/kernel/pci_psycho.c
+++ b/arch/sparc/kernel/pci_psycho.c
@@ -602,8 +602,11 @@ static struct of_device_id __initdata psycho_match[] = {
 };
 
 static struct of_platform_driver psycho_driver = {
-	.name		= DRIVER_NAME,
-	.match_table	= psycho_match,
+	.driver = {
+		.name = DRIVER_NAME,
+		.owner = THIS_MODULE,
+		.of_match_table = psycho_match,
+	},
 	.probe		= psycho_probe,
 };
 
diff --git a/arch/sparc/kernel/pci_sabre.c b/arch/sparc/kernel/pci_sabre.c
index 5048498..6dad8e3 100644
--- a/arch/sparc/kernel/pci_sabre.c
+++ b/arch/sparc/kernel/pci_sabre.c
@@ -596,8 +596,11 @@ static struct of_device_id __initdata sabre_match[] = {
 };
 
 static struct of_platform_driver sabre_driver = {
-	.name		= DRIVER_NAME,
-	.match_table	= sabre_match,
+	.driver = {
+		.name = DRIVER_NAME,
+		.owner = THIS_MODULE,
+		.of_match_table = sabre_match,
+	},
 	.probe		= sabre_probe,
 };
 
diff --git a/arch/sparc/kernel/pci_schizo.c b/arch/sparc/kernel/pci_schizo.c
index 2f3f921..97a1ae2 100644
--- a/arch/sparc/kernel/pci_schizo.c
+++ b/arch/sparc/kernel/pci_schizo.c
@@ -1491,8 +1491,11 @@ static struct of_device_id __initdata schizo_match[] = {
 };
 
 static struct of_platform_driver schizo_driver = {
-	.name		= DRIVER_NAME,
-	.match_table	= schizo_match,
+	.driver = {
+		.name = DRIVER_NAME,
+		.owner = THIS_MODULE,
+		.of_match_table = schizo_match,
+	},
 	.probe		= schizo_probe,
 };
 
diff --git a/arch/sparc/kernel/pci_sun4v.c b/arch/sparc/kernel/pci_sun4v.c
index 5c11f56..a24af6f 100644
--- a/arch/sparc/kernel/pci_sun4v.c
+++ b/arch/sparc/kernel/pci_sun4v.c
@@ -1009,8 +1009,11 @@ static struct of_device_id __initdata pci_sun4v_match[] = {
 };
 
 static struct of_platform_driver pci_sun4v_driver = {
-	.name		= DRIVER_NAME,
-	.match_table	= pci_sun4v_match,
+	.driver = {
+		.name = DRIVER_NAME,
+		.owner = THIS_MODULE,
+		.of_match_table = pci_sun4v_match,
+	},
 	.probe		= pci_sun4v_probe,
 };
 
diff --git a/arch/sparc/kernel/pmc.c b/arch/sparc/kernel/pmc.c
index 5e4563d..9589d8b 100644
--- a/arch/sparc/kernel/pmc.c
+++ b/arch/sparc/kernel/pmc.c
@@ -79,8 +79,11 @@ static struct of_device_id __initdata pmc_match[] = {
 MODULE_DEVICE_TABLE(of, pmc_match);
 
 static struct of_platform_driver pmc_driver = {
-	.name		= "pmc",
-	.match_table	= pmc_match,
+	.driver = {
+		.name = "pmc",
+		.owner = THIS_MODULE,
+		.of_match_table = pmc_match,
+	},
 	.probe		= pmc_probe,
 };
 
diff --git a/arch/sparc/kernel/power.c b/arch/sparc/kernel/power.c
index e3f806a..168d4cb 100644
--- a/arch/sparc/kernel/power.c
+++ b/arch/sparc/kernel/power.c
@@ -60,10 +60,11 @@ static struct of_device_id __initdata power_match[] = {
 };
 
 static struct of_platform_driver power_driver = {
-	.match_table	= power_match,
 	.probe		= power_probe,
-	.driver		= {
-		.name	= "power",
+	.driver = {
+		.name = "power",
+		.owner = THIS_MODULE,
+		.of_match_table = power_match,
 	},
 };
 
diff --git a/arch/sparc/kernel/time_32.c b/arch/sparc/kernel/time_32.c
index e0dbed9..217ba27 100644
--- a/arch/sparc/kernel/time_32.c
+++ b/arch/sparc/kernel/time_32.c
@@ -185,10 +185,11 @@ static struct of_device_id __initdata clock_match[] = {
 };
 
 static struct of_platform_driver clock_driver = {
-	.match_table	= clock_match,
 	.probe		= clock_probe,
-	.driver		= {
-		.name	= "rtc",
+	.driver = {
+		.name = "rtc",
+		.owner = THIS_MODULE,
+		.of_match_table = clock_match,
 	},
 };
 
diff --git a/arch/sparc/kernel/time_64.c b/arch/sparc/kernel/time_64.c
index ee3fe41..b2cf014 100644
--- a/arch/sparc/kernel/time_64.c
+++ b/arch/sparc/kernel/time_64.c
@@ -462,10 +462,11 @@ static struct of_device_id __initdata rtc_match[] = {
 };
 
 static struct of_platform_driver rtc_driver = {
-	.match_table	= rtc_match,
 	.probe		= rtc_probe,
-	.driver		= {
-		.name	= "rtc",
+	.driver = {
+		.name = "rtc",
+		.owner = THIS_MODULE,
+		.of_match_table = rtc_match,
 	},
 };
 
@@ -494,10 +495,11 @@ static struct of_device_id __initdata bq4802_match[] = {
 };
 
 static struct of_platform_driver bq4802_driver = {
-	.match_table	= bq4802_match,
 	.probe		= bq4802_probe,
-	.driver		= {
-		.name	= "bq4802",
+	.driver = {
+		.name = "bq4802",
+		.owner = THIS_MODULE,
+		.of_match_table = bq4802_match,
 	},
 };
 
@@ -557,10 +559,11 @@ static struct of_device_id __initdata mostek_match[] = {
 };
 
 static struct of_platform_driver mostek_driver = {
-	.match_table	= mostek_match,
 	.probe		= mostek_probe,
-	.driver		= {
-		.name	= "mostek",
+	.driver = {
+		.name = "mostek",
+		.owner = THIS_MODULE,
+		.of_match_table = mostek_match,
 	},
 };
 

