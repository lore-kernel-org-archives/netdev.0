From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 53/71] mipsnet: Move the MIPS driver
Date: Sat, 30 Jul 2011 20:27:12 -0700
Message-ID: <1312082850-24914-54-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:38846 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753181Ab1GaD2e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:28:34 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the MIPS drivers into drivers/net/ethernet/ and
make the necessary Kconfig and Makefile changes.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                  |    8 --------
 drivers/net/Makefile                 |    1 -
 drivers/net/ethernet/Kconfig         |    9 +++++++++
 drivers/net/ethernet/Makefile        |    1 +
 drivers/net/{ => ethernet}/mipsnet.c |    0
 5 files changed, 10 insertions(+), 9 deletions(-)
 rename drivers/net/{ => ethernet}/mipsnet.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 7022efd..beee9a2 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -237,14 +237,6 @@ config MACB
 
 source "drivers/net/arm/Kconfig"
 
-config MIPS_SIM_NET
-	tristate "MIPS simulator Network device"
-	depends on MIPS_SIM
-	help
-	  The MIPSNET device is a simple Ethernet network device which is
-	  emulated by the MIPS Simulator.
-	  If you are not using a MIPSsim or are unsure, say N.
-
 config SH_ETH
 	tristate "Renesas SuperH Ethernet support"
 	depends on SUPERH && \
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 6c17cb6..389c268 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -54,7 +54,6 @@ obj-$(CONFIG_MACVLAN) += macvlan.o
 obj-$(CONFIG_MACVTAP) += macvtap.o
 obj-$(CONFIG_DEFXX) += defxx.o
 obj-$(CONFIG_EQUALIZER) += eql.o
-obj-$(CONFIG_MIPS_SIM_NET) += mipsnet.o
 obj-$(CONFIG_TUN) += tun.o
 obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_NET_NETX) += netx-eth.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index dae10a3..f1509a5 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -55,6 +55,15 @@ config KORINA
 source "drivers/net/ethernet/marvell/Kconfig"
 source "drivers/net/ethernet/mellanox/Kconfig"
 source "drivers/net/ethernet/micrel/Kconfig"
+
+config MIPS_SIM_NET
+	tristate "MIPS simulator Network device"
+	depends on MIPS_SIM
+	---help---
+	  The MIPSNET device is a simple Ethernet network device which is
+	  emulated by the MIPS Simulator.
+	  If you are not using a MIPSsim or are unsure, say N.
+
 source "drivers/net/ethernet/myricom/Kconfig"
 source "drivers/net/ethernet/natsemi/Kconfig"
 source "drivers/net/ethernet/8390/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index ddf097d..50fc50a 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -29,6 +29,7 @@ obj-$(CONFIG_KORINA) += korina.o
 obj-$(CONFIG_NET_VENDOR_MARVELL) += marvell/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
 obj-$(CONFIG_NET_VENDOR_MICREL) += micrel/
+obj-$(CONFIG_MIPS_SIM_NET) += mipsnet.o
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
 obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
 obj-$(CONFIG_NET_VENDOR_NUVOTON) += nuvoton/
diff --git a/drivers/net/mipsnet.c b/drivers/net/ethernet/mipsnet.c
similarity index 100%
rename from drivers/net/mipsnet.c
rename to drivers/net/ethernet/mipsnet.c
-- 
1.7.6

