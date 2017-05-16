From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: [PATCH net-next] tcp: warn on negative reordering values
Date: Tue, 16 May 2017 17:39:02 -0400
Message-ID: <20170516213903.78909-1-soheil.kdev@gmail.com>
Cc: Soheil Hassas Yeganeh <soheil@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:34754 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750932AbdEPVjH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 17:39:07 -0400
Received: by mail-qt0-f196.google.com with SMTP id l39so22582654qtb.1
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 14:39:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil@google.com>

Commit bafbb9c73241 ("tcp: eliminate negative reordering
in tcp_clean_rtx_queue") fixes an issue for negative
reordering metrics.

To be resilient to such errors, warn and return
when a negative metric is passed to tcp_update_reordering().

Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f27dff64e59e..eb5eb87060a2 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -886,6 +886,9 @@ static void tcp_update_reordering(struct sock *sk, const int metric,
 	struct tcp_sock *tp = tcp_sk(sk);
 	int mib_idx;
 
+	if (WARN_ON_ONCE(metric < 0))
+		return;
+
 	if (metric > tp->reordering) {
 		tp->reordering = min(sysctl_tcp_max_reordering, metric);
 
-- 
2.13.0.303.g4ebf302169-goog
