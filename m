From: kaber@trash.net
Subject: [PATCH 38/84] netfilter: ipv6: use NFPROTO values for NF_HOOK invocation
Date: Mon, 10 May 2010 22:18:09 +0200
Message-ID: <1273522735-24672-39-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

The semantic patch that was used:
// <smpl>
@@
@@
(NF_HOOK
|NF_HOOK_THRESH
|nf_hook
)(
-PF_INET6,
+NFPROTO_IPV6,
 ...)
// </smpl>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/ipv6/ip6_input.c                    |    4 ++--
 net/ipv6/ip6_output.c                   |   16 ++++++++--------
 net/ipv6/ip6mr.c                        |    2 +-
 net/ipv6/mcast.c                        |    4 ++--
 net/ipv6/ndisc.c                        |    4 ++--
 net/ipv6/netfilter/nf_conntrack_reasm.c |    2 +-
 net/ipv6/raw.c                          |    4 ++--
 net/ipv6/xfrm6_input.c                  |    2 +-
 net/ipv6/xfrm6_output.c                 |    4 ++--
 9 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index e28f920..2c01dc6 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -142,7 +142,7 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	/* Must drop socket now because of tproxy. */
 	skb_orphan(skb);
 
-	return NF_HOOK(PF_INET6, NF_INET_PRE_ROUTING, skb, dev, NULL,
+	return NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING, skb, dev, NULL,
 		       ip6_rcv_finish);
 err:
 	IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INHDRERRORS);
@@ -235,7 +235,7 @@ discard:
 
 int ip6_input(struct sk_buff *skb)
 {
-	return NF_HOOK(PF_INET6, NF_INET_LOCAL_IN, skb, skb->dev, NULL,
+	return NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_IN, skb, skb->dev, NULL,
 		       ip6_input_finish);
 }
 
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index dabf108..4535b7a 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -66,8 +66,8 @@ int __ip6_local_out(struct sk_buff *skb)
 		len = 0;
 	ipv6_hdr(skb)->payload_len = htons(len);
 
-	return nf_hook(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, skb_dst(skb)->dev,
-		       dst_output);
+	return nf_hook(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL,
+		       skb_dst(skb)->dev, dst_output);
 }
 
 int ip6_local_out(struct sk_buff *skb)
@@ -134,8 +134,8 @@ static int ip6_output2(struct sk_buff *skb)
 			   is not supported in any case.
 			 */
 			if (newskb)
-				NF_HOOK(PF_INET6, NF_INET_POST_ROUTING, newskb,
-					NULL, newskb->dev,
+				NF_HOOK(NFPROTO_IPV6, NF_INET_POST_ROUTING,
+					newskb, NULL, newskb->dev,
 					ip6_dev_loopback_xmit);
 
 			if (ipv6_hdr(skb)->hop_limit == 0) {
@@ -150,7 +150,7 @@ static int ip6_output2(struct sk_buff *skb)
 				skb->len);
 	}
 
-	return NF_HOOK(PF_INET6, NF_INET_POST_ROUTING, skb, NULL, skb->dev,
+	return NF_HOOK(NFPROTO_IPV6, NF_INET_POST_ROUTING, skb, NULL, skb->dev,
 		       ip6_output_finish);
 }
 
@@ -260,8 +260,8 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
 	if ((skb->len <= mtu) || skb->local_df || skb_is_gso(skb)) {
 		IP6_UPD_PO_STATS(net, ip6_dst_idev(skb_dst(skb)),
 			      IPSTATS_MIB_OUT, skb->len);
-		return NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, dst->dev,
-				dst_output);
+		return NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL,
+			       dst->dev, dst_output);
 	}
 
 	if (net_ratelimit())
@@ -537,7 +537,7 @@ int ip6_forward(struct sk_buff *skb)
 	hdr->hop_limit--;
 
 	IP6_INC_STATS_BH(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTFORWDATAGRAMS);
-	return NF_HOOK(PF_INET6, NF_INET_FORWARD, skb, skb->dev, dst->dev,
+	return NF_HOOK(NFPROTO_IPV6, NF_INET_FORWARD, skb, skb->dev, dst->dev,
 		       ip6_forward_finish);
 
 error:
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 52e0f74..430372e 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1566,7 +1566,7 @@ static int ip6mr_forward2(struct sk_buff *skb, struct mfc6_cache *c, int vifi)
 
 	IP6CB(skb)->flags |= IP6SKB_FORWARDED;
 
-	return NF_HOOK(PF_INET6, NF_INET_FORWARD, skb, skb->dev, dev,
+	return NF_HOOK(NFPROTO_IPV6, NF_INET_FORWARD, skb, skb->dev, dev,
 		       ip6mr_forward2_finish);
 
 out_free:
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index bcd9719..773b9d1 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1479,7 +1479,7 @@ static void mld_sendpack(struct sk_buff *skb)
 
 	payload_len = skb->len;
 
-	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, skb->dev,
+	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL, skb->dev,
 		      dst_output);
 out:
 	if (!err) {
@@ -1847,7 +1847,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 		goto err_out;
 
 	skb_dst_set(skb, dst);
-	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, skb->dev,
+	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL, skb->dev,
 		      dst_output);
 out:
 	if (!err) {
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 8bcc4b7..8e96a35 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -535,7 +535,7 @@ void ndisc_send_skb(struct sk_buff *skb,
 	idev = in6_dev_get(dst->dev);
 	IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUT, skb->len);
 
-	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, dst->dev,
+	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL, dst->dev,
 		      dst_output);
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(net, idev, type);
@@ -1617,7 +1617,7 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 	skb_dst_set(buff, dst);
 	idev = in6_dev_get(dst->dev);
 	IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUT, skb->len);
-	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, buff, NULL, dst->dev,
+	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, buff, NULL, dst->dev,
 		      dst_output);
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(net, idev, NDISC_REDIRECT);
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index f1171b7..8f80e24 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -643,7 +643,7 @@ void nf_ct_frag6_output(unsigned int hooknum, struct sk_buff *skb,
 		s2 = s->next;
 		s->next = NULL;
 
-		NF_HOOK_THRESH(PF_INET6, hooknum, s, in, out, okfn,
+		NF_HOOK_THRESH(NFPROTO_IPV6, hooknum, s, in, out, okfn,
 			       NF_IP6_PRI_CONNTRACK_DEFRAG + 1);
 		s = s2;
 	}
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index ed31c37..e9e1f77 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -636,8 +636,8 @@ static int rawv6_send_hdrinc(struct sock *sk, void *from, int length,
 		goto error_fault;
 
 	IP6_UPD_PO_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUT, skb->len);
-	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
-		      dst_output);
+	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL,
+		      rt->u.dst.dev, dst_output);
 	if (err > 0)
 		err = net_xmit_errno(err);
 	if (err)
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 2bc98ed..f8c3cf8 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -42,7 +42,7 @@ int xfrm6_transport_finish(struct sk_buff *skb, int async)
 	ipv6_hdr(skb)->payload_len = htons(skb->len);
 	__skb_push(skb, skb->data - skb_network_header(skb));
 
-	NF_HOOK(PF_INET6, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
+	NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
 		ip6_rcv_finish);
 	return -1;
 }
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 0c92112..6434bd5 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -90,6 +90,6 @@ static int xfrm6_output_finish(struct sk_buff *skb)
 
 int xfrm6_output(struct sk_buff *skb)
 {
-	return NF_HOOK(PF_INET6, NF_INET_POST_ROUTING, skb, NULL, skb_dst(skb)->dev,
-		       xfrm6_output_finish);
+	return NF_HOOK(NFPROTO_IPV6, NF_INET_POST_ROUTING, skb, NULL,
+		       skb_dst(skb)->dev, xfrm6_output_finish);
 }
-- 
1.7.0.4

