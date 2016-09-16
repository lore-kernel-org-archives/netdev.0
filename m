From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH resend] sctp: Remove some redundant code
Date: Fri, 16 Sep 2016 23:05:35 +0200
Message-ID: <1474059935-17343-1-git-send-email-christophe.jaillet@wanadoo.fr>
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: marcelo.leitner@gmail.com, vyasevich@gmail.com,
        nhorman@tuxdriver.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In commit 311b21774f13 ("sctp: simplify sk_receive_queue locking"), a call
to 'skb_queue_splice_tail_init()' has been made explicit. Previously it was
hidden in 'sctp_skb_list_tail()'

Now, the code around it looks redundant. The '_init()' part of
'skb_queue_splice_tail_init()' should already do the same.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
---
Resent because netdev@ was not in copy
Acked-by tags added
---
 net/sctp/ulpqueue.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index 877e55066f89..84d0fdaf7de9 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -140,11 +140,8 @@ int sctp_clear_pd(struct sock *sk, struct sctp_association *asoc)
 		 * we can go ahead and clear out the lobby in one shot
 		 */
 		if (!skb_queue_empty(&sp->pd_lobby)) {
-			struct list_head *list;
 			skb_queue_splice_tail_init(&sp->pd_lobby,
 						   &sk->sk_receive_queue);
-			list = (struct list_head *)&sctp_sk(sk)->pd_lobby;
-			INIT_LIST_HEAD(list);
 			return 1;
 		}
 	} else {
-- 
2.7.4
