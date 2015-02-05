From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/16] fm10k: Resolve compile warnings with W=1
Date: Thu,  5 Feb 2015 01:35:36 -0800
Message-ID: <1423128950-12388-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1423128950-12388-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55122 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753268AbbBEJgD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2015 04:36:03 -0500
In-Reply-To: <1423128950-12388-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

Fix two cases where variables are being set but not used.

Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Krishneil Singh<Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c | 5 ++---
 drivers/net/ethernet/intel/fm10k/fm10k_ptp.c | 3 ---
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
index 14a4ea7..9f5457c 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
@@ -1194,12 +1194,11 @@ static s32 fm10k_mbx_process_disconnect(struct fm10k_hw *hw,
 {
 	const enum fm10k_mbx_state state = mbx->state;
 	const u32 *hdr = &mbx->mbx_hdr;
-	u16 head, tail;
+	u16 head;
 	s32 err;
 
-	/* we will need to pull all of the fields for verification */
+	/* we will need to pull the header field for verification */
 	head = FM10K_MSG_HDR_FIELD_GET(*hdr, HEAD);
-	tail = FM10K_MSG_HDR_FIELD_GET(*hdr, TAIL);
 
 	/* We should not be receiving disconnect if Rx is incomplete */
 	if (mbx->pushed)
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c b/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
index 7822809..d966044 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
@@ -57,7 +57,6 @@ void fm10k_ts_tx_enqueue(struct fm10k_intfc *interface, struct sk_buff *skb)
 	struct sk_buff_head *list = &interface->ts_tx_skb_queue;
 	struct sk_buff *clone;
 	unsigned long flags;
-	__le16 dglort;
 
 	/* create clone for us to return on the Tx path */
 	clone = skb_clone_sk(skb);
@@ -65,8 +64,6 @@ void fm10k_ts_tx_enqueue(struct fm10k_intfc *interface, struct sk_buff *skb)
 		return;
 
 	FM10K_CB(clone)->ts_tx_timeout = jiffies + FM10K_TS_TX_TIMEOUT;
-	dglort = FM10K_CB(clone)->fi.w.dglort;
-
 	spin_lock_irqsave(&list->lock, flags);
 
 	/* attempt to locate any buffers with the same dglort,
-- 
1.9.3
