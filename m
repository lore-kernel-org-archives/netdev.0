From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH net] tcp: Fix integer-overflows in TCP vegas
Date: Tue, 22 Jul 2014 23:36:57 +0200
Message-ID: <1406065017-22102-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: netdev@vger.kernel.org,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	Doug Leith <doug.leith@nuim.ie>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:54505 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752460AbaGVVhG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 17:37:06 -0400
Received: by mail-we0-f169.google.com with SMTP id u56so265624wes.14
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 14:37:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In vegas we do a multiplication of the cwnd and the rtt. This
may overflow and thus their result is stored in a u64. However, we first
need to cast the cwnd so that actually 64-bit arithmetic is done.

Cc: Doug Leith <doug.leith@nuim.ie>
Fixes: 8d3a564da34e (tcp: tcp_vegas cong avoid fix)
Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 net/ipv4/tcp_vegas.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
index 9a5e05f27f4f..6a4bdea2a0fb 100644
--- a/net/ipv4/tcp_vegas.c
+++ b/net/ipv4/tcp_vegas.c
@@ -218,7 +218,7 @@ static void tcp_vegas_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 			 * This is:
 			 *     (actual rate in segments) * baseRTT
 			 */
-			target_cwnd = tp->snd_cwnd * vegas->baseRTT / rtt;
+			target_cwnd = (u64)tp->snd_cwnd * vegas->baseRTT / rtt;
 
 			/* Calculate the difference between the window we had,
 			 * and the window we would like to have. This quantity
-- 
1.9.3
