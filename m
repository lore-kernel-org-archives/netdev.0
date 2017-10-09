From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/14] i40e: add check for return from find_first_bit call
Date: Mon,  9 Oct 2017 15:38:37 -0700
Message-ID: <20171009223841.2557-11-jeffrey.t.kirsher@intel.com>
References: <20171009223841.2557-1-jeffrey.t.kirsher@intel.com>
Cc: Lihong Yang <lihong.yang@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:36096 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755536AbdJIWjH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 18:39:07 -0400
In-Reply-To: <20171009223841.2557-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lihong Yang <lihong.yang@intel.com>

The find_first_bit function will return the size passed to search
if the first set bit is not found. This patch adds the check in case
that happens as the return value would be used as the index in an array
and that would have caused the out-of-bounds access.

Detected by CoverityScan, CID 1295969 Out-of-bounds access

Signed-off-by: Lihong Yang <lihong.yang@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 83727906a386..125dcd1d2233 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -306,6 +306,10 @@ static void i40e_config_irq_link_list(struct i40e_vf *vf, u16 vsi_id,
 	next_q = find_first_bit(&linklistmap,
 				(I40E_MAX_VSI_QP *
 				 I40E_VIRTCHNL_SUPPORTED_QTYPES));
+	if (unlikely(next_q == (I40E_MAX_VSI_QP *
+				I40E_VIRTCHNL_SUPPORTED_QTYPES)))
+		goto irq_list_done;
+
 	vsi_queue_id = next_q / I40E_VIRTCHNL_SUPPORTED_QTYPES;
 	qtype = next_q % I40E_VIRTCHNL_SUPPORTED_QTYPES;
 	pf_queue_id = i40e_vc_get_pf_queue_id(vf, vsi_id, vsi_queue_id);
-- 
2.14.2
