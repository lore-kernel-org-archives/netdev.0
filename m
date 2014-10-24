From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/9] i40e: process link events when setting up switch
Date: Thu, 23 Oct 2014 21:10:03 -0700
Message-ID: <1414123806-20049-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1414123806-20049-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:57054 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751777AbaJXEKR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2014 00:10:17 -0400
In-Reply-To: <1414123806-20049-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Add code to handle link events when updating the PF switch. This
allows link information to be properly provided to VFs in all cases.

Change-ID: If314c95f3d39259ef4c40a4a3b823381e28fb24f
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index ff6d94d..1fbbe11 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8730,6 +8730,14 @@ static int i40e_setup_pf_switch(struct i40e_pf *pf, bool reinit)
 	pf->fc_autoneg_status = ((pf->hw.phy.link_info.an_info &
 				  I40E_AQ_AN_COMPLETED) ? true : false);
 
+	/* fill in link information and enable LSE reporting */
+	i40e_update_link_info(&pf->hw, true);
+	i40e_link_event(pf);
+
+	/* Initialize user-specific link properties */
+	pf->fc_autoneg_status = ((pf->hw.phy.link_info.an_info &
+				  I40E_AQ_AN_COMPLETED) ? true : false);
+
 	i40e_ptp_init(pf);
 
 	return ret;
-- 
1.9.3
