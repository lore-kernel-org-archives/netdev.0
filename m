From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: patches for PROC_FS=n (2.6.0-test7)
Date: Sun, 12 Oct 2003 20:13:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031012201316.7ecf73c8.rddunlap@osdl.org>
References: <Pine.GSO.4.58.0310101519330.9806@inky>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@redhat.com, elmer@ylenurme.ee,
        Elmer.Joandi@ut.ee
Return-path: <netdev-bounce@oss.sgi.com>
To: "Noah J. Misch" <noah@caltech.edu>
In-Reply-To: <Pine.GSO.4.58.0310101519330.9806@inky>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 10 Oct 2003 16:06:29 -0700 (PDT) "Noah J. Misch" <noah@caltech.edu> wrote:

| > There are several other drivers/protocols that don't build
| > with PROC_FS=n, like arlan, siimage, ipx, llc, and bluetooth.


Here's a patch for the wireless/arlan driver for PROC_FS=n.
Currently it defines both a function and a macro for
init_arlan_proc() if PROC_FS=n.  This causes a bunch of
compile-time errors.

It looks to me like it should always call the init_arlan_proc()
(and cleanup_arlan_proc()) functions since it inits some sysctl tables.
Or am I misunderstanding it?

Thanks,
--
~Randy


patch_name:	arlan_noprocfs.patch
patch_version:	2003-10-12.19:46:24
author:		Randy.Dunlap <rddunlap@osdl.org>
description:	use init_arlan_proc() for sysctl inits
product:	Linux
product_versions: 2.6.0-test7
diffstat:	=
 drivers/net/wireless/arlan.h |    5 -----
 1 files changed, 5 deletions(-)


diff -Naur ./drivers/net/wireless/arlan.h~arlanprocfs ./drivers/net/wireless/arlan.h
--- ./drivers/net/wireless/arlan.h~arlanprocfs	2003-10-08 12:24:08.000000000 -0700
+++ ./drivers/net/wireless/arlan.h	2003-10-12 19:45:46.000000000 -0700
@@ -39,13 +39,8 @@
 #define ARLAN_RCV_PROMISC 1
 #define ARLAN_RCV_CONTROL 2
 
-#ifdef CONFIG_PROC_FS
 extern int init_arlan_proc(void);
 extern void cleanup_arlan_proc(void);
-#else
-#define init_arlan_proc()	(0)
-#define cleanup_arlan_proc()	do { } while (0);
-#endif
 
 extern struct net_device *arlan_device[MAX_ARLANS];
 extern int	arlan_debug;
