From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH] tcp: convert cached rtt from usec to jiffies when feeding
 initial rto
Date: Sun, 21 Feb 2016 10:12:39 +0300
Message-ID: <20160221071239.9977.45366.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1f.mail.yandex.net ([95.108.130.40]:48864 "EHLO
	forward-corp1f.mail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750955AbcBURn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 12:43:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently it's converted into msecs, thus HZ=1000 intact.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Fixes: 740b0f1841f6 ("tcp: switch rtt estimations to usec resolution")
---
 net/ipv4/tcp_metrics.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index c8cbc2b4b792..a726d7853ce5 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -550,7 +550,7 @@ reset:
 	 */
 	if (crtt > tp->srtt_us) {
 		/* Set RTO like tcp_rtt_estimator(), but from cached RTT. */
-		crtt /= 8 * USEC_PER_MSEC;
+		crtt /= 8 * USEC_PER_SEC / HZ;
 		inet_csk(sk)->icsk_rto = crtt + max(2 * crtt, tcp_rto_min(sk));
 	} else if (tp->srtt_us == 0) {
 		/* RFC6298: 5.7 We've failed to get a valid RTT sample from
