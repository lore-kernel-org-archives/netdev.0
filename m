From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH] tcp: fix comment for tp->highest_sack
Date: Mon, 27 Feb 2012 17:51:10 -0500
Message-ID: <1330383070-10367-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f202.google.com ([209.85.215.202]:63561 "EHLO
	mail-ey0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755681Ab2B0WvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 17:51:18 -0500
Received: by eaaf13 with SMTP id f13so182815eaa.1
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2012 14:51:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There was an off-by-one error in the comments describing the
highest_sack field in struct tcp_sock. The comments previously claimed
that it was the "start sequence of the highest skb with SACKed
bit". This commit fixes the comments to note that it is the "start
sequence of the skb just *after* the highest skb with SACKed bit".

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 include/linux/tcp.h |    3 ++-
 include/net/tcp.h   |    5 +++--
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 46a85c9..3c7ffdb 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -412,7 +412,8 @@ struct tcp_sock {
 
 	struct tcp_sack_block recv_sack_cache[4];
 
-	struct sk_buff *highest_sack;   /* highest skb with SACK received
+	struct sk_buff *highest_sack;   /* skb just after the highest
+					 * skb with SACKed bit set
 					 * (validity guaranteed only if
 					 * sacked_out > 0)
 					 */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 42c29bf..2d80c29 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1364,8 +1364,9 @@ static inline void tcp_push_pending_frames(struct sock *sk)
 	}
 }
 
-/* Start sequence of the highest skb with SACKed bit, valid only if
- * sacked > 0 or when the caller has ensured validity by itself.
+/* Start sequence of the skb just after the highest skb with SACKed
+ * bit, valid only if sacked_out > 0 or when the caller has ensured
+ * validity by itself.
  */
 static inline u32 tcp_highest_sack_seq(struct tcp_sock *tp)
 {
-- 
1.7.7.3
