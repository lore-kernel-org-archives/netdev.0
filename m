From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 43/72] a2065/ariadne: Move the a2065/ariadne drivers
Date: Sat, 25 Jun 2011 06:58:54 -0700
Message-ID: <1309010363-22750-44-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37787 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752167Ab1FYOAK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:10 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the a2065/ariadne drivers to drivers/net/ethernet/ and make
the necessary Kconfig and Makefile changes.

CC: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                  |   21 ---------------------
 drivers/net/Makefile                 |    2 --
 drivers/net/ethernet/Kconfig         |   23 +++++++++++++++++++++++
 drivers/net/ethernet/Makefile        |    2 ++
 drivers/net/{ => ethernet}/a2065.c   |    0
 drivers/net/{ => ethernet}/a2065.h   |    0
 drivers/net/{ => ethernet}/ariadne.c |    0
 drivers/net/{ => ethernet}/ariadne.h |    0
 8 files changed, 25 insertions(+), 23 deletions(-)
 rename drivers/net/{ => ethernet}/a2065.c (100%)
 rename drivers/net/{ => ethernet}/a2065.h (100%)
 rename drivers/net/{ => ethernet}/ariadne.c (100%)
 rename drivers/net/{ => ethernet}/ariadne.h (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index ddbdf3c..ed588b5 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -235,27 +235,6 @@ config MACB
 	  To compile this driver as a module, choose M here: the module
 	  will be called macb.
 
-config ARIADNE
-	tristate "Ariadne support"
-	depends on ZORRO
-	help
-	  If you have a Village Tronic Ariadne Ethernet adapter, say Y.
-	  Otherwise, say N.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called ariadne.
-
-config A2065
-	tristate "A2065 support"
-	depends on ZORRO
-	select CRC32
-	help
-	  If you have a Commodore A2065 Ethernet adapter, say Y. Otherwise,
-	  say N.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called a2065.
-
 config LASI_82596
 	tristate "Lasi ethernet"
 	depends on GSC
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 0d02503..f9f3478 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -79,8 +79,6 @@ obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_KORINA) += korina.o
 obj-$(CONFIG_MIPS_AU1X00_ENET) += au1000_eth.o
 obj-$(CONFIG_MIPS_SIM_NET) += mipsnet.o
-obj-$(CONFIG_A2065) += a2065.o
-obj-$(CONFIG_ARIADNE) += ariadne.o
 obj-$(CONFIG_TUN) += tun.o
 obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_NET_NETX) += netx-eth.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 74d98b3..9ade631 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -12,8 +12,31 @@ menuconfig ETHERNET
 if ETHERNET
 
 source "drivers/net/ethernet/3com/Kconfig"
+
+config A2065
+	tristate "A2065 support"
+	depends on ZORRO
+	select CRC32
+	---help---
+	  If you have a Commodore A2065 Ethernet adapter, say Y. Otherwise,
+	  say N.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called a2065.
+
 source "drivers/net/ethernet/amd/Kconfig"
 source "drivers/net/ethernet/apple/Kconfig"
+
+config ARIADNE
+	tristate "Ariadne support"
+	depends on ZORRO
+	---help---
+	  If you have a Village Tronic Ariadne Ethernet adapter, say Y.
+	  Otherwise, say N.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called ariadne.
+
 source "drivers/net/ethernet/arm/Kconfig"
 source "drivers/net/ethernet/atheros/Kconfig"
 source "drivers/net/ethernet/broadcom/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 4a682a7..5704a3b 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -4,8 +4,10 @@
 
 obj-$(CONFIG_NET_VENDOR_3COM) += 3com/
 obj-$(CONFIG_NET_VENDOR_8390) += 8390/
+obj-$(CONFIG_A2065) += a2065.o
 obj-$(CONFIG_NET_VENDOR_AMD) += amd/
 obj-$(CONFIG_NET_VENDOR_APPLE) += apple/
+obj-$(CONFIG_ARIADNE) += ariadne.o
 obj-$(CONFIG_NET_ARM) += arm/
 obj-$(CONFIG_NET_VENDOR_ATHEROS) += atheros/
 obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
diff --git a/drivers/net/a2065.c b/drivers/net/ethernet/a2065.c
similarity index 100%
rename from drivers/net/a2065.c
rename to drivers/net/ethernet/a2065.c
diff --git a/drivers/net/a2065.h b/drivers/net/ethernet/a2065.h
similarity index 100%
rename from drivers/net/a2065.h
rename to drivers/net/ethernet/a2065.h
diff --git a/drivers/net/ariadne.c b/drivers/net/ethernet/ariadne.c
similarity index 100%
rename from drivers/net/ariadne.c
rename to drivers/net/ethernet/ariadne.c
diff --git a/drivers/net/ariadne.h b/drivers/net/ethernet/ariadne.h
similarity index 100%
rename from drivers/net/ariadne.h
rename to drivers/net/ethernet/ariadne.h
-- 
1.7.5.4

