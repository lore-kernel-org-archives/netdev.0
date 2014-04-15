From: Kenjiro Nakayama <nakayamakenjiro@gmail.com>
Subject: [PATCH v2] ipv4: Add option to get TCP_FASTOPEN to getsockopt()
Date: Tue, 15 Apr 2014 21:35:11 +0900
Message-ID: <87r44yixds.fsf@gmail.com>
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

Hi,

TCP_FASTOPEN option can be set via setsockopt(), but the value cannot be
gotten via getsockopt(). This patch adds the option to getsockopt().

Sighned-off-by: Kenjiro Nakayama <nakayamakenjiro@gmail.com>

 	Add option to get TCP_FASTOPEN to getsockopt()
---
 net/ipv4/tcp.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4bd6d52..86186f4 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2916,6 +2916,13 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 	case TCP_USER_TIMEOUT:
 		val = jiffies_to_msecs(icsk->icsk_user_timeout);
 		break;
+
+	case TCP_FASTOPEN:
+		val = icsk->icsk_accept_queue.fastopenq ?
+		    icsk->icsk_accept_queue.fastopenq->max_qlen
+		    : sysctl_tcp_fastopen;
+		break;
+
 	case TCP_TIMESTAMP:
 		val = tcp_time_stamp + tp->tsoffset;
 		break;
--
1.9.0
