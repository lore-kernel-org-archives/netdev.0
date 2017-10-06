From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] i40e: re-enable PTP L4 capabilities for XL710 if FW >6.0
Date: Fri,  6 Oct 2017 10:57:16 -0700
Message-ID: <20171006175727.868-5-jeffrey.t.kirsher@intel.com>
References: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
Cc: Alan Brady <alan.brady@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:17217 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751862AbdJFR5u (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Oct 2017 13:57:50 -0400
In-Reply-To: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Brady <alan.brady@intel.com>

Starting with XL710 FW 5.3 PTP L4 was disabled for XL710 due to a bug.  The
bug has since been resolved in XL710 FW >6.0 and PTP L4 can now be
re-enabled on those devices with updated firmware.

Signed-off-by: Alan Brady <alan.brady@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d2bb4f17c89e..85132eee9f64 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9074,6 +9074,11 @@ static int i40e_sw_init(struct i40e_pf *pf)
 	    (pf->hw.aq.fw_maj_ver >= 5)))
 		pf->hw_features |= I40E_HW_USE_SET_LLDP_MIB;
 
+	/* Enable PTP L4 if FW > v6.0 */
+	if (pf->hw.mac.type == I40E_MAC_XL710 &&
+	    pf->hw.aq.fw_maj_ver >= 6)
+		pf->hw_features |= I40E_HW_PTP_L4_CAPABLE;
+
 	if (pf->hw.func_caps.vmdq) {
 		pf->num_vmdq_vsis = I40E_DEFAULT_NUM_VMDQ_VSI;
 		pf->flags |= I40E_FLAG_VMDQ_ENABLED;
-- 
2.14.2
