From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/14] i40e: fix fdir programming
Date: Thu, 26 Jun 2014 05:13:53 -0700
Message-ID: <1403784834-23301-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403784834-23301-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:10427 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757719AbaFZMOc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2014 08:14:32 -0400
In-Reply-To: <1403784834-23301-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

There were a couple of fields in the fdir descriptor setup that
were not being reprogrammed, which left the opportunity for stale
data to be pushed as part of the descriptor next time it was used.

Change-ID: Ieee5c96a7d4713d469693f086c4854de949a7633
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index c5749d6..5cc27fb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -100,8 +100,6 @@ int i40e_program_fdir_filter(struct i40e_fdir_filter *fdir_data, u8 *raw_packet,
 			I40E_TXD_FLTR_QW0_DEST_VSI_SHIFT) &
 		       I40E_TXD_FLTR_QW0_DEST_VSI_MASK;
 
-	fdir_desc->qindex_flex_ptype_vsi = cpu_to_le32(fpt);
-
 	dcc = I40E_TX_DESC_DTYPE_FILTER_PROG;
 
 	if (add)
@@ -124,6 +122,8 @@ int i40e_program_fdir_filter(struct i40e_fdir_filter *fdir_data, u8 *raw_packet,
 			I40E_TXD_FLTR_QW1_CNTINDEX_MASK;
 	}
 
+	fdir_desc->qindex_flex_ptype_vsi = cpu_to_le32(fpt);
+	fdir_desc->rsvd = cpu_to_le32(0);
 	fdir_desc->dtype_cmd_cntindex = cpu_to_le32(dcc);
 	fdir_desc->fd_id = cpu_to_le32(fdir_data->fd_id);
 
@@ -1688,7 +1688,9 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
 		I40E_TXD_FLTR_QW1_CNTINDEX_MASK;
 
 	fdir_desc->qindex_flex_ptype_vsi = cpu_to_le32(flex_ptype);
+	fdir_desc->rsvd = cpu_to_le32(0);
 	fdir_desc->dtype_cmd_cntindex = cpu_to_le32(dtype_cmd);
+	fdir_desc->fd_id = cpu_to_le32(0);
 }
 
 /**
-- 
1.9.3
