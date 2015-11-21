From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next v2 4/9] net: ipmr: fix code and comment style
Date: Sat, 21 Nov 2015 15:57:27 +0100
Message-ID: <1448117852-4254-5-git-send-email-razor@blackwall.org>
References: <1448117852-4254-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:33570 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760573AbbKUO73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2015 09:59:29 -0500
Received: by wmec201 with SMTP id c201so107651418wme.0
        for <netdev@vger.kernel.org>; Sat, 21 Nov 2015 06:59:27 -0800 (PST)
In-Reply-To: <1448117852-4254-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Trivial code and comment style fixes, also removed some extra newlines,
spaces and tabs.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/mroute.h |  59 ++++++------------
 net/ipv4/ipmr.c             | 142 ++++++++++++--------------------------------
 2 files changed, 54 insertions(+), 147 deletions(-)

diff --git a/include/uapi/linux/mroute.h b/include/uapi/linux/mroute.h
index a382d2c04a42..cf943016930f 100644
--- a/include/uapi/linux/mroute.h
+++ b/include/uapi/linux/mroute.h
@@ -4,15 +4,13 @@
 #include <linux/sockios.h>
 #include <linux/types.h>
 
-/*
- *	Based on the MROUTING 3.5 defines primarily to keep
- *	source compatibility with BSD.
+/* Based on the MROUTING 3.5 defines primarily to keep
+ * source compatibility with BSD.
  *
- *	See the mrouted code for the original history.
- *
- *      Protocol Independent Multicast (PIM) data structures included
- *      Carlos Picoto (cap@di.fc.ul.pt)
+ * See the mrouted code for the original history.
  *
+ * Protocol Independent Multicast (PIM) data structures included
+ * Carlos Picoto (cap@di.fc.ul.pt)
  */
 
 #define MRT_BASE	200
@@ -34,15 +32,13 @@
 #define SIOCGETSGCNT	(SIOCPROTOPRIVATE+1)
 #define SIOCGETRPF	(SIOCPROTOPRIVATE+2)
 
-#define MAXVIFS		32	
+#define MAXVIFS		32
 typedef unsigned long vifbitmap_t;	/* User mode code depends on this lot */
 typedef unsigned short vifi_t;
 #define ALL_VIFS	((vifi_t)(-1))
 
-/*
- *	Same idea as select
- */
- 
+/* Same idea as select */
+
 #define VIFM_SET(n,m)	((m)|=(1<<(n)))
 #define VIFM_CLR(n,m)	((m)&=~(1<<(n)))
 #define VIFM_ISSET(n,m)	((m)&(1<<(n)))
@@ -50,11 +46,9 @@ typedef unsigned short vifi_t;
 #define VIFM_COPY(mfrom,mto)	((mto)=(mfrom))
 #define VIFM_SAME(m1,m2)	((m1)==(m2))
 
-/*
- *	Passed by mrouted for an MRT_ADD_VIF - again we use the
- *	mrouted 3.6 structures for compatibility
+/* Passed by mrouted for an MRT_ADD_VIF - again we use the
+ * mrouted 3.6 structures for compatibility
  */
- 
 struct vifctl {
 	vifi_t	vifc_vifi;		/* Index of VIF */
 	unsigned char vifc_flags;	/* VIFF_ flags */
@@ -73,10 +67,7 @@ struct vifctl {
 #define VIFF_USE_IFINDEX	0x8	/* use vifc_lcl_ifindex instead of
 					   vifc_lcl_addr to find an interface */
 
-/*
- *	Cache manipulation structures for mrouted and PIMd
- */
- 
+/* Cache manipulation structures for mrouted and PIMd */
 struct mfcctl {
 	struct in_addr mfcc_origin;		/* Origin of mcast	*/
 	struct in_addr mfcc_mcastgrp;		/* Group in question	*/
@@ -88,10 +79,7 @@ struct mfcctl {
 	int	     mfcc_expire;
 };
 
-/* 
- *	Group count retrieval for mrouted
- */
- 
+/*  Group count retrieval for mrouted */
 struct sioc_sg_req {
 	struct in_addr src;
 	struct in_addr grp;
@@ -100,10 +88,7 @@ struct sioc_sg_req {
 	unsigned long wrong_if;
 };
 
-/*
- *	To get vif packet counts
- */
-
+/* To get vif packet counts */
 struct sioc_vif_req {
 	vifi_t	vifi;		/* Which iface */
 	unsigned long icount;	/* In packets */
@@ -112,11 +97,9 @@ struct sioc_vif_req {
 	unsigned long obytes;	/* Out bytes */
 };
 
-/*
- *	This is the format the mroute daemon expects to see IGMP control
- *	data. Magically happens to be like an IP packet as per the original
+/* This is the format the mroute daemon expects to see IGMP control
+ * data. Magically happens to be like an IP packet as per the original
  */
- 
 struct igmpmsg {
 	__u32 unused1,unused2;
 	unsigned char im_msgtype;		/* What is this */
@@ -126,21 +109,13 @@ struct igmpmsg {
 	struct in_addr im_src,im_dst;
 };
 
-/*
- *	That's all usermode folks
- */
-
-
+/* That's all usermode folks */
 
 #define MFC_ASSERT_THRESH (3*HZ)		/* Maximal freq. of asserts */
 
-/*
- *	Pseudo messages used by mrouted
- */
-
+/* Pseudo messages used by mrouted */
 #define IGMPMSG_NOCACHE		1		/* Kern cache fill request to mrouted */
 #define IGMPMSG_WRONGVIF	2		/* For PIM assert processing (unused) */
 #define IGMPMSG_WHOLEPKT	3		/* For PIM Register processing */
 
-
 #endif /* _UAPI__LINUX_MROUTE_H */
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index e153ab7b17a1..286ede3716ee 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -102,9 +102,7 @@ static inline bool pimsm_enabled(void)
 
 static DEFINE_RWLOCK(mrt_lock);
 
-/*
- *	Multicast router control variables
- */
+/* Multicast router control variables */
 
 #define VIF_EXISTS(_mrt, _idx) ((_mrt)->vif_table[_idx].dev != NULL)
 
@@ -393,8 +391,7 @@ static void ipmr_del_tunnel(struct net_device *dev, struct vifctl *v)
 	}
 }
 
-static
-struct net_device *ipmr_new_tunnel(struct net *net, struct vifctl *v)
+static struct net_device *ipmr_new_tunnel(struct net *net, struct vifctl *v)
 {
 	struct net_device  *dev;
 
@@ -561,8 +558,7 @@ static int __pim_rcv(struct mr_table *mrt, struct sk_buff *skb,
 	struct iphdr *encap;
 
 	encap = (struct iphdr *)(skb_transport_header(skb) + pimlen);
-	/*
-	 * Check that:
+	/* Check that:
 	 * a. packet is really sent to a multicast group
 	 * b. packet is not a NULL-REGISTER
 	 * c. packet is not truncated
@@ -603,7 +599,6 @@ static struct net_device *ipmr_reg_vif(struct net *net, struct mr_table *mrt)
  *	vif_delete - Delete a VIF entry
  *	@notify: Set to 1, if the caller is a notifier_call
  */
-
 static int vif_delete(struct mr_table *mrt, int vifi, int notify,
 		      struct list_head *head)
 {
@@ -673,7 +668,6 @@ static inline void ipmr_cache_free(struct mfc_cache *c)
 /* Destroy an unresolved cache entry, killing queued skbs
  * and reporting error to netlink readers.
  */
-
 static void ipmr_destroy_unres(struct mr_table *mrt, struct mfc_cache *c)
 {
 	struct net *net = read_pnet(&mrt->net);
@@ -701,9 +695,7 @@ static void ipmr_destroy_unres(struct mr_table *mrt, struct mfc_cache *c)
 	ipmr_cache_free(c);
 }
 
-
 /* Timer process for the unresolved queue. */
-
 static void ipmr_expire_process(unsigned long arg)
 {
 	struct mr_table *mrt = (struct mr_table *)arg;
@@ -743,7 +735,6 @@ out:
 }
 
 /* Fill oifs list. It is called under write locked mrt_lock. */
-
 static void ipmr_update_thresholds(struct mr_table *mrt, struct mfc_cache *cache,
 				   unsigned char *ttls)
 {
@@ -808,7 +799,6 @@ static int vif_add(struct net *net, struct mr_table *mrt,
 			return err;
 		}
 		break;
-
 	case VIFF_USE_IFINDEX:
 	case 0:
 		if (vifc->vifc_flags == VIFF_USE_IFINDEX) {
@@ -928,9 +918,7 @@ skip:
 	return ipmr_cache_find_any_parent(mrt, vifi);
 }
 
-/*
- *	Allocate a multicast cache entry
- */
+/* Allocate a multicast cache entry */
 static struct mfc_cache *ipmr_cache_alloc(void)
 {
 	struct mfc_cache *c = kmem_cache_zalloc(mrt_cachep, GFP_KERNEL);
@@ -951,10 +939,7 @@ static struct mfc_cache *ipmr_cache_alloc_unres(void)
 	return c;
 }
 
-/*
- *	A cache entry has gone into a resolved state from queued
- */
-
+/* A cache entry has gone into a resolved state from queued */
 static void ipmr_cache_resolve(struct net *net, struct mr_table *mrt,
 			       struct mfc_cache *uc, struct mfc_cache *c)
 {
@@ -962,7 +947,6 @@ static void ipmr_cache_resolve(struct net *net, struct mr_table *mrt,
 	struct nlmsgerr *e;
 
 	/* Play the pending entries through our router */
-
 	while ((skb = __skb_dequeue(&uc->mfc_un.unres.unresolved))) {
 		if (ip_hdr(skb)->version == 0) {
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct iphdr));
@@ -1064,12 +1048,9 @@ static int ipmr_cache_report(struct mr_table *mrt,
 	return ret;
 }
 
-/*
- *	Queue a packet for resolution. It gets locked cache entry!
- */
-
-static int
-ipmr_cache_unresolved(struct mr_table *mrt, vifi_t vifi, struct sk_buff *skb)
+/* Queue a packet for resolution. It gets locked cache entry! */
+static int ipmr_cache_unresolved(struct mr_table *mrt, vifi_t vifi,
+				 struct sk_buff *skb)
 {
 	bool found = false;
 	int err;
@@ -1087,7 +1068,6 @@ ipmr_cache_unresolved(struct mr_table *mrt, vifi_t vifi, struct sk_buff *skb)
 
 	if (!found) {
 		/* Create a new entry if allowable */
-
 		if (atomic_read(&mrt->cache_resolve_queue_len) >= 10 ||
 		    (c = ipmr_cache_alloc_unres()) == NULL) {
 			spin_unlock_bh(&mfc_unres_lock);
@@ -1097,13 +1077,11 @@ ipmr_cache_unresolved(struct mr_table *mrt, vifi_t vifi, struct sk_buff *skb)
 		}
 
 		/* Fill in the new cache entry */
-
 		c->mfc_parent	= -1;
 		c->mfc_origin	= iph->saddr;
 		c->mfc_mcastgrp	= iph->daddr;
 
 		/* Reflect first query at mrouted. */
-
 		err = ipmr_cache_report(mrt, skb, vifi, IGMPMSG_NOCACHE);
 		if (err < 0) {
 			/* If the report failed throw the cache entry
@@ -1125,7 +1103,6 @@ ipmr_cache_unresolved(struct mr_table *mrt, vifi_t vifi, struct sk_buff *skb)
 	}
 
 	/* See if we can append the packet */
-
 	if (c->mfc_un.unres.unresolved.qlen > 3) {
 		kfree_skb(skb);
 		err = -ENOBUFS;
@@ -1138,9 +1115,7 @@ ipmr_cache_unresolved(struct mr_table *mrt, vifi_t vifi, struct sk_buff *skb)
 	return err;
 }
 
-/*
- *	MFC cache manipulation by user space mroute daemon
- */
+/* MFC cache manipulation by user space mroute daemon */
 
 static int ipmr_mfc_delete(struct mr_table *mrt, struct mfcctl *mfc, int parent)
 {
@@ -1211,9 +1186,8 @@ static int ipmr_mfc_add(struct net *net, struct mr_table *mrt,
 
 	list_add_rcu(&c->list, &mrt->mfc_cache_array[line]);
 
-	/*
-	 *	Check to see if we resolved a queued list. If so we
-	 *	need to send on the frames and tidy up.
+	/* Check to see if we resolved a queued list. If so we
+	 * need to send on the frames and tidy up.
 	 */
 	found = false;
 	spin_lock_bh(&mfc_unres_lock);
@@ -1238,10 +1212,7 @@ static int ipmr_mfc_add(struct net *net, struct mr_table *mrt,
 	return 0;
 }
 
-/*
- *	Close the multicast socket, and clear the vif tables etc
- */
-
+/* Close the multicast socket, and clear the vif tables etc */
 static void mroute_clean_tables(struct mr_table *mrt)
 {
 	int i;
@@ -1249,7 +1220,6 @@ static void mroute_clean_tables(struct mr_table *mrt)
 	struct mfc_cache *c, *next;
 
 	/* Shut down all active vif entries */
-
 	for (i = 0; i < mrt->maxvif; i++) {
 		if (!(mrt->vif_table[i].flags & VIFF_STATIC))
 			vif_delete(mrt, i, 0, &list);
@@ -1257,7 +1227,6 @@ static void mroute_clean_tables(struct mr_table *mrt)
 	unregister_netdevice_many(&list);
 
 	/* Wipe the cache */
-
 	for (i = 0; i < MFC_LINES; i++) {
 		list_for_each_entry_safe(c, next, &mrt->mfc_cache_array[i], list) {
 			if (c->mfc_flags & MFC_STATIC)
@@ -1301,11 +1270,10 @@ static void mrtsock_destruct(struct sock *sk)
 	rtnl_unlock();
 }
 
-/*
- *	Socket options and virtual interface manipulation. The whole
- *	virtual interface system is a complete heap, but unfortunately
- *	that's how BSD mrouted happens to think. Maybe one day with a proper
- *	MOSPF/PIM router set up we can clean this up.
+/* Socket options and virtual interface manipulation. The whole
+ * virtual interface system is a complete heap, but unfortunately
+ * that's how BSD mrouted happens to think. Maybe one day with a proper
+ * MOSPF/PIM router set up we can clean this up.
  */
 
 int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsigned int optlen)
@@ -1373,10 +1341,9 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 		rtnl_unlock();
 		return ret;
 
-		/*
-		 *	Manipulate the forwarding caches. These live
-		 *	in a sort of kernel/user symbiosis.
-		 */
+	/* Manipulate the forwarding caches. These live
+	 * in a sort of kernel/user symbiosis.
+	 */
 	case MRT_ADD_MFC:
 	case MRT_DEL_MFC:
 		parent = -1;
@@ -1397,9 +1364,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 					   parent);
 		rtnl_unlock();
 		return ret;
-		/*
-		 *	Control PIM assert.
-		 */
+	/* Control PIM assert. */
 	case MRT_ASSERT:
 	{
 		int v;
@@ -1456,19 +1421,13 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 		return ret;
 	}
 #endif
-	/*
-	 *	Spurious command, or MRT_VERSION which you cannot
-	 *	set.
-	 */
+	/* Spurious command, or MRT_VERSION which you cannot set. */
 	default:
 		return -ENOPROTOOPT;
 	}
 }
 
-/*
- *	Getsock opt support for the multicast routing system.
- */
-
+/* Getsock opt support for the multicast routing system. */
 int ip_mroute_getsockopt(struct sock *sk, int optname, char __user *optval, int __user *optlen)
 {
 	int olr;
@@ -1512,10 +1471,7 @@ int ip_mroute_getsockopt(struct sock *sk, int optname, char __user *optval, int
 	return 0;
 }
 
-/*
- *	The IP multicast ioctl support routines.
- */
-
+/* The IP multicast ioctl support routines. */
 int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg)
 {
 	struct sioc_sg_req sr;
@@ -1648,7 +1604,6 @@ int ipmr_compat_ioctl(struct sock *sk, unsigned int cmd, void __user *arg)
 }
 #endif
 
-
 static int ipmr_device_event(struct notifier_block *this, unsigned long event, void *ptr)
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
@@ -1670,17 +1625,14 @@ static int ipmr_device_event(struct notifier_block *this, unsigned long event, v
 	return NOTIFY_DONE;
 }
 
-
 static struct notifier_block ip_mr_notifier = {
 	.notifier_call = ipmr_device_event,
 };
 
-/*
- *	Encapsulate a packet by attaching a valid IPIP header to it.
- *	This avoids tunnel drivers and other mess and gives us the speed so
- *	important for multicast video.
+/* Encapsulate a packet by attaching a valid IPIP header to it.
+ * This avoids tunnel drivers and other mess and gives us the speed so
+ * important for multicast video.
  */
-
 static void ip_encap(struct net *net, struct sk_buff *skb,
 		     __be32 saddr, __be32 daddr)
 {
@@ -1722,9 +1674,7 @@ static inline int ipmr_forward_finish(struct net *net, struct sock *sk,
 	return dst_output(net, sk, skb);
 }
 
-/*
- *	Processing handlers for ipmr_forward
- */
+/* Processing handlers for ipmr_forward */
 
 static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 			    struct sk_buff *skb, struct mfc_cache *c, int vifi)
@@ -1773,7 +1723,6 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 		 * allow to send ICMP, so that packets will disappear
 		 * to blackhole.
 		 */
-
 		IP_INC_STATS(net, IPSTATS_MIB_FRAGFAILS);
 		ip_rt_put(rt);
 		goto out_free;
@@ -1805,8 +1754,7 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 
 	IPCB(skb)->flags |= IPSKB_FORWARDED;
 
-	/*
-	 * RFC1584 teaches, that DVMRP/PIM router must deliver packets locally
+	/* RFC1584 teaches, that DVMRP/PIM router must deliver packets locally
 	 * not only before forwarding, but after forwarding on all output
 	 * interfaces. It is clear, if mrouter runs a multicasting
 	 * program, it should receive packets not depending to what interface
@@ -1837,7 +1785,6 @@ static int ipmr_find_vif(struct mr_table *mrt, struct net_device *dev)
 }
 
 /* "local" means that we should preserve one skb (for local delivery) */
-
 static void ip_mr_forward(struct net *net, struct mr_table *mrt,
 			  struct sk_buff *skb, struct mfc_cache *cache,
 			  int local)
@@ -1862,9 +1809,7 @@ static void ip_mr_forward(struct net *net, struct mr_table *mrt,
 			goto forward;
 	}
 
-	/*
-	 * Wrong interface: drop packet and (maybe) send PIM assert.
-	 */
+	/* Wrong interface: drop packet and (maybe) send PIM assert. */
 	if (mrt->vif_table[vif].dev != skb->dev) {
 		if (rt_is_output_route(skb_rtable(skb))) {
 			/* It is our own packet, looped back.
@@ -1903,9 +1848,7 @@ forward:
 	mrt->vif_table[vif].pkt_in++;
 	mrt->vif_table[vif].bytes_in += skb->len;
 
-	/*
-	 *	Forward the frame
-	 */
+	/* Forward the frame */
 	if (cache->mfc_origin == htonl(INADDR_ANY) &&
 	    cache->mfc_mcastgrp == htonl(INADDR_ANY)) {
 		if (true_vifi >= 0 &&
@@ -1979,11 +1922,9 @@ static struct mr_table *ipmr_rt_fib_lookup(struct net *net, struct sk_buff *skb)
 	return mrt;
 }
 
-/*
- *	Multicast packets for forwarding arrive here
- *	Called with rcu_read_lock();
+/* Multicast packets for forwarding arrive here
+ * Called with rcu_read_lock();
  */
-
 int ip_mr_input(struct sk_buff *skb)
 {
 	struct mfc_cache *cache;
@@ -2034,9 +1975,7 @@ int ip_mr_input(struct sk_buff *skb)
 						    vif);
 	}
 
-	/*
-	 *	No usable cache entry
-	 */
+	/* No usable cache entry */
 	if (!cache) {
 		int vif;
 
@@ -2078,10 +2017,7 @@ dont_forward:
 }
 
 #ifdef CONFIG_IP_PIMSM_V1
-/*
- * Handle IGMP messages of PIMv1
- */
-
+/* Handle IGMP messages of PIMv1 */
 int pim_rcv_v1(struct sk_buff *skb)
 {
 	struct igmphdr *pim;
@@ -2406,9 +2342,8 @@ done:
 }
 
 #ifdef CONFIG_PROC_FS
-/*
- *	The /proc interfaces to multicast routing :
- *	/proc/net/ip_mr_cache & /proc/net/ip_mr_vif
+/* The /proc interfaces to multicast routing :
+ * /proc/net/ip_mr_cache & /proc/net/ip_mr_vif
  */
 struct ipmr_vif_iter {
 	struct seq_net_private p;
@@ -2692,10 +2627,7 @@ static const struct net_protocol pim_protocol = {
 };
 #endif
 
-
-/*
- *	Setup for IP multicast routing
- */
+/* Setup for IP multicast routing */
 static int __net_init ipmr_net_init(struct net *net)
 {
 	int err;
-- 
2.4.3
