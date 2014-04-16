From: Kenjiro Nakayama <nakayamakenjiro@gmail.com>
Subject: [PATCH v3] tcp: Add a TCP_FASTOPEN socket option to get a max backlog on its listner
Date: Thu, 17 Apr 2014 01:25:01 +0900
Message-ID: <87a9bljl7m.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neal Cardwell <ncardwell@google.com>,
	Netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a TCP_FASTOPEN socket option to get a max backlog on its
listener to getsockopt().

Signed-off-by: Kenjiro Nakayama <nakayamakenjiro@gmail.com>
---
 net/ipv4/tcp.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4bd6d52..eb1dde3 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2916,6 +2916,14 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 	case TCP_USER_TIMEOUT:
 		val = jiffies_to_msecs(icsk->icsk_user_timeout);
 		break;
+
+	case TCP_FASTOPEN:
+		if (icsk->icsk_accept_queue.fastopenq != NULL)
+			val = icsk->icsk_accept_queue.fastopenq->max_qlen;
+		else
+			val = 0;
+		break;
+
 	case TCP_TIMESTAMP:
 		val = tcp_time_stamp + tp->tsoffset;
 		break;
--
1.9.0
