From: Jianjun Kong <jianjun@zeuux.org>
Subject: [PATCH 4/6] nets: clean up net/ipv4/igmp.c
Date: Mon, 3 Nov 2008 16:19:49 +0800
Message-ID: <20081103081949.GE14553@ubuntu>
References: <20081102074446.GA12140@ubuntu> <490DEAD3.3030202@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeuux.org ([210.51.160.52]:54987 "EHLO z.billxu.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754634AbYKCITn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 03:19:43 -0500
Content-Disposition: inline
In-Reply-To: <490DEAD3.3030202@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[PATCH 4/6] clean up net/ipv4/igmp.c

Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
---
 net/ipv4/igmp.c |   46 +++++++++++++++++++++++-----------------------
 1 files changed, 23 insertions(+), 23 deletions(-)

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
 
-- 
1.5.6.3

