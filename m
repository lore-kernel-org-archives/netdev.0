From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net] tcp: delete unused parameter in tcp_nagle_check()
Date: Mon, 24 Mar 2014 14:49:34 +0800
Message-ID: <4609be8bb5dacb54d14e1b1f5dc8264b85c7c8d3.1395630957.git.panweiping3@gmail.com>
Cc: edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22928 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750827AbaCXGtk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2014 02:49:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit d4589926d7a9 (tcp: refine TSO splits), tcp_nagle_check() does
not use parameter mss_now anymore.

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 net/ipv4/tcp_output.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 17a11e6..fbf4403 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1426,7 +1426,7 @@ static void tcp_minshall_update(struct tcp_sock *tp, unsigned int mss_now,
  *    With Minshall's modification: all sent small packets are ACKed.
  */
 static bool tcp_nagle_check(bool partial, const struct tcp_sock *tp,
-			    unsigned int mss_now, int nonagle)
+			    int nonagle)
 {
 	return partial &&
 		((nonagle & TCP_NAGLE_CORK) ||
@@ -1458,7 +1458,7 @@ static unsigned int tcp_mss_split_point(const struct sock *sk,
 	 * to include this last segment in this skb.
 	 * Otherwise, we'll split the skb at last MSS boundary
 	 */
-	if (tcp_nagle_check(partial != 0, tp, mss_now, nonagle))
+	if (tcp_nagle_check(partial != 0, tp, nonagle))
 		return needed - partial;
 
 	return needed;
@@ -1521,7 +1521,7 @@ static inline bool tcp_nagle_test(const struct tcp_sock *tp, const struct sk_buf
 	if (tcp_urg_mode(tp) || (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN))
 		return true;
 
-	if (!tcp_nagle_check(skb->len < cur_mss, tp, cur_mss, nonagle))
+	if (!tcp_nagle_check(skb->len < cur_mss, tp, nonagle))
 		return true;
 
 	return false;
-- 
1.7.4
