From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 2/2] isdn: i4l: move active-isdn drivers to staging
Date: Wed,  2 Mar 2016 20:06:46 +0100
Message-ID: <1456945629-1793533-2-git-send-email-arnd@arndb.de>
References: <1456945629-1793533-1-git-send-email-arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>,
	Jonathan Corbet <corbet@lwn.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@driverdev.osuosl.org
To: Karsten Keil <isdn@linux-pingi.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:57863 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753056AbcCBTI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 14:08:27 -0500
In-Reply-To: <1456945629-1793533-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The icn, act2000 and pcbit drivers are all for very old hardware,
and it is highly unlikely that anyone is actually still using them
on modern kernels, if at all.

All three drivers apparently are for hardware that predates PCI
being the common connector, as they are ISA-only and active
PCI ISDN cards were widely available in the 1990s.

Looking through the git logs, it I cannot find any indication of a
patch to any of these drivers that has been tested on real hardware,
only cleanups or global API changes.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 Documentation/isdn/00-INDEX                                 |  8 --------
 drivers/isdn/Makefile                                       |  3 ---
 drivers/isdn/i4l/Kconfig                                    | 10 ----------
 drivers/staging/Kconfig                                     |  2 ++
 drivers/staging/Makefile                                    |  1 +
 .../staging/i4l/Documentation}/README.act2000               |  0
 .../isdn => drivers/staging/i4l/Documentation}/README.icn   |  0
 .../isdn => drivers/staging/i4l/Documentation}/README.pcbit |  0
 .../isdn => drivers/staging/i4l/Documentation}/README.sc    |  0
 drivers/staging/i4l/Kconfig                                 | 13 +++++++++++++
 drivers/staging/i4l/Makefile                                |  5 +++++
 drivers/staging/i4l/TODO                                    |  3 +++
 drivers/{isdn => staging/i4l}/act2000/Kconfig               |  0
 drivers/{isdn => staging/i4l}/act2000/Makefile              |  0
 drivers/{isdn => staging/i4l}/act2000/act2000.h             |  0
 drivers/{isdn => staging/i4l}/act2000/act2000_isa.c         |  0
 drivers/{isdn => staging/i4l}/act2000/act2000_isa.h         |  0
 drivers/{isdn => staging/i4l}/act2000/capi.c                |  0
 drivers/{isdn => staging/i4l}/act2000/capi.h                |  0
 drivers/{isdn => staging/i4l}/act2000/module.c              |  0
 drivers/{isdn => staging/i4l}/icn/Kconfig                   |  0
 drivers/{isdn => staging/i4l}/icn/Makefile                  |  0
 drivers/{isdn => staging/i4l}/icn/icn.c                     |  0
 drivers/{isdn => staging/i4l}/icn/icn.h                     |  0
 drivers/{isdn => staging/i4l}/pcbit/Kconfig                 |  0
 drivers/{isdn => staging/i4l}/pcbit/Makefile                |  0
 drivers/{isdn => staging/i4l}/pcbit/callbacks.c             |  0
 drivers/{isdn => staging/i4l}/pcbit/callbacks.h             |  0
 drivers/{isdn => staging/i4l}/pcbit/capi.c                  |  0
 drivers/{isdn => staging/i4l}/pcbit/capi.h                  |  0
 drivers/{isdn => staging/i4l}/pcbit/drv.c                   |  0
 drivers/{isdn => staging/i4l}/pcbit/edss1.c                 |  0
 drivers/{isdn => staging/i4l}/pcbit/edss1.h                 |  0
 drivers/{isdn => staging/i4l}/pcbit/layer2.c                |  0
 drivers/{isdn => staging/i4l}/pcbit/layer2.h                |  0
 drivers/{isdn => staging/i4l}/pcbit/module.c                |  0
 drivers/{isdn => staging/i4l}/pcbit/pcbit.h                 |  0
 37 files changed, 24 insertions(+), 21 deletions(-)
 rename {Documentation/isdn => drivers/staging/i4l/Documentation}/README.act2000 (100%)
 rename {Documentation/isdn => drivers/staging/i4l/Documentation}/README.icn (100%)
 rename {Documentation/isdn => drivers/staging/i4l/Documentation}/README.pcbit (100%)
 rename {Documentation/isdn => drivers/staging/i4l/Documentation}/README.sc (100%)
 create mode 100644 drivers/staging/i4l/Kconfig
 create mode 100644 drivers/staging/i4l/Makefile
 create mode 100644 drivers/staging/i4l/TODO
 rename drivers/{isdn => staging/i4l}/act2000/Kconfig (100%)
 rename drivers/{isdn => staging/i4l}/act2000/Makefile (100%)
 rename drivers/{isdn => staging/i4l}/act2000/act2000.h (100%)
 rename drivers/{isdn => staging/i4l}/act2000/act2000_isa.c (100%)
 rename drivers/{isdn => staging/i4l}/act2000/act2000_isa.h (100%)
 rename drivers/{isdn => staging/i4l}/act2000/capi.c (100%)
 rename drivers/{isdn => staging/i4l}/act2000/capi.h (100%)
 rename drivers/{isdn => staging/i4l}/act2000/module.c (100%)
 rename drivers/{isdn => staging/i4l}/icn/Kconfig (100%)
 rename drivers/{isdn => staging/i4l}/icn/Makefile (100%)
 rename drivers/{isdn => staging/i4l}/icn/icn.c (100%)
 rename drivers/{isdn => staging/i4l}/icn/icn.h (100%)
 rename drivers/{isdn => staging/i4l}/pcbit/Kconfig (100%)
 rename drivers/{isdn => staging/i4l}/pcbit/Makefile (100%)
 rename drivers/{isdn => staging/i4l}/pcbit/callbacks.c (100%)
 rename drivers/{isdn => staging/i4l}/pcbit/callbacks.h (100%)
 rename drivers/{isdn => staging/i4l}/pcbit/capi.c (100%)
 rename drivers/{isdn => staging/i4l}/pcbit/capi.h (100%)
 rename drivers/{isdn => staging/i4l}/pcbit/drv.c (100%)
 rename drivers/{isdn => staging/i4l}/pcbit/edss1.c (100%)
 rename drivers/{isdn => staging/i4l}/pcbit/edss1.h (100%)
 rename drivers/{isdn => staging/i4l}/pcbit/layer2.c (100%)
 rename drivers/{isdn => staging/i4l}/pcbit/layer2.h (100%)
 rename drivers/{isdn => staging/i4l}/pcbit/module.c (100%)
 rename drivers/{isdn => staging/i4l}/pcbit/pcbit.h (100%)

diff --git a/Documentation/isdn/00-INDEX b/Documentation/isdn/00-INDEX
index e87e336f590e..2d1889b6c1fa 100644
--- a/Documentation/isdn/00-INDEX
+++ b/Documentation/isdn/00-INDEX
@@ -16,8 +16,6 @@ README.FAQ
 	- general info for FAQ.
 README.HiSax
 	- info on the HiSax driver which replaces the old teles.
-README.act2000
-	- info on driver for IBM ACT-2000 card.
 README.audio
 	- info for running audio over ISDN.
 README.avmb1
@@ -34,14 +32,8 @@ README.hfc-pci
 	- info on hfc-pci based cards.
 README.hysdn
         - info on driver for Hypercope active HYSDN cards
-README.icn
-	- info on the ICN-ISDN-card and its driver.
 README.mISDN
 	- info on the Modular ISDN subsystem (mISDN)
-README.pcbit
-	- info on the PCBIT-D ISDN adapter and driver.
-README.sc
-	- info on driver for Spellcaster cards.
 README.syncppp
 	- info on running Sync PPP over ISDN.
 README.x25
diff --git a/drivers/isdn/Makefile b/drivers/isdn/Makefile
index 91c81965e7ca..c32e45826c2c 100644
--- a/drivers/isdn/Makefile
+++ b/drivers/isdn/Makefile
@@ -8,9 +8,6 @@ obj-$(CONFIG_MISDN)			+= mISDN/
 obj-$(CONFIG_ISDN)			+= hardware/
 obj-$(CONFIG_ISDN_DIVERSION)		+= divert/
 obj-$(CONFIG_ISDN_DRV_HISAX)		+= hisax/
-obj-$(CONFIG_ISDN_DRV_ICN)		+= icn/
-obj-$(CONFIG_ISDN_DRV_PCBIT)		+= pcbit/
 obj-$(CONFIG_ISDN_DRV_LOOP)		+= isdnloop/
-obj-$(CONFIG_ISDN_DRV_ACT2000)		+= act2000/
 obj-$(CONFIG_HYSDN)			+= hysdn/
 obj-$(CONFIG_ISDN_DRV_GIGASET)		+= gigaset/
diff --git a/drivers/isdn/i4l/Kconfig b/drivers/isdn/i4l/Kconfig
index f5b714cd7618..68e54d9f2f53 100644
--- a/drivers/isdn/i4l/Kconfig
+++ b/drivers/isdn/i4l/Kconfig
@@ -123,16 +123,6 @@ comment "ISDN4Linux hardware drivers"
 
 source "drivers/isdn/hisax/Kconfig"
 
-
-menu "Active cards"
-
-source "drivers/isdn/icn/Kconfig"
-
-source "drivers/isdn/pcbit/Kconfig"
-
-source "drivers/isdn/act2000/Kconfig"
-
-endmenu
 # end ISDN_I4L
 endif
 
diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
index 5f9a97a77393..ff894bc63b3b 100644
--- a/drivers/staging/Kconfig
+++ b/drivers/staging/Kconfig
@@ -104,4 +104,6 @@ source "drivers/staging/wilc1000/Kconfig"
 
 source "drivers/staging/most/Kconfig"
 
+source "drivers/staging/i4l/Kconfig"
+
 endif # STAGING
diff --git a/drivers/staging/Makefile b/drivers/staging/Makefile
index b3920c224013..8242923371ad 100644
--- a/drivers/staging/Makefile
+++ b/drivers/staging/Makefile
@@ -41,3 +41,4 @@ obj-$(CONFIG_FB_TFT)		+= fbtft/
 obj-$(CONFIG_FSL_MC_BUS)	+= fsl-mc/
 obj-$(CONFIG_WILC1000)		+= wilc1000/
 obj-$(CONFIG_MOST)		+= most/
+obj-$(CONFIG_ISDN_I4L)		+= i4l/
diff --git a/Documentation/isdn/README.act2000 b/drivers/staging/i4l/Documentation/README.act2000
similarity index 100%
rename from Documentation/isdn/README.act2000
rename to drivers/staging/i4l/Documentation/README.act2000
diff --git a/Documentation/isdn/README.icn b/drivers/staging/i4l/Documentation/README.icn
similarity index 100%
rename from Documentation/isdn/README.icn
rename to drivers/staging/i4l/Documentation/README.icn
diff --git a/Documentation/isdn/README.pcbit b/drivers/staging/i4l/Documentation/README.pcbit
similarity index 100%
rename from Documentation/isdn/README.pcbit
rename to drivers/staging/i4l/Documentation/README.pcbit
diff --git a/Documentation/isdn/README.sc b/drivers/staging/i4l/Documentation/README.sc
similarity index 100%
rename from Documentation/isdn/README.sc
rename to drivers/staging/i4l/Documentation/README.sc
diff --git a/drivers/staging/i4l/Kconfig b/drivers/staging/i4l/Kconfig
new file mode 100644
index 000000000000..920216e88de7
--- /dev/null
+++ b/drivers/staging/i4l/Kconfig
@@ -0,0 +1,13 @@
+#
+# Old ISDN4Linux config
+#
+menu "Old ISDN4Linux (deprecated)"
+	depends on ISDN_I4L
+
+source "drivers/staging/i4l/icn/Kconfig"
+
+source "drivers/staging/i4l/pcbit/Kconfig"
+
+source "drivers/staging/i4l/act2000/Kconfig"
+
+endmenu
diff --git a/drivers/staging/i4l/Makefile b/drivers/staging/i4l/Makefile
new file mode 100644
index 000000000000..158b87093db5
--- /dev/null
+++ b/drivers/staging/i4l/Makefile
@@ -0,0 +1,5 @@
+# Makefile for the old ISDN I4L subsystem and device drivers.
+
+obj-$(CONFIG_ISDN_DRV_ICN)		+= icn/
+obj-$(CONFIG_ISDN_DRV_PCBIT)		+= pcbit/
+obj-$(CONFIG_ISDN_DRV_ACT2000)		+= act2000/
diff --git a/drivers/staging/i4l/TODO b/drivers/staging/i4l/TODO
new file mode 100644
index 000000000000..6fe2c08bec7a
--- /dev/null
+++ b/drivers/staging/i4l/TODO
@@ -0,0 +1,3 @@
+* The icn, pcbit and act2000 drivers are dead, remove them in 2017
+  after another longterm kernel has been released, just in the
+  unlikely case someone still has this hardware.
diff --git a/drivers/isdn/act2000/Kconfig b/drivers/staging/i4l/act2000/Kconfig
similarity index 100%
rename from drivers/isdn/act2000/Kconfig
rename to drivers/staging/i4l/act2000/Kconfig
diff --git a/drivers/isdn/act2000/Makefile b/drivers/staging/i4l/act2000/Makefile
similarity index 100%
rename from drivers/isdn/act2000/Makefile
rename to drivers/staging/i4l/act2000/Makefile
diff --git a/drivers/isdn/act2000/act2000.h b/drivers/staging/i4l/act2000/act2000.h
similarity index 100%
rename from drivers/isdn/act2000/act2000.h
rename to drivers/staging/i4l/act2000/act2000.h
diff --git a/drivers/isdn/act2000/act2000_isa.c b/drivers/staging/i4l/act2000/act2000_isa.c
similarity index 100%
rename from drivers/isdn/act2000/act2000_isa.c
rename to drivers/staging/i4l/act2000/act2000_isa.c
diff --git a/drivers/isdn/act2000/act2000_isa.h b/drivers/staging/i4l/act2000/act2000_isa.h
similarity index 100%
rename from drivers/isdn/act2000/act2000_isa.h
rename to drivers/staging/i4l/act2000/act2000_isa.h
diff --git a/drivers/isdn/act2000/capi.c b/drivers/staging/i4l/act2000/capi.c
similarity index 100%
rename from drivers/isdn/act2000/capi.c
rename to drivers/staging/i4l/act2000/capi.c
diff --git a/drivers/isdn/act2000/capi.h b/drivers/staging/i4l/act2000/capi.h
similarity index 100%
rename from drivers/isdn/act2000/capi.h
rename to drivers/staging/i4l/act2000/capi.h
diff --git a/drivers/isdn/act2000/module.c b/drivers/staging/i4l/act2000/module.c
similarity index 100%
rename from drivers/isdn/act2000/module.c
rename to drivers/staging/i4l/act2000/module.c
diff --git a/drivers/isdn/icn/Kconfig b/drivers/staging/i4l/icn/Kconfig
similarity index 100%
rename from drivers/isdn/icn/Kconfig
rename to drivers/staging/i4l/icn/Kconfig
diff --git a/drivers/isdn/icn/Makefile b/drivers/staging/i4l/icn/Makefile
similarity index 100%
rename from drivers/isdn/icn/Makefile
rename to drivers/staging/i4l/icn/Makefile
diff --git a/drivers/isdn/icn/icn.c b/drivers/staging/i4l/icn/icn.c
similarity index 100%
rename from drivers/isdn/icn/icn.c
rename to drivers/staging/i4l/icn/icn.c
diff --git a/drivers/isdn/icn/icn.h b/drivers/staging/i4l/icn/icn.h
similarity index 100%
rename from drivers/isdn/icn/icn.h
rename to drivers/staging/i4l/icn/icn.h
diff --git a/drivers/isdn/pcbit/Kconfig b/drivers/staging/i4l/pcbit/Kconfig
similarity index 100%
rename from drivers/isdn/pcbit/Kconfig
rename to drivers/staging/i4l/pcbit/Kconfig
diff --git a/drivers/isdn/pcbit/Makefile b/drivers/staging/i4l/pcbit/Makefile
similarity index 100%
rename from drivers/isdn/pcbit/Makefile
rename to drivers/staging/i4l/pcbit/Makefile
diff --git a/drivers/isdn/pcbit/callbacks.c b/drivers/staging/i4l/pcbit/callbacks.c
similarity index 100%
rename from drivers/isdn/pcbit/callbacks.c
rename to drivers/staging/i4l/pcbit/callbacks.c
diff --git a/drivers/isdn/pcbit/callbacks.h b/drivers/staging/i4l/pcbit/callbacks.h
similarity index 100%
rename from drivers/isdn/pcbit/callbacks.h
rename to drivers/staging/i4l/pcbit/callbacks.h
diff --git a/drivers/isdn/pcbit/capi.c b/drivers/staging/i4l/pcbit/capi.c
similarity index 100%
rename from drivers/isdn/pcbit/capi.c
rename to drivers/staging/i4l/pcbit/capi.c
diff --git a/drivers/isdn/pcbit/capi.h b/drivers/staging/i4l/pcbit/capi.h
similarity index 100%
rename from drivers/isdn/pcbit/capi.h
rename to drivers/staging/i4l/pcbit/capi.h
diff --git a/drivers/isdn/pcbit/drv.c b/drivers/staging/i4l/pcbit/drv.c
similarity index 100%
rename from drivers/isdn/pcbit/drv.c
rename to drivers/staging/i4l/pcbit/drv.c
diff --git a/drivers/isdn/pcbit/edss1.c b/drivers/staging/i4l/pcbit/edss1.c
similarity index 100%
rename from drivers/isdn/pcbit/edss1.c
rename to drivers/staging/i4l/pcbit/edss1.c
diff --git a/drivers/isdn/pcbit/edss1.h b/drivers/staging/i4l/pcbit/edss1.h
similarity index 100%
rename from drivers/isdn/pcbit/edss1.h
rename to drivers/staging/i4l/pcbit/edss1.h
diff --git a/drivers/isdn/pcbit/layer2.c b/drivers/staging/i4l/pcbit/layer2.c
similarity index 100%
rename from drivers/isdn/pcbit/layer2.c
rename to drivers/staging/i4l/pcbit/layer2.c
diff --git a/drivers/isdn/pcbit/layer2.h b/drivers/staging/i4l/pcbit/layer2.h
similarity index 100%
rename from drivers/isdn/pcbit/layer2.h
rename to drivers/staging/i4l/pcbit/layer2.h
diff --git a/drivers/isdn/pcbit/module.c b/drivers/staging/i4l/pcbit/module.c
similarity index 100%
rename from drivers/isdn/pcbit/module.c
rename to drivers/staging/i4l/pcbit/module.c
diff --git a/drivers/isdn/pcbit/pcbit.h b/drivers/staging/i4l/pcbit/pcbit.h
similarity index 100%
rename from drivers/isdn/pcbit/pcbit.h
rename to drivers/staging/i4l/pcbit/pcbit.h
-- 
2.7.0
