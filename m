From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/7) ipmr.c - make local stuff static
Date: Wed, 25 Jun 2003 11:40:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030625114051.7a5cc652.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Make things static where possible in ipmr.c.

diff -Nru a/include/linux/mroute.h b/include/linux/mroute.h
--- a/include/linux/mroute.h	Wed Jun 25 11:15:02 2003
+++ b/include/linux/mroute.h	Wed Jun 25 11:15:02 2003
@@ -217,7 +217,6 @@
 	__u32	flags;
 };
 
-extern int pim_rcv(struct sk_buff *);
 extern int pim_rcv_v1(struct sk_buff *);
 
 struct rtmsg;
diff -Nru a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
--- a/net/ipv4/ipmr.c	Wed Jun 25 11:15:02 2003
+++ b/net/ipv4/ipmr.c	Wed Jun 25 11:15:02 2003
@@ -83,13 +83,13 @@
 
 #define VIF_EXISTS(idx) (vif_table[idx].dev != NULL)
 
-int mroute_do_assert;					/* Set in PIM assert	*/
-int mroute_do_pim;
+static int mroute_do_assert;				/* Set in PIM assert	*/
+static int mroute_do_pim;
 
 static struct mfc_cache *mfc_cache_array[MFC_LINES];	/* Forwarding cache	*/
 
 static struct mfc_cache *mfc_unres_queue;		/* Queue of unresolved entries */
-atomic_t cache_resolve_queue_len;			/* Size of unresolved	*/
+static atomic_t cache_resolve_queue_len;		/* Size of unresolved	*/
 
 /* Special spinlock for queue of unresolved entries */
 static spinlock_t mfc_unres_lock = SPIN_LOCK_UNLOCKED;
@@ -102,7 +102,7 @@
    In this case data path is free of exclusive locks at all.
  */
 
-kmem_cache_t *mrt_cachep;
+static kmem_cache_t *mrt_cachep;
 
 static int ip_mr_forward(struct sk_buff *skb, struct mfc_cache *cache, int local);
 static int ipmr_cache_report(struct sk_buff *pkt, vifi_t vifi, int assert);
@@ -187,8 +187,7 @@
 	kfree(dev);
 }
 
-static
-struct net_device *ipmr_reg_vif(struct vifctl *v)
+static struct net_device *ipmr_reg_vif(struct vifctl *v)
 {
 	struct net_device  *dev;
 	struct in_device *in_dev;
@@ -316,7 +315,7 @@
 
 /* Single timer process for all the unresolved queue. */
 
-void ipmr_expire_process(unsigned long dummy)
+static void ipmr_expire_process(unsigned long dummy)
 {
 	unsigned long now;
 	unsigned long expires;
@@ -683,7 +682,7 @@
  *	MFC cache manipulation by user space mroute daemon
  */
 
-int ipmr_mfc_delete(struct mfcctl *mfc)
+static int ipmr_mfc_delete(struct mfcctl *mfc)
 {
 	int line;
 	struct mfc_cache *c, **cp;
@@ -704,7 +703,7 @@
 	return -ENOENT;
 }
 
-int ipmr_mfc_add(struct mfcctl *mfc, int mrtsock)
+static int ipmr_mfc_add(struct mfcctl *mfc, int mrtsock)
 {
 	int line;
 	struct mfc_cache *uc, *c, **cp;
@@ -1232,7 +1231,7 @@
 		ipmr_forward_finish);
 }
 
-int ipmr_find_vif(struct net_device *dev)
+static int ipmr_find_vif(struct net_device *dev)
 {
 	int ct;
 	for (ct=maxvif-1; ct>=0; ct--) {
@@ -1244,7 +1243,7 @@
 
 /* "local" means that we should preserve one skb (for local delivery) */
 
-int ip_mr_forward(struct sk_buff *skb, struct mfc_cache *cache, int local)
+static int ip_mr_forward(struct sk_buff *skb, struct mfc_cache *cache, int local)
 {
 	int psend = -1;
 	int vif, ct;
@@ -1472,7 +1471,7 @@
 #endif
 
 #ifdef CONFIG_IP_PIMSM_V2
-int pim_rcv(struct sk_buff * skb)
+static int pim_rcv(struct sk_buff * skb)
 {
 	struct pimreghdr *pim = (struct pimreghdr*)skb->h.raw;
 	struct iphdr   *encap;
