From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/16] i40e: Support FW CEE DCB UP to TC map nibble swap
Date: Thu,  8 Oct 2015 18:32:48 -0700
Message-ID: <1444354374-24351-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Bowers <gregory.j.bowers@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:23167 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755367AbbJIBc5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 21:32:57 -0400
In-Reply-To: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Bowers <gregory.j.bowers@intel.com>

Changes parsing of AQ command Get CEE DCBX OPER CFG (0x0A07). Change is
required because FW creates the oper_prio_tc nibbles reversed from those
in the CEE Priority Group sub-TLV.

Change-ID: I7d9d8641bb430d30e286fc3fac909866ef8a0de8
Signed-off-by: Greg Bowers <gregory.j.bowers@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_dcb.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_dcb.c b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
index fbec7d7..6fa07ef 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_dcb.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
@@ -681,15 +681,18 @@ static void i40e_cee_to_dcb_config(
 	/* CEE PG data to ETS config */
 	dcbcfg->etscfg.maxtcs = cee_cfg->oper_num_tc;
 
+	/* Note that the FW creates the oper_prio_tc nibbles reversed
+	 * from those in the CEE Priority Group sub-TLV.
+	 */
 	for (i = 0; i < 4; i++) {
 		tc = (u8)((cee_cfg->oper_prio_tc[i] &
-			 I40E_CEE_PGID_PRIO_1_MASK) >>
-			 I40E_CEE_PGID_PRIO_1_SHIFT);
-		dcbcfg->etscfg.prioritytable[i*2] =  tc;
-		tc = (u8)((cee_cfg->oper_prio_tc[i] &
 			 I40E_CEE_PGID_PRIO_0_MASK) >>
 			 I40E_CEE_PGID_PRIO_0_SHIFT);
-		dcbcfg->etscfg.prioritytable[i*2 + 1] = tc;
+		dcbcfg->etscfg.prioritytable[i * 2] =  tc;
+		tc = (u8)((cee_cfg->oper_prio_tc[i] &
+			 I40E_CEE_PGID_PRIO_1_MASK) >>
+			 I40E_CEE_PGID_PRIO_1_SHIFT);
+		dcbcfg->etscfg.prioritytable[i * 2 + 1] = tc;
 	}
 
 	for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++)
-- 
2.4.3
