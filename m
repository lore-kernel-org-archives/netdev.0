From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/7] ipv4: Use flowi4_init_output() in cookie_v4_check()
Date: Thu, 31 Mar 2011 17:12:21 -0700 (PDT)
Message-ID: <20110331.171221.179941268.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56984
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759531Ab1DAAM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 20:12:59 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id E514224C089
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2011 17:12:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/syncookies.c |   18 +++++++-----------
 1 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 8b44c6d..71e0296 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -345,17 +345,13 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	 * no easy way to do this.
 	 */
 	{
-		struct flowi4 fl4 = {
-			.flowi4_mark = sk->sk_mark,
-			.daddr = ((opt && opt->srr) ?
-				  opt->faddr : ireq->rmt_addr),
-			.saddr = ireq->loc_addr,
-			.flowi4_tos = RT_CONN_FLAGS(sk),
-			.flowi4_proto = IPPROTO_TCP,
-			.flowi4_flags = inet_sk_flowi_flags(sk),
-			.fl4_sport = th->dest,
-			.fl4_dport = th->source,
-		};
+		struct flowi4 fl4;
+
+		flowi4_init_output(&fl4, 0, sk->sk_mark, RT_CONN_FLAGS(sk),
+				   RT_SCOPE_UNIVERSE, IPPROTO_TCP,
+				   inet_sk_flowi_flags(sk),
+				   (opt && opt->srr) ? opt->faddr : ireq->rmt_addr,
+				   ireq->loc_addr, th->source, th->dest);
 		security_req_classify_flow(req, flowi4_to_flowi(&fl4));
 		rt = ip_route_output_key(sock_net(sk), &fl4);
 		if (IS_ERR(rt)) {
-- 
1.7.4.2

