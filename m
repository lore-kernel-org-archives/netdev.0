From: =?UTF-8?B?TsOpbWV0aCBNw6FydG9u?= <nm127@freemail.hu>
Subject: [PATCH 2/2] 8139too: different style cleanups
Date: Sat, 14 Jun 2008 14:37:15 +0200
Message-ID: <4853BB7B.4030905@freemail.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Trivial Patch Monkey <trivial@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760257AbYFNMiV@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: M=C3=A1rton N=C3=A9meth <nm127@freemail.hu>

Clean up the following errors and warnings reported by checkpatch.pl:
 - Use #include <linux/io.h> instead of <asm/io.h>
 - Use #include <linux/uaccess.h> instead of <asm/uaccess.h>
 - __func__ should be used instead of gcc specific __FUNCTION__
 - Macros with complex values should be enclosed in parenthesis
 - do not add new typedefs
 - trailing statements should be on next line
 - braces {} are not necessary for single statement blocks
 - plain inline is preferred over __inline__

Signed-off-by: M=C3=A1rton N=C3=A9meth <nm127@freemail.hu>
---
--- b/drivers/net/8139too.c	2008-06-14 14:08:18.000000000 +0200
+++ c/drivers/net/8139too.c	2008-06-14 14:16:49.000000000 +0200
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
@@ -135,7 +135,7 @@
 #if RTL8139_DEBUG
 /* note: prints function name for you */
 #  define DPRINTK(fmt, args...) \
-	printk(KERN_DEBUG "%s: " fmt, __FUNCTION__ , ## args)
+	printk(KERN_DEBUG "%s: " fmt, __func__ , ## args)
 #else
 #  define DPRINTK(fmt, args...)
 #endif
@@ -146,7 +146,7 @@
 #  define assert(expr) \
 	if (unlikely(!(expr))) {					\
 		printk(KERN_ERR "Assertion failed! %s,%s,%s,line=3D%d\n",	\
-		       #expr, __FILE__, __FUNCTION__, __LINE__);	\
+		       #expr, __FILE__, __func__, __LINE__);	\
 	}
 #endif

@@ -221,9 +221,9 @@ enum {
 #define RTL8139B_IO_SIZE 256

 #define RTL8129_CAPS	HAS_MII_XCVR
-#define RTL8139_CAPS	HAS_CHIP_XCVR|HAS_LNK_CHNG
+#define RTL8139_CAPS	(HAS_CHIP_XCVR|HAS_LNK_CHNG)

-typedef enum {
+enum {
 	RTL8139 =3D 0,
 	RTL8129,
 } board_t;
@@ -1033,7 +1033,8 @@ static int __devinit rtl8139_init_one(st
 	/* dev is fully set up and ready to use now */
 	DPRINTK("about to register device named %s (%p)...\n", dev->name, dev=
);
 	i =3D register_netdev(dev);
-	if (i) goto err_out;
+	if (i)
+		goto err_out;

 	pci_set_drvdata(pdev, dev);

@@ -1378,9 +1379,9 @@ static void rtl_check_media(struct net_d
 {
 	struct rtl8139_private *tp =3D netdev_priv(dev);

-	if (tp->phys[0] >=3D 0) {
+	if (tp->phys[0] >=3D 0)
 		mii_check_media(&tp->mii, netif_msg_link(tp), init_media);
-	}
+
 }

 /* Start the hardware at open or resume. */
@@ -1921,7 +1922,7 @@ static void rtl8139_rx_err(u32 rx_status
 }

 #if RX_BUF_IDX =3D=3D 3
-static __inline__ void wrap_copy(struct sk_buff *skb, const unsigned c=
har *ring,
+static inline void wrap_copy(struct sk_buff *skb, const unsigned char =
*ring,
 				 u32 offset, unsigned int size)
 {
 	u32 left =3D RX_BUF_LEN - offset;
