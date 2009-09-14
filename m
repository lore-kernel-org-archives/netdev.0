From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 1/3] net: constify struct net_protocol
Date: Tue, 15 Sep 2009 02:21:47 +0400
Message-ID: <20090914222146.GA31565@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f217.google.com ([209.85.219.217]:41501 "EHLO
	mail-ew0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757441AbZINWaC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 18:30:02 -0400
Received: by ewy17 with SMTP id 17so3372247ewy.39
        for <netdev@vger.kernel.org>; Mon, 14 Sep 2009 15:30:03 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove long removed "inet_protocol_base" declaration.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/protocol.h |    7 +++----
 net/dccp/ipv4.c        |    2 +-
 net/ipv4/af_inet.c     |   18 +++++++++---------
 net/ipv4/ah4.c         |    2 +-
 net/ipv4/esp4.c        |    2 +-
 net/ipv4/icmp.c        |    2 +-
 net/ipv4/ip_gre.c      |    2 +-
 net/ipv4/ip_input.c    |    2 +-
 net/ipv4/ipcomp.c      |    2 +-
 net/ipv4/ipmr.c        |    6 +-----
 net/ipv4/protocol.c    |    6 +++---
 net/ipv4/tunnel4.c     |    4 ++--
 net/ipv4/udplite.c     |    2 +-
 net/sctp/protocol.c    |    2 +-
 14 files changed, 27 insertions(+), 32 deletions(-)

--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -94,15 +94,14 @@ struct inet_protosw {
 #define INET_PROTOSW_PERMANENT 0x02  /* Permanent protocols are unremovable. */
 #define INET_PROTOSW_ICSK      0x04  /* Is this an inet_connection_sock? */
 
-extern struct net_protocol *inet_protocol_base;
-extern struct net_protocol *inet_protos[MAX_INET_PROTOS];
+extern const struct net_protocol *inet_protos[MAX_INET_PROTOS];
 
 #if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
 extern struct inet6_protocol *inet6_protos[MAX_INET_PROTOS];
 #endif
 
-extern int	inet_add_protocol(struct net_protocol *prot, unsigned char num);
-extern int	inet_del_protocol(struct net_protocol *prot, unsigned char num);
+extern int	inet_add_protocol(const struct net_protocol *prot, unsigned char num);
+extern int	inet_del_protocol(const struct net_protocol *prot, unsigned char num);
 extern void	inet_register_protosw(struct inet_protosw *p);
 extern void	inet_unregister_protosw(struct inet_protosw *p);
 
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -948,7 +948,7 @@ static struct proto dccp_v4_prot = {
 #endif
 };
 
-static struct net_protocol dccp_v4_protocol = {
+static const struct net_protocol dccp_v4_protocol = {
 	.handler	= dccp_v4_rcv,
 	.err_handler	= dccp_v4_err,
 	.no_policy	= 1,
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -244,7 +244,7 @@ EXPORT_SYMBOL(build_ehash_secret);
 static inline int inet_netns_ok(struct net *net, int protocol)
 {
 	int hash;
-	struct net_protocol *ipprot;
+	const struct net_protocol *ipprot;
 
 	if (net_eq(net, &init_net))
 		return 1;
@@ -1162,7 +1162,7 @@ EXPORT_SYMBOL(inet_sk_rebuild_header);
 static int inet_gso_send_check(struct sk_buff *skb)
 {
 	struct iphdr *iph;
-	struct net_protocol *ops;
+	const struct net_protocol *ops;
 	int proto;
 	int ihl;
 	int err = -EINVAL;
@@ -1198,7 +1198,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb, int features)
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	struct iphdr *iph;
-	struct net_protocol *ops;
+	const struct net_protocol *ops;
 	int proto;
 	int ihl;
 	int id;
@@ -1265,7 +1265,7 @@ out:
 static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 					 struct sk_buff *skb)
 {
-	struct net_protocol *ops;
+	const struct net_protocol *ops;
 	struct sk_buff **pp = NULL;
 	struct sk_buff *p;
 	struct iphdr *iph;
@@ -1342,7 +1342,7 @@ out:
 
 static int inet_gro_complete(struct sk_buff *skb)
 {
-	struct net_protocol *ops;
+	const struct net_protocol *ops;
 	struct iphdr *iph = ip_hdr(skb);
 	int proto = iph->protocol & (MAX_INET_PROTOS - 1);
 	int err = -ENOSYS;
@@ -1427,13 +1427,13 @@ void snmp_mib_free(void *ptr[2])
 EXPORT_SYMBOL_GPL(snmp_mib_free);
 
 #ifdef CONFIG_IP_MULTICAST
-static struct net_protocol igmp_protocol = {
+static const struct net_protocol igmp_protocol = {
 	.handler =	igmp_rcv,
 	.netns_ok =	1,
 };
 #endif
 
-static struct net_protocol tcp_protocol = {
+static const struct net_protocol tcp_protocol = {
 	.handler =	tcp_v4_rcv,
 	.err_handler =	tcp_v4_err,
 	.gso_send_check = tcp_v4_gso_send_check,
@@ -1444,7 +1444,7 @@ static struct net_protocol tcp_protocol = {
 	.netns_ok =	1,
 };
 
-static struct net_protocol udp_protocol = {
+static const struct net_protocol udp_protocol = {
 	.handler =	udp_rcv,
 	.err_handler =	udp_err,
 	.gso_send_check = udp4_ufo_send_check,
@@ -1453,7 +1453,7 @@ static struct net_protocol udp_protocol = {
 	.netns_ok =	1,
 };
 
-static struct net_protocol icmp_protocol = {
+static const struct net_protocol icmp_protocol = {
 	.handler =	icmp_rcv,
 	.no_policy =	1,
 	.netns_ok =	1,
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -311,7 +311,7 @@ static const struct xfrm_type ah_type =
 	.output		= ah_output
 };
 
-static struct net_protocol ah4_protocol = {
+static const struct net_protocol ah4_protocol = {
 	.handler	=	xfrm4_rcv,
 	.err_handler	=	ah4_err,
 	.no_policy	=	1,
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -615,7 +615,7 @@ static const struct xfrm_type esp_type =
 	.output		= esp_output
 };
 
-static struct net_protocol esp4_protocol = {
+static const struct net_protocol esp4_protocol = {
 	.handler	=	xfrm4_rcv,
 	.err_handler	=	esp4_err,
 	.no_policy	=	1,
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -655,7 +655,7 @@ static void icmp_unreach(struct sk_buff *skb)
 	struct iphdr *iph;
 	struct icmphdr *icmph;
 	int hash, protocol;
-	struct net_protocol *ipprot;
+	const struct net_protocol *ipprot;
 	u32 info = 0;
 	struct net *net;
 
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1288,7 +1288,7 @@ static void ipgre_fb_tunnel_init(struct net_device *dev)
 }
 
 
-static struct net_protocol ipgre_protocol = {
+static const struct net_protocol ipgre_protocol = {
 	.handler	=	ipgre_rcv,
 	.err_handler	=	ipgre_err,
 	.netns_ok	=	1,
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -202,7 +202,7 @@ static int ip_local_deliver_finish(struct sk_buff *skb)
 	{
 		int protocol = ip_hdr(skb)->protocol;
 		int hash, raw;
-		struct net_protocol *ipprot;
+		const struct net_protocol *ipprot;
 
 	resubmit:
 		raw = raw_local_deliver(skb, protocol);
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -146,7 +146,7 @@ static const struct xfrm_type ipcomp_type = {
 	.output		= ipcomp_output
 };
 
-static struct net_protocol ipcomp4_protocol = {
+static const struct net_protocol ipcomp4_protocol = {
 	.handler	=	xfrm4_rcv,
 	.err_handler	=	ipcomp4_err,
 	.no_policy	=	1,
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -99,10 +99,6 @@ static int ipmr_cache_report(struct net *net,
 			     struct sk_buff *pkt, vifi_t vifi, int assert);
 static int ipmr_fill_mroute(struct sk_buff *skb, struct mfc_cache *c, struct rtmsg *rtm);
 
-#ifdef CONFIG_IP_PIMSM_V2
-static struct net_protocol pim_protocol;
-#endif
-
 static struct timer_list ipmr_expire_timer;
 
 /* Service routines creating virtual interfaces: DVMRP tunnels and PIMREG */
@@ -1945,7 +1941,7 @@ static const struct file_operations ipmr_mfc_fops = {
 #endif
 
 #ifdef CONFIG_IP_PIMSM_V2
-static struct net_protocol pim_protocol = {
+static const struct net_protocol pim_protocol = {
 	.handler	=	pim_rcv,
 	.netns_ok	=	1,
 };
--- a/net/ipv4/protocol.c
+++ b/net/ipv4/protocol.c
@@ -28,14 +28,14 @@
 #include <linux/spinlock.h>
 #include <net/protocol.h>
 
-struct net_protocol *inet_protos[MAX_INET_PROTOS] ____cacheline_aligned_in_smp;
+const struct net_protocol *inet_protos[MAX_INET_PROTOS] ____cacheline_aligned_in_smp;
 static DEFINE_SPINLOCK(inet_proto_lock);
 
 /*
  *	Add a protocol handler to the hash tables
  */
 
-int inet_add_protocol(struct net_protocol *prot, unsigned char protocol)
+int inet_add_protocol(const struct net_protocol *prot, unsigned char protocol)
 {
 	int hash, ret;
 
@@ -57,7 +57,7 @@ int inet_add_protocol(struct net_protocol *prot, unsigned char protocol)
  *	Remove a protocol from the hash tables.
  */
 
-int inet_del_protocol(struct net_protocol *prot, unsigned char protocol)
+int inet_del_protocol(const struct net_protocol *prot, unsigned char protocol)
 {
 	int hash, ret;
 
--- a/net/ipv4/tunnel4.c
+++ b/net/ipv4/tunnel4.c
@@ -132,7 +132,7 @@ static void tunnel64_err(struct sk_buff *skb, u32 info)
 }
 #endif
 
-static struct net_protocol tunnel4_protocol = {
+static const struct net_protocol tunnel4_protocol = {
 	.handler	=	tunnel4_rcv,
 	.err_handler	=	tunnel4_err,
 	.no_policy	=	1,
@@ -140,7 +140,7 @@ static struct net_protocol tunnel4_protocol = {
 };
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-static struct net_protocol tunnel64_protocol = {
+static const struct net_protocol tunnel64_protocol = {
 	.handler	=	tunnel64_rcv,
 	.err_handler	=	tunnel64_err,
 	.no_policy	=	1,
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -25,7 +25,7 @@ static void udplite_err(struct sk_buff *skb, u32 info)
 	__udp4_lib_err(skb, info, &udplite_table);
 }
 
-static	struct net_protocol udplite_protocol = {
+static const struct net_protocol udplite_protocol = {
 	.handler	= udplite_rcv,
 	.err_handler	= udplite_err,
 	.no_policy	= 1,
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -924,7 +924,7 @@ static struct inet_protosw sctp_stream_protosw = {
 };
 
 /* Register with IP layer.  */
-static struct net_protocol sctp_protocol = {
+static const struct net_protocol sctp_protocol = {
 	.handler     = sctp_rcv,
 	.err_handler = sctp_v4_err,
 	.no_policy   = 1,
