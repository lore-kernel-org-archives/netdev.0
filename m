From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/11] i40e: Enable l2tsel bit for VLAN tag control
Date: Wed, 27 Aug 2014 02:26:40 -0700
Message-ID: <1409131606-15011-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1409131606-15011-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Ashish Shah <ashish.n.shah@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:64397 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932832AbaH0J0x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 05:26:53 -0400
In-Reply-To: <1409131606-15011-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Enable the l2tsel bit on Rx queue contexts that are assigned to VFs so
that the VF can get the stripped VLAN tag.

Change-ID: I7d9bc56238a9ea9baf5e8a97e69b9e27ebb9d169
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Ashish Shah <ashish.n.shah@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 3ac6a0d..0309bf8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -350,6 +350,7 @@ static int i40e_config_vsi_rx_queue(struct i40e_vf *vf, u16 vsi_idx,
 	rx_ctx.lrxqthresh = 2;
 	rx_ctx.crcstrip = 1;
 	rx_ctx.prefena = 1;
+	rx_ctx.l2tsel = 1;
 
 	/* clear the context in the HMC */
 	ret = i40e_clear_lan_rx_queue_context(hw, pf_queue_id);
-- 
1.9.3
