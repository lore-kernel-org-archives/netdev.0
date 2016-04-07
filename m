From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/14] i40e/i40evf: Drop unused tx_ring argument
Date: Wed,  6 Apr 2016 20:29:30 -0700
Message-ID: <1459999779-22254-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459999779-22254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:47670 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754088AbcDGD3o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2016 23:29:44 -0400
In-Reply-To: <1459999779-22254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Some of the tx_ring arguments can be deleted since they are not used.

Change-ID: I99275b0f191d7f63ec2f05061919904940c36f31
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 6 ++----
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 6 ++----
 2 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 76a48e9..f4e4d3d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2252,15 +2252,13 @@ out:
 
 /**
  * i40e_tso - set up the tso context descriptor
- * @tx_ring:  ptr to the ring to send
  * @skb:      ptr to the skb we're sending
  * @hdr_len:  ptr to the size of the packet header
  * @cd_type_cmd_tso_mss: Quad Word 1
  *
  * Returns 0 if no TSO can happen, 1 if tso is going, or error
  **/
-static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
-		    u8 *hdr_len, u64 *cd_type_cmd_tso_mss)
+static int i40e_tso(struct sk_buff *skb, u8 *hdr_len, u64 *cd_type_cmd_tso_mss)
 {
 	u64 cd_cmd, cd_tso_len, cd_mss;
 	union {
@@ -2932,7 +2930,7 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	else if (protocol == htons(ETH_P_IPV6))
 		tx_flags |= I40E_TX_FLAGS_IPV6;
 
-	tso = i40e_tso(tx_ring, skb, &hdr_len, &cd_type_cmd_tso_mss);
+	tso = i40e_tso(skb, &hdr_len, &cd_type_cmd_tso_mss);
 
 	if (tso < 0)
 		goto out_drop;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index d633dcf..ec1f447 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1519,15 +1519,13 @@ out:
 
 /**
  * i40e_tso - set up the tso context descriptor
- * @tx_ring:  ptr to the ring to send
  * @skb:      ptr to the skb we're sending
  * @hdr_len:  ptr to the size of the packet header
  * @cd_type_cmd_tso_mss: Quad Word 1
  *
  * Returns 0 if no TSO can happen, 1 if tso is going, or error
  **/
-static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
-		    u8 *hdr_len, u64 *cd_type_cmd_tso_mss)
+static int i40e_tso(struct sk_buff *skb, u8 *hdr_len, u64 *cd_type_cmd_tso_mss)
 {
 	u64 cd_cmd, cd_tso_len, cd_mss;
 	union {
@@ -2150,7 +2148,7 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	else if (protocol == htons(ETH_P_IPV6))
 		tx_flags |= I40E_TX_FLAGS_IPV6;
 
-	tso = i40e_tso(tx_ring, skb, &hdr_len, &cd_type_cmd_tso_mss);
+	tso = i40e_tso(skb, &hdr_len, &cd_type_cmd_tso_mss);
 
 	if (tso < 0)
 		goto out_drop;
-- 
2.5.5
