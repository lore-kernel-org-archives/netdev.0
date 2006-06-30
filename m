From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/wanrouter/wanmain.c: cleanups
Date: Fri, 30 Jun 2006 13:33:05 +0200
Message-ID: <20060630113305.GT19712@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751743AbWF3Lel@vger.kernel.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch contains the following cleanups:
- make the following needlessly global functions static:
  - lock_adapter_irq()
  - unlock_adapter_irq()
- #if 0 the following unused global functions:
  - wanrouter_encapsulate()
  - wanrouter_type_trans()

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was already sent on:
- 5 Apr 2006

 include/linux/wanrouter.h |    8 --------
 net/wanrouter/wanmain.c   |   17 ++++++++---------
 2 files changed, 8 insertions(+), 17 deletions(-)

--- linux-2.6.17-rc1-mm1-full/include/linux/wanrouter.h.old	2006-04-05 17:03:07.000000000 +0200
+++ linux-2.6.17-rc1-mm1-full/include/linux/wanrouter.h	2006-04-05 17:15:20.000000000 +0200
@@ -516,9 +516,6 @@
 /* Public functions available for device drivers */
 extern int register_wan_device(struct wan_device *wandev);
 extern int unregister_wan_device(char *name);
-__be16 wanrouter_type_trans(struct sk_buff *skb, struct net_device *dev);
-int wanrouter_encapsulate(struct sk_buff *skb, struct net_device *dev,
-			  unsigned short type);
 
 /* Proc interface functions. These must not be called by the drivers! */
 extern int wanrouter_proc_init(void);
@@ -527,11 +524,6 @@
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
--- linux-2.6.17-rc1-mm1-full/net/wanrouter/wanmain.c.old	2006-04-05 17:03:39.000000000 +0200
+++ linux-2.6.17-rc1-mm1-full/net/wanrouter/wanmain.c	2006-04-05 17:18:32.000000000 +0200
@@ -144,8 +144,8 @@
 
 static struct wan_device *wanrouter_find_device(char *name);
 static int wanrouter_delete_interface(struct wan_device *wandev, char *name);
-void lock_adapter_irq(spinlock_t *lock, unsigned long *smp_flags);
-void unlock_adapter_irq(spinlock_t *lock, unsigned long *smp_flags);
+static void lock_adapter_irq(spinlock_t *lock, unsigned long *smp_flags);
+static void unlock_adapter_irq(spinlock_t *lock, unsigned long *smp_flags);
 
 
 
@@ -162,8 +162,8 @@
  *	Organize Unique Identifiers for encapsulation/decapsulation
  */
 
-static unsigned char wanrouter_oui_ether[] = { 0x00, 0x00, 0x00 };
 #if 0
+static unsigned char wanrouter_oui_ether[] = { 0x00, 0x00, 0x00 };
 static unsigned char wanrouter_oui_802_2[] = { 0x00, 0x80, 0xC2 };
 #endif
 
@@ -304,6 +304,8 @@
 	return 0;
 }
 
+#if 0
+
 /*
  *	Encapsulate packet.
  *
@@ -399,6 +401,7 @@
 	return ethertype;
 }
 
+#endif  /*  0  */
 
 /*
  *	WAN device IOCTL.
@@ -860,23 +863,19 @@
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
 
