From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 03/15] de6xx: relocate ancient parallel port eth drivers to legacy
Date: Thu, 28 Oct 2010 21:19:07 -0400
Message-ID: <1288315159-1350-4-git-send-email-paul.gortmaker@windriver.com>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33965 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755651Ab0J2BT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 21:19:27 -0400
In-Reply-To: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These old drivers pre-date USB, coming from the early 1990's
and with the legacy parallel port also now largely gone from
any current hardware, these need to be relocated to the legacy
directory, since they won't have been in active use for years.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/Kconfig              |   30 ------------------------------
 drivers/net/Makefile             |    2 --
 drivers/net/legacy/Kconfig       |   30 ++++++++++++++++++++++++++++++
 drivers/net/legacy/Makefile      |    2 ++
 drivers/net/{ => legacy}/de600.c |    0
 drivers/net/{ => legacy}/de600.h |    0
 drivers/net/{ => legacy}/de620.c |    0
 drivers/net/{ => legacy}/de620.h |    0
 8 files changed, 32 insertions(+), 32 deletions(-)
 rename drivers/net/{ => legacy}/de600.c (100%)
 rename drivers/net/{ => legacy}/de600.h (100%)
 rename drivers/net/{ => legacy}/de620.c (100%)
 rename drivers/net/{ => legacy}/de620.h (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index cb7f3f4..eb65a3a 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1867,36 +1867,6 @@ config ATP
 	  To compile this driver as a module, choose M here: the module
 	  will be called atp.
 
-config DE600
-	tristate "D-Link DE600 pocket adapter support"
-	depends on NET_POCKET && PARPORT
-	---help---
-	  This is a network (Ethernet) device which attaches to your parallel
-	  port. Read <file:Documentation/networking/DLINK.txt> as well as the
-	  Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>, if you want to use
-	  this. It is possible to have several devices share a single parallel
-	  port and it is safe to compile the corresponding drivers into the
-	  kernel.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called de600.
-
-config DE620
-	tristate "D-Link DE620 pocket adapter support"
-	depends on NET_POCKET && PARPORT
-	---help---
-	  This is a network (Ethernet) device which attaches to your parallel
-	  port. Read <file:Documentation/networking/DLINK.txt> as well as the
-	  Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>, if you want to use
-	  this. It is possible to have several devices share a single parallel
-	  port and it is safe to compile the corresponding drivers into the
-	  kernel.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called de620.
-
 config SGISEEQ
 	tristate "SGI Seeq ethernet controller support"
 	depends on SGI_HAS_SEEQ
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index eb99117..41594da 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -174,8 +174,6 @@ obj-$(CONFIG_DUMMY) += dummy.o
 obj-$(CONFIG_IFB) += ifb.o
 obj-$(CONFIG_MACVLAN) += macvlan.o
 obj-$(CONFIG_MACVTAP) += macvtap.o
-obj-$(CONFIG_DE600) += de600.o
-obj-$(CONFIG_DE620) += de620.o
 obj-$(CONFIG_LANCE) += lance.o
 obj-$(CONFIG_SUN3_82586) += sun3_82586.o
 obj-$(CONFIG_SUN3LANCE) += sun3lance.o
diff --git a/drivers/net/legacy/Kconfig b/drivers/net/legacy/Kconfig
index fa2d6f8..ef6fa1f 100644
--- a/drivers/net/legacy/Kconfig
+++ b/drivers/net/legacy/Kconfig
@@ -14,3 +14,33 @@ config EL1
 
 	  To compile this driver as a module, choose M here. The module
 	  will be called 3c501.
+
+config DE600
+	tristate "D-Link DE600 pocket adapter support"
+	depends on NET_POCKET && PARPORT
+	---help---
+	  This is a network (Ethernet) device which attaches to your parallel
+	  port. Read <file:Documentation/networking/DLINK.txt> as well as the
+	  Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>, if you want to use
+	  this. It is possible to have several devices share a single parallel
+	  port and it is safe to compile the corresponding drivers into the
+	  kernel.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called de600.
+
+config DE620
+	tristate "D-Link DE620 pocket adapter support"
+	depends on NET_POCKET && PARPORT
+	---help---
+	  This is a network (Ethernet) device which attaches to your parallel
+	  port. Read <file:Documentation/networking/DLINK.txt> as well as the
+	  Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>, if you want to use
+	  this. It is possible to have several devices share a single parallel
+	  port and it is safe to compile the corresponding drivers into the
+	  kernel.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called de620.
diff --git a/drivers/net/legacy/Makefile b/drivers/net/legacy/Makefile
index acbf0b2..e82ca16 100644
--- a/drivers/net/legacy/Makefile
+++ b/drivers/net/legacy/Makefile
@@ -3,3 +3,5 @@
 #
 
 obj-$(CONFIG_EL1) += 3c501.o
+obj-$(CONFIG_DE600) += de600.o
+obj-$(CONFIG_DE620) += de620.o
diff --git a/drivers/net/de600.c b/drivers/net/legacy/de600.c
similarity index 100%
rename from drivers/net/de600.c
rename to drivers/net/legacy/de600.c
diff --git a/drivers/net/de600.h b/drivers/net/legacy/de600.h
similarity index 100%
rename from drivers/net/de600.h
rename to drivers/net/legacy/de600.h
diff --git a/drivers/net/de620.c b/drivers/net/legacy/de620.c
similarity index 100%
rename from drivers/net/de620.c
rename to drivers/net/legacy/de620.c
diff --git a/drivers/net/de620.h b/drivers/net/legacy/de620.h
similarity index 100%
rename from drivers/net/de620.h
rename to drivers/net/legacy/de620.h
-- 
1.7.3.2.146.g2d444

