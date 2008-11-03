From: Jianjun Kong <jianjun@zeuux.org>
Subject: [PATCH 3/6] nets: clean up net/ipv4/fib_frontend.c fib_hash.c
	ip_gre.c
Date: Mon, 3 Nov 2008 16:19:31 +0800
Message-ID: <20081103081931.GD14553@ubuntu>
References: <20081102074446.GA12140@ubuntu> <490DEAD3.3030202@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeuux.org ([210.51.160.52]:55759 "EHLO z.billxu.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754594AbYKCITY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 03:19:24 -0500
Content-Disposition: inline
In-Reply-To: <490DEAD3.3030202@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 [PATCH 3/6] clean up net/ipv4/
 fib_frontend.c fib_hash.c ip_gre.c

Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
---
 net/ipv4/fib_frontend.c |   10 +++++-----
 net/ipv4/fib_hash.c     |   12 ++++++------
 net/ipv4/ip_gre.c       |   14 +++++++-------
 3 files changed, 18 insertions(+), 18 deletions(-)

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
-- 
1.5.6.3

