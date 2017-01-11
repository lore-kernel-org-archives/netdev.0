From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 06/13] s390/qeth: drop qeth_l2_del_all_macs() parameter
Date: Wed, 11 Jan 2017 12:55:53 +0100
Message-ID: <20170111115600.4524-7-ubraun@linux.vnet.ibm.com>
References: <20170111115600.4524-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        stable@vger.kernel.org, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170111115600.4524-1-ubraun@linux.vnet.ibm.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julian Wiedmann <jwi@linux.vnet.ibm.com>

The only caller passes del = 0, so remove both the parameter and
the code that handles != 0.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 9c921c28..3025f56 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -216,7 +216,7 @@ static int qeth_l2_write_mac(struct qeth_card *card, struct qeth_mac *mac)
 	return rc;
 }
 
-static void qeth_l2_del_all_macs(struct qeth_card *card, int del)
+static void qeth_l2_del_all_macs(struct qeth_card *card)
 {
 	struct qeth_mac *mac;
 	struct hlist_node *tmp;
@@ -224,13 +224,6 @@ static void qeth_l2_del_all_macs(struct qeth_card *card, int del)
 
 	spin_lock_bh(&card->mclock);
 	hash_for_each_safe(card->mac_htable, i, tmp, mac, hnode) {
-		if (del) {
-			if (mac->is_uc)
-				qeth_l2_send_setdelmac(card, mac->mac_addr,
-						IPA_CMD_DELVMAC);
-			else
-				qeth_l2_send_delgroupmac(card, mac->mac_addr);
-		}
 		hash_del(&mac->hnode);
 		kfree(mac);
 	}
@@ -425,7 +418,7 @@ static void qeth_l2_stop_card(struct qeth_card *card, int recovery_mode)
 		card->state = CARD_STATE_SOFTSETUP;
 	}
 	if (card->state == CARD_STATE_SOFTSETUP) {
-		qeth_l2_del_all_macs(card, 0);
+		qeth_l2_del_all_macs(card);
 		qeth_clear_ipacmd_list(card);
 		card->state = CARD_STATE_HARDSETUP;
 	}
-- 
2.8.4
