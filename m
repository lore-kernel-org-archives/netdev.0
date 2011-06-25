From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 60/72] fealnx: Move the Myson driver
Date: Sat, 25 Jun 2011 06:59:11 -0700
Message-ID: <1309010363-22750-61-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Donald Becker <becker@scyld.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:41778 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752566Ab1FYOAf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:35 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Myson driver into drivers/net/ethernet/ and make the
necessary Kconfig and Makefile changes.

CC: Donald Becker <becker@scyld.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                 |    9 ---------
 drivers/net/Makefile                |    1 -
 drivers/net/ethernet/Kconfig        |   10 ++++++++++
 drivers/net/ethernet/Makefile       |    1 +
 drivers/net/{ => ethernet}/fealnx.c |    0
 5 files changed, 11 insertions(+), 10 deletions(-)
 rename drivers/net/{ => ethernet}/fealnx.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 463e4cf..4ec5d5e 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -395,15 +395,6 @@ config FORCEDETH
 	  To compile this driver as a module, choose M here. The module
 	  will be called forcedeth.
 
-config FEALNX
-	tristate "Myson MTD-8xx PCI Ethernet support"
-	depends on NET_PCI && PCI
-	select CRC32
-	select MII
-	help
-	  Say Y here to support the Myson MTD-800 family of PCI-based Ethernet 
-	  cards. <http://www.myson.com.tw/>
-
 config NET_POCKET
 	bool "Pocket and portable adapters"
 	depends on PARPORT
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index f57a0be..8b0a478 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -17,7 +17,6 @@ obj-$(CONFIG_PLIP) += plip.o
 obj-$(CONFIG_ROADRUNNER) += rrunner.o
 
 obj-$(CONFIG_ISERIES_VETH) += iseries_veth.o
-obj-$(CONFIG_FEALNX) += fealnx.o
 obj-$(CONFIG_SKFP) += skfp/
 obj-$(CONFIG_ADAPTEC_STARFIRE) += starfire.o
 obj-$(CONFIG_RIONET) += rionet.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 3c10879..45becd2 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -79,6 +79,16 @@ source "drivers/net/ethernet/micrel/Kconfig"
 source "drivers/net/ethernet/mips/Kconfig"
 source "drivers/net/ethernet/motorola/Kconfig"
 source "drivers/net/ethernet/myricom/Kconfig"
+
+config FEALNX
+	tristate "Myson MTD-8xx PCI Ethernet support"
+	depends on PCI
+	select CRC32
+	select MII
+	---help---
+	  Say Y here to support the Myson MTD-800 family of PCI-based Ethernet
+	  cards. <http://www.myson.com.tw/>
+
 source "drivers/net/ethernet/natsemi/Kconfig"
 source "drivers/net/ethernet/8390/Kconfig"
 source "drivers/net/ethernet/octeon/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 537631b..c4284aa 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -32,6 +32,7 @@ obj-$(CONFIG_NET_VENDOR_MICREL) += micrel/
 obj-$(CONFIG_NET_MIPS) += mips/
 obj-$(CONFIG_NET_VENDOR_MOTOROLA) += motorola/
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
+obj-$(CONFIG_FEALNX) += fealnx.o
 obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
 obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
 obj-$(CONFIG_NET_ISA) += isa/
diff --git a/drivers/net/fealnx.c b/drivers/net/ethernet/fealnx.c
similarity index 100%
rename from drivers/net/fealnx.c
rename to drivers/net/ethernet/fealnx.c
-- 
1.7.5.4

