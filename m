From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 2/2] drivers, s390: fix errors resulting from refcount conversions
Date: Mon,  3 Jul 2017 14:50:28 +0300
Message-ID: <1499082628-21253-3-git-send-email-elena.reshetova@intel.com>
References: <1499082628-21253-1-git-send-email-elena.reshetova@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499082628-21253-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For some reason it looks like our tree hasn't been tested
with s390-default_defconfig, so this commit fixes errors
reported from it.
---
 drivers/s390/net/ctcm_fsms.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/s390/net/ctcm_fsms.c b/drivers/s390/net/ctcm_fsms.c
index e9847ce..570ae3b 100644
--- a/drivers/s390/net/ctcm_fsms.c
+++ b/drivers/s390/net/ctcm_fsms.c
@@ -217,7 +217,7 @@ void ctcm_purge_skb_queue(struct sk_buff_head *q)
 	CTCM_DBF_TEXT(TRACE, CTC_DBF_DEBUG, __func__);
 
 	while ((skb = skb_dequeue(q))) {
-		atomic_dec(&skb->users);
+		refcount_dec(&skb->users);
 		dev_kfree_skb_any(skb);
 	}
 }
@@ -271,7 +271,7 @@ static void chx_txdone(fsm_instance *fi, int event, void *arg)
 			priv->stats.tx_bytes += 2;
 			first = 0;
 		}
-		atomic_dec(&skb->users);
+		refcount_dec(&skb->users);
 		dev_kfree_skb_irq(skb);
 	}
 	spin_lock(&ch->collect_lock);
@@ -297,7 +297,7 @@ static void chx_txdone(fsm_instance *fi, int event, void *arg)
 				skb_put(ch->trans_skb, skb->len), skb->len);
 			priv->stats.tx_packets++;
 			priv->stats.tx_bytes += skb->len - LL_HEADER_LENGTH;
-			atomic_dec(&skb->users);
+			refcount_dec(&skb->users);
 			dev_kfree_skb_irq(skb);
 			i++;
 		}
@@ -1248,7 +1248,7 @@ static void ctcmpc_chx_txdone(fsm_instance *fi, int event, void *arg)
 			priv->stats.tx_bytes += 2;
 			first = 0;
 		}
-		atomic_dec(&skb->users);
+		refcount_dec(&skb->users);
 		dev_kfree_skb_irq(skb);
 	}
 	spin_lock(&ch->collect_lock);
@@ -1298,7 +1298,7 @@ static void ctcmpc_chx_txdone(fsm_instance *fi, int event, void *arg)
 		data_space -= skb->len;
 		priv->stats.tx_packets++;
 		priv->stats.tx_bytes += skb->len;
-		atomic_dec(&skb->users);
+		refcount_dec(&skb->users);
 		dev_kfree_skb_any(skb);
 		peekskb = skb_peek(&ch->collect_queue);
 		if (peekskb->len > data_space)
@@ -1795,7 +1795,7 @@ static void ctcmpc_chx_send_sweep(fsm_instance *fsm, int event, void *arg)
 		fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
 				goto done;
 	} else {
-		atomic_inc(&skb->users);
+		refcount_inc(&skb->users);
 		skb_queue_tail(&wch->io_queue, skb);
 	}
 
-- 
2.7.4
