From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
Subject: [PATCH net-next v2 5/5] net: l2tp: fix negative assignment to unsigned int
Date: Mon,  7 Nov 2016 20:39:28 +0000
Message-ID: <20161107203928.30111-5-asbjorn@asbjorn.st>
References: <20161107203928.30111-1-asbjorn@asbjorn.st>
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161107203928.30111-1-asbjorn@asbjorn.st>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

recv_seq, send_seq and lns_mode mode are all defined as
unsigned int foo:1;

Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
---
 net/l2tp/l2tp_core.c | 2 +-
 net/l2tp/l2tp_ppp.c  | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index a2ed3bd..85948c6 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -715,7 +715,7 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 			l2tp_info(session, L2TP_MSG_SEQ,
 				  "%s: requested to enable seq numbers by LNS\n",
 				  session->name);
-			session->send_seq = -1;
+			session->send_seq = 1;
 			l2tp_session_set_header_len(session, tunnel->version);
 		}
 	} else {
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 41d47bf..2ddfec1 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -1272,7 +1272,7 @@ static int pppol2tp_session_setsockopt(struct sock *sk,
 			err = -EINVAL;
 			break;
 		}
-		session->recv_seq = val ? -1 : 0;
+		session->recv_seq = !!val;
 		l2tp_info(session, PPPOL2TP_MSG_CONTROL,
 			  "%s: set recv_seq=%d\n",
 			  session->name, session->recv_seq);
@@ -1283,7 +1283,7 @@ static int pppol2tp_session_setsockopt(struct sock *sk,
 			err = -EINVAL;
 			break;
 		}
-		session->send_seq = val ? -1 : 0;
+		session->send_seq = !!val;
 		{
 			struct sock *ssk      = ps->sock;
 			struct pppox_sock *po = pppox_sk(ssk);
@@ -1301,7 +1301,7 @@ static int pppol2tp_session_setsockopt(struct sock *sk,
 			err = -EINVAL;
 			break;
 		}
-		session->lns_mode = val ? -1 : 0;
+		session->lns_mode = !!val;
 		l2tp_info(session, PPPOL2TP_MSG_CONTROL,
 			  "%s: set lns_mode=%d\n",
 			  session->name, session->lns_mode);
-- 
2.10.1
