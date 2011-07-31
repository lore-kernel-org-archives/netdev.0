From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 58/71] fealnx: Move the Myson driver
Date: Sat, 30 Jul 2011 20:27:17 -0700
Message-ID: <1312082850-24914-59-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Donald Becker <becker@scyld.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:39387 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753404Ab1GaD2l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:28:41 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
index 363801e..1fef312 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -370,15 +370,6 @@ config FORCEDETH
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
index 051439f..e11166a 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -16,7 +16,6 @@ obj-$(CONFIG_PLIP) += plip.o
 
 obj-$(CONFIG_ROADRUNNER) += rrunner.o
 
-obj-$(CONFIG_FEALNX) += fealnx.o
 obj-$(CONFIG_SKFP) += skfp/
 obj-$(CONFIG_ADAPTEC_STARFIRE) += starfire.o
 obj-$(CONFIG_RIONET) += rionet.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 78e567f..711297f 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -73,6 +73,16 @@ config MIPS_SIM_NET
 	  If you are not using a MIPSsim or are unsure, say N.
 
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
 source "drivers/net/ethernet/nuvoton/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 48d3209..e30dde4 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -34,6 +34,7 @@ obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
 obj-$(CONFIG_NET_VENDOR_MICREL) += micrel/
 obj-$(CONFIG_MIPS_SIM_NET) += mipsnet.o
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
+obj-$(CONFIG_FEALNX) += fealnx.o
 obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
 obj-$(CONFIG_NET_VENDOR_NUVOTON) += nuvoton/
 obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
diff --git a/drivers/net/fealnx.c b/drivers/net/ethernet/fealnx.c
similarity index 100%
rename from drivers/net/fealnx.c
rename to drivers/net/ethernet/fealnx.c
-- 
1.7.6

