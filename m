From: Richard Alpe <richard.alpe@ericsson.com>
Subject: [PATCH net-next 2/2] tipc: rename udp_port in
	struct udp_media_addr
Date: Mon, 27 Jun 2016 13:34:07 +0200
Message-ID: <1467027247-25469-2-git-send-email-richard.alpe@ericsson.com>
References: <1467027247-25469-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1467027247-25469-1-git-send-email-richard.alpe@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Context implies that port in struct "udp_media_addr" is referring
to a UDP port.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/udp_media.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
index c9cf2be..b016c01 100644
--- a/net/tipc/udp_media.c
+++ b/net/tipc/udp_media.c
@@ -63,7 +63,7 @@
  */
 struct udp_media_addr {
 	__be16	proto;
-	__be16	udp_port;
+	__be16	port;
 	union {
 		struct in_addr ipv4;
 		struct in6_addr ipv6;
@@ -108,9 +108,9 @@ static int tipc_udp_addr2str(struct tipc_media_addr *a, char *buf, int size)
 	struct udp_media_addr *ua = (struct udp_media_addr *)&a->value;
 
 	if (ntohs(ua->proto) == ETH_P_IP)
-		snprintf(buf, size, "%pI4:%u", &ua->ipv4, ntohs(ua->udp_port));
+		snprintf(buf, size, "%pI4:%u", &ua->ipv4, ntohs(ua->port));
 	else if (ntohs(ua->proto) == ETH_P_IPV6)
-		snprintf(buf, size, "%pI6:%u", &ua->ipv6, ntohs(ua->udp_port));
+		snprintf(buf, size, "%pI6:%u", &ua->ipv6, ntohs(ua->port));
 	else
 		pr_err("Invalid UDP media address\n");
 	return 0;
@@ -178,8 +178,8 @@ static int tipc_udp_send_msg(struct net *net, struct sk_buff *skb,
 		skb->dev = rt->dst.dev;
 		ttl = ip4_dst_hoplimit(&rt->dst);
 		udp_tunnel_xmit_skb(rt, ub->ubsock->sk, skb, src->ipv4.s_addr,
-				    dst->ipv4.s_addr, 0, ttl, 0, src->udp_port,
-				    dst->udp_port, false, true);
+				    dst->ipv4.s_addr, 0, ttl, 0, src->port,
+				    dst->port, false, true);
 #if IS_ENABLED(CONFIG_IPV6)
 	} else {
 		struct dst_entry *ndst;
@@ -196,8 +196,8 @@ static int tipc_udp_send_msg(struct net *net, struct sk_buff *skb,
 		ttl = ip6_dst_hoplimit(ndst);
 		err = udp_tunnel6_xmit_skb(ndst, ub->ubsock->sk, skb,
 					   ndst->dev, &src->ipv6,
-					   &dst->ipv6, 0, ttl, 0, src->udp_port,
-					   dst->udp_port, false);
+					   &dst->ipv6, 0, ttl, 0, src->port,
+					   dst->port, false);
 #endif
 	}
 	return err;
@@ -292,12 +292,12 @@ err:
 
 		ip4 = (struct sockaddr_in *)&sa_local;
 		local->proto = htons(ETH_P_IP);
-		local->udp_port = ip4->sin_port;
+		local->port = ip4->sin_port;
 		local->ipv4.s_addr = ip4->sin_addr.s_addr;
 
 		ip4 = (struct sockaddr_in *)&sa_remote;
 		remote->proto = htons(ETH_P_IP);
-		remote->udp_port = ip4->sin_port;
+		remote->port = ip4->sin_port;
 		remote->ipv4.s_addr = ip4->sin_addr.s_addr;
 		return 0;
 
@@ -312,13 +312,13 @@ err:
 			return -EINVAL;
 
 		local->proto = htons(ETH_P_IPV6);
-		local->udp_port = ip6->sin6_port;
+		local->port = ip6->sin6_port;
 		memcpy(&local->ipv6, &ip6->sin6_addr, sizeof(struct in6_addr));
 		ub->ifindex = ip6->sin6_scope_id;
 
 		ip6 = (struct sockaddr_in6 *)&sa_remote;
 		remote->proto = htons(ETH_P_IPV6);
-		remote->udp_port = ip6->sin6_port;
+		remote->port = ip6->sin6_port;
 		memcpy(&remote->ipv6, &ip6->sin6_addr, sizeof(struct in6_addr));
 		return 0;
 #endif
@@ -386,7 +386,7 @@ static int tipc_udp_enable(struct net *net, struct tipc_bearer *b,
 		err = -EAFNOSUPPORT;
 		goto err;
 	}
-	udp_conf.local_udp_port = local.udp_port;
+	udp_conf.local_udp_port = local.port;
 	err = udp_sock_create(net, &udp_conf, &ub->ubsock);
 	if (err)
 		goto err;
-- 
2.1.4


------------------------------------------------------------------------------
Attend Shape: An AT&T Tech Expo July 15-16. Meet us at AT&T Park in San
Francisco, CA to explore cutting-edge tech and listen to tech luminaries
present their vision of the future. This family event has something for
everyone, including kids. Get more information and register today.
http://sdm.link/attshape
