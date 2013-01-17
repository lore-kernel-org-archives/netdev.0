From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 03/11] ipv6 route: Dump gateway based on RTF_GATEWAY
 flag and rt->rt6i_gateway.
Date: Fri, 18 Jan 2013 02:42:03 +0900
Message-ID: <50F837EB.20900@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, xiyou.wangcong@gmail.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:44389 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751437Ab3AQRmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 12:42:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not depend on rt->n.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/route.c |   12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 5d9ca27..d82eb1f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2484,7 +2484,6 @@ static int rt6_fill_node(struct net *net,
 	struct nlmsghdr *nlh;
 	long expires;
 	u32 table;
-	struct neighbour *n;
 
 	if (prefix) {	/* user wants prefix routes only */
 		if (!(rt->rt6i_flags & RTF_PREFIX_RT)) {
@@ -2597,9 +2596,8 @@ static int rt6_fill_node(struct net *net,
 	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst)) < 0)
 		goto nla_put_failure;
 
-	n = rt->n;
-	if (n) {
-		if (nla_put(skb, RTA_GATEWAY, 16, &n->primary_key) < 0)
+	if (rt->rt6i_flags & RTF_GATEWAY) {
+		if (nla_put(skb, RTA_GATEWAY, 16, &rt->rt6i_gateway) < 0)
 			goto nla_put_failure;
 	}
 
@@ -2794,7 +2792,6 @@ struct rt6_proc_arg
 static int rt6_info_route(struct rt6_info *rt, void *p_arg)
 {
 	struct seq_file *m = p_arg;
-	struct neighbour *n;
 
 	seq_printf(m, "%pi6 %02x ", &rt->rt6i_dst.addr, rt->rt6i_dst.plen);
 
@@ -2803,9 +2800,8 @@ static int rt6_info_route(struct rt6_info *rt, void *p_arg)
 #else
 	seq_puts(m, "00000000000000000000000000000000 00 ");
 #endif
-	n = rt->n;
-	if (n) {
-		seq_printf(m, "%pi6", n->primary_key);
+	if (rt->rt6i_flags & RTF_GATEWAY) {
+		seq_printf(m, "%pi6", &rt->rt6i_gateway);
 	} else {
 		seq_puts(m, "00000000000000000000000000000000");
 	}
-- 
1.7.9.5
