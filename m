From: Gustavo Zacarias <gustavo@zacarias.com.ar>
Subject: [PATCH] iproute2: bump to version 4.1.0
Date: Sat, 27 Jun 2015 08:15:51 -0300
Message-ID: <1435403751-17245-2-git-send-email-gustavo@zacarias.com.ar>
References: <1435403751-17245-1-git-send-email-gustavo@zacarias.com.ar>
Cc: Gustavo Zacarias <gustavo@zacarias.com.ar>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.zacarias.com.ar ([176.9.42.171]:39876 "EHLO
	www.zacarias.com.ar" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753367AbbF0LQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jun 2015 07:16:14 -0400
In-Reply-To: <1435403751-17245-1-git-send-email-gustavo@zacarias.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Gustavo Zacarias <gustavo@zacarias.com.ar>
---
 ...c-make-build-conditional-on-having-libmnl.patch | 33 ++++++++++++++++++++++
 package/iproute2/iproute2.hash                     |  2 +-
 package/iproute2/iproute2.mk                       |  6 +++-
 3 files changed, 39 insertions(+), 2 deletions(-)
 create mode 100644 package/iproute2/0001-tipc-make-build-conditional-on-having-libmnl.patch

diff --git a/package/iproute2/0001-tipc-make-build-conditional-on-having-libmnl.patch b/package/iproute2/0001-tipc-make-build-conditional-on-having-libmnl.patch
new file mode 100644
index 0000000..ccd1daf
--- /dev/null
+++ b/package/iproute2/0001-tipc-make-build-conditional-on-having-libmnl.patch
@@ -0,0 +1,33 @@
+From db17dd9728b77485f26abb1ac5fcda65130f4a8d Mon Sep 17 00:00:00 2001
+From: Gustavo Zacarias <gustavo@zacarias.com.ar>
+Date: Sat, 27 Jun 2015 08:08:51 -0300
+Subject: [PATCHv2 iproute2] tipc: make build conditional on having libmnl
+
+Signed-off-by: Gustavo Zacarias <gustavo@zacarias.com.ar>
+---
+ tipc/Makefile | 5 +++++
+ 1 file changed, 5 insertions(+)
+
+diff --git a/tipc/Makefile b/tipc/Makefile
+index 4bda8c5..b3ef9b9 100644
+--- a/tipc/Makefile
++++ b/tipc/Makefile
+@@ -1,3 +1,6 @@
++include ../Config
++ifeq ($(HAVE_MNL),y)
++
+ TIPCOBJ=bearer.o \
+     cmdl.o link.o \
+     media.o misc.o \
+@@ -8,6 +11,8 @@ TIPCOBJ=bearer.o \
+ TARGETS=tipc
+ LDLIBS += -lmnl
+ 
++endif
++
+ all: $(TARGETS) $(LIBS)
+ 
+ tipc: $(TIPCOBJ)
+-- 
+2.3.6
+
diff --git a/package/iproute2/iproute2.hash b/package/iproute2/iproute2.hash
index 336d6b6..659e275 100644
--- a/package/iproute2/iproute2.hash
+++ b/package/iproute2/iproute2.hash
@@ -1,2 +1,2 @@
 # From https://kernel.org/pub/linux/utils/net/iproute2/sha256sums.asc
-sha256	5cd06eb1050b858b308b65705725042bb566fd261135e35a73dafb48cd632618	iproute2-4.0.0.tar.xz
+sha256	d1326696c6a8f81ba66aaf48d858005cf280c81d3284d8d2c99748e3d0746146	iproute2-4.1.0.tar.xz
diff --git a/package/iproute2/iproute2.mk b/package/iproute2/iproute2.mk
index a8f4400..dabc8b4 100644
--- a/package/iproute2/iproute2.mk
+++ b/package/iproute2/iproute2.mk
@@ -4,7 +4,7 @@
 #
 ################################################################################
 
-IPROUTE2_VERSION = 4.0.0
+IPROUTE2_VERSION = 4.1.0
 IPROUTE2_SOURCE = iproute2-$(IPROUTE2_VERSION).tar.xz
 IPROUTE2_SITE = $(BR2_KERNEL_MIRROR)/linux/utils/net/iproute2
 IPROUTE2_DEPENDENCIES = host-bison host-flex host-pkgconf
@@ -17,6 +17,10 @@ ifeq ($(BR2_PACKAGE_BUSYBOX),y)
 IPROUTE2_DEPENDENCIES += busybox
 endif
 
+ifeq ($(BR2_PACKAGE_LIBMNL),y)
+IPROUTE2_DEPENDENCIES += libmnl
+endif
+
 # If we've got iptables enable xtables support for tc
 ifeq ($(BR2_PACKAGE_IPTABLES)x$(BR2_STATIC_LIBS),yx)
 IPROUTE2_DEPENDENCIES += iptables
-- 
2.3.6
