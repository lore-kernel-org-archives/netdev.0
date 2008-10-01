From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: [net-next PATCH 04/16] Make inet_sock.h independent of route.h
Date: Wed, 01 Oct 2008 16:24:31 +0200
Message-ID: <20081001142431.4893.41703.stgit@este>
References: <20081001142431.4893.48078.stgit@este>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-reply-to: <20081001142431.4893.48078.stgit@este>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

inet_iif() in inet_sock.h requires route.h. Since users of inet_iif()
usually require other route.h functionality anyway this patch moves
inet_iif() to route.h.

Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
---

 include/net/inet_sock.h            |    7 -------
 include/net/ip_vs.h                |    1 +
 include/net/route.h                |    5 +++++
 net/ipv4/netfilter/nf_nat_helper.c |    1 +
 net/ipv6/af_inet6.c                |    1 +
 5 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index e97b66e..139b78b 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -24,7 +24,6 @@
 #include <net/flow.h>
 #include <net/sock.h>
 #include <net/request_sock.h>
-#include <net/route.h>
 #include <net/netns/hash.h>
 
 /** struct ip_options - IP Options
@@ -195,12 +194,6 @@ static inline int inet_sk_ehashfn(const struct sock *sk)
 	return inet_ehashfn(net, laddr, lport, faddr, fport);
 }
 
-
-static inline int inet_iif(const struct sk_buff *skb)
-{
-	return skb->rtable->rt_iif;
-}
-
 static inline struct request_sock *inet_reqsk_alloc(struct request_sock_ops *ops)
 {
 	struct request_sock *req = reqsk_alloc(ops);
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 33e2ac6..0b2071d 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -22,6 +22,7 @@
 
 #include <net/checksum.h>
 #include <linux/netfilter.h>		/* for union nf_inet_addr */
+#include <linux/ip.h>
 #include <linux/ipv6.h>			/* for struct ipv6hdr */
 #include <net/ipv6.h>			/* for ipv6_addr_copy */
 
diff --git a/include/net/route.h b/include/net/route.h
index 4f0d8c1..31d1485 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -204,4 +204,9 @@ static inline struct inet_peer *rt_get_peer(struct rtable *rt)
 	return rt->peer;
 }
 
+static inline int inet_iif(const struct sk_buff *skb)
+{
+	return skb->rtable->rt_iif;
+}
+
 #endif	/* _ROUTE_H */
diff --git a/net/ipv4/netfilter/nf_nat_helper.c b/net/ipv4/netfilter/nf_nat_helper.c
index 11976ea..112dcfa 100644
--- a/net/ipv4/netfilter/nf_nat_helper.c
+++ b/net/ipv4/netfilter/nf_nat_helper.c
@@ -16,6 +16,7 @@
 #include <linux/udp.h>
 #include <net/checksum.h>
 #include <net/tcp.h>
+#include <net/route.h>
 
 #include <linux/netfilter_ipv4.h>
 #include <net/netfilter/nf_conntrack.h>
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 95055f8..f018704 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -50,6 +50,7 @@
 #include <net/ipip.h>
 #include <net/protocol.h>
 #include <net/inet_common.h>
+#include <net/route.h>
 #include <net/transp_v6.h>
 #include <net/ip6_route.h>
 #include <net/addrconf.h>


