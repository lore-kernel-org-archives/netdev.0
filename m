From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 53/72] korina: Move the IDT driver
Date: Sat, 25 Jun 2011 06:59:04 -0700
Message-ID: <1309010363-22750-54-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	"IDT Inc." <rischelp@idt.com>, Felix Fietkau <nbd@openwrt.org>,
	Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37764 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752330Ab1FYOAV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:21 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the IDT driver into drivers/net/ethernet/ and make the
necessary Kconfig and Makefile changes

CC: "IDT Inc." <rischelp@idt.com>
CC: Felix Fietkau <nbd@openwrt.org>
CC: Florian Fainelli <florian@openwrt.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                 |    7 -------
 drivers/net/Makefile                |    1 -
 drivers/net/ethernet/Kconfig        |    7 +++++++
 drivers/net/ethernet/Makefile       |    1 +
 drivers/net/{ => ethernet}/korina.c |    0
 5 files changed, 8 insertions(+), 8 deletions(-)
 rename drivers/net/{ => ethernet}/korina.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 211679e..2635bd1 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -249,13 +249,6 @@ config SNI_82596
 	  Say Y here to support the on-board Intel 82596 ethernet controller
 	  built into SNI RM machines.
 
-config KORINA
-	tristate "Korina (IDT RC32434) Ethernet support"
-	depends on NET_ETHERNET && MIKROTIK_RB532
-	help
-	  If you have a Mikrotik RouterBoard 500 or IDT RC32434
-	  based system say Y. Otherwise say N.
-
 config MIPS_AU1X00_ENET
 	tristate "MIPS AU1000 Ethernet support"
 	depends on MIPS_ALCHEMY
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 5413c17..3dff87b 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -62,7 +62,6 @@ obj-$(CONFIG_LASI_82596) += lasi_82596.o
 obj-$(CONFIG_SNI_82596) += sni_82596.o
 obj-$(CONFIG_SC92031) += sc92031.o
 obj-$(CONFIG_EQUALIZER) += eql.o
-obj-$(CONFIG_KORINA) += korina.o
 obj-$(CONFIG_MIPS_AU1X00_ENET) += au1000_eth.o
 obj-$(CONFIG_MIPS_SIM_NET) += mipsnet.o
 obj-$(CONFIG_TUN) += tun.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index fda90fc..6115051 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -64,6 +64,13 @@ config JME
 	  To compile this driver as a module, choose M here. The module
 	  will be called jme.
 
+config KORINA
+	tristate "Korina (IDT RC32434) Ethernet support"
+	depends on MIKROTIK_RB532
+	---help---
+	  If you have a Mikrotik RouterBoard 500 or IDT RC32434
+	  based system say Y. Otherwise say N.
+
 source "drivers/net/ethernet/marvell/Kconfig"
 source "drivers/net/ethernet/mellanox/Kconfig"
 source "drivers/net/ethernet/micrel/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 3588c50..22a6eaa 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -23,6 +23,7 @@ obj-$(CONFIG_NET_VENDOR_IBM) += ibm/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_IP1000) += icplus/
 obj-$(CONFIG_JME) += jme.o
+obj-$(CONFIG_KORINA) += korina.o
 obj-$(CONFIG_NET_VENDOR_MARVELL) += marvell/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
 obj-$(CONFIG_NET_VENDOR_MICREL) += micrel/
diff --git a/drivers/net/korina.c b/drivers/net/ethernet/korina.c
similarity index 100%
rename from drivers/net/korina.c
rename to drivers/net/ethernet/korina.c
-- 
1.7.5.4

