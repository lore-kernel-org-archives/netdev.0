From: akpm@linux-foundation.org
Subject: [patch 10/11] dccp-warning-fixes
Date: Mon, 05 Feb 2007 16:31:09 -0800
Message-ID: <200702060032.l160WCkf004646@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	akpm@linux-foundation.org, acme@conectiva.com.br
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:41516 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965220AbXBFAdD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 19:33:03 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

sparc64:

net/dccp/ccids/ccid3.c: In function `ccid3_hc_tx_packet_recv':
net/dccp/ccids/ccid3.c:480: warning: long long unsigned int format, __u64 arg (arg 6)
net/dccp/ccids/ccid3.c: In function `ccid3_hc_rx_packet_recv':
net/dccp/ccids/ccid3.c:1007: warning: long int format, different type arg (arg 3)
net/dccp/ccids/ccid3.c:1007: warning: long int format, different type arg (arg 4)

opaque types must be suitably cast for printing.

Cc: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/dccp/ccids/ccid3.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff -puN net/dccp/ccids/ccid3.c~dccp-warning-fixes net/dccp/ccids/ccid3.c
--- a/net/dccp/ccids/ccid3.c~dccp-warning-fixes
+++ a/net/dccp/ccids/ccid3.c
@@ -479,7 +479,8 @@ static void ccid3_hc_tx_packet_recv(stru
 
 			ccid3_pr_debug("%s(%p), s=%u, w_init=%llu, "
 				       "R_sample=%dus, X=%u\n", dccp_role(sk),
-				       sk, hctx->ccid3hctx_s, w_init,
+				       sk, hctx->ccid3hctx_s,
+				       (unsigned long long)w_init,
 				       (int)r_sample,
 				       (unsigned)(hctx->ccid3hctx_x >> 6));
 
@@ -1005,7 +1006,7 @@ static void ccid3_hc_rx_packet_recv(stru
 		DCCP_BUG_ON(r_sample < 0);
 		if (unlikely(r_sample <= t_elapsed))
 			DCCP_WARN("r_sample=%ldus, t_elapsed=%ldus\n",
-				  r_sample, t_elapsed);
+				  (long)r_sample, (long)t_elapsed);
 		else
 			r_sample -= t_elapsed;
 		CCID3_RTT_SANITY_CHECK(r_sample);
_
