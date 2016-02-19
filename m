From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/16] i40e: Fix for unexpected messaging
Date: Fri, 19 Feb 2016 01:54:03 -0800
Message-ID: <1455875651-21696-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455875651-21696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:8261 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1427413AbcBSJyW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 04:54:22 -0500
In-Reply-To: <1455875651-21696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This fixes an issue where a previously removed message
has returned.  Changing the message type to dev_dbg
leaves the info, if desired, but takes it out of normal
everyday usage. Also changed call to only provide port
data when its valid and not when its not (delete case).

Change-ID: Ief6f33b915f6364c24fa8e5789c2fc3168b5e2ed
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 53660f1..05def9f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7109,12 +7109,13 @@ static void i40e_sync_udp_filters_subtask(struct i40e_pf *pf)
 				ret = i40e_aq_del_udp_tunnel(hw, i, NULL);
 
 			if (ret) {
-				dev_info(&pf->pdev->dev,
-					 "%s vxlan port %d, index %d failed, err %s aq_err %s\n",
-					 port ? "add" : "delete",
-					 ntohs(port), i,
-					 i40e_stat_str(&pf->hw, ret),
-					 i40e_aq_str(&pf->hw,
+				dev_dbg(&pf->pdev->dev,
+					"%s %s port %d, index %d failed, err %s aq_err %s\n",
+					pf->udp_ports[i].type ? "vxlan" : "geneve",
+					port ? "add" : "delete",
+					ntohs(port), i,
+					i40e_stat_str(&pf->hw, ret),
+					i40e_aq_str(&pf->hw,
 						    pf->hw.aq.asq_last_status));
 				pf->udp_ports[i].index = 0;
 			}
-- 
2.5.0
