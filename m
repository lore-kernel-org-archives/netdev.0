From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 62/72] starfire: Move the starfire driver
Date: Sat, 25 Jun 2011 06:59:13 -0700
Message-ID: <1309010363-22750-63-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Ion Badulescu <ionut@badula.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37770 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751952Ab1FYOAg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:36 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the starfire driver into drivers/net/ethernet/ and make
the necessary Kconfig and Makefile changes.

CC: Ion Badulescu <ionut@badula.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                           |    2 +-
 drivers/net/Kconfig                   |   14 --------------
 drivers/net/Makefile                  |    1 -
 drivers/net/ethernet/Kconfig          |   14 ++++++++++++++
 drivers/net/ethernet/Makefile         |    1 +
 drivers/net/{ => ethernet}/starfire.c |    0
 6 files changed, 16 insertions(+), 16 deletions(-)
 rename drivers/net/{ => ethernet}/starfire.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index f1f555d..432dbfc 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6031,7 +6031,7 @@ F:	drivers/staging/
 STARFIRE/DURALAN NETWORK DRIVER
 M:	Ion Badulescu <ionut@badula.org>
 S:	Odd Fixes
-F:	drivers/net/starfire*
+F:	drivers/net/ethernet/starfire*
 
 SUN3/3X
 M:	Sam Creasey <sammy@sammy.net>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 04968e8..dcdf6e6 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -370,20 +370,6 @@ config NET_PCI
 	  will be asked for your specific card in the following questions. If
 	  you are unsure, say Y.
 
-config ADAPTEC_STARFIRE
-	tristate "Adaptec Starfire/DuraLAN support"
-	depends on NET_PCI && PCI
-	select CRC32
-	select MII
-	help
-	  Say Y here if you have an Adaptec Starfire (or DuraLAN) PCI network
-	  adapter. The DuraLAN chip is used on the 64 bit PCI boards from
-	  Adaptec e.g. the ANA-6922A. The older 32 bit boards use the tulip
-	  driver.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called starfire.  This is recommended.
-
 config NET_POCKET
 	bool "Pocket and portable adapters"
 	depends on PARPORT
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 97edc95..ae1b74d 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -18,7 +18,6 @@ obj-$(CONFIG_ROADRUNNER) += rrunner.o
 
 obj-$(CONFIG_ISERIES_VETH) += iseries_veth.o
 obj-$(CONFIG_SKFP) += skfp/
-obj-$(CONFIG_ADAPTEC_STARFIRE) += starfire.o
 obj-$(CONFIG_RIONET) += rionet.o
 obj-$(CONFIG_SH_ETH) += sh_eth.o
 
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 94e8630..6ade848 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -24,6 +24,20 @@ config A2065
 	  To compile this driver as a module, choose M here: the module
 	  will be called a2065.
 
+config ADAPTEC_STARFIRE
+	tristate "Adaptec Starfire/DuraLAN support"
+	depends on PCI
+	select CRC32
+	select MII
+	---help---
+	  Say Y here if you have an Adaptec Starfire (or DuraLAN) PCI network
+	  adapter. The DuraLAN chip is used on the 64 bit PCI boards from
+	  Adaptec e.g. the ANA-6922A. The older 32 bit boards use the tulip
+	  driver.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called starfire.  This is recommended.
+
 source "drivers/net/ethernet/amd/Kconfig"
 source "drivers/net/ethernet/apple/Kconfig"
 
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index b6ff610..eef91e6 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -5,6 +5,7 @@
 obj-$(CONFIG_NET_VENDOR_3COM) += 3com/
 obj-$(CONFIG_NET_VENDOR_8390) += 8390/
 obj-$(CONFIG_A2065) += a2065.o
+obj-$(CONFIG_ADAPTEC_STARFIRE) += starfire.o
 obj-$(CONFIG_NET_VENDOR_AMD) += amd/
 obj-$(CONFIG_NET_VENDOR_APPLE) += apple/
 obj-$(CONFIG_ARIADNE) += ariadne.o
diff --git a/drivers/net/starfire.c b/drivers/net/ethernet/starfire.c
similarity index 100%
rename from drivers/net/starfire.c
rename to drivers/net/ethernet/starfire.c
-- 
1.7.5.4

