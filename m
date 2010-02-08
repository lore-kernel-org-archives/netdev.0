From: Andreas Petlund <apetlund@simula.no>
Subject: [net-next PATCH v2 1/3] net: TCP thin-stream detection
Date: Mon, 08 Feb 2010 15:25:32 +0100
Message-ID: <4B701EDC.7040109@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>,
	william.allen.simpson@gmail.com
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Major change: Stopped stream from being detected as thin if in initial slow-start

>From 1c448f7c65a016ded7eedd44fe74874e5b3cdbc0 Mon Sep 17 00:00:00 2001
From: Andreas Petlund <apetlund@simula.no>
Date: Mon, 8 Feb 2010 14:05:24 +0100
Subject: [PATCH 1/3] net: TCP thin-stream detection


Signed-off-by: Andreas Petlund <apetlund@simula.no>
---
 include/net/tcp.h |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 87d164b..e5e2056 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1386,6 +1386,13 @@ static inline void tcp_highest_sack_combine(struct sock *sk,
 		tcp_sk(sk)->highest_sack = new;
 }
 
+/* Determines whether this is a thin stream (which may suffer from
+ * increased latency). Used to trigger latency-reducing mechanisms.*/
+static inline unsigned int tcp_stream_is_thin(struct tcp_sock *tp)
+{
+	return tp->packets_out < 4 && !tcp_in_initial_slowstart(tp);
+}
+
 /* /proc */
 enum tcp_seq_states {
 	TCP_SEQ_STATE_LISTENING,
-- 
1.6.3.3
