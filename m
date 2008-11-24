From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 13/39] wimax: Makefile, Kconfig and docbook linkage for the stack
Date: Mon, 24 Nov 2008 13:50:36 -0800
Message-ID: <2b8698eac3210a1c65e5fff8fb939291f76d9d03.1227562829.git.inaky@linux.intel.com>
References: <cover.1227562829.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:13165 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753252AbYKXVvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 16:51:20 -0500
In-Reply-To: <cover.1227562829.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides Makefile and KConfig for the WiMAX stack,
integrating them into the networking stack's Makefile, Kconfig and
doc-book templates.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 Documentation/DocBook/networking.tmpl |    8 ++++++++
 drivers/net/Kconfig                   |    2 ++
 drivers/net/Makefile                  |    1 +
 drivers/net/wimax/Kconfig             |   33 +++++++++++++++++++++++++++++++++
 drivers/net/wimax/Makefile            |   12 ++++++++++++
 5 files changed, 56 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/wimax/Kconfig
 create mode 100644 drivers/net/wimax/Makefile

diff --git a/Documentation/DocBook/networking.tmpl b/Documentation/DocBook/networking.tmpl
index f24f9e8..ee2d66d 100644
--- a/Documentation/DocBook/networking.tmpl
+++ b/Documentation/DocBook/networking.tmpl
@@ -101,6 +101,14 @@ X!Enet/core/wireless.c
      <sect1><title>Synchronous PPP</title>
 !Edrivers/net/wan/syncppp.c
      </sect1>
+     <sect1><title>WiMAX</title>
+!Edrivers/net/wimax/op-msg.c
+!Edrivers/net/wimax/op-reset.c
+!Edrivers/net/wimax/op-rfkill.c
+!Edrivers/net/wimax/stack.c
+!Iinclude/net/wimax.h
+!Iinclude/linux/wimax.h
+     </sect1>
   </chapter>
 
 </book>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 11f143f..f413d58 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2584,6 +2584,8 @@ source "drivers/net/tokenring/Kconfig"
 
 source "drivers/net/wireless/Kconfig"
 
+source "drivers/net/wimax/Kconfig"
+
 source "drivers/net/usb/Kconfig"
 
 source "drivers/net/pcmcia/Kconfig"
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index f19acf8..3885561 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -262,3 +262,4 @@ obj-$(CONFIG_NIU) += niu.o
 obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 obj-$(CONFIG_SFC) += sfc/
 
+obj-$(CONFIG_WIMAX) += wimax/
diff --git a/drivers/net/wimax/Kconfig b/drivers/net/wimax/Kconfig
new file mode 100644
index 0000000..98d4c27
--- /dev/null
+++ b/drivers/net/wimax/Kconfig
@@ -0,0 +1,33 @@
+#
+# WiMAX LAN device configuration
+#
+
+menuconfig WIMAX
+       tristate "WiMAX device support"
+       help
+
+         Select to configure support for devices that provide wireless
+         broadband connectivity using the WiMAX protocol (IEEE 802.16).
+
+         Please note that most of these devices require signing up for
+         a service plan with a provider.
+
+         If unsure, it is safe to select M (module).
+
+config WIMAX_DEBUG_LEVEL
+       int "WiMAX debug level"
+       depends on WIMAX
+       default 8
+       help
+
+         Select the maximum debug verbosity level to be compiled into
+         the WiMAX stack code.
+
+         By default, debug messages are disabled at runtime and can be
+         selectively enabled for different parts of the code using the
+         sysfs debug-levels file.
+
+         If set at zero, this will compile out all the debug code.
+
+         It is recommended that it is left at 8.
+
diff --git a/drivers/net/wimax/Makefile b/drivers/net/wimax/Makefile
new file mode 100644
index 0000000..22d5a28
--- /dev/null
+++ b/drivers/net/wimax/Makefile
@@ -0,0 +1,12 @@
+
+obj-$(CONFIG_WIMAX)		+= wimax.o
+
+wimax-objs :=		\
+	id-table.o	\
+	op-msg.o	\
+	op-open.o	\
+	op-reset.o	\
+	op-rfkill.o	\
+	stack.o
+
+
-- 
1.5.6.5

