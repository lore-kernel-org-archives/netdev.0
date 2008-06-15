From: =?ISO-8859-1?Q?N=E9meth_M=E1rton?= <nm127@freemail.hu>
Subject: [PATCH] 8139too: some style cleanups
Date: Sun, 15 Jun 2008 09:52:30 +0200
Message-ID: <4854CA3E.60208@freemail.hu>
References: <4853BB62.1060109@freemail.hu> <4853C8AD.9020407@s5r6.in-berlin.de> <48541165.7050304@freemail.hu> <485421C1.8010102@s5r6.in-berlin.de> <4854C9BF.8040900@freemail.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	Trivial Patch Monkey <trivial@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>,
	David Newall <davidn@davidnewall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail02d.mail.t-online.hu ([84.2.42.7]:61470 "EHLO
	mail02d.mail.t-online.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751131AbYFOHwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2008 03:52:33 -0400
In-Reply-To: <4854C9BF.8040900@freemail.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: M=E1rton N=E9meth <nm127@freemail.hu>

Clean up the following errors and warnings reported by checkpatch.pl:
 + ERROR: Macros with complex values should be enclosed in parenthesis
 + WARNING: __func__ should be used instead of gcc specific __FUNCTION_=
_
 + WARNING: plain inline is preferred over __inline__
 + WARNING: Use #include <linux/io.h> instead of <asm/io.h>
 + WARNING: Use #include <linux/uaccess.h> instead of <asm/uaccess.h>

The changes were verified with by comparing the "objdump -d 8139too.ko"
output which is exactly the same for the old and new version in case of
config CONFIG_8139TOO=3Dm, CONFIG_8139TOO_PIO=3Dn, CONFIG_8139TOO_TUNE_=
TWISTER=3Dn,
CONFIG_8139TOO_8129=3Dn, CONFIG_8139_OLD_RX_RESET=3Dn.
Software versions used: gcc 4.2.3, objdump 2.18.0.20080103, on elf32-i3=
86.

Signed-off-by: M=E1rton N=E9meth <nm127@freemail.hu>
---
--- a/drivers/net/8139too.c	2008-06-14 00:20:47.000000000 +0200
+++ b/drivers/net/8139too.c	2008-06-15 09:10:14.000000000 +0200
@@ -107,8 +107,8 @@
 #include <linux/mii.h>
 #include <linux/completion.h>
 #include <linux/crc32.h>
-#include <asm/io.h>
-#include <asm/uaccess.h>
+#include <linux/io.h>
+#include <linux/uaccess.h>
 #include <asm/irq.h>

 #define RTL8139_DRIVER_NAME   DRV_NAME " Fast Ethernet driver " DRV_VE=
RSION
@@ -134,7 +134,7 @@

 #if RTL8139_DEBUG
 /* note: prints function name for you */
-#  define DPRINTK(fmt, args...) printk(KERN_DEBUG "%s: " fmt, __FUNCTI=
ON__ , ## args)
+#  define DPRINTK(fmt, args...) printk(KERN_DEBUG "%s: " fmt, __func__=
 , ## args)
 #else
 #  define DPRINTK(fmt, args...)
 #endif
@@ -145,7 +145,7 @@
 #  define assert(expr) \
         if(unlikely(!(expr))) {				        \
         printk(KERN_ERR "Assertion failed! %s,%s,%s,line=3D%d\n",	\
-        #expr,__FILE__,__FUNCTION__,__LINE__);		        \
+	#expr, __FILE__, __func__, __LINE__);			\
         }
 #endif

@@ -219,7 +219,7 @@ enum {
 #define RTL8139B_IO_SIZE 256

 #define RTL8129_CAPS	HAS_MII_XCVR
-#define RTL8139_CAPS	HAS_CHIP_XCVR|HAS_LNK_CHNG
+#define RTL8139_CAPS	(HAS_CHIP_XCVR|HAS_LNK_CHNG)

 typedef enum {
 	RTL8139 =3D 0,
@@ -1890,7 +1890,7 @@ static void rtl8139_rx_err (u32 rx_statu
 }

 #if RX_BUF_IDX =3D=3D 3
-static __inline__ void wrap_copy(struct sk_buff *skb, const unsigned c=
har *ring,
+static inline void wrap_copy(struct sk_buff *skb, const unsigned char =
*ring,
 				 u32 offset, unsigned int size)
 {
 	u32 left =3D RX_BUF_LEN - offset;
