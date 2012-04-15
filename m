From: dbaluta@ixiacom.com
Subject: [PATCH][trivial] ipv4: fix checkpatch errors
Date: Sun, 15 Apr 2012 14:34:41 +0300
Message-ID: <1334489681-4662-1-git-send-email-dbaluta@ixiacom.com>
Cc: linux-kernel@vger.kernel.org, Daniel Baluta <dbaluta@ixiacom.com>
To: netdev@vger.kernel.org, trivial@kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Baluta <dbaluta@ixiacom.com>

Fix checkpatch errors of the following type:
	* ERROR: "foo * bar" should be "foo *bar"
	* ERROR: "(foo*)" should be "(foo *)"

Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>
---
 net/ipv4/af_inet.c         |    2 +-
 net/ipv4/ah4.c             |    2 +-
 net/ipv4/igmp.c            |   16 ++++++++--------
 net/ipv4/inet_hashtables.c |    2 +-
 net/ipv4/ip_forward.c      |    4 ++--
 net/ipv4/ip_gre.c          |   16 ++++++++--------
 net/ipv4/ip_options.c      |   24 ++++++++++++------------
 net/ipv4/ip_sockglue.c     |    2 +-
 net/ipv4/ipip.c            |    4 ++--
 net/ipv4/ping.c            |    2 +-
 net/ipv4/raw.c             |    2 +-
 net/ipv4/route.c           |   10 +++++-----
 net/ipv4/tcp_probe.c       |    2 +-
 net/ipv4/udp.c             |    2 +-
 net/ipv4/udp_impl.h        |    2 +-
 net/ipv4/xfrm4_policy.c    |    2 +-
 16 files changed, 47 insertions(+), 47 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 10e3751..3744c1c 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -541,7 +541,7 @@ out:
 }
 EXPORT_SYMBOL(inet_bind);
 
-int inet_dgram_connect(struct socket *sock, struct sockaddr * uaddr,
+int inet_dgram_connect(struct socket *sock, struct sockaddr *uaddr,
 		       int addr_len, int flags)
 {
 	struct sock *sk = sock->sk;
diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index fd508b5..3a28075 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -77,7 +77,7 @@ static inline struct scatterlist *ah_req_sg(struct crypto_ahash *ahash,
 
 static int ip_clear_mutable_options(const struct iphdr *iph, __be32 *daddr)
 {
-	unsigned char * optptr = (unsigned char*)(iph+1);
+	unsigned char *optptr = (unsigned char *)(iph+1);
 	int  l = iph->ihl*4 - sizeof(struct iphdr);
 	int  optlen;
 
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index ceaac24..6699f23 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -344,10 +344,10 @@ static struct sk_buff *igmpv3_newpack(struct net_device *dev, int size)
 	pip->protocol = IPPROTO_IGMP;
 	pip->tot_len  = 0;	/* filled in later */
 	ip_select_ident(pip, &rt->dst, NULL);
-	((u8*)&pip[1])[0] = IPOPT_RA;
-	((u8*)&pip[1])[1] = 4;
-	((u8*)&pip[1])[2] = 0;
-	((u8*)&pip[1])[3] = 0;
+	((u8 *)&pip[1])[0] = IPOPT_RA;
+	((u8 *)&pip[1])[1] = 4;
+	((u8 *)&pip[1])[2] = 0;
+	((u8 *)&pip[1])[3] = 0;
 
 	skb->transport_header = skb->network_header + sizeof(struct iphdr) + 4;
 	skb_put(skb, sizeof(*pig));
@@ -688,10 +688,10 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 	iph->saddr    = fl4.saddr;
 	iph->protocol = IPPROTO_IGMP;
 	ip_select_ident(iph, &rt->dst, NULL);
-	((u8*)&iph[1])[0] = IPOPT_RA;
-	((u8*)&iph[1])[1] = 4;
-	((u8*)&iph[1])[2] = 0;
-	((u8*)&iph[1])[3] = 0;
+	((u8 *)&iph[1])[0] = IPOPT_RA;
+	((u8 *)&iph[1])[1] = 4;
+	((u8 *)&iph[1])[2] = 0;
+	((u8 *)&iph[1])[3] = 0;
 
 	ih = (struct igmphdr *)skb_put(skb, sizeof(struct igmphdr));
 	ih->type = type;
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 984ec65..7880af9 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -217,7 +217,7 @@ begin:
 }
 EXPORT_SYMBOL_GPL(__inet_lookup_listener);
 
-struct sock * __inet_lookup_established(struct net *net,
+struct sock *__inet_lookup_established(struct net *net,
 				  struct inet_hashinfo *hashinfo,
 				  const __be32 saddr, const __be16 sport,
 				  const __be32 daddr, const u16 hnum,
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 29a07b6..e5c44fc 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -41,7 +41,7 @@
 
 static int ip_forward_finish(struct sk_buff *skb)
 {
-	struct ip_options * opt	= &(IPCB(skb)->opt);
+	struct ip_options *opt	= &(IPCB(skb)->opt);
 
 	IP_INC_STATS_BH(dev_net(skb_dst(skb)->dev), IPSTATS_MIB_OUTFORWDATAGRAMS);
 
@@ -55,7 +55,7 @@ int ip_forward(struct sk_buff *skb)
 {
 	struct iphdr *iph;	/* Our header */
 	struct rtable *rt;	/* Route we use */
-	struct ip_options * opt	= &(IPCB(skb)->opt);
+	struct ip_options *opt	= &(IPCB(skb)->opt);
 
 	if (skb_warn_if_lro(skb))
 		goto drop;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index b9abf26..2e6c3b7 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -216,7 +216,7 @@ static struct rtnl_link_stats64 *ipgre_get_stats64(struct net_device *dev,
 
 /* Given src, dst and key, find appropriate for input tunnel. */
 
-static struct ip_tunnel * ipgre_tunnel_lookup(struct net_device *dev,
+static struct ip_tunnel *ipgre_tunnel_lookup(struct net_device *dev,
 					      __be32 remote, __be32 local,
 					      __be32 key, __be16 gre_proto)
 {
@@ -483,7 +483,7 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
  */
 
 	const struct iphdr *iph = (const struct iphdr *)skb->data;
-	__be16	     *p = (__be16*)(skb->data+(iph->ihl<<2));
+	__be16	     *p = (__be16 *)(skb->data+(iph->ihl<<2));
 	int grehlen = (iph->ihl<<2) + 4;
 	const int type = icmp_hdr(skb)->type;
 	const int code = icmp_hdr(skb)->code;
@@ -593,7 +593,7 @@ static int ipgre_rcv(struct sk_buff *skb)
 
 	iph = ip_hdr(skb);
 	h = skb->data;
-	flags = *(__be16*)h;
+	flags = *(__be16 *)h;
 
 	if (flags&(GRE_CSUM|GRE_KEY|GRE_ROUTING|GRE_SEQ|GRE_VERSION)) {
 		/* - Version must be 0.
@@ -617,11 +617,11 @@ static int ipgre_rcv(struct sk_buff *skb)
 			offset += 4;
 		}
 		if (flags&GRE_KEY) {
-			key = *(__be32*)(h + offset);
+			key = *(__be32 *)(h + offset);
 			offset += 4;
 		}
 		if (flags&GRE_SEQ) {
-			seqno = ntohl(*(__be32*)(h + offset));
+			seqno = ntohl(*(__be32 *)(h + offset));
 			offset += 4;
 		}
 	}
@@ -921,7 +921,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 				   htons(ETH_P_TEB) : skb->protocol;
 
 	if (tunnel->parms.o_flags&(GRE_KEY|GRE_CSUM|GRE_SEQ)) {
-		__be32 *ptr = (__be32*)(((u8*)iph) + tunnel->hlen - 4);
+		__be32 *ptr = (__be32 *)(((u8 *)iph) + tunnel->hlen - 4);
 
 		if (tunnel->parms.o_flags&GRE_SEQ) {
 			++tunnel->o_seqno;
@@ -934,7 +934,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 		}
 		if (tunnel->parms.o_flags&GRE_CSUM) {
 			*ptr = 0;
-			*(__sum16*)ptr = ip_compute_csum((void*)(iph+1), skb->len - sizeof(struct iphdr));
+			*(__sum16 *)ptr = ip_compute_csum((void *)(iph+1), skb->len - sizeof(struct iphdr));
 		}
 	}
 
@@ -1190,7 +1190,7 @@ static int ipgre_header(struct sk_buff *skb, struct net_device *dev,
 {
 	struct ip_tunnel *t = netdev_priv(dev);
 	struct iphdr *iph = (struct iphdr *)skb_push(skb, t->hlen);
-	__be16 *p = (__be16*)(iph+1);
+	__be16 *p = (__be16 *)(iph+1);
 
 	memcpy(iph, &t->parms.iph, sizeof(struct iphdr));
 	p[0]		= t->parms.o_flags;
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index a0d0d9d..1372c45 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -210,10 +210,10 @@ int ip_options_echo(struct ip_options *dopt, struct sk_buff *skb)
  *	Simple and stupid 8), but the most efficient way.
  */
 
-void ip_options_fragment(struct sk_buff * skb)
+void ip_options_fragment(struct sk_buff *skb)
 {
 	unsigned char *optptr = skb_network_header(skb) + sizeof(struct iphdr);
-	struct ip_options * opt = &(IPCB(skb)->opt);
+	struct ip_options *opt = &(IPCB(skb)->opt);
 	int  l = opt->optlen;
 	int  optlen;
 
@@ -248,13 +248,13 @@ void ip_options_fragment(struct sk_buff * skb)
  */
 
 int ip_options_compile(struct net *net,
-		       struct ip_options * opt, struct sk_buff * skb)
+		       struct ip_options *opt, struct sk_buff *skb)
 {
 	int l;
-	unsigned char * iph;
-	unsigned char * optptr;
+	unsigned char *iph;
+	unsigned char *optptr;
 	int optlen;
-	unsigned char * pp_ptr = NULL;
+	unsigned char *pp_ptr = NULL;
 	struct rtable *rt = NULL;
 
 	if (skb != NULL) {
@@ -473,20 +473,20 @@ EXPORT_SYMBOL(ip_options_compile);
  *	Undo all the changes done by ip_options_compile().
  */
 
-void ip_options_undo(struct ip_options * opt)
+void ip_options_undo(struct ip_options *opt)
 {
 	if (opt->srr) {
-		unsigned  char * optptr = opt->__data+opt->srr-sizeof(struct  iphdr);
+		unsigned  char *optptr = opt->__data+opt->srr-sizeof(struct  iphdr);
 		memmove(optptr+7, optptr+3, optptr[1]-7);
 		memcpy(optptr+3, &opt->faddr, 4);
 	}
 	if (opt->rr_needaddr) {
-		unsigned  char * optptr = opt->__data+opt->rr-sizeof(struct  iphdr);
+		unsigned  char *optptr = opt->__data+opt->rr-sizeof(struct  iphdr);
 		optptr[2] -= 4;
 		memset(&optptr[optptr[2]-1], 0, 4);
 	}
 	if (opt->ts) {
-		unsigned  char * optptr = opt->__data+opt->ts-sizeof(struct  iphdr);
+		unsigned  char *optptr = opt->__data+opt->ts-sizeof(struct  iphdr);
 		if (opt->ts_needtime) {
 			optptr[2] -= 4;
 			memset(&optptr[optptr[2]-1], 0, 4);
@@ -549,8 +549,8 @@ int ip_options_get(struct net *net, struct ip_options_rcu **optp,
 
 void ip_forward_options(struct sk_buff *skb)
 {
-	struct   ip_options * opt	= &(IPCB(skb)->opt);
-	unsigned char * optptr;
+	struct   ip_options *opt	= &(IPCB(skb)->opt);
+	unsigned char *optptr;
 	struct rtable *rt = skb_rtable(skb);
 	unsigned char *raw = skb_network_header(skb);
 
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 2fd0fba..0a87e1f 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -90,7 +90,7 @@ static void ip_cmsg_recv_opts(struct msghdr *msg, struct sk_buff *skb)
 static void ip_cmsg_recv_retopts(struct msghdr *msg, struct sk_buff *skb)
 {
 	unsigned char optbuf[sizeof(struct ip_options) + 40];
-	struct ip_options * opt = (struct ip_options *)optbuf;
+	struct ip_options *opt = (struct ip_options *)optbuf;
 
 	if (IPCB(skb)->opt.optlen == 0)
 		return;
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index b5a1849..2d0f99b 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -185,7 +185,7 @@ static struct rtnl_link_stats64 *ipip_get_stats64(struct net_device *dev,
 	return tot;
 }
 
-static struct ip_tunnel * ipip_tunnel_lookup(struct net *net,
+static struct ip_tunnel *ipip_tunnel_lookup(struct net *net,
 		__be32 remote, __be32 local)
 {
 	unsigned int h0 = HASH(remote);
@@ -260,7 +260,7 @@ static void ipip_tunnel_link(struct ipip_net *ipn, struct ip_tunnel *t)
 	rcu_assign_pointer(*tp, t);
 }
 
-static struct ip_tunnel * ipip_tunnel_locate(struct net *net,
+static struct ip_tunnel *ipip_tunnel_locate(struct net *net,
 		struct ip_tunnel_parm *parms, int create)
 {
 	__be32 remote = parms->iph.daddr;
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 50009c7..9f380ac 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -410,7 +410,7 @@ struct pingfakehdr {
 	__wsum wcheck;
 };
 
-static int ping_getfrag(void *from, char * to,
+static int ping_getfrag(void *from, char *to,
 			int offset, int fraglen, int odd, struct sk_buff *skb)
 {
 	struct pingfakehdr *pfh = (struct pingfakehdr *)from;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index bbd604c..4032b81 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -288,7 +288,7 @@ void raw_icmp_error(struct sk_buff *skb, int protocol, u32 info)
 	read_unlock(&raw_v4_hashinfo.lock);
 }
 
-static int raw_rcv_skb(struct sock * sk, struct sk_buff * skb)
+static int raw_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	/* Charge it to the socket. */
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e4d18f2..a13ce23 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2215,7 +2215,7 @@ static int ip_mkroute_input(struct sk_buff *skb,
 			    struct in_device *in_dev,
 			    __be32 daddr, __be32 saddr, u32 tos)
 {
-	struct rtable* rth = NULL;
+	struct rtable *rth = NULL;
 	int err;
 	unsigned hash;
 
@@ -2257,11 +2257,11 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	struct flowi4	fl4;
 	unsigned	flags = 0;
 	u32		itag = 0;
-	struct rtable * rth;
+	struct rtable *rth;
 	unsigned	hash;
 	__be32		spec_dst;
 	int		err = -EINVAL;
-	struct net    * net = dev_net(dev);
+	struct net    *net = dev_net(dev);
 
 	/* IP on this device is disabled. */
 
@@ -2433,7 +2433,7 @@ martian_source_keep_err:
 int ip_route_input_common(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 			   u8 tos, struct net_device *dev, bool noref)
 {
-	struct rtable * rth;
+	struct rtable *rth;
 	unsigned	hash;
 	int iif = dev->ifindex;
 	struct net *net;
@@ -3068,7 +3068,7 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
-static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void *arg)
+static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct rtmsg *rtm;
diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index a981cdc..a8df705 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -138,7 +138,7 @@ static struct jprobe tcp_jprobe = {
 	.entry	= jtcp_rcv_established,
 };
 
-static int tcpprobe_open(struct inode * inode, struct file * file)
+static int tcpprobe_open(struct inode *inode, struct file *file)
 {
 	/* Reset (empty) log */
 	spin_lock_bh(&tcp_probe.lock);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ad1e0dd..381ea51 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -847,7 +847,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	 *	Get and verify the address.
 	 */
 	if (msg->msg_name) {
-		struct sockaddr_in * usin = (struct sockaddr_in *)msg->msg_name;
+		struct sockaddr_in *usin = (struct sockaddr_in *)msg->msg_name;
 		if (msg->msg_namelen < sizeof(*usin))
 			return -EINVAL;
 		if (usin->sin_family != AF_INET) {
diff --git a/net/ipv4/udp_impl.h b/net/ipv4/udp_impl.h
index aaad650..5a681e2 100644
--- a/net/ipv4/udp_impl.h
+++ b/net/ipv4/udp_impl.h
@@ -25,7 +25,7 @@ extern int	udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			    size_t len, int noblock, int flags, int *addr_len);
 extern int	udp_sendpage(struct sock *sk, struct page *page, int offset,
 			     size_t size, int flags);
-extern int	udp_queue_rcv_skb(struct sock * sk, struct sk_buff *skb);
+extern int	udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
 extern void	udp_destroy_sock(struct sock *sk);
 
 #ifdef CONFIG_PROC_FS
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index a0b4c5d..8ef24e1 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -152,7 +152,7 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 
 		case IPPROTO_AH:
 			if (pskb_may_pull(skb, xprth + 8 - skb->data)) {
-				__be32 *ah_hdr = (__be32*)xprth;
+				__be32 *ah_hdr = (__be32 *)xprth;
 
 				fl4->fl4_ipsec_spi = ah_hdr[1];
 			}
-- 
1.7.1
