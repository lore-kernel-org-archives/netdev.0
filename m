From: Tracey Dent <tdent48227@gmail.com>
Subject: [PATCH] Net: ceph: Makefile: Remove unnessary code
Date: Sun, 21 Nov 2010 20:23:50 -0500
Message-ID: <1290389030-2743-1-git-send-email-tdent48227@gmail.com>
Cc: ceph-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	Tracey Dent <tdent48227@gmail.com>
To: sage@newdream.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the if and else conditional because the code is in mainline and there
is no need in it being there.

Signed-off-by: Tracey Dent <tdent48227@gmail.com>
---
 net/ceph/Makefile |   22 ----------------------
 1 files changed, 0 insertions(+), 22 deletions(-)

diff --git a/net/ceph/Makefile b/net/ceph/Makefile
index 153bdec..e87ef43 100644
--- a/net/ceph/Makefile
+++ b/net/ceph/Makefile
@@ -1,9 +1,6 @@
 #
 # Makefile for CEPH filesystem.
 #
-
-ifneq ($(KERNELRELEASE),)
-
 obj-$(CONFIG_CEPH_LIB) += libceph.o
 
 libceph-y := ceph_common.o messenger.o msgpool.o buffer.o pagelist.o \
@@ -16,22 +13,3 @@ libceph-y := ceph_common.o messenger.o msgpool.o buffer.o pagelist.o \
 	ceph_fs.o ceph_strings.o ceph_hash.o \
 	pagevec.o
 
-else
-#Otherwise we were called directly from the command
-# line; invoke the kernel build system.
-
-KERNELDIR ?= /lib/modules/$(shell uname -r)/build
-PWD := $(shell pwd)
-
-default: all
-
-all:
-	$(MAKE) -C $(KERNELDIR) M=$(PWD) CONFIG_CEPH_LIB=m modules
-
-modules_install:
-	$(MAKE) -C $(KERNELDIR) M=$(PWD) CONFIG_CEPH_LIB=m modules_install
-
-clean:
-	$(MAKE) -C $(KERNELDIR) M=$(PWD) clean
-
-endif
-- 
1.7.3.2.245.g03276
