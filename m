From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  08/14] i40e: fix sign extension issue
Date: Fri, 18 Oct 2013 06:23:12 -0700
Message-ID: <1382102598-11343-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1382102598-11343-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: a@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41785 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754292Ab3JRNXl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Oct 2013 09:23:41 -0400
In-Reply-To: <1382102598-11343-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This is a fix for an issue reported by coverity, reported
by Hannes Frederic Sowa.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Hannes Frederic Sowa <hannes@stressinduktion.org>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index fbc40cd..8fc313c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -99,9 +99,9 @@ int i40e_program_fdir_filter(struct i40e_fdir_data *fdir_data,
 					   << I40E_TXD_FLTR_QW0_DEST_VSI_SHIFT);
 	else
 		fdir_desc->qindex_flex_ptype_vsi |=
-					    cpu_to_le32((fdir_data->dest_vsi
-					    << I40E_TXD_FLTR_QW0_DEST_VSI_SHIFT)
-					    & I40E_TXD_FLTR_QW0_DEST_VSI_MASK);
+			cpu_to_le32((((u32)fdir_data->dest_vsi) <<
+					  I40E_TXD_FLTR_QW0_DEST_VSI_SHIFT) &
+				    I40E_TXD_FLTR_QW0_DEST_VSI_MASK);
 
 	fdir_desc->dtype_cmd_cntindex =
 				    cpu_to_le32(I40E_TX_DESC_DTYPE_FILTER_PROG);
@@ -127,9 +127,9 @@ int i40e_program_fdir_filter(struct i40e_fdir_data *fdir_data,
 		fdir_desc->dtype_cmd_cntindex |=
 				    cpu_to_le32(I40E_TXD_FLTR_QW1_CNT_ENA_MASK);
 		fdir_desc->dtype_cmd_cntindex |=
-					    cpu_to_le32((fdir_data->cnt_index
-					    << I40E_TXD_FLTR_QW1_CNTINDEX_SHIFT)
-					    & I40E_TXD_FLTR_QW1_CNTINDEX_MASK);
+			cpu_to_le32((((u32)fdir_data->cnt_index) <<
+					   I40E_TXD_FLTR_QW1_CNTINDEX_SHIFT) &
+				    I40E_TXD_FLTR_QW1_CNTINDEX_MASK);
 	}
 
 	fdir_desc->fd_id = cpu_to_le32(fdir_data->fd_id);
-- 
1.8.3.1
