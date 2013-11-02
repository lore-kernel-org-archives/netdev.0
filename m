From: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Subject: [PATCH net-next 09/13] driver: s390: remove unnecessary NULL check before dev_kfree_skb_any
Date: Sat,  2 Nov 2013 19:17:50 +0530
Message-ID: <1383400074-30555-10-git-send-email-govindarajulu90@gmail.com>
References: <1383400074-30555-1-git-send-email-govindarajulu90@gmail.com>
Cc: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
To: davem@davemloft.net, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	schwidefsky@de.ibm.com, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	IvDoorn@gmail.com, sbhatewara@vmware.com, samuel@sortiz.org,
	chas@cmf.nrl.navy.mil, roland@kernel.org, isdn@linux-pingi.de,
	jcliburn@gmail.com, benve@cisco.com, ssujith@cisco.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shahed.shaikh@qlogic.com, joe@perches.com, apw@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383400074-30555-1-git-send-email-govindarajulu90@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dev_kfree_skb_any is protected from NULL. No need to check for NULL
while calling this function.

Signed-off-by: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
---
 drivers/s390/net/claw.c           | 6 ++----
 drivers/s390/net/ctcm_mpc.c       | 6 ++----
 drivers/s390/net/qeth_core_main.c | 6 ++----
 3 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/s390/net/claw.c b/drivers/s390/net/claw.c
index fd7b3bd..66c0b14 100644
--- a/drivers/s390/net/claw.c
+++ b/drivers/s390/net/claw.c
@@ -834,10 +834,8 @@ claw_release(struct net_device *dev)
                         ccw_check_return_code(privptr->channel[i].cdev, rc);
                 }
         }
-	if (privptr->pk_skb != NULL) {
-		dev_kfree_skb_any(privptr->pk_skb);
-		privptr->pk_skb = NULL;
-	}
+	dev_kfree_skb_any(privptr->pk_skb);
+	privptr->pk_skb = NULL;
 	if(privptr->buffs_alloc != 1) {
 		CLAW_DBF_TEXT(4, trace, "none2fre");
 		return 0;
diff --git a/drivers/s390/net/ctcm_mpc.c b/drivers/s390/net/ctcm_mpc.c
index 2dbc77b..2dd53a6 100644
--- a/drivers/s390/net/ctcm_mpc.c
+++ b/drivers/s390/net/ctcm_mpc.c
@@ -964,8 +964,7 @@ void mpc_channel_action(struct channel *ch, int direction, int action)
 		grp->outstanding_xid2++;
 		ch->in_mpcgroup = 1;
 
-		if (ch->xid_skb != NULL)
-			dev_kfree_skb_any(ch->xid_skb);
+		dev_kfree_skb_any(ch->xid_skb);
 
 		ch->xid_skb = __dev_alloc_skb(MPC_BUFSIZE_DEFAULT,
 					GFP_ATOMIC | GFP_DMA);
@@ -1017,8 +1016,7 @@ void mpc_channel_action(struct channel *ch, int direction, int action)
 		grp->num_channel_paths--;
 		grp->active_channels[direction]--;
 
-		if (ch->xid_skb != NULL)
-			dev_kfree_skb_any(ch->xid_skb);
+		dev_kfree_skb_any(ch->xid_skb);
 		ch->xid_skb = NULL;
 
 		if (grp->channels_terminating)
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 0a328d0..7d33b94 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -1282,10 +1282,8 @@ static void qeth_free_qdio_buffers(struct qeth_card *card)
 
 	qeth_free_cq(card);
 	cancel_delayed_work_sync(&card->buffer_reclaim_work);
-	for (j = 0; j < QDIO_MAX_BUFFERS_PER_Q; ++j) {
-		if (card->qdio.in_q->bufs[j].rx_skb)
-			dev_kfree_skb_any(card->qdio.in_q->bufs[j].rx_skb);
-	}
+	for (j = 0; j < QDIO_MAX_BUFFERS_PER_Q; ++j)
+		dev_kfree_skb_any(card->qdio.in_q->bufs[j].rx_skb);
 	kfree(card->qdio.in_q);
 	card->qdio.in_q = NULL;
 	/* inbound buffer pool */
-- 
1.8.4.2
