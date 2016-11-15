From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/5] net: busy-poll: remove need_resched() from sk_can_busy_loop()
Date: Tue, 15 Nov 2016 10:15:12 -0800
Message-ID: <1479233715-9905-3-git-send-email-edumazet@google.com>
References: <1479233715-9905-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Adam Belay <abelay@google.com>, Zach Brown <zach.brown@ni.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <ariel.elior@cavium.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33458 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751749AbcKOSW6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 13:22:58 -0500
Received: by mail-pf0-f178.google.com with SMTP id d2so37477558pfd.0
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 10:22:58 -0800 (PST)
In-Reply-To: <1479233715-9905-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now sk_busy_loop() can schedule by itself, we can remove
need_resched() check from sk_can_busy_loop()

Also add a const to its struct sock parameter.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Adam Belay <abelay@google.com>
Cc: Tariq Toukan <tariqt@mellanox.com>
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
Cc: Ariel Elior <ariel.elior@cavium.com>
---
 include/net/busy_poll.h | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
index 2fbeb1313c0f..965e52b9b5a3 100644
--- a/include/net/busy_poll.h
+++ b/include/net/busy_poll.h
@@ -58,10 +58,9 @@ static inline unsigned long busy_loop_end_time(void)
 	return busy_loop_us_clock() + ACCESS_ONCE(sysctl_net_busy_poll);
 }
 
-static inline bool sk_can_busy_loop(struct sock *sk)
+static inline bool sk_can_busy_loop(const struct sock *sk)
 {
-	return sk->sk_ll_usec && sk->sk_napi_id &&
-	       !need_resched() && !signal_pending(current);
+	return sk->sk_ll_usec && sk->sk_napi_id && !signal_pending(current);
 }
 
 
-- 
2.8.0.rc3.226.g39d4020
