From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/10] octeon: Move the Cavium driver
Date: Fri, 12 Aug 2011 03:52:49 -0700
Message-ID: <1313146371-6562-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313146371-6562-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	David Daney <david.daney@cavium.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:54616 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752720Ab1HLKxA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 06:53:00 -0400
In-Reply-To: <1313146371-6562-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Cavium driver to drivers/net/ethernet/octeon/ and
make the necessary Kconfig and Makefile changes.

CC: David Daney <david.daney@cavium.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Acked-by: David Daney <david.daney@cavium.com>
---
 drivers/net/Kconfig                             |    2 --
 drivers/net/Makefile                            |    1 -
 drivers/net/ethernet/Kconfig                    |    1 +
 drivers/net/ethernet/Makefile                   |    1 +
 drivers/net/{ => ethernet}/octeon/Kconfig       |    6 +++++-
 drivers/net/ethernet/octeon/Makefile            |    5 +++++
 drivers/net/{ => ethernet}/octeon/octeon_mgmt.c |    0
 drivers/net/octeon/Makefile                     |    2 --
 8 files changed, 12 insertions(+), 6 deletions(-)
 rename drivers/net/{ => ethernet}/octeon/Kconfig (85%)
 create mode 100644 drivers/net/ethernet/octeon/Makefile
 rename drivers/net/{ => ethernet}/octeon/octeon_mgmt.c (100%)
 delete mode 100644 drivers/net/octeon/Makefile

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 99b209e..b896621 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -506,8 +506,6 @@ config LANTIQ_ETOP
 	help
 	  Support for the MII0 inside the Lantiq SoC
 
-source "drivers/net/octeon/Kconfig"
-
 endif # NET_ETHERNET
 
 #
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index d8c286e..648fa5c 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -105,5 +105,4 @@ obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 obj-$(CONFIG_WIMAX) += wimax/
 obj-$(CONFIG_CAIF) += caif/
 
-obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
 obj-$(CONFIG_TILE_NET) += tile/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 140dd73..70c60ef 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -38,6 +38,7 @@ source "drivers/net/ethernet/myricom/Kconfig"
 source "drivers/net/ethernet/natsemi/Kconfig"
 source "drivers/net/ethernet/8390/Kconfig"
 source "drivers/net/ethernet/nuvoton/Kconfig"
+source "drivers/net/ethernet/octeon/Kconfig"
 source "drivers/net/ethernet/oki-semi/Kconfig"
 source "drivers/net/ethernet/packetengines/Kconfig"
 source "drivers/net/ethernet/pasemi/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 8a97b19..929ee29 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -29,6 +29,7 @@ obj-$(CONFIG_NET_VENDOR_MICREL) += micrel/
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
 obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
 obj-$(CONFIG_NET_VENDOR_NUVOTON) += nuvoton/
+obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
 obj-$(CONFIG_NET_VENDOR_OKI) += oki-semi/
 obj-$(CONFIG_NET_PACKET_ENGINE) += packetengines/
 obj-$(CONFIG_NET_VENDOR_PASEMI) += pasemi/
diff --git a/drivers/net/octeon/Kconfig b/drivers/net/ethernet/octeon/Kconfig
similarity index 85%
rename from drivers/net/octeon/Kconfig
rename to drivers/net/ethernet/octeon/Kconfig
index 1e56bbf..3de52ff 100644
--- a/drivers/net/octeon/Kconfig
+++ b/drivers/net/ethernet/octeon/Kconfig
@@ -1,10 +1,14 @@
+#
+# Cavium network device configuration
+#
+
 config OCTEON_MGMT_ETHERNET
 	tristate "Octeon Management port ethernet driver (CN5XXX, CN6XXX)"
 	depends on  CPU_CAVIUM_OCTEON
 	select PHYLIB
 	select MDIO_OCTEON
 	default y
-	help
+	---help---
 	  This option enables the ethernet driver for the management
 	  port on Cavium Networks' Octeon CN57XX, CN56XX, CN55XX,
 	  CN54XX, CN52XX, and CN6XXX chips.
diff --git a/drivers/net/ethernet/octeon/Makefile b/drivers/net/ethernet/octeon/Makefile
new file mode 100644
index 0000000..efa41c1
--- /dev/null
+++ b/drivers/net/ethernet/octeon/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Cavium network device drivers.
+#
+
+obj-$(CONFIG_OCTEON_MGMT_ETHERNET)	+= octeon_mgmt.o
diff --git a/drivers/net/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
similarity index 100%
rename from drivers/net/octeon/octeon_mgmt.c
rename to drivers/net/ethernet/octeon/octeon_mgmt.c
diff --git a/drivers/net/octeon/Makefile b/drivers/net/octeon/Makefile
deleted file mode 100644
index 906edec..0000000
--- a/drivers/net/octeon/Makefile
+++ /dev/null
@@ -1,2 +0,0 @@
-
-obj-$(CONFIG_OCTEON_MGMT_ETHERNET)	+= octeon_mgmt.o
-- 
1.7.6

