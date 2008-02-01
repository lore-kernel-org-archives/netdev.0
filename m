From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 3/7] ctcm: infrastructure for replaced ctc driver
Date: Fri, 01 Feb 2008 15:51:31 +0100
Message-ID: <20080201145257.998609000@linux.vnet.ibm.com>
References: <20080201145128.462823000@linux.vnet.ibm.com>
Cc: Peter Tiedemann <ptiedem@de.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:52754 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755251AbYBAOxC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 09:53:02 -0500
Content-Disposition: inline; filename=ctcm_infrastructure.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Tiedemann <ptiedem@de.ibm.com>

establish base stuff for the replaced ctc driver, i.e. Kconfig and
Makefile adaptions
    arch/s390/defconfig
    drivers/s390/net/Kconfig
    drivers/s390/net/Makefile

Signed-off-by: Peter Tiedemann <ptiedem@de.ibm.com>
Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 drivers/s390/net/Kconfig  |   12 +++++++-----
 drivers/s390/net/Makefile |    5 ++---
 2 files changed, 9 insertions(+), 8 deletions(-)

Index: linux-2.6-uschi/drivers/s390/net/Makefile
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/Makefile
+++ linux-2.6-uschi/drivers/s390/net/Makefile
@@ -2,11 +2,10 @@
 # S/390 network devices
 #
 
-ctc-objs := ctcmain.o ctcdbug.o
-
+ctcm-objs := ctcm_main.o ctcm_fsms.o ctcm_mpc.o ctcm_sysfs.o ctcm_dbug.o
+obj-$(CONFIG_CTCM) += ctcm.o fsm.o cu3088.o
 obj-$(CONFIG_NETIUCV) += netiucv.o fsm.o
 obj-$(CONFIG_SMSGIUCV) += smsgiucv.o
-obj-$(CONFIG_CTC) += ctc.o fsm.o cu3088.o
 obj-$(CONFIG_LCS) += lcs.o cu3088.o
 obj-$(CONFIG_CLAW) += claw.o cu3088.o
 qeth-y := qeth_main.o qeth_mpc.o qeth_sys.o qeth_eddp.o 
Index: linux-2.6-uschi/drivers/s390/net/Kconfig
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/Kconfig
+++ linux-2.6-uschi/drivers/s390/net/Kconfig
@@ -11,15 +11,17 @@ config LCS
 	   To compile as a module, choose M. The module name is lcs.ko.
 	   If you do not know what it is, it's safe to choose Y.
 
-config CTC
-	tristate "CTC device support"
+config CTCM
+	tristate "CTC and MPC SNA device support"
 	depends on CCW && NETDEVICES
 	help
 	  Select this option if you want to use channel-to-channel
 	  point-to-point networking on IBM System z.
 	  This device driver supports real CTC coupling using ESCON.
 	  It also supports virtual CTCs when running under VM.
-	  To compile as a module, choose M. The module name is ctc.ko.
+	  This driver also supports channel-to-channel MPC SNA devices.
+	  MPC is an SNA protocol device used by Communication Server for Linux.
+	  To compile as a module, choose M. The module name is ctcm.ko.
 	  To compile into the kernel, choose Y.
 	  If you do not need any channel-to-channel connection, choose N.
 
@@ -84,7 +86,7 @@ config QETH_VLAN
 	  802.1q VLAN support in the qeth device driver.
 
 config CCWGROUP
- 	tristate
-	default (LCS || CTC || QETH)
+	tristate
+	default (LCS || CTCM || QETH)
 
 endmenu

-- 
