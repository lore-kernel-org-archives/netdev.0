From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v3 net-next 4/4] tcp: shrink tcp_timewait_sock by 8 bytes
Date: Thu,  8 Oct 2015 19:33:24 -0700
Message-ID: <1444358004-26483-5-git-send-email-edumazet@google.com>
References: <1444358004-26483-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33789 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756627AbbJICdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 22:33:40 -0400
Received: by pacex6 with SMTP id ex6so72008935pac.0
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 19:33:40 -0700 (PDT)
In-Reply-To: <1444358004-26483-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reducing tcp_timewait_sock from 280 bytes to 272 bytes
allows SLAB to pack 15 objects per page instead of 14 (on x86)

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/tcp.h | 4 ++--
 include/net/sock.h  | 2 ++
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index e442e6e9a365..86a7edaa6797 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -356,8 +356,8 @@ static inline struct tcp_sock *tcp_sk(const struct sock *sk)
 
 struct tcp_timewait_sock {
 	struct inet_timewait_sock tw_sk;
-	u32			  tw_rcv_nxt;
-	u32			  tw_snd_nxt;
+#define tw_rcv_nxt tw_sk.__tw_common.skc_tw_rcv_nxt
+#define tw_snd_nxt tw_sk.__tw_common.skc_tw_snd_nxt
 	u32			  tw_rcv_wnd;
 	u32			  tw_ts_offset;
 	u32			  tw_ts_recent;
diff --git a/include/net/sock.h b/include/net/sock.h
index fce12399fad4..288934da0ae3 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -229,6 +229,7 @@ struct sock_common {
 	union {
 		int		skc_incoming_cpu;
 		u32		skc_rcv_wnd;
+		u32		skc_tw_rcv_nxt; /* struct tcp_timewait_sock  */
 	};
 
 	atomic_t		skc_refcnt;
@@ -237,6 +238,7 @@ struct sock_common {
 	union {
 		u32		skc_rxhash;
 		u32		skc_window_clamp;
+		u32		skc_tw_snd_nxt; /* struct tcp_timewait_sock */
 	};
 	/* public: */
 };
-- 
2.6.0.rc2.230.g3dd15c0
