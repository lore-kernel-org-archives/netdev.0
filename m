From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: busy-poll: remove LL_FLUSH_FAILED and
 LL_FLUSH_BUSY
Date: Fri, 10 Feb 2017 05:46:46 -0800
Message-ID: <1486734406.7793.142.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36431 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751430AbdBJNsM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 08:48:12 -0500
Received: by mail-pf0-f196.google.com with SMTP id 19so2665151pfo.3
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 05:46:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Commit 79e7fff47b7b ("net: remove support for per driver
ndo_busy_poll()") made them obsolete.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/busy_poll.h |    4 ----
 net/core/dev.c          |    3 ---
 2 files changed, 7 deletions(-)

diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
index d73b849e29a6869e282103f329c3a02f4e1a6882..b8d637225a07ddd2c0183b75a42cd5c9c5a69851 100644
--- a/include/net/busy_poll.h
+++ b/include/net/busy_poll.h
@@ -33,10 +33,6 @@ struct napi_struct;
 extern unsigned int sysctl_net_busy_read __read_mostly;
 extern unsigned int sysctl_net_busy_poll __read_mostly;
 
-/* return values from ndo_ll_poll */
-#define LL_FLUSH_FAILED		-1
-#define LL_FLUSH_BUSY		-2
-
 static inline bool net_busy_loop_on(void)
 {
 	return sysctl_net_busy_poll;
diff --git a/net/core/dev.c b/net/core/dev.c
index 0921609dfa81b70a13e0b4ca7852fde6ded7ed82..a6d9b1f071b330c3428c2a0a2d4eb13584911939 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4998,9 +4998,6 @@ bool sk_busy_loop(struct sock *sk, int nonblock)
 					LINUX_MIB_BUSYPOLLRXPACKETS, rc);
 		local_bh_enable();
 
-		if (rc == LL_FLUSH_FAILED)
-			break; /* permanent failure */
-
 		if (nonblock || !skb_queue_empty(&sk->sk_receive_queue) ||
 		    busy_loop_timeout(end_time))
 			break;
