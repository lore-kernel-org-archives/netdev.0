From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] tcp: cubic update for net-2.6.22
Date: Fri, 23 Mar 2007 13:38:57 -0700
Message-ID: <20070323133857.5f19e4ff@freekitty>
References: <00e401c76d51$79a31d20$4a580e98@ncsu2cc0c3fa00>
	<20070323091720.575f9162@freekitty>
	<20070323.102510.74748426.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rhee@eos.ncsu.edu, sha2@ncsu.edu, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:37471 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992563AbXCWUjF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 16:39:05 -0400
In-Reply-To: <20070323.102510.74748426.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following update received from Injong updates TCP cubic to the latest
version. I am running more complete tests and will have results after 4/1.

According to Injong: the new version improves on its scalability,
fairness and stability.  So in all properties, we confirmed it shows better
performance.

NCSU results (for 2.6.18 and 2.6.20) available:
	http://netsrv.csc.ncsu.edu/wiki/index.php/TCP_Testing

This version is described in a new Internet draft for CUBIC.
	http://www.ietf.org/internet-drafts/draft-rhee-tcp-cubic-00.txt


Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 net/ipv4/tcp_cubic.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index 15c5803..296845b 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -1,5 +1,5 @@
 /*
- * TCP CUBIC: Binary Increase Congestion control for TCP v2.0
+ * TCP CUBIC: Binary Increase Congestion control for TCP v2.1
  *
  * This is from the implementation of CUBIC TCP in
  * Injong Rhee, Lisong Xu.
@@ -214,7 +214,9 @@ static inline void bictcp_update(struct bictcp *ca, u32 cwnd)
 	if (ca->delay_min > 0) {
 		/* max increment = Smax * rtt / 0.1  */
 		min_cnt = (cwnd * HZ * 8)/(10 * max_increment * ca->delay_min);
-		if (ca->cnt < min_cnt)
+
+		/* use concave growth when the target is above the origin */
+		if (ca->cnt < min_cnt && t >= ca->bic_K)
 			ca->cnt = min_cnt;
 	}
 
@@ -400,4 +402,4 @@ module_exit(cubictcp_unregister);
 MODULE_AUTHOR("Sangtae Ha, Stephen Hemminger");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("CUBIC TCP");
-MODULE_VERSION("2.0");
+MODULE_VERSION("2.1");
-- 
1.4.4.2

