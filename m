From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH] be2net: Fix some u16 fields appropriately
Date: Sun, 27 Aug 2017 15:24:45 +0800
Message-ID: <1503818685-32068-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: Sathya Perla <sathya.perla@broadcom.com>,
        jit Khaparde <ajit.khaparde@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In be_tx_compl_process, frag_index declared as u32, so it's better to
declare last_index as u32 also.

CC: Ajit Khaparde <ajit.khaparde@broadcom.com>
Fixes: b0fd2eb28bd4 ("be2net: Declare some u16 fields as u32 to improve
performance")
Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 drivers/net/ethernet/emulex/benet/be.h      | 2 +-
 drivers/net/ethernet/emulex/benet/be_main.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 674cf9d..2ba4d61 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -255,7 +255,7 @@ struct be_tx_stats {
 /* Structure to hold some data of interest obtained from a TX CQE */
 struct be_tx_compl_info {
 	u8 status;		/* Completion status */
-	u16 end_index;		/* Completed TXQ Index */
+	u32 end_index;		/* Completed TXQ Index */
 };
 
 struct be_tx_obj {
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 319eee3..3645344 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2606,7 +2606,7 @@ static struct be_tx_compl_info *be_tx_compl_get(struct be_tx_obj *txo)
 }
 
 static u16 be_tx_compl_process(struct be_adapter *adapter,
-			       struct be_tx_obj *txo, u16 last_index)
+			       struct be_tx_obj *txo, u32 last_index)
 {
 	struct sk_buff **sent_skbs = txo->sent_skb_list;
 	struct be_queue_info *txq = &txo->q;
-- 
1.8.3.1
