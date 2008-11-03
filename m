From: Jianjun Kong <jianjun@zeuux.org>
Subject: [PATCH 6/6] nets: clean up net/ipv4/ipmr.c
Date: Mon, 3 Nov 2008 16:20:02 +0800
Message-ID: <20081103082002.GG14553@ubuntu>
References: <20081102074446.GA12140@ubuntu> <490DEAD3.3030202@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeuux.org ([210.51.160.52]:50045 "EHLO z.billxu.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754690AbYKCITz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 03:19:55 -0500
Content-Disposition: inline
In-Reply-To: <490DEAD3.3030202@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 [PATCH 6/6] clean net/ipv4/ipmr.c

 Signed-off-by: Jianjun Kong <jianjun@zeuux.org>

---
 net/ipv4/ipmr.c |  130 +++++++++++++++++++++++++++---------------------------
 1 files changed, 65 insertions(+), 65 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index b42e082..05ed336 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -331,7 +331,7 @@ static void ipmr_destroy_unres(struct mfc_cache *c)
 
 	atomic_dec(&cache_resolve_queue_len);
 
-	while ((skb=skb_dequeue(&c->mfc_un.unres.unresolved))) {
+	while ((skb = skb_dequeue(&c->mfc_un.unres.unresolved))) {
 		if (ip_hdr(skb)->version == 0) {
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct iphdr));
 			nlh->nlmsg_type = NLMSG_ERROR;
@@ -477,13 +477,13 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
 	/*
 	 *	Fill in the VIF structures
 	 */
-	v->rate_limit=vifc->vifc_rate_limit;
-	v->local=vifc->vifc_lcl_addr.s_addr;
-	v->remote=vifc->vifc_rmt_addr.s_addr;
-	v->flags=vifc->vifc_flags;
+	v->rate_limit = vifc->vifc_rate_limit;
+	v->local = vifc->vifc_lcl_addr.s_addr;
+	v->remote = vifc->vifc_rmt_addr.s_addr;
+	v->flags = vifc->vifc_flags;
 	if (!mrtsock)
 		v->flags |= VIFF_STATIC;
-	v->threshold=vifc->vifc_threshold;
+	v->threshold = vifc->vifc_threshold;
 	v->bytes_in = 0;
 	v->bytes_out = 0;
 	v->pkt_in = 0;
@@ -494,7 +494,7 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
 
 	/* And finish update writing critical data */
 	write_lock_bh(&mrt_lock);
-	v->dev=dev;
+	v->dev = dev;
 #ifdef CONFIG_IP_PIMSM
 	if (v->flags&VIFF_REGISTER)
 		reg_vif_num = vifi;
@@ -507,7 +507,7 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
 
 static struct mfc_cache *ipmr_cache_find(__be32 origin, __be32 mcastgrp)
 {
-	int line=MFC_HASH(mcastgrp,origin);
+	int line = MFC_HASH(mcastgrp, origin);
 	struct mfc_cache *c;
 
 	for (c=mfc_cache_array[line]; c; c = c->next) {
@@ -522,8 +522,8 @@ static struct mfc_cache *ipmr_cache_find(__be32 origin, __be32 mcastgrp)
  */
 static struct mfc_cache *ipmr_cache_alloc(void)
 {
-	struct mfc_cache *c=kmem_cache_zalloc(mrt_cachep, GFP_KERNEL);
-	if (c==NULL)
+	struct mfc_cache *c = kmem_cache_zalloc(mrt_cachep, GFP_KERNEL);
+	if (c == NULL)
 		return NULL;
 	c->mfc_un.res.minvif = MAXVIFS;
 	return c;
@@ -531,8 +531,8 @@ static struct mfc_cache *ipmr_cache_alloc(void)
 
 static struct mfc_cache *ipmr_cache_alloc_unres(void)
 {
-	struct mfc_cache *c=kmem_cache_zalloc(mrt_cachep, GFP_ATOMIC);
-	if (c==NULL)
+	struct mfc_cache *c = kmem_cache_zalloc(mrt_cachep, GFP_ATOMIC);
+	if (c == NULL)
 		return NULL;
 	skb_queue_head_init(&c->mfc_un.unres.unresolved);
 	c->mfc_un.unres.expires = jiffies + 10*HZ;
@@ -552,7 +552,7 @@ static void ipmr_cache_resolve(struct mfc_cache *uc, struct mfc_cache *c)
 	 *	Play the pending entries through our router
 	 */
 
-	while ((skb=__skb_dequeue(&uc->mfc_un.unres.unresolved))) {
+	while ((skb = __skb_dequeue(&uc->mfc_un.unres.unresolved))) {
 		if (ip_hdr(skb)->version == 0) {
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct iphdr));
 
@@ -637,7 +637,7 @@ static int ipmr_cache_report(struct sk_buff *pkt, vifi_t vifi, int assert)
 	 *	Add our header
 	 */
 
-	igmp=(struct igmphdr *)skb_put(skb,sizeof(struct igmphdr));
+	igmp=(struct igmphdr *)skb_put(skb, sizeof(struct igmphdr));
 	igmp->type	=
 	msg->im_msgtype = assert;
 	igmp->code 	=	0;
@@ -653,7 +653,7 @@ static int ipmr_cache_report(struct sk_buff *pkt, vifi_t vifi, int assert)
 	/*
 	 *	Deliver to mrouted
 	 */
-	if ((ret=sock_queue_rcv_skb(mroute_socket,skb))<0) {
+	if ((ret = sock_queue_rcv_skb(mroute_socket, skb))<0) {
 		if (net_ratelimit())
 			printk(KERN_WARNING "mroute: pending queue full, dropping entries.\n");
 		kfree_skb(skb);
@@ -685,7 +685,7 @@ ipmr_cache_unresolved(vifi_t vifi, struct sk_buff *skb)
 		 *	Create a new entry if allowable
 		 */
 
-		if (atomic_read(&cache_resolve_queue_len)>=10 ||
+		if (atomic_read(&cache_resolve_queue_len) >= 10 ||
 		    (c=ipmr_cache_alloc_unres())==NULL) {
 			spin_unlock_bh(&mfc_unres_lock);
 
@@ -728,7 +728,7 @@ ipmr_cache_unresolved(vifi_t vifi, struct sk_buff *skb)
 		kfree_skb(skb);
 		err = -ENOBUFS;
 	} else {
-		skb_queue_tail(&c->mfc_un.unres.unresolved,skb);
+		skb_queue_tail(&c->mfc_un.unres.unresolved, skb);
 		err = 0;
 	}
 
@@ -745,7 +745,7 @@ static int ipmr_mfc_delete(struct mfcctl *mfc)
 	int line;
 	struct mfc_cache *c, **cp;
 
-	line=MFC_HASH(mfc->mfcc_mcastgrp.s_addr, mfc->mfcc_origin.s_addr);
+	line = MFC_HASH(mfc->mfcc_mcastgrp.s_addr, mfc->mfcc_origin.s_addr);
 
 	for (cp=&mfc_cache_array[line]; (c=*cp) != NULL; cp = &c->next) {
 		if (c->mfc_origin == mfc->mfcc_origin.s_addr &&
@@ -766,7 +766,7 @@ static int ipmr_mfc_add(struct mfcctl *mfc, int mrtsock)
 	int line;
 	struct mfc_cache *uc, *c, **cp;
 
-	line=MFC_HASH(mfc->mfcc_mcastgrp.s_addr, mfc->mfcc_origin.s_addr);
+	line = MFC_HASH(mfc->mfcc_mcastgrp.s_addr, mfc->mfcc_origin.s_addr);
 
 	for (cp=&mfc_cache_array[line]; (c=*cp) != NULL; cp = &c->next) {
 		if (c->mfc_origin == mfc->mfcc_origin.s_addr &&
@@ -787,13 +787,13 @@ static int ipmr_mfc_add(struct mfcctl *mfc, int mrtsock)
 	if (!ipv4_is_multicast(mfc->mfcc_mcastgrp.s_addr))
 		return -EINVAL;
 
-	c=ipmr_cache_alloc();
-	if (c==NULL)
+	c = ipmr_cache_alloc();
+	if (c == NULL)
 		return -ENOMEM;
 
-	c->mfc_origin=mfc->mfcc_origin.s_addr;
-	c->mfc_mcastgrp=mfc->mfcc_mcastgrp.s_addr;
-	c->mfc_parent=mfc->mfcc_parent;
+	c->mfc_origin = mfc->mfcc_origin.s_addr;
+	c->mfc_mcastgrp = mfc->mfcc_mcastgrp.s_addr;
+	c->mfc_parent = mfc->mfcc_parent;
 	ipmr_update_thresholds(c, mfc->mfcc_ttls);
 	if (!mrtsock)
 		c->mfc_flags |= MFC_STATIC;
@@ -846,7 +846,7 @@ static void mroute_clean_tables(struct sock *sk)
 	/*
 	 *	Wipe the cache
 	 */
-	for (i=0;i<MFC_LINES;i++) {
+	for (i=0; i<MFC_LINES; i++) {
 		struct mfc_cache *c, **cp;
 
 		cp = &mfc_cache_array[i];
@@ -887,7 +887,7 @@ static void mrtsock_destruct(struct sock *sk)
 		IPV4_DEVCONF_ALL(sock_net(sk), MC_FORWARDING)--;
 
 		write_lock_bh(&mrt_lock);
-		mroute_socket=NULL;
+		mroute_socket = NULL;
 		write_unlock_bh(&mrt_lock);
 
 		mroute_clean_tables(sk);
@@ -902,7 +902,7 @@ static void mrtsock_destruct(struct sock *sk)
  *	MOSPF/PIM router set up we can clean this up.
  */
 
-int ip_mroute_setsockopt(struct sock *sk,int optname,char __user *optval,int optlen)
+int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, int optlen)
 {
 	int ret;
 	struct vifctl vif;
@@ -918,7 +918,7 @@ int ip_mroute_setsockopt(struct sock *sk,int optname,char __user *optval,int opt
 		if (sk->sk_type != SOCK_RAW ||
 		    inet_sk(sk)->num != IPPROTO_IGMP)
 			return -EOPNOTSUPP;
-		if (optlen!=sizeof(int))
+		if (optlen != sizeof(int))
 			return -ENOPROTOOPT;
 
 		rtnl_lock();
@@ -930,7 +930,7 @@ int ip_mroute_setsockopt(struct sock *sk,int optname,char __user *optval,int opt
 		ret = ip_ra_control(sk, 1, mrtsock_destruct);
 		if (ret == 0) {
 			write_lock_bh(&mrt_lock);
-			mroute_socket=sk;
+			mroute_socket = sk;
 			write_unlock_bh(&mrt_lock);
 
 			IPV4_DEVCONF_ALL(sock_net(sk), MC_FORWARDING)++;
@@ -938,19 +938,19 @@ int ip_mroute_setsockopt(struct sock *sk,int optname,char __user *optval,int opt
 		rtnl_unlock();
 		return ret;
 	case MRT_DONE:
-		if (sk!=mroute_socket)
+		if (sk != mroute_socket)
 			return -EACCES;
 		return ip_ra_control(sk, 0, NULL);
 	case MRT_ADD_VIF:
 	case MRT_DEL_VIF:
-		if (optlen!=sizeof(vif))
+		if (optlen != sizeof(vif))
 			return -EINVAL;
-		if (copy_from_user(&vif,optval,sizeof(vif)))
+		if (copy_from_user(&vif, optval, sizeof(vif)))
 			return -EFAULT;
 		if (vif.vifc_vifi >= MAXVIFS)
 			return -ENFILE;
 		rtnl_lock();
-		if (optname==MRT_ADD_VIF) {
+		if (optname == MRT_ADD_VIF) {
 			ret = vif_add(&vif, sk==mroute_socket);
 		} else {
 			ret = vif_delete(vif.vifc_vifi, 0);
@@ -964,12 +964,12 @@ int ip_mroute_setsockopt(struct sock *sk,int optname,char __user *optval,int opt
 		 */
 	case MRT_ADD_MFC:
 	case MRT_DEL_MFC:
-		if (optlen!=sizeof(mfc))
+		if (optlen != sizeof(mfc))
 			return -EINVAL;
-		if (copy_from_user(&mfc,optval, sizeof(mfc)))
+		if (copy_from_user(&mfc, optval, sizeof(mfc)))
 			return -EFAULT;
 		rtnl_lock();
-		if (optname==MRT_DEL_MFC)
+		if (optname == MRT_DEL_MFC)
 			ret = ipmr_mfc_delete(&mfc);
 		else
 			ret = ipmr_mfc_add(&mfc, sk==mroute_socket);
@@ -1028,12 +1028,12 @@ int ip_mroute_setsockopt(struct sock *sk,int optname,char __user *optval,int opt
  *	Getsock opt support for the multicast routing system.
  */
 
-int ip_mroute_getsockopt(struct sock *sk,int optname,char __user *optval,int __user *optlen)
+int ip_mroute_getsockopt(struct sock *sk, int optname, char __user *optval, int __user *optlen)
 {
 	int olr;
 	int val;
 
-	if (optname!=MRT_VERSION &&
+	if (optname != MRT_VERSION &&
 #ifdef CONFIG_IP_PIMSM
 	   optname!=MRT_PIM &&
 #endif
@@ -1047,17 +1047,17 @@ int ip_mroute_getsockopt(struct sock *sk,int optname,char __user *optval,int __u
 	if (olr < 0)
 		return -EINVAL;
 
-	if (put_user(olr,optlen))
+	if (put_user(olr, optlen))
 		return -EFAULT;
-	if (optname==MRT_VERSION)
-		val=0x0305;
+	if (optname == MRT_VERSION)
+		val = 0x0305;
 #ifdef CONFIG_IP_PIMSM
-	else if (optname==MRT_PIM)
-		val=mroute_do_pim;
+	else if (optname == MRT_PIM)
+		val = mroute_do_pim;
 #endif
 	else
-		val=mroute_do_assert;
-	if (copy_to_user(optval,&val,olr))
+		val = mroute_do_assert;
+	if (copy_to_user(optval, &val, olr))
 		return -EFAULT;
 	return 0;
 }
@@ -1075,27 +1075,27 @@ int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg)
 
 	switch (cmd) {
 	case SIOCGETVIFCNT:
-		if (copy_from_user(&vr,arg,sizeof(vr)))
+		if (copy_from_user(&vr, arg, sizeof(vr)))
 			return -EFAULT;
-		if (vr.vifi>=maxvif)
+		if (vr.vifi >= maxvif)
 			return -EINVAL;
 		read_lock(&mrt_lock);
 		vif=&vif_table[vr.vifi];
 		if (VIF_EXISTS(vr.vifi))	{
-			vr.icount=vif->pkt_in;
-			vr.ocount=vif->pkt_out;
-			vr.ibytes=vif->bytes_in;
-			vr.obytes=vif->bytes_out;
+			vr.icount = vif->pkt_in;
+			vr.ocount = vif->pkt_out;
+			vr.ibytes = vif->bytes_in;
+			vr.obytes = vif->bytes_out;
 			read_unlock(&mrt_lock);
 
-			if (copy_to_user(arg,&vr,sizeof(vr)))
+			if (copy_to_user(arg, &vr, sizeof(vr)))
 				return -EFAULT;
 			return 0;
 		}
 		read_unlock(&mrt_lock);
 		return -EADDRNOTAVAIL;
 	case SIOCGETSGCNT:
-		if (copy_from_user(&sr,arg,sizeof(sr)))
+		if (copy_from_user(&sr, arg, sizeof(sr)))
 			return -EFAULT;
 
 		read_lock(&mrt_lock);
@@ -1106,7 +1106,7 @@ int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg)
 			sr.wrong_if = c->mfc_un.res.wrong_if;
 			read_unlock(&mrt_lock);
 
-			if (copy_to_user(arg,&sr,sizeof(sr)))
+			if (copy_to_user(arg, &sr, sizeof(sr)))
 				return -EFAULT;
 			return 0;
 		}
@@ -1130,15 +1130,15 @@ static int ipmr_device_event(struct notifier_block *this, unsigned long event, v
 	if (event != NETDEV_UNREGISTER)
 		return NOTIFY_DONE;
 	v=&vif_table[0];
-	for (ct=0;ct<maxvif;ct++,v++) {
-		if (v->dev==dev)
+	for (ct=0; ct<maxvif; ct++,v++) {
+		if (v->dev == dev)
 			vif_delete(ct, 1);
 	}
 	return NOTIFY_DONE;
 }
 
 
-static struct notifier_block ip_mr_notifier={
+static struct notifier_block ip_mr_notifier = {
 	.notifier_call = ipmr_device_event,
 };
 
@@ -1204,7 +1204,7 @@ static void ipmr_queue_xmit(struct sk_buff *skb, struct mfc_cache *c, int vifi)
 #ifdef CONFIG_IP_PIMSM
 	if (vif->flags & VIFF_REGISTER) {
 		vif->pkt_out++;
-		vif->bytes_out+=skb->len;
+		vif->bytes_out += skb->len;
 		vif->dev->stats.tx_bytes += skb->len;
 		vif->dev->stats.tx_packets++;
 		ipmr_cache_report(skb, vifi, IGMPMSG_WHOLEPKT);
@@ -1254,7 +1254,7 @@ static void ipmr_queue_xmit(struct sk_buff *skb, struct mfc_cache *c, int vifi)
 	}
 
 	vif->pkt_out++;
-	vif->bytes_out+=skb->len;
+	vif->bytes_out += skb->len;
 
 	dst_release(skb->dst);
 	skb->dst = &rt->u.dst;
@@ -1352,7 +1352,7 @@ static int ip_mr_forward(struct sk_buff *skb, struct mfc_cache *cache, int local
 	}
 
 	vif_table[vif].pkt_in++;
-	vif_table[vif].bytes_in+=skb->len;
+	vif_table[vif].bytes_in += skb->len;
 
 	/*
 	 *	Forward the frame
@@ -1364,7 +1364,7 @@ static int ip_mr_forward(struct sk_buff *skb, struct mfc_cache *cache, int local
 				if (skb2)
 					ipmr_queue_xmit(skb2, cache, psend);
 			}
-			psend=ct;
+			psend = ct;
 		}
 	}
 	if (psend != -1) {
@@ -1428,7 +1428,7 @@ int ip_mr_input(struct sk_buff *skb)
 	/*
 	 *	No usable cache entry
 	 */
-	if (cache==NULL) {
+	if (cache == NULL) {
 		int vif;
 
 		if (local) {
@@ -1602,13 +1602,13 @@ ipmr_fill_mroute(struct sk_buff *skb, struct mfc_cache *c, struct rtmsg *rtm)
 	if (dev)
 		RTA_PUT(skb, RTA_IIF, 4, &dev->ifindex);
 
-	mp_head = (struct rtattr*)skb_put(skb, RTA_LENGTH(0));
+	mp_head = (struct rtattr *)skb_put(skb, RTA_LENGTH(0));
 
 	for (ct = c->mfc_un.res.minvif; ct < c->mfc_un.res.maxvif; ct++) {
 		if (c->mfc_un.res.ttls[ct] < 255) {
 			if (skb_tailroom(skb) < RTA_ALIGN(RTA_ALIGN(sizeof(*nhp)) + 4))
 				goto rtattr_failure;
-			nhp = (struct rtnexthop*)skb_put(skb, RTA_ALIGN(sizeof(*nhp)));
+			nhp = (struct rtnexthop *)skb_put(skb, RTA_ALIGN(sizeof(*nhp)));
 			nhp->rtnh_flags = 0;
 			nhp->rtnh_hops = c->mfc_un.res.ttls[ct];
 			nhp->rtnh_ifindex = vif_table[ct].dev->ifindex;
@@ -1634,7 +1634,7 @@ int ipmr_get_route(struct sk_buff *skb, struct rtmsg *rtm, int nowait)
 	read_lock(&mrt_lock);
 	cache = ipmr_cache_find(rt->rt_src, rt->rt_dst);
 
-	if (cache==NULL) {
+	if (cache == NULL) {
 		struct sk_buff *skb2;
 		struct iphdr *iph;
 		struct net_device *dev;
-- 
1.5.6.3

