From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] ipv4: tcp_minisocks: use BUG_ON instead of if condition
 followed by BUG
Date: Mon, 23 Oct 2017 13:10:56 -0500
Message-ID: <20171023181056.GA25239@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway34.websitewelcome.com ([192.185.148.204]:33700 "EHLO
        gateway34.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751208AbdJWSK6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 14:10:58 -0400
Received: from cm17.websitewelcome.com (cm17.websitewelcome.com [100.42.49.20])
        by gateway34.websitewelcome.com (Postfix) with ESMTP id B3DA29D1
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 13:10:57 -0500 (CDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use BUG_ON instead of if condition followed by BUG in tcp_time_wait.

This issue was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 net/ipv4/tcp_minisocks.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 2341b9f..a952357 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -298,8 +298,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 			key = tp->af_specific->md5_lookup(sk, sk);
 			if (key) {
 				tcptw->tw_md5_key = kmemdup(key, sizeof(*key), GFP_ATOMIC);
-				if (tcptw->tw_md5_key && !tcp_alloc_md5sig_pool())
-					BUG();
+				BUG_ON(tcptw->tw_md5_key && !tcp_alloc_md5sig_pool());
 			}
 		} while (0);
 #endif
-- 
2.7.4
