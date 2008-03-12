From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 8/8] New driver "sfc" for Solarstorm SFC4000 controller (try #8)
Date: Wed, 12 Mar 2008 01:26:30 +0000
Message-ID: <20080312012629.GJ24160@solarflare.com>
References: <20080312012102.GB24160@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net-drivers@solarflare.com, Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:54774 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751612AbYCLB0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2008 21:26:38 -0400
Content-Disposition: inline
In-Reply-To: <20080312012102.GB24160@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
diff --git a/MAINTAINERS b/MAINTAINERS
index 36c7bc6..7da7c3a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3495,6 +3495,13 @@ M:	pfg@sgi.com
 L:	linux-ia64@vger.kernel.org
 S:	Supported
 
+SFC NETWORK DRIVER
+P:	Steve Hodgson
+P:	Ben Hutchings
+P:	Robert Stonehouse
+M:	linux-net-drivers@solarflare.com
+S:	Supported
+
 SGI VISUAL WORKSTATION 320 AND 540
 P:	Andrey Panin
 M:	pazke@donpac.ru
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f337800..1b476a3 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2666,6 +2666,7 @@ config BNX2X
 	  To compile this driver as a module, choose M here: the module
 	  will be called bnx2x.  This is recommended.
 
+source "drivers/net/sfc/Kconfig"
 
 endif # NETDEV_10000
 
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 3b1ea32..afffee3 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -252,3 +252,5 @@ obj-$(CONFIG_FS_ENET) += fs_enet/
 obj-$(CONFIG_NETXEN_NIC) += netxen/
 obj-$(CONFIG_NIU) += niu.o
 obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
+obj-$(CONFIG_SFC) += sfc/
+
diff --git a/drivers/net/sfc/Kconfig b/drivers/net/sfc/Kconfig
new file mode 100644
index 0000000..dbad95c
--- /dev/null
+++ b/drivers/net/sfc/Kconfig
@@ -0,0 +1,12 @@
+config SFC
+	tristate "Solarflare Solarstorm SFC4000 support"
+	depends on PCI && INET
+	select MII
+	select INET_LRO
+	select CRC32
+	help
+	  This driver supports 10-gigabit Ethernet cards based on
+	  the Solarflare Communications Solarstorm SFC4000 controller.
+
+	  To compile this driver as a module, choose M here.  The module
+	  will be called sfc.
diff --git a/drivers/net/sfc/Makefile b/drivers/net/sfc/Makefile
new file mode 100644
index 0000000..4a29613
--- /dev/null
+++ b/drivers/net/sfc/Makefile
@@ -0,0 +1,23 @@
+
+# Final objects
+sfc_o = sfc.o
+
+# Constituent objects
+sfc_elements_o :=
+sfc_elements_o += efx.o
+sfc_elements_o += falcon.o
+sfc_elements_o += tx.o
+sfc_elements_o += rx.o
+sfc_elements_o += falcon_xmac.o
+sfc_elements_o += i2c-direct.o
+sfc_elements_o += ethtool.o
+sfc_elements_o += xfp_phy.o
+sfc_elements_o += mdio_10g.o
+sfc_elements_o += tenxpress.o
+sfc_elements_o += boards.o
+sfc_elements_o += sfe4001.o
+
+obj-$(CONFIG_SFC) += $(sfc_o)
+
+sfc-objs = $(sfc_elements_o)
+

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
