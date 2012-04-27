From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH] tcp: clean up use of jiffies in tcp_rcv_rtt_measure()
Date: Fri, 27 Apr 2012 11:29:37 -0400
Message-ID: <1335540577-32554-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>, ilpo.jarvinen@helsinki.fi,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f202.google.com ([209.85.213.202]:39117 "EHLO
	mail-yx0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760020Ab2D0P3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 11:29:42 -0400
Received: by yenq2 with SMTP id q2so90769yen.1
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2012 08:29:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean up a reference to jiffies in tcp_rcv_rtt_measure() that should
instead reference tcp_time_stamp. Since the result of the subtraction
is passed into a function taking u32, this should not change any
behavior (and indeed the generated assembly does not change on
x86_64). However, it seems worth cleaning this up for consistency and
clarity (and perhaps to avoid bugs if this is copied and pasted
somewhere else).

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 3ff36406..2a702e3 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -495,7 +495,7 @@ static inline void tcp_rcv_rtt_measure(struct tcp_sock *tp)
 		goto new_measure;
 	if (before(tp->rcv_nxt, tp->rcv_rtt_est.seq))
 		return;
-	tcp_rcv_rtt_update(tp, jiffies - tp->rcv_rtt_est.time, 1);
+	tcp_rcv_rtt_update(tp, tcp_time_stamp - tp->rcv_rtt_est.time, 1);
 
 new_measure:
 	tp->rcv_rtt_est.seq = tp->rcv_nxt + tp->rcv_wnd;
-- 
1.7.7.3
