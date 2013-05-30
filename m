From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [PATCH v5 12/13] ARM: kirkwood: remove redundant DT board files
Date: Fri, 31 May 2013 00:28:56 +0200
Message-ID: <87txlknluf.fsf@natisbad.org>
References: <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com>
	<1369855975-21489-1-git-send-email-sebastian.hesselbarth@gmail.com>
	<1369855975-21489-13-git-send-email-sebastian.hesselbarth@gmail.com>
	<8738t4q1kv.fsf@natisbad.org>
	<20130530193708.GC31290@titan.lakedaemon.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mic92-1-81-57-185-249.fbx.proxad.net ([81.57.185.249]:57541
	"EHLO smtp.natisbad.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756190Ab3E3W22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 18:28:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Jason Cooper <jason@lakedaemon.net> writes:

>> For instance 6bd98481ab34 (arm: kirkwood: NETGEAR ReadyNAS Duo v2 init
>> PCIe via DT) currently sitting in jcooper/mvebu/pcie_kirkwood removes
>> the PCIE init routine in board-readynas.c, and yours remove ge00
>> init. With both applied, the whole file can go away.
>> 
>> AFAICT, this may be the case soon for:
>> 
>>  arch/arm/mach-kirkwood/board-iconnect.c   (36e5722089)
>>  arch/arm/mach-kirkwood/board-mplcec4.c    (9470fbfb8d)
>>  arch/arm/mach-kirkwood/board-nsa310.c     (40fa8e5da2)
>>  arch/arm/mach-kirkwood/board-readynas.c   (6bd98481ab)
>>  arch/arm/mach-kirkwood/board-ts219.c      (259e234608)
>
> Would you mind putting a patch together (for after v3.10 drops) to do
> this?  If you applied Sebastian's series on top of mvebu/pcie_kirkwood,
> that should get you almost there.  The last half of his series is going
> in after v3.10...

Something like the quick quilt-generated patch at the end of this email
(done after a dummy merge of Sebastian's set in mvebu/pcie_kirkwood)? I
will take a look at what remains after Sebastian's set hit one of your
branch but I guess he will have included most of what is in the patch to
help you with the merge.

Anyway, at the end here is what DT board files would remain:

$ ls -1 arch/arm/mach-kirkwood/board-*.c
arch/arm/mach-kirkwood/board-dnskw.c
arch/arm/mach-kirkwood/board-dt.c
arch/arm/mach-kirkwood/board-lsxl.c
arch/arm/mach-kirkwood/board-ts219.c

Just one question though: the removal of MACH_*_DT in Kconfig removes
the automatic selection of useful board specific options like
ARM_APPENDED_DTB, ARM_ATAG_DTB_COMPAT, POWER_RESET_RESTART,
POWER_RESET_QNAP. Is that expected?

> You may want to try merging in mvebu/boards and mvebu/soc.  Those have
> the changes to use dt for the restart and power-off drivers.  That'll
> allow us to empty out a few more board files.  mvebu/dt also has a patch
> from Valentin allowing us to remove the keymile board as well.

yes. After a merge w/ mvebu/boards to get restart and poweroff would
allow to get rid of board-ts219.c and board-lsxl.c, leaving mainly
board-dnskw.c.

Cheers,

a+

Index: linux/arch/arm/mach-kirkwood/board-iconnect.c
===================================================================
--- linux.orig/arch/arm/mach-kirkwood/board-iconnect.c	2013-05-30 23:38:53.652311676 +0200
+++ /dev/null	1970-01-01 00:00:00.000000000 +0000
@@ -1,15 +0,0 @@
-/*
- * arch/arm/mach-kirkwood/board-iconnect.c
- *
- * Iomega i-connect Board Setup
- *
- * This file is licensed under the terms of the GNU General Public
- * License version 2.  This program is licensed "as is" without any
- * warranty of any kind, whether express or implied.
- */
-
-#include <linux/kernel.h>
-#include <linux/init.h>
-#include <linux/of.h>
-#include "common.h"
-
Index: linux/arch/arm/mach-kirkwood/Makefile
===================================================================
--- linux.orig/arch/arm/mach-kirkwood/Makefile	2013-05-30 23:38:53.652311676 +0200
+++ linux/arch/arm/mach-kirkwood/Makefile	2013-05-30 23:38:53.644311636 +0200
@@ -19,9 +19,6 @@
 obj-$(CONFIG_MACH_TS41X)		+= ts41x-setup.o tsx1x-common.o
 
 obj-$(CONFIG_ARCH_KIRKWOOD_DT)		+= board-dt.o
-obj-$(CONFIG_MACH_DB88F628X_BP_DT)	+= board-db88f628x-bp.o
 obj-$(CONFIG_MACH_DLINK_KIRKWOOD_DT)	+= board-dnskw.o
 obj-$(CONFIG_MACH_LSXL_DT)		+= board-lsxl.o
-obj-$(CONFIG_MACH_MPLCEC4_DT)		+= board-mplcec4.o
-obj-$(CONFIG_MACH_READYNAS_DT)		+= board-readynas.o
 obj-$(CONFIG_MACH_TS219_DT)		+= board-ts219.o tsx1x-common.o
Index: linux/arch/arm/mach-kirkwood/board-db88f628x-bp.c
===================================================================
--- linux.orig/arch/arm/mach-kirkwood/board-db88f628x-bp.c	2013-05-30 23:38:53.652311676 +0200
+++ /dev/null	1970-01-01 00:00:00.000000000 +0000
@@ -1,24 +0,0 @@
-/*
- * Saeed Bishara <saeed@marvell.com>
- *
- * Marvell DB-88F628{1,2}-BP Development Board Setup
- *
- * This file is licensed under the terms of the GNU General Public
- * License version 2.  This program is licensed "as is" without any
- * warranty of any kind, whether express or implied.
- */
-
-#include <linux/kernel.h>
-#include <linux/init.h>
-#include <linux/of.h>
-#include <linux/mv643xx_eth.h>
-#include "common.h"
-
-static struct mv643xx_eth_platform_data db88f628x_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
-};
-
-void __init db88f628x_init(void)
-{
-	kirkwood_ge00_init(&db88f628x_ge00_data);
-}
Index: linux/arch/arm/mach-kirkwood/board-mplcec4.c
===================================================================
--- linux.orig/arch/arm/mach-kirkwood/board-mplcec4.c	2013-05-30 23:38:53.652311676 +0200
+++ /dev/null	1970-01-01 00:00:00.000000000 +0000
@@ -1,21 +0,0 @@
-/*
- * Copyright (C) 2012 MPL AG, Switzerland
- * Stefan Peter <s.peter@mpl.ch>
- *
- * arch/arm/mach-kirkwood/board-mplcec4.c
- *
- * This file is licensed under the terms of the GNU General Public
- * License version 2.  This program is licensed "as is" without any
- * warranty of any kind, whether express or implied.
- */
-
-#include <linux/kernel.h>
-#include <linux/init.h>
-#include "common.h"
-
-void __init mplcec4_init(void)
-{
-}
-
-
-
Index: linux/arch/arm/mach-kirkwood/board-readynas.c
===================================================================
--- linux.orig/arch/arm/mach-kirkwood/board-readynas.c	2013-05-30 23:38:53.652311676 +0200
+++ /dev/null	1970-01-01 00:00:00.000000000 +0000
@@ -1,21 +0,0 @@
-/*
- * NETGEAR ReadyNAS Duo v2 Board setup for drivers not already
- * converted to DT.
- *
- * Copyright (C) 2013, Arnaud EBALARD <arno@natisbad.org>
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#include <linux/kernel.h>
-#include <linux/init.h>
-#include <linux/platform_device.h>
-#include <mach/kirkwood.h>
-#include "common.h"
-
-void __init netgear_readynas_init(void)
-{
-}
Index: linux/arch/arm/mach-kirkwood/common.h
===================================================================
--- linux.orig/arch/arm/mach-kirkwood/common.h	2013-05-30 23:38:53.652311676 +0200
+++ linux/arch/arm/mach-kirkwood/common.h	2013-05-30 23:38:53.648311656 +0200
@@ -55,16 +55,6 @@
 void kirkwood_clk_init(void);
 
 /* board init functions for boards not fully converted to fdt */
-#ifdef CONFIG_MACH_DREAMPLUG_DT
-void dreamplug_init(void);
-#else
-static inline void dreamplug_init(void) {};
-#endif
-#ifdef CONFIG_MACH_GURUPLUG_DT
-void guruplug_dt_init(void);
-#else
-static inline void guruplug_dt_init(void) {};
-#endif
 #ifdef CONFIG_MACH_TS219_DT
 void qnap_dt_ts219_init(void);
 #else
@@ -77,94 +67,12 @@
 static inline void dnskw_init(void) {};
 #endif
 
-#ifdef CONFIG_MACH_ICONNECT_DT
-void iconnect_init(void);
-#else
-static inline void iconnect_init(void) {};
-#endif
-
-#ifdef CONFIG_MACH_IB62X0_DT
-void ib62x0_init(void);
-#else
-static inline void ib62x0_init(void) {};
-#endif
-
-#ifdef CONFIG_MACH_DOCKSTAR_DT
-void dockstar_dt_init(void);
-#else
-static inline void dockstar_dt_init(void) {};
-#endif
-
-#ifdef CONFIG_MACH_GOFLEXNET_DT
-void goflexnet_init(void);
-#else
-static inline void goflexnet_init(void) {};
-#endif
-
 #ifdef CONFIG_MACH_LSXL_DT
 void lsxl_init(void);
 #else
 static inline void lsxl_init(void) {};
 #endif
 
-#ifdef CONFIG_MACH_IOMEGA_IX2_200_DT
-void iomega_ix2_200_init(void);
-#else
-static inline void iomega_ix2_200_init(void) {};
-#endif
-
-#ifdef CONFIG_MACH_KM_KIRKWOOD_DT
-void km_kirkwood_init(void);
-#else
-static inline void km_kirkwood_init(void) {};
-#endif
-
-#ifdef CONFIG_MACH_DB88F628X_BP_DT
-void db88f628x_init(void);
-#else
-static inline void db88f628x_init(void) {};
-#endif
-
-#ifdef CONFIG_MACH_MPLCEC4_DT
-void mplcec4_init(void);
-#else
-static inline void mplcec4_init(void) {};
-#endif
-
-#if defined(CONFIG_MACH_INETSPACE_V2_DT) || \
-	defined(CONFIG_MACH_NETSPACE_V2_DT) || \
-	defined(CONFIG_MACH_NETSPACE_MAX_V2_DT) || \
-	defined(CONFIG_MACH_NETSPACE_LITE_V2_DT) || \
-	defined(CONFIG_MACH_NETSPACE_MINI_V2_DT)
-void ns2_init(void);
-#else
-static inline void ns2_init(void) {};
-#endif
-
-#ifdef CONFIG_MACH_OPENBLOCKS_A6_DT
-void openblocks_a6_init(void);
-#else
-static inline void openblocks_a6_init(void) {};
-#endif
-
-#ifdef CONFIG_MACH_READYNAS_DT
-void netgear_readynas_init(void);
-#else
-static inline void netgear_readynas_init(void) {};
-#endif
-
-#ifdef CONFIG_MACH_TOPKICK_DT
-void usi_topkick_init(void);
-#else
-static inline void usi_topkick_init(void) {};
-#endif
-
-#ifdef CONFIG_MACH_CLOUDBOX_DT
-void cloudbox_init(void);
-#else
-static inline void cloudbox_init(void) {};
-#endif
-
 /* early init functions not converted to fdt yet */
 char *kirkwood_id(void);
 void kirkwood_l2_init(void);
Index: linux/arch/arm/mach-kirkwood/Kconfig
===================================================================
--- linux.orig/arch/arm/mach-kirkwood/Kconfig	2013-05-30 23:38:53.652311676 +0200
+++ linux/arch/arm/mach-kirkwood/Kconfig	2013-05-30 23:38:53.648311656 +0200
@@ -140,13 +140,6 @@
 	  Say 'Y' here if you want your kernel to support the
 	  Marvell Kirkwood using flattened device tree.
 
-config MACH_DB88F628X_BP_DT
-	bool "Marvell DB-88F628x-BP Development Board (Flattened Device Tree)"
-	help
-	  Say 'Y' here if you want your kernel to support the Marvell
-	  DB-88F6281-BP and DB-88F6282-BP Development Board (Flattened
-	  Device Tree).
-
 config MACH_DLINK_KIRKWOOD_DT
 	bool "D-Link Kirkwood-based NAS (Flattened Device Tree)"
 	select ARCH_KIRKWOOD_DT
@@ -163,22 +156,6 @@
 	  Buffalo Linkstation LS-XHL & LS-CHLv2 devices, using
 	  Flattened Device Tree.
 
-config MACH_MPLCEC4_DT
-	bool "MPL CEC4 (Flattened Device Tree)"
-	select ARCH_KIRKWOOD_DT
-	help
-	  Say 'Y' here if you want your kernel to support the
-	  MPL CEC4 (Flattened Device Tree).
-
-config MACH_READYNAS_DT
-	bool "NETGEAR ReadyNAS Duo v2 (Flattened Device Tree)"
-	select ARCH_KIRKWOOD_DT
-	select ARM_APPENDED_DTB
-	select ARM_ATAG_DTB_COMPAT
-	help
-	  Say 'Y' here if you want your kernel to support the
-	  NETGEAR ReadyNAS Duo v2 using Fattened Device Tree.
-
 config MACH_TS219_DT
 	bool "Device Tree for QNAP TS-11X, TS-21X NAS"
 	select ARCH_KIRKWOOD_DT
Index: linux/arch/arm/configs/kirkwood_defconfig
===================================================================
--- linux.orig/arch/arm/configs/kirkwood_defconfig	2013-05-30 23:38:53.596311398 +0200
+++ linux/arch/arm/configs/kirkwood_defconfig	2013-05-30 23:41:42.293147920 +0200
@@ -32,9 +32,6 @@
 CONFIG_MACH_TS41X=y
 CONFIG_MACH_DLINK_KIRKWOOD_DT=y
 CONFIG_MACH_LSXL_DT=y
-CONFIG_MACH_MPLCEC4_DT=y
-CONFIG_MACH_NSA310_DT=y
-CONFIG_MACH_READYNAS_DT=y
 CONFIG_MACH_TS219_DT=y
 # CONFIG_CPU_FEROCEON_OLD_ID is not set
 CONFIG_PREEMPT=y
Index: linux/arch/arm/mach-kirkwood/board-dt.c
===================================================================
--- linux.orig/arch/arm/mach-kirkwood/board-dt.c	2013-05-30 23:38:53.616311497 +0200
+++ linux/arch/arm/mach-kirkwood/board-dt.c	2013-05-30 23:45:41.782335483 +0200
@@ -113,16 +113,6 @@
 	if (of_machine_is_compatible("buffalo,lsxl"))
 		lsxl_init();
 
-	if (of_machine_is_compatible("marvell,db-88f6281-bp") ||
-	    of_machine_is_compatible("marvell,db-88f6282-bp"))
-		db88f628x_init();
-
-	if (of_machine_is_compatible("mpl,cec4"))
-		mplcec4_init();
-
-	if (of_machine_is_compatible("netgear,readynas-duo-v2"))
-		netgear_readynas_init();
-
 	of_platform_populate(NULL, kirkwood_dt_match_table, NULL, NULL);
 }
 
