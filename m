From: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH net 5/9] net/smc: adapt send request completion notification
Date: Thu, 21 Sep 2017 09:16:30 +0200
Message-ID: <20170921071634.16883-6-ubraun@linux.vnet.ibm.com>
References: <20170921071634.16883-1-ubraun@linux.vnet.ibm.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jwi-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
        schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org,
        raspl-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170921071634.16883-1-ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The solicited flag is meaningful for the receive completion queue.
Ask for next work completion of any type on the send queue.

Signed-off-by: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 net/smc/smc_wr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/smc/smc_wr.c b/net/smc/smc_wr.c
index ab56bda66783..525d91e0d57e 100644
--- a/net/smc/smc_wr.c
+++ b/net/smc/smc_wr.c
@@ -244,7 +244,7 @@ int smc_wr_tx_send(struct smc_link *link, struct smc_wr_tx_pend_priv *priv)
 	int rc;
 
 	ib_req_notify_cq(link->smcibdev->roce_cq_send,
-			 IB_CQ_SOLICITED_MASK | IB_CQ_REPORT_MISSED_EVENTS);
+			 IB_CQ_NEXT_COMP | IB_CQ_REPORT_MISSED_EVENTS);
 	pend = container_of(priv, struct smc_wr_tx_pend, priv);
 	rc = ib_post_send(link->roce_qp, &link->wr_tx_ibs[pend->idx],
 			  &failed_wr);
-- 
2.13.5

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
