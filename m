From: sjur.brandeland@stericsson.com
Subject: [PATCH 1/2] caif: Kconfig and Makefile fixes
Date: Sat, 26 Jun 2010 23:31:28 +0200
Message-ID: <1277587889-17314-1-git-send-email-sjur.brandeland@stericsson.com>
References: <20100625.211223.232914661.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: sjurbr@gmail.com, netdev@vger.kernel.org, marcel@holtmann.org,
	daniel.martensson@stericsson.com, linus.walleij@stericsson.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eterpe-smout.broadpark.no ([80.202.8.16]:42651 "EHLO
	eterpe-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753669Ab0FZVbo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jun 2010 17:31:44 -0400
Received: from terra-smin.broadpark.no ([unknown] [80.202.8.13])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L4N00A0Y54UOO10@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Sat, 26 Jun 2010 23:31:42 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.68])
 by terra-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L4N00CHI54T00J0@terra-smin.broadpark.no> for
 netdev@vger.kernel.org; Sat, 26 Jun 2010 23:31:42 +0200 (CEST)
In-reply-to: <20100625.211223.232914661.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Use "depends on" instead of "if" in Kconfig files.
Fixed CAIF debug flag, and removed unnecessary clean-* options.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---

David Miller wrote:
>Surrounding a config options with "if XXX" protection is not the
>proper way to protect config options.  Simply add a proper "Depends"
>specification to it.

Thanks Dave,
I've updated the existing Kconfig files with "depends on" instead of "if".

 drivers/net/caif/Kconfig  |    5 +----
 drivers/net/caif/Makefile |   10 ++--------
 net/caif/Kconfig          |    7 ++-----
 net/caif/Makefile         |   14 ++------------
 4 files changed, 7 insertions(+), 29 deletions(-)

diff --git a/drivers/net/caif/Kconfig b/drivers/net/caif/Kconfig
index 0b28e01..6f33ee4 100644
--- a/drivers/net/caif/Kconfig
+++ b/drivers/net/caif/Kconfig
@@ -2,16 +2,13 @@
 # CAIF physical drivers
 #
 
-if CAIF
-
 comment "CAIF transport drivers"
 
 config CAIF_TTY
 	tristate "CAIF TTY transport driver"
+	depends on CAIF
 	default n
 	---help---
 	The CAIF TTY transport driver is a Line Discipline (ldisc)
 	identified as N_CAIF. When this ldisc is opened from user space
 	it will redirect the TTY's traffic into the CAIF stack.
-
-endif # CAIF
diff --git a/drivers/net/caif/Makefile b/drivers/net/caif/Makefile
index 52b6d1f..e6d3ca0 100644
--- a/drivers/net/caif/Makefile
+++ b/drivers/net/caif/Makefile
@@ -1,12 +1,6 @@
-ifeq ($(CONFIG_CAIF_DEBUG),1)
-CAIF_DBG_FLAGS := -DDEBUG
+ifeq ($(CONFIG_CAIF_DEBUG),y)
+EXTRA_CFLAGS += -DDEBUG
 endif
 
-KBUILD_EXTRA_SYMBOLS=net/caif/Module.symvers
-
-ccflags-y := $(CAIF_FLAGS) $(CAIF_DBG_FLAGS)
-clean-dirs:= .tmp_versions
-clean-files:= Module.symvers modules.order *.cmd *~ \
-
 # Serial interface
 obj-$(CONFIG_CAIF_TTY) += caif_serial.o
diff --git a/net/caif/Kconfig b/net/caif/Kconfig
index ed65178..529750d 100644
--- a/net/caif/Kconfig
+++ b/net/caif/Kconfig
@@ -21,19 +21,18 @@ menuconfig CAIF
 	See Documentation/networking/caif for a further explanation on how to
 	use and configure CAIF.
 
-if CAIF
-
 config  CAIF_DEBUG
 	bool "Enable Debug"
+	depends on CAIF
 	default n
 	--- help ---
 	Enable the inclusion of debug code in the CAIF stack.
 	Be aware that doing this will impact performance.
 	If unsure say N.
 
-
 config CAIF_NETDEV
 	tristate "CAIF GPRS Network device"
+	depends on CAIF
 	default CAIF
 	---help---
 	Say Y if you will be using a CAIF based GPRS network device.
@@ -41,5 +40,3 @@ config CAIF_NETDEV
 	If you select to build it as a built-in then the main CAIF device must
 	also be a built-in.
 	If unsure say Y.
-
-endif
diff --git a/net/caif/Makefile b/net/caif/Makefile
index 34852af..f87481f 100644
--- a/net/caif/Makefile
+++ b/net/caif/Makefile
@@ -1,23 +1,13 @@
-ifeq ($(CONFIG_CAIF_DEBUG),1)
-CAIF_DBG_FLAGS := -DDEBUG
+ifeq ($(CONFIG_CAIF_DEBUG),y)
+EXTRA_CFLAGS += -DDEBUG
 endif
 
-ccflags-y := $(CAIF_FLAGS) $(CAIF_DBG_FLAGS)
-
 caif-objs := caif_dev.o \
 	cfcnfg.o cfmuxl.o cfctrl.o  \
 	cffrml.o cfveil.o cfdbgl.o\
 	cfserl.o cfdgml.o  \
 	cfrfml.o cfvidl.o cfutill.o \
 	cfsrvl.o cfpkt_skbuff.o caif_config_util.o
-clean-dirs:= .tmp_versions
-
-clean-files:= \
-	Module.symvers \
-	modules.order \
-	*.cmd \
-	*.o \
-	*~
 
 obj-$(CONFIG_CAIF) += caif.o
 obj-$(CONFIG_CAIF_NETDEV) += chnl_net.o
-- 
1.6.3.3

