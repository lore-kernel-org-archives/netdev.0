From: akpm@linux-foundation.org
Subject: [patch 06/11] net/wanrouter/wanmain.c: cleanups
Date: Mon, 05 Feb 2007 16:31:05 -0800
Message-ID: <200702060032.l160W8LR004633@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, bunk@stusta.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:41586 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965239AbXBFAfW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 19:35:22 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>

This patch contains the following cleanups:
- make the following needlessly global functions static:
  - lock_adapter_irq()
  - unlock_adapter_irq()
- #if 0 the following unused global functions:
  - wanrouter_encapsulate()
  - wanrouter_type_trans()

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/wanrouter.h |    8 --------
 net/wanrouter/wanmain.c   |   17 ++++++++---------
 2 files changed, 8 insertions(+), 17 deletions(-)

diff -puN include/linux/wanrouter.h~net-wanrouter-wanmainc-cleanups include/linux/wanrouter.h
--- a/include/linux/wanrouter.h~net-wanrouter-wanmainc-cleanups
+++ a/include/linux/wanrouter.h
@@ -516,9 +516,6 @@ struct wan_device {
 /* Public functions available for device drivers */
 extern int register_wan_device(struct wan_device *wandev);
 extern int unregister_wan_device(char *name);
-__be16 wanrouter_type_trans(struct sk_buff *skb, struct net_device *dev);
-int wanrouter_encapsulate(struct sk_buff *skb, struct net_device *dev,
-			  unsigned short type);
 
 /* Proc interface functions. These must not be called by the drivers! */
 extern int wanrouter_proc_init(void);
@@ -527,11 +524,6 @@ extern int wanrouter_proc_add(struct wan
 extern int wanrouter_proc_delete(struct wan_device *wandev);
 extern int wanrouter_ioctl( struct inode *inode, struct file *file, unsigned int cmd, unsigned long arg);
 
-extern void lock_adapter_irq(spinlock_t *lock, unsigned long *smp_flags);
-extern void unlock_adapter_irq(spinlock_t *lock, unsigned long *smp_flags);
-
-
-
 /* Public Data */
 /* list of registered devices */
 extern struct wan_device *wanrouter_router_devlist;
diff -puN net/wanrouter/wanmain.c~net-wanrouter-wanmainc-cleanups net/wanrouter/wanmain.c
--- a/net/wanrouter/wanmain.c~net-wanrouter-wanmainc-cleanups
+++ a/net/wanrouter/wanmain.c
@@ -86,8 +86,8 @@ static int wanrouter_device_del_if(struc
 
 static struct wan_device *wanrouter_find_device(char *name);
 static int wanrouter_delete_interface(struct wan_device *wandev, char *name);
-void lock_adapter_irq(spinlock_t *lock, unsigned long *smp_flags);
-void unlock_adapter_irq(spinlock_t *lock, unsigned long *smp_flags);
+static void lock_adapter_irq(spinlock_t *lock, unsigned long *smp_flags);
+static void unlock_adapter_irq(spinlock_t *lock, unsigned long *smp_flags);
 
 
 
@@ -104,8 +104,8 @@ struct wan_device* wanrouter_router_devl
  *	Organize Unique Identifiers for encapsulation/decapsulation
  */
 
-static unsigned char wanrouter_oui_ether[] = { 0x00, 0x00, 0x00 };
 #if 0
+static unsigned char wanrouter_oui_ether[] = { 0x00, 0x00, 0x00 };
 static unsigned char wanrouter_oui_802_2[] = { 0x00, 0x80, 0xC2 };
 #endif
 
@@ -246,6 +246,8 @@ int unregister_wan_device(char *name)
 	return 0;
 }
 
+#if 0
+
 /*
  *	Encapsulate packet.
  *
@@ -341,6 +343,7 @@ __be16 wanrouter_type_trans(struct sk_bu
 	return ethertype;
 }
 
+#endif  /*  0  */
 
 /*
  *	WAN device IOCTL.
@@ -799,23 +802,19 @@ static int wanrouter_delete_interface(st
 	return 0;
 }
 
-void lock_adapter_irq(spinlock_t *lock, unsigned long *smp_flags)
+static void lock_adapter_irq(spinlock_t *lock, unsigned long *smp_flags)
 {
        	spin_lock_irqsave(lock, *smp_flags);
 }
 
 
-void unlock_adapter_irq(spinlock_t *lock, unsigned long *smp_flags)
+static void unlock_adapter_irq(spinlock_t *lock, unsigned long *smp_flags)
 {
 	spin_unlock_irqrestore(lock, *smp_flags);
 }
 
 EXPORT_SYMBOL(register_wan_device);
 EXPORT_SYMBOL(unregister_wan_device);
-EXPORT_SYMBOL(wanrouter_encapsulate);
-EXPORT_SYMBOL(wanrouter_type_trans);
-EXPORT_SYMBOL(lock_adapter_irq);
-EXPORT_SYMBOL(unlock_adapter_irq);
 
 MODULE_LICENSE("GPL");
 
_
