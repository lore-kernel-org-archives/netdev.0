From: Jianjun Kong <jianjun@zeuux.org>
Subject: [PATCH 1/6] nets: clean up net/ipv4/ah4.c esp4.c fib_semantics.c
	inet_connection_sock.c inetpeer.c ip_output.c
Date: Mon, 3 Nov 2008 16:19:14 +0800
Message-ID: <20081103081914.GB14553@ubuntu>
References: <20081102074446.GA12140@ubuntu> <490DEAD3.3030202@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeuux.org ([210.51.160.52]:61269 "EHLO z.billxu.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755146AbYKCITH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 03:19:07 -0500
Content-Disposition: inline
In-Reply-To: <490DEAD3.3030202@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	
 [PATCH 1/6] clean up net/ipv4/
 ah4.c esp4.c fib_semantics.c inet_connection_sock.c inetpeer.c ip_output.c

Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
---
 net/ipv4/ah4.c                  |    4 ++--
 net/ipv4/esp4.c                 |    4 ++--
 net/ipv4/fib_semantics.c        |    8 ++++----
 net/ipv4/inet_connection_sock.c |    2 +-
 net/ipv4/inetpeer.c             |    2 +-
 net/ipv4/ip_output.c            |    6 +++---
 6 files changed, 13 insertions(+), 13 deletions(-)

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
-- 
1.5.6.3

