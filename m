From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/14] i40e: Fix NPAR Tx Scheduler init
Date: Thu,  5 Mar 2015 08:46:19 -0800
Message-ID: <1425573992-30955-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:41895 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757766AbbCEQqw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 11:46:52 -0500
In-Reply-To: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Recent changes to the driver initialization have caused the BW
configurations to not take effect.  We use a BW configuration read and
write back to "kick" the Tx scheduler into action.

Change-ID: I94ab377c58d3a3986e3de62b6c199be3fd2ee5e6
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 56bdaff..620dd23 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7576,6 +7576,10 @@ static int i40e_sw_init(struct i40e_pf *pf)
 
 	mutex_init(&pf->switch_mutex);
 
+	/* If NPAR is enabled nudge the Tx scheduler */
+	if (pf->hw.func_caps.npar_enable && (!i40e_get_npar_bw_setting(pf)))
+		i40e_set_npar_bw_setting(pf);
+
 sw_init_done:
 	return err;
 }
-- 
1.9.3
