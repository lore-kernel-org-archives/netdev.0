From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH] net: remove redundant checking for sock timer state
Date: Fri, 1 Feb 2013 13:53:00 +0800
Message-ID: <1359697980-28613-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:51315 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751255Ab3BAFuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 00:50:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's unnecessary to check whether the sock timer to be stopped is
pending or not in sk_stop_timer() as del_timer() will do the same
thing later.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/core/sock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index bc131d4..33144bd 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2212,7 +2212,7 @@ EXPORT_SYMBOL(sk_reset_timer);
 
 void sk_stop_timer(struct sock *sk, struct timer_list* timer)
 {
-	if (timer_pending(timer) && del_timer(timer))
+	if (del_timer(timer))
 		__sock_put(sk);
 }
 EXPORT_SYMBOL(sk_stop_timer);
-- 
1.7.1
