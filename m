From: Jianjun Kong <jianjun@zeuux.org>
Subject: [PATCH] nets: clean up net/ipv4/*
Date: Sun, 2 Nov 2008 15:44:47 +0800
Message-ID: <20081102074446.GA12140@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Linux-Kernel-Mailing-List <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeuux.org ([210.51.160.52]:55065 "EHLO z.billxu.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752583AbYKBHow (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Nov 2008 02:44:52 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


clean up net/ipv4/* about code style.

Signed-off-by: Jianjun Kong <jianjun@zeuux.org>

---
 net/ipv4/ah4.c                  |    4 +-
 net/ipv4/arp.c                  |   18 +++---
 net/ipv4/devinet.c              |   10 ++--
 net/ipv4/esp4.c                 |    4 +-
 net/ipv4/fib_frontend.c         |   10 ++--
 net/ipv4/fib_hash.c             |   12 ++--
 net/ipv4/fib_semantics.c        |    8 +-
 net/ipv4/igmp.c                 |   46 +++++++-------
 net/ipv4/inet_connection_sock.c |    2 +-
 net/ipv4/inetpeer.c             |    2 +-
 net/ipv4/ip_fragment.c          |    2 +-
 net/ipv4/ip_gre.c               |   14 ++--
 net/ipv4/ip_input.c             |    4 +-
 net/ipv4/ip_output.c            |    6 +-
 net/ipv4/ip_sockglue.c          |   32 +++++-----
 net/ipv4/ipip.c                 |    2 +-
 net/ipv4/ipmr.c                 |  130 +++++++++++++++++++-------------------
 net/ipv4/raw.c                  |    8 +-
 net/ipv4/route.c                |    6 +-
 net/ipv4/tcp.c                  |    6 +-
 net/ipv4/tcp_ipv4.c             |   16 +++---
 net/ipv4/tcp_minisocks.c        |    2 +-
 net/ipv4/tcp_output.c           |    8 +-
 net/ipv4/tcp_timer.c            |    4 +-
 net/ipv4/tcp_yeah.c             |    4 +-
 net/ipv4/udp.c                  |   26 ++++----
 net/ipv4/xfrm4_policy.c         |    2 +-
 27 files changed, 194 insertions(+), 194 deletions(-)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 8219b7e..3f20518 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -201,8 +201,8 @@ out:
 
 static void ah4_err(struct sk_buff *skb, u32 info)
 {
-	struct iphdr *iph = (struct iphdr*)skb->data;
-	struct ip_auth_hdr *ah = (struct ip_auth_hdr*)(skb->data+(iph->ihl<<2));
+	struct iphdr *iph = (struct iphdr *)skb->data;
+	struct ip_auth_hdr *ah = (struct ip_auth_hdr *)(skb->data+(iph->ihl<<2));
 	struct xfrm_state *x;
 
 	if (icmp_hdr(skb)->type != ICMP_DEST_UNREACH ||
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 1a9dd66..dc7e0cb 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -506,7 +506,7 @@ int arp_bind_neighbour(struct dst_entry *dst)
 	if (dev == NULL)
 		return -EINVAL;
 	if (n == NULL) {
-		__be32 nexthop = ((struct rtable*)dst)->rt_gateway;
+		__be32 nexthop = ((struct rtable *)dst)->rt_gateway;
 		if (dev->flags&(IFF_LOOPBACK|IFF_POINTOPOINT))
 			nexthop = 0;
 		n = __neigh_lookup_errno(
@@ -640,14 +640,14 @@ struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 	arp_ptr=(unsigned char *)(arp+1);
 
 	memcpy(arp_ptr, src_hw, dev->addr_len);
-	arp_ptr+=dev->addr_len;
-	memcpy(arp_ptr, &src_ip,4);
-	arp_ptr+=4;
+	arp_ptr += dev->addr_len;
+	memcpy(arp_ptr, &src_ip, 4);
+	arp_ptr += 4;
 	if (target_hw != NULL)
 		memcpy(arp_ptr, target_hw, dev->addr_len);
 	else
 		memset(arp_ptr, 0, dev->addr_len);
-	arp_ptr+=dev->addr_len;
+	arp_ptr += dev->addr_len;
 	memcpy(arp_ptr, &dest_ip, 4);
 
 	return skb;
@@ -823,11 +823,11 @@ static int arp_process(struct sk_buff *skb)
 				int dont_send = 0;
 
 				if (!dont_send)
-					dont_send |= arp_ignore(in_dev,sip,tip);
+					dont_send |= arp_ignore(in_dev, sip, tip);
 				if (!dont_send && IN_DEV_ARPFILTER(in_dev))
-					dont_send |= arp_filter(sip,tip,dev);
+					dont_send |= arp_filter(sip, tip, dev);
 				if (!dont_send)
-					arp_send(ARPOP_REPLY,ETH_P_ARP,sip,dev,tip,sha,dev->dev_addr,sha);
+					arp_send(ARPOP_REPLY, ETH_P_ARP, sip, dev, tip, sha, dev->dev_addr, sha);
 
 				neigh_release(n);
 			}
@@ -842,7 +842,7 @@ static int arp_process(struct sk_buff *skb)
 				if (NEIGH_CB(skb)->flags & LOCALLY_ENQUEUED ||
 				    skb->pkt_type == PACKET_HOST ||
 				    in_dev->arp_parms->proxy_delay == 0) {
-					arp_send(ARPOP_REPLY,ETH_P_ARP,sip,dev,tip,sha,dev->dev_addr,sha);
+					arp_send(ARPOP_REPLY, ETH_P_ARP, sip, dev, tip, sha, dev->dev_addr, sha);
 				} else {
 					pneigh_enqueue(&arp_tbl, in_dev->arp_parms, skb);
 					in_dev_put(in_dev);
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 56fce3a..833d99e 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1108,7 +1108,7 @@ out:
 }
 
 static struct notifier_block ip_netdev_notifier = {
-	.notifier_call =inetdev_event,
+	.notifier_call = inetdev_event,
 };
 
 static inline size_t inet_nlmsg_size(void)
@@ -1195,7 +1195,7 @@ done:
 	return skb->len;
 }
 
-static void rtmsg_ifa(int event, struct in_ifaddr* ifa, struct nlmsghdr *nlh,
+static void rtmsg_ifa(int event, struct in_ifaddr *ifa, struct nlmsghdr *nlh,
 		      u32 pid)
 {
 	struct sk_buff *skb;
@@ -1262,7 +1262,7 @@ static void inet_forward_change(struct net *net)
 }
 
 static int devinet_conf_proc(ctl_table *ctl, int write,
-			     struct file* filp, void __user *buffer,
+			     struct file *filp, void __user *buffer,
 			     size_t *lenp, loff_t *ppos)
 {
 	int ret = proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
@@ -1334,7 +1334,7 @@ static int devinet_conf_sysctl(ctl_table *table,
 }
 
 static int devinet_sysctl_forward(ctl_table *ctl, int write,
-				  struct file* filp, void __user *buffer,
+				  struct file *filp, void __user *buffer,
 				  size_t *lenp, loff_t *ppos)
 {
 	int *valp = ctl->data;
@@ -1363,7 +1363,7 @@ static int devinet_sysctl_forward(ctl_table *ctl, int write,
 }
 
 int ipv4_doint_and_flush(ctl_table *ctl, int write,
-			 struct file* filp, void __user *buffer,
+			 struct file *filp, void __user *buffer,
 			 size_t *lenp, loff_t *ppos)
 {
 	int *valp = ctl->data;
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 21515d4..95a9c65 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -413,8 +413,8 @@ static u32 esp4_get_mtu(struct xfrm_state *x, int mtu)
 
 static void esp4_err(struct sk_buff *skb, u32 info)
 {
-	struct iphdr *iph = (struct iphdr*)skb->data;
-	struct ip_esp_hdr *esph = (struct ip_esp_hdr*)(skb->data+(iph->ihl<<2));
+	struct iphdr *iph = (struct iphdr *)skb->data;
+	struct ip_esp_hdr *esph = (struct ip_esp_hdr *)(skb->data+(iph->ihl<<2));
 	struct xfrm_state *x;
 
 	if (icmp_hdr(skb)->type != ICMP_DEST_UNREACH ||
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 65c1503..741e4fa 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -578,7 +578,7 @@ errout:
 	return err;
 }
 
-static int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
+static int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
 	struct fib_config cfg;
@@ -600,7 +600,7 @@ errout:
 	return err;
 }
 
-static int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
+static int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
 	struct fib_config cfg;
@@ -903,7 +903,7 @@ static void fib_disable_ip(struct net_device *dev, int force)
 
 static int fib_inetaddr_event(struct notifier_block *this, unsigned long event, void *ptr)
 {
-	struct in_ifaddr *ifa = (struct in_ifaddr*)ptr;
+	struct in_ifaddr *ifa = (struct in_ifaddr *)ptr;
 	struct net_device *dev = ifa->ifa_dev->dev;
 
 	switch (event) {
@@ -964,11 +964,11 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 }
 
 static struct notifier_block fib_inetaddr_notifier = {
-	.notifier_call =fib_inetaddr_event,
+	.notifier_call = fib_inetaddr_event,
 };
 
 static struct notifier_block fib_netdev_notifier = {
-	.notifier_call =fib_netdev_event,
+	.notifier_call = fib_netdev_event,
 };
 
 static int __net_init ip_fib_net_init(struct net *net)
diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index c8cac6c..ded8c44 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -247,7 +247,7 @@ fn_hash_lookup(struct fib_table *tb, const struct flowi *flp, struct fib_result
 {
 	int err;
 	struct fn_zone *fz;
-	struct fn_hash *t = (struct fn_hash*)tb->tb_data;
+	struct fn_hash *t = (struct fn_hash *)tb->tb_data;
 
 	read_lock(&fib_hash_lock);
 	for (fz = t->fn_zone_list; fz; fz = fz->fz_next) {
@@ -283,7 +283,7 @@ fn_hash_select_default(struct fib_table *tb, const struct flowi *flp, struct fib
 	struct fib_node *f;
 	struct fib_info *fi = NULL;
 	struct fib_info *last_resort;
-	struct fn_hash *t = (struct fn_hash*)tb->tb_data;
+	struct fn_hash *t = (struct fn_hash *)tb->tb_data;
 	struct fn_zone *fz = t->fn_zones[0];
 
 	if (fz == NULL)
@@ -548,7 +548,7 @@ out:
 
 static int fn_hash_delete(struct fib_table *tb, struct fib_config *cfg)
 {
-	struct fn_hash *table = (struct fn_hash*)tb->tb_data;
+	struct fn_hash *table = (struct fn_hash *)tb->tb_data;
 	struct fib_node *f;
 	struct fib_alias *fa, *fa_to_delete;
 	struct fn_zone *fz;
@@ -748,7 +748,7 @@ static int fn_hash_dump(struct fib_table *tb, struct sk_buff *skb, struct netlin
 {
 	int m, s_m;
 	struct fn_zone *fz;
-	struct fn_hash *table = (struct fn_hash*)tb->tb_data;
+	struct fn_hash *table = (struct fn_hash *)tb->tb_data;
 
 	s_m = cb->args[2];
 	read_lock(&fib_hash_lock);
@@ -845,10 +845,10 @@ static struct fib_alias *fib_get_first(struct seq_file *seq)
 			struct hlist_node *node;
 			struct fib_node *fn;
 
-			hlist_for_each_entry(fn,node,iter->hash_head,fn_hash) {
+			hlist_for_each_entry(fn, node, iter->hash_head, fn_hash) {
 				struct fib_alias *fa;
 
-				list_for_each_entry(fa,&fn->fn_alias,fa_list) {
+				list_for_each_entry(fa, &fn->fn_alias, fa_list) {
 					iter->fn = fn;
 					iter->fa = fa;
 					goto out;
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index ded2ae3..4817dea 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -63,16 +63,16 @@ static DEFINE_SPINLOCK(fib_multipath_lock);
 for (nhsel=0, nh = (fi)->fib_nh; nhsel < (fi)->fib_nhs; nh++, nhsel++)
 
 #define change_nexthops(fi) { int nhsel; struct fib_nh * nh; \
-for (nhsel=0, nh = (struct fib_nh*)((fi)->fib_nh); nhsel < (fi)->fib_nhs; nh++, nhsel++)
+for (nhsel=0, nh = (struct fib_nh *)((fi)->fib_nh); nhsel < (fi)->fib_nhs; nh++, nhsel++)
 
 #else /* CONFIG_IP_ROUTE_MULTIPATH */
 
 /* Hope, that gcc will optimize it to get rid of dummy loop */
 
-#define for_nexthops(fi) { int nhsel=0; const struct fib_nh * nh = (fi)->fib_nh; \
+#define for_nexthops(fi) { int nhsel = 0; const struct fib_nh * nh = (fi)->fib_nh; \
 for (nhsel=0; nhsel < 1; nhsel++)
 
-#define change_nexthops(fi) { int nhsel=0; struct fib_nh * nh = (struct fib_nh*)((fi)->fib_nh); \
+#define change_nexthops(fi) { int nhsel = 0; struct fib_nh * nh = (struct fib_nh *)((fi)->fib_nh); \
 for (nhsel=0; nhsel < 1; nhsel++)
 
 #endif /* CONFIG_IP_ROUTE_MULTIPATH */
@@ -358,7 +358,7 @@ int fib_detect_death(struct fib_info *fi, int order,
 		state = n->nud_state;
 		neigh_release(n);
 	}
-	if (state==NUD_REACHABLE)
+	if (state == NUD_REACHABLE)
 		return 0;
 	if ((state&NUD_VALID) && order != dflt)
 		return 0;
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index a0d8645..f92733e 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -167,7 +167,7 @@ static __inline__ void igmp_stop_timer(struct ip_mc_list *im)
 	spin_lock_bh(&im->lock);
 	if (del_timer(&im->timer))
 		atomic_dec(&im->refcnt);
-	im->tm_running=0;
+	im->tm_running = 0;
 	im->reporter = 0;
 	im->unsolicit_count = 0;
 	spin_unlock_bh(&im->lock);
@@ -176,9 +176,9 @@ static __inline__ void igmp_stop_timer(struct ip_mc_list *im)
 /* It must be called with locked im->lock */
 static void igmp_start_timer(struct ip_mc_list *im, int max_delay)
 {
-	int tv=net_random() % max_delay;
+	int tv = net_random() % max_delay;
 
-	im->tm_running=1;
+	im->tm_running = 1;
 	if (!mod_timer(&im->timer, jiffies+tv+2))
 		atomic_inc(&im->refcnt);
 }
@@ -207,7 +207,7 @@ static void igmp_mod_timer(struct ip_mc_list *im, int max_delay)
 	if (del_timer(&im->timer)) {
 		if ((long)(im->timer.expires-jiffies) < max_delay) {
 			add_timer(&im->timer);
-			im->tm_running=1;
+			im->tm_running = 1;
 			spin_unlock_bh(&im->lock);
 			return;
 		}
@@ -358,7 +358,7 @@ static int igmpv3_sendpack(struct sk_buff *skb)
 
 static int grec_size(struct ip_mc_list *pmc, int type, int gdel, int sdel)
 {
-	return sizeof(struct igmpv3_grec) + 4*igmp_scount(pmc,type,gdel,sdel);
+	return sizeof(struct igmpv3_grec) + 4*igmp_scount(pmc, type, gdel, sdel);
 }
 
 static struct sk_buff *add_grhead(struct sk_buff *skb, struct ip_mc_list *pmc,
@@ -653,7 +653,7 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 		return -1;
 	}
 
-	skb=alloc_skb(IGMP_SIZE+LL_ALLOCATED_SPACE(dev), GFP_ATOMIC);
+	skb = alloc_skb(IGMP_SIZE+LL_ALLOCATED_SPACE(dev), GFP_ATOMIC);
 	if (skb == NULL) {
 		ip_rt_put(rt);
 		return -1;
@@ -682,11 +682,11 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 	((u8*)&iph[1])[3] = 0;
 
 	ih = (struct igmphdr *)skb_put(skb, sizeof(struct igmphdr));
-	ih->type=type;
-	ih->code=0;
-	ih->csum=0;
-	ih->group=group;
-	ih->csum=ip_compute_csum((void *)ih, sizeof(struct igmphdr));
+	ih->type = type;
+	ih->code = 0;
+	ih->csum = 0;
+	ih->group = group;
+	ih->csum = ip_compute_csum((void *)ih, sizeof(struct igmphdr));
 
 	return ip_local_out(skb);
 }
@@ -728,7 +728,7 @@ static void igmp_timer_expire(unsigned long data)
 	struct in_device *in_dev = im->interface;
 
 	spin_lock(&im->lock);
-	im->tm_running=0;
+	im->tm_running = 0;
 
 	if (im->unsolicit_count) {
 		im->unsolicit_count--;
@@ -997,7 +997,7 @@ static void ip_mc_filter_add(struct in_device *in_dev, __be32 addr)
 	   --ANK
 	   */
 	if (arp_mc_map(addr, buf, dev, 0) == 0)
-		dev_mc_add(dev,buf,dev->addr_len,0);
+		dev_mc_add(dev, buf, dev->addr_len, 0);
 }
 
 /*
@@ -1010,7 +1010,7 @@ static void ip_mc_filter_del(struct in_device *in_dev, __be32 addr)
 	struct net_device *dev = in_dev->dev;
 
 	if (arp_mc_map(addr, buf, dev, 0) == 0)
-		dev_mc_delete(dev,buf,dev->addr_len,0);
+		dev_mc_delete(dev, buf, dev->addr_len, 0);
 }
 
 #ifdef CONFIG_IP_MULTICAST
@@ -1210,10 +1210,10 @@ void ip_mc_inc_group(struct in_device *in_dev, __be32 addr)
 	if (!im)
 		goto out;
 
-	im->users=1;
-	im->interface=in_dev;
+	im->users = 1;
+	im->interface = in_dev;
 	in_dev_hold(in_dev);
-	im->multiaddr=addr;
+	im->multiaddr = addr;
 	/* initial mode is (EX, empty) */
 	im->sfmode = MCAST_EXCLUDE;
 	im->sfcount[MCAST_INCLUDE] = 0;
@@ -1224,7 +1224,7 @@ void ip_mc_inc_group(struct in_device *in_dev, __be32 addr)
 	atomic_set(&im->refcnt, 1);
 	spin_lock_init(&im->lock);
 #ifdef CONFIG_IP_MULTICAST
-	im->tm_running=0;
+	im->tm_running = 0;
 	setup_timer(&im->timer, &igmp_timer_expire, (unsigned long)im);
 	im->unsolicit_count = IGMP_Unsolicited_Report_Count;
 	im->reporter = 0;
@@ -1232,8 +1232,8 @@ void ip_mc_inc_group(struct in_device *in_dev, __be32 addr)
 #endif
 	im->loaded = 0;
 	write_lock_bh(&in_dev->mc_list_lock);
-	im->next=in_dev->mc_list;
-	in_dev->mc_list=im;
+	im->next = in_dev->mc_list;
+	in_dev->mc_list = im;
 	in_dev->mc_count++;
 	write_unlock_bh(&in_dev->mc_list_lock);
 #ifdef CONFIG_IP_MULTICAST
@@ -1279,7 +1279,7 @@ void ip_mc_dec_group(struct in_device *in_dev, __be32 addr)
 	ASSERT_RTNL();
 
 	for (ip=&in_dev->mc_list; (i=*ip)!=NULL; ip=&i->next) {
-		if (i->multiaddr==addr) {
+		if (i->multiaddr == addr) {
 			if (--i->users == 0) {
 				write_lock_bh(&in_dev->mc_list_lock);
 				*ip = i->next;
@@ -1738,7 +1738,7 @@ int ip_mc_join_group(struct sock *sk , struct ip_mreqn *imr)
 {
 	int err;
 	__be32 addr = imr->imr_multiaddr.s_addr;
-	struct ip_mc_socklist *iml=NULL, *i;
+	struct ip_mc_socklist *iml = NULL, *i;
 	struct in_device *in_dev;
 	struct inet_sock *inet = inet_sk(sk);
 	struct net *net = sock_net(sk);
@@ -1769,7 +1769,7 @@ int ip_mc_join_group(struct sock *sk , struct ip_mreqn *imr)
 	err = -ENOBUFS;
 	if (count >= sysctl_igmp_max_memberships)
 		goto done;
-	iml = sock_kmalloc(sk,sizeof(*iml),GFP_KERNEL);
+	iml = sock_kmalloc(sk, sizeof(*iml), GFP_KERNEL);
 	if (iml == NULL)
 		goto done;
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index bd1278a..36f4cbc 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -323,7 +323,7 @@ void inet_csk_reset_keepalive_timer(struct sock *sk, unsigned long len)
 
 EXPORT_SYMBOL(inet_csk_reset_keepalive_timer);
 
-struct dst_entry* inet_csk_route_req(struct sock *sk,
+struct dst_entry *inet_csk_route_req(struct sock *sk,
 				     const struct request_sock *req)
 {
 	struct rtable *rt;
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index a456cee..b1fbe18 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -144,7 +144,7 @@ static void unlink_from_unused(struct inet_peer *p)
  * _stack is known to be NULL or not at compile time,
  * so compiler will optimize the if (_stack) tests.
  */
-#define lookup(_daddr,_stack) 					\
+#define lookup(_daddr, _stack) 					\
 ({								\
 	struct inet_peer *u, **v;				\
 	if (_stack != NULL) {					\
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index e4f81f5..e33b010 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -56,7 +56,7 @@ struct ipfrag_skb_cb
 	int			offset;
 };
 
-#define FRAG_CB(skb)	((struct ipfrag_skb_cb*)((skb)->cb))
+#define FRAG_CB(skb)	((struct ipfrag_skb_cb *)((skb)->cb))
 
 /* Describe an entry in the "incomplete datagrams" queue. */
 struct ipq {
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 85c487b..191ef75 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -371,7 +371,7 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
    by themself???
  */
 
-	struct iphdr *iph = (struct iphdr*)skb->data;
+	struct iphdr *iph = (struct iphdr *)skb->data;
 	__be16	     *p = (__be16*)(skb->data+(iph->ihl<<2));
 	int grehlen = (iph->ihl<<2) + 4;
 	const int type = icmp_hdr(skb)->type;
@@ -632,7 +632,7 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (dev->header_ops && dev->type == ARPHRD_IPGRE) {
 		gre_hlen = 0;
-		tiph = (struct iphdr*)skb->data;
+		tiph = (struct iphdr *)skb->data;
 	} else {
 		gre_hlen = tunnel->hlen;
 		tiph = &tunnel->parms.iph;
@@ -660,7 +660,7 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 			if (neigh == NULL)
 				goto tx_error;
 
-			addr6 = (struct in6_addr*)&neigh->primary_key;
+			addr6 = (struct in6_addr *)&neigh->primary_key;
 			addr_type = ipv6_addr_type(addr6);
 
 			if (addr_type == IPV6_ADDR_ANY) {
@@ -726,7 +726,7 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 #ifdef CONFIG_IPV6
 	else if (skb->protocol == htons(ETH_P_IPV6)) {
-		struct rt6_info *rt6 = (struct rt6_info*)skb->dst;
+		struct rt6_info *rt6 = (struct rt6_info *)skb->dst;
 
 		if (rt6 && mtu < dst_mtu(skb->dst) && mtu >= IPV6_MIN_MTU) {
 			if ((tunnel->parms.iph.daddr &&
@@ -800,7 +800,7 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 			iph->ttl = old_iph->ttl;
 #ifdef CONFIG_IPV6
 		else if (skb->protocol == htons(ETH_P_IPV6))
-			iph->ttl = ((struct ipv6hdr*)old_iph)->hop_limit;
+			iph->ttl = ((struct ipv6hdr *)old_iph)->hop_limit;
 #endif
 		else
 			iph->ttl = dst_metric(&rt->u.dst, RTAX_HOPLIMIT);
@@ -962,7 +962,7 @@ ipgre_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 					break;
 				}
 			} else {
-				unsigned nflags=0;
+				unsigned nflags = 0;
 
 				t = netdev_priv(dev);
 
@@ -1104,7 +1104,7 @@ static int ipgre_header(struct sk_buff *skb, struct net_device *dev,
 
 static int ipgre_header_parse(const struct sk_buff *skb, unsigned char *haddr)
 {
-	struct iphdr *iph = (struct iphdr*) skb_mac_header(skb);
+	struct iphdr *iph = (struct iphdr *) skb_mac_header(skb);
 	memcpy(haddr, &iph->saddr, 4);
 	return 4;
 }
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 861978a..6649684 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -342,9 +342,9 @@ static int ip_rcv_finish(struct sk_buff *skb)
 		struct ip_rt_acct *st = per_cpu_ptr(ip_rt_acct, smp_processor_id());
 		u32 idx = skb->dst->tclassid;
 		st[idx&0xFF].o_packets++;
-		st[idx&0xFF].o_bytes+=skb->len;
+		st[idx&0xFF].o_bytes += skb->len;
 		st[(idx>>16)&0xFF].i_packets++;
-		st[(idx>>16)&0xFF].i_bytes+=skb->len;
+		st[(idx>>16)&0xFF].i_bytes += skb->len;
 	}
 #endif
 
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index d2a8f8b..46d7be2 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -430,7 +430,7 @@ static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
  *	single device frame, and queue such a frame for sending.
  */
 
-int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*))
+int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 {
 	struct iphdr *iph;
 	int raw = 0;
@@ -720,7 +720,7 @@ static inline int ip_ufo_append_data(struct sock *sk,
 			int getfrag(void *from, char *to, int offset, int len,
 			       int odd, struct sk_buff *skb),
 			void *from, int length, int hh_len, int fragheaderlen,
-			int transhdrlen, int mtu,unsigned int flags)
+			int transhdrlen, int mtu, unsigned int flags)
 {
 	struct sk_buff *skb;
 	int err;
@@ -741,7 +741,7 @@ static inline int ip_ufo_append_data(struct sock *sk,
 		skb_reserve(skb, hh_len);
 
 		/* create space for UDP/IP header */
-		skb_put(skb,fragheaderlen + transhdrlen);
+		skb_put(skb, fragheaderlen + transhdrlen);
 
 		/* initialize network header pointer */
 		skb_reset_network_header(skb);
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 465abf0..e976efe 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -94,7 +94,7 @@ static void ip_cmsg_recv_opts(struct msghdr *msg, struct sk_buff *skb)
 static void ip_cmsg_recv_retopts(struct msghdr *msg, struct sk_buff *skb)
 {
 	unsigned char optbuf[sizeof(struct ip_options) + 40];
-	struct ip_options * opt = (struct ip_options*)optbuf;
+	struct ip_options * opt = (struct ip_options *)optbuf;
 
 	if (IPCB(skb)->opt.optlen == 0)
 		return;
@@ -411,7 +411,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			    int optname, char __user *optval, int optlen)
 {
 	struct inet_sock *inet = inet_sk(sk);
-	int val=0,err;
+	int val = 0, err;
 
 	if (((1<<optname) & ((1<<IP_PKTINFO) | (1<<IP_RECVTTL) |
 			     (1<<IP_RECVOPTS) | (1<<IP_RECVTOS) |
@@ -437,7 +437,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 	/* If optlen==0, it is equivalent to val == 0 */
 
 	if (ip_mroute_opt(optname))
-		return ip_mroute_setsockopt(sk,optname,optval,optlen);
+		return ip_mroute_setsockopt(sk, optname, optval, optlen);
 
 	err = 0;
 	lock_sock(sk);
@@ -549,7 +549,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			goto e_inval;
 		if (optlen<1)
 			goto e_inval;
-		if (val==-1)
+		if (val == -1)
 			val = 1;
 		if (val < 0 || val > 255)
 			goto e_inval;
@@ -573,12 +573,12 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 
 		err = -EFAULT;
 		if (optlen >= sizeof(struct ip_mreqn)) {
-			if (copy_from_user(&mreq,optval,sizeof(mreq)))
+			if (copy_from_user(&mreq, optval, sizeof(mreq)))
 				break;
 		} else {
 			memset(&mreq, 0, sizeof(mreq));
 			if (optlen >= sizeof(struct in_addr) &&
-			    copy_from_user(&mreq.imr_address,optval,sizeof(struct in_addr)))
+			    copy_from_user(&mreq.imr_address, optval, sizeof(struct in_addr)))
 				break;
 		}
 
@@ -626,11 +626,11 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			goto e_inval;
 		err = -EFAULT;
 		if (optlen >= sizeof(struct ip_mreqn)) {
-			if (copy_from_user(&mreq,optval,sizeof(mreq)))
+			if (copy_from_user(&mreq, optval, sizeof(mreq)))
 				break;
 		} else {
 			memset(&mreq, 0, sizeof(mreq));
-			if (copy_from_user(&mreq,optval,sizeof(struct ip_mreq)))
+			if (copy_from_user(&mreq, optval, sizeof(struct ip_mreq)))
 				break;
 		}
 
@@ -808,7 +808,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			err = -ENOBUFS;
 			break;
 		}
-		gsf = kmalloc(optlen,GFP_KERNEL);
+		gsf = kmalloc(optlen, GFP_KERNEL);
 		if (!gsf) {
 			err = -ENOBUFS;
 			break;
@@ -828,7 +828,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			goto mc_msf_out;
 		}
 		msize = IP_MSFILTER_SIZE(gsf->gf_numsrc);
-		msf = kmalloc(msize,GFP_KERNEL);
+		msf = kmalloc(msize, GFP_KERNEL);
 		if (!msf) {
 			err = -ENOBUFS;
 			goto mc_msf_out;
@@ -971,9 +971,9 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 		return -EOPNOTSUPP;
 
 	if (ip_mroute_opt(optname))
-		return ip_mroute_getsockopt(sk,optname,optval,optlen);
+		return ip_mroute_getsockopt(sk, optname, optval, optlen);
 
-	if (get_user(len,optlen))
+	if (get_user(len, optlen))
 		return -EFAULT;
 	if (len < 0)
 		return -EINVAL;
@@ -984,7 +984,7 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 	case IP_OPTIONS:
 	{
 		unsigned char optbuf[sizeof(struct ip_options)+40];
-		struct ip_options * opt = (struct ip_options*)optbuf;
+		struct ip_options * opt = (struct ip_options *)optbuf;
 		opt->optlen = 0;
 		if (inet->opt)
 			memcpy(optbuf, inet->opt,
@@ -1154,13 +1154,13 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 		len = 1;
 		if (put_user(len, optlen))
 			return -EFAULT;
-		if (copy_to_user(optval,&ucval,1))
+		if (copy_to_user(optval, &ucval, 1))
 			return -EFAULT;
 	} else {
 		len = min_t(unsigned int, sizeof(int), len);
 		if (put_user(len, optlen))
 			return -EFAULT;
-		if (copy_to_user(optval,&val,len))
+		if (copy_to_user(optval, &val, len))
 			return -EFAULT;
 	}
 	return 0;
@@ -1178,7 +1178,7 @@ int ip_getsockopt(struct sock *sk, int level,
 			!ip_mroute_opt(optname)) {
 		int len;
 
-		if (get_user(len,optlen))
+		if (get_user(len, optlen))
 			return -EFAULT;
 
 		lock_sock(sk);
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 29609d2..b3c3d7b 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -281,7 +281,7 @@ static int ipip_err(struct sk_buff *skb, u32 info)
    8 bytes of packet payload. It means, that precise relaying of
    ICMP in the real Internet is absolutely infeasible.
  */
-	struct iphdr *iph = (struct iphdr*)skb->data;
+	struct iphdr *iph = (struct iphdr *)skb->data;
 	const int type = icmp_hdr(skb)->type;
 	const int code = icmp_hdr(skb)->code;
 	struct ip_tunnel *t;
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
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index cd97574..998fcff 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -247,7 +247,7 @@ static void raw_err(struct sock *sk, struct sk_buff *skb, u32 info)
 	}
 
 	if (inet->recverr) {
-		struct iphdr *iph = (struct iphdr*)skb->data;
+		struct iphdr *iph = (struct iphdr *)skb->data;
 		u8 *payload = skb->data + (iph->ihl << 2);
 
 		if (inet->hdrincl)
@@ -465,7 +465,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	 */
 
 	if (msg->msg_namelen) {
-		struct sockaddr_in *usin = (struct sockaddr_in*)msg->msg_name;
+		struct sockaddr_in *usin = (struct sockaddr_in *)msg->msg_name;
 		err = -EINVAL;
 		if (msg->msg_namelen < sizeof(*usin))
 			goto out;
@@ -851,7 +851,7 @@ struct proto raw_prot = {
 static struct sock *raw_get_first(struct seq_file *seq)
 {
 	struct sock *sk;
-	struct raw_iter_state* state = raw_seq_private(seq);
+	struct raw_iter_state *state = raw_seq_private(seq);
 
 	for (state->bucket = 0; state->bucket < RAW_HTABLE_SIZE;
 			++state->bucket) {
@@ -868,7 +868,7 @@ found:
 
 static struct sock *raw_get_next(struct seq_file *seq, struct sock *sk)
 {
-	struct raw_iter_state* state = raw_seq_private(seq);
+	struct raw_iter_state *state = raw_seq_private(seq);
 
 	do {
 		sk = sk_next(sk);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 2ea6dcc..90a7482 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1908,7 +1908,7 @@ static int ip_mkroute_input(struct sk_buff *skb,
 			    struct in_device *in_dev,
 			    __be32 daddr, __be32 saddr, u32 tos)
 {
-	struct rtable* rth = NULL;
+	struct rtable *rth = NULL;
 	int err;
 	unsigned hash;
 
@@ -2270,7 +2270,7 @@ static int __mkroute_output(struct rtable **result,
 	rth->rt_gateway = fl->fl4_dst;
 	rth->rt_spec_dst= fl->fl4_src;
 
-	rth->u.dst.output=ip_output;
+	rth->u.dst.output = ip_output;
 	rth->rt_genid = rt_genid(dev_net(dev_out));
 
 	RT_CACHE_STAT_INC(out_slow_tot);
@@ -2752,7 +2752,7 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
-static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void *arg)
+static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct rtmsg *rtm;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index eccb716..60c28ad 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1681,7 +1681,7 @@ void tcp_set_state(struct sock *sk, int state)
 			inet_put_port(sk);
 		/* fall through */
 	default:
-		if (oldstate==TCP_ESTABLISHED)
+		if (oldstate == TCP_ESTABLISHED)
 			TCP_DEC_STATS(sock_net(sk), TCP_MIB_CURRESTAB);
 	}
 
@@ -1691,7 +1691,7 @@ void tcp_set_state(struct sock *sk, int state)
 	sk->sk_state = state;
 
 #ifdef STATE_TRACE
-	SOCK_DEBUG(sk, "TCP sk=%p, State %s -> %s\n",sk, statename[oldstate],statename[state]);
+	SOCK_DEBUG(sk, "TCP sk=%p, State %s -> %s\n", sk, statename[oldstate], statename[state]);
 #endif
 }
 EXPORT_SYMBOL_GPL(tcp_set_state);
@@ -2651,7 +2651,7 @@ EXPORT_SYMBOL(tcp_md5_hash_key);
 
 void tcp_done(struct sock *sk)
 {
-	if(sk->sk_state == TCP_SYN_SENT || sk->sk_state == TCP_SYN_RECV)
+	if (sk->sk_state == TCP_SYN_SENT || sk->sk_state == TCP_SYN_RECV)
 		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_ATTEMPTFAILS);
 
 	tcp_set_state(sk, TCP_CLOSE);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5c8fa7f..0969ca3 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1877,7 +1877,7 @@ static void *listening_get_next(struct seq_file *seq, void *cur)
 	struct inet_connection_sock *icsk;
 	struct hlist_node *node;
 	struct sock *sk = cur;
-	struct tcp_iter_state* st = seq->private;
+	struct tcp_iter_state *st = seq->private;
 	struct net *net = seq_file_net(seq);
 
 	if (!sk) {
@@ -1963,7 +1963,7 @@ static inline int empty_bucket(struct tcp_iter_state *st)
 
 static void *established_get_first(struct seq_file *seq)
 {
-	struct tcp_iter_state* st = seq->private;
+	struct tcp_iter_state *st = seq->private;
 	struct net *net = seq_file_net(seq);
 	void *rc = NULL;
 
@@ -2008,7 +2008,7 @@ static void *established_get_next(struct seq_file *seq, void *cur)
 	struct sock *sk = cur;
 	struct inet_timewait_sock *tw;
 	struct hlist_node *node;
-	struct tcp_iter_state* st = seq->private;
+	struct tcp_iter_state *st = seq->private;
 	struct net *net = seq_file_net(seq);
 
 	++st->num;
@@ -2067,7 +2067,7 @@ static void *established_get_idx(struct seq_file *seq, loff_t pos)
 static void *tcp_get_idx(struct seq_file *seq, loff_t pos)
 {
 	void *rc;
-	struct tcp_iter_state* st = seq->private;
+	struct tcp_iter_state *st = seq->private;
 
 	inet_listen_lock(&tcp_hashinfo);
 	st->state = TCP_SEQ_STATE_LISTENING;
@@ -2084,7 +2084,7 @@ static void *tcp_get_idx(struct seq_file *seq, loff_t pos)
 
 static void *tcp_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	struct tcp_iter_state* st = seq->private;
+	struct tcp_iter_state *st = seq->private;
 	st->state = TCP_SEQ_STATE_LISTENING;
 	st->num = 0;
 	return *pos ? tcp_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
@@ -2093,7 +2093,7 @@ static void *tcp_seq_start(struct seq_file *seq, loff_t *pos)
 static void *tcp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	void *rc = NULL;
-	struct tcp_iter_state* st;
+	struct tcp_iter_state *st;
 
 	if (v == SEQ_START_TOKEN) {
 		rc = tcp_get_idx(seq, 0);
@@ -2123,7 +2123,7 @@ out:
 
 static void tcp_seq_stop(struct seq_file *seq, void *v)
 {
-	struct tcp_iter_state* st = seq->private;
+	struct tcp_iter_state *st = seq->private;
 
 	switch (st->state) {
 	case TCP_SEQ_STATE_OPENREQ:
@@ -2284,7 +2284,7 @@ static void get_timewait4_sock(struct inet_timewait_sock *tw,
 
 static int tcp4_seq_show(struct seq_file *seq, void *v)
 {
-	struct tcp_iter_state* st;
+	struct tcp_iter_state *st;
 	int len;
 
 	if (v == SEQ_START_TOKEN) {
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 779f2e9..f67effb 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -491,7 +491,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
  *	as a request_sock.
  */
 
-struct sock *tcp_check_req(struct sock *sk,struct sk_buff *skb,
+struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 			   struct request_sock *req,
 			   struct request_sock **prev)
 {
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index ba85d88..a524627 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -42,7 +42,7 @@
 /* People can turn this off for buggy TCP's found in printers etc. */
 int sysctl_tcp_retrans_collapse __read_mostly = 1;
 
-/* People can turn this on to  work with those rare, broken TCPs that
+/* People can turn this on to work with those rare, broken TCPs that
  * interpret the window field as a signed quantity.
  */
 int sysctl_tcp_workaround_signed_windows __read_mostly = 0;
@@ -484,7 +484,7 @@ static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 	}
 	if (likely(sysctl_tcp_window_scaling)) {
 		opts->ws = tp->rx_opt.rcv_wscale;
-		if(likely(opts->ws))
+		if (likely(opts->ws))
 			size += TCPOLEN_WSCALE_ALIGNED;
 	}
 	if (likely(sysctl_tcp_sack)) {
@@ -526,7 +526,7 @@ static unsigned tcp_synack_options(struct sock *sk,
 
 	if (likely(ireq->wscale_ok)) {
 		opts->ws = ireq->rcv_wscale;
-		if(likely(opts->ws))
+		if (likely(opts->ws))
 			size += TCPOLEN_WSCALE_ALIGNED;
 	}
 	if (likely(doing_ts)) {
@@ -1172,7 +1172,7 @@ static int tcp_init_tso_segs(struct sock *sk, struct sk_buff *skb,
 
 static inline int tcp_minshall_check(const struct tcp_sock *tp)
 {
-	return after(tp->snd_sml,tp->snd_una) &&
+	return after(tp->snd_sml, tp->snd_una) &&
 		!after(tp->snd_sml, tp->snd_nxt);
 }
 
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 6b6dff1..63c23a4 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -171,7 +171,7 @@ static int tcp_write_timeout(struct sock *sk)
 
 static void tcp_delack_timer(unsigned long data)
 {
-	struct sock *sk = (struct sock*)data;
+	struct sock *sk = (struct sock *)data;
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 
@@ -396,7 +396,7 @@ out:;
 
 static void tcp_write_timer(unsigned long data)
 {
-	struct sock *sk = (struct sock*)data;
+	struct sock *sk = (struct sock *)data;
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	int event;
 
diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
index e03b101..9ec843a 100644
--- a/net/ipv4/tcp_yeah.c
+++ b/net/ipv4/tcp_yeah.c
@@ -83,7 +83,7 @@ static void tcp_yeah_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
 	else if (!yeah->doing_reno_now) {
 		/* Scalable */
 
-		tp->snd_cwnd_cnt+=yeah->pkts_acked;
+		tp->snd_cwnd_cnt += yeah->pkts_acked;
 		if (tp->snd_cwnd_cnt > min(tp->snd_cwnd, TCP_SCALABLE_AI_CNT)){
 			if (tp->snd_cwnd < tp->snd_cwnd_clamp)
 				tp->snd_cwnd++;
@@ -224,7 +224,7 @@ static u32 tcp_yeah_ssthresh(struct sock *sk) {
 
 		reduction = max( reduction, tp->snd_cwnd >> TCP_YEAH_DELTA);
 	} else
-		reduction = max(tp->snd_cwnd>>1,2U);
+		reduction = max(tp->snd_cwnd>>1, 2U);
 
 	yeah->fast_count = 0;
 	yeah->reno_count = max(yeah->reno_count>>1, 2U);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 2095abc..45a6c7c 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -230,22 +230,22 @@ static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 			if (inet->rcv_saddr) {
 				if (inet->rcv_saddr != daddr)
 					continue;
-				score+=2;
+				score += 2;
 			}
 			if (inet->daddr) {
 				if (inet->daddr != saddr)
 					continue;
-				score+=2;
+				score += 2;
 			}
 			if (inet->dport) {
 				if (inet->dport != sport)
 					continue;
-				score+=2;
+				score += 2;
 			}
 			if (sk->sk_bound_dev_if) {
 				if (sk->sk_bound_dev_if != dif)
 					continue;
-				score+=2;
+				score += 2;
 			}
 			if (score == 9) {
 				result = sk;
@@ -326,8 +326,8 @@ found:
 void __udp4_lib_err(struct sk_buff *skb, u32 info, struct hlist_head udptable[])
 {
 	struct inet_sock *inet;
-	struct iphdr *iph = (struct iphdr*)skb->data;
-	struct udphdr *uh = (struct udphdr*)(skb->data+(iph->ihl<<2));
+	struct iphdr *iph = (struct iphdr *)skb->data;
+	struct udphdr *uh = (struct udphdr *)(skb->data+(iph->ihl<<2));
 	const int type = icmp_hdr(skb)->type;
 	const int code = icmp_hdr(skb)->code;
 	struct sock *sk;
@@ -488,7 +488,7 @@ static int udp_push_pending_frames(struct sock *sk)
 
 	} else if (skb->ip_summed == CHECKSUM_PARTIAL) { /* UDP hardware csum */
 
-		udp4_hwcsum_outgoing(sk, skb, fl->fl4_src,fl->fl4_dst, up->len);
+		udp4_hwcsum_outgoing(sk, skb, fl->fl4_src, fl->fl4_dst, up->len);
 		goto send;
 
 	} else						 /*   `normal' UDP    */
@@ -561,7 +561,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	 *	Get and verify the address.
 	 */
 	if (msg->msg_name) {
-		struct sockaddr_in * usin = (struct sockaddr_in*)msg->msg_name;
+		struct sockaddr_in * usin = (struct sockaddr_in *)msg->msg_name;
 		if (msg->msg_namelen < sizeof(*usin))
 			return -EINVAL;
 		if (usin->sin_family != AF_INET) {
@@ -623,7 +623,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	}
 
 	if (connected)
-		rt = (struct rtable*)sk_dst_check(sk, 0);
+		rt = (struct rtable *)sk_dst_check(sk, 0);
 
 	if (rt == NULL) {
 		struct flowi fl = { .oif = ipc.oif,
@@ -829,7 +829,7 @@ int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	 *	Check any passed addresses
 	 */
 	if (addr_len)
-		*addr_len=sizeof(*sin);
+		*addr_len = sizeof(*sin);
 
 	if (flags & MSG_ERRQUEUE)
 		return ip_recv_error(sk, msg, len);
@@ -1154,7 +1154,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 	struct sock *sk;
 	struct udphdr *uh = udp_hdr(skb);
 	unsigned short ulen;
-	struct rtable *rt = (struct rtable*)skb->dst;
+	struct rtable *rt = (struct rtable *)skb->dst;
 	__be32 saddr = ip_hdr(skb)->saddr;
 	__be32 daddr = ip_hdr(skb)->daddr;
 	struct net *net = dev_net(skb->dev);
@@ -1366,7 +1366,7 @@ int udp_lib_getsockopt(struct sock *sk, int level, int optname,
 	struct udp_sock *up = udp_sk(sk);
 	int val, len;
 
-	if (get_user(len,optlen))
+	if (get_user(len, optlen))
 		return -EFAULT;
 
 	len = min_t(unsigned int, len, sizeof(int));
@@ -1399,7 +1399,7 @@ int udp_lib_getsockopt(struct sock *sk, int level, int optname,
 
 	if (put_user(len, optlen))
 		return -EFAULT;
-	if (copy_to_user(optval, &val,len))
+	if (copy_to_user(optval, &val, len))
 		return -EFAULT;
 	return 0;
 }
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index c63de0a..f9a775b 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -65,7 +65,7 @@ __xfrm4_find_bundle(struct flowi *fl, struct xfrm_policy *policy)
 
 	read_lock_bh(&policy->lock);
 	for (dst = policy->bundles; dst; dst = dst->next) {
-		struct xfrm_dst *xdst = (struct xfrm_dst*)dst;
+		struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
 		if (xdst->u.rt.fl.oif == fl->oif &&	/*XXX*/
 		    xdst->u.rt.fl.fl4_dst == fl->fl4_dst &&
 		    xdst->u.rt.fl.fl4_src == fl->fl4_src &&
-- 
1.5.6.3

