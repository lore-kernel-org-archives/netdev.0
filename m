From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] i40e: Delete ATR filter on RST
Date: Wed, 26 Mar 2014 11:03:19 -0700
Message-ID: <1395857013-7568-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395857013-7568-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:3602 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754906AbaCZSER (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 14:04:17 -0400
In-Reply-To: <1395857013-7568-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

We currently delete ATR filter on FIN alone, delete on RST as well.

Change-ID: Ie7cae5d1046b9d1d4a0d6ef5bdbf41224c3dade6
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 851f653..de25a32 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1624,8 +1624,11 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
 
 	tx_ring->atr_count++;
 
-	/* sample on all syn/fin packets or once every atr sample rate */
-	if (!th->fin && !th->syn && (tx_ring->atr_count < tx_ring->atr_sample_rate))
+	/* sample on all syn/fin/rst packets or once every atr sample rate */
+	if (!th->fin &&
+	    !th->syn &&
+	    !th->rst &&
+	    (tx_ring->atr_count < tx_ring->atr_sample_rate))
 		return;
 
 	tx_ring->atr_count = 0;
@@ -1649,7 +1652,7 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
 
 	dtype_cmd = I40E_TX_DESC_DTYPE_FILTER_PROG;
 
-	dtype_cmd |= th->fin ?
+	dtype_cmd |= (th->fin || th->rst) ?
 		     (I40E_FILTER_PROGRAM_DESC_PCMD_REMOVE <<
 		      I40E_TXD_FLTR_QW1_PCMD_SHIFT) :
 		     (I40E_FILTER_PROGRAM_DESC_PCMD_ADD_UPDATE <<
-- 
1.8.3.1
