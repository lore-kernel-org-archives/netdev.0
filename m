From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next] i40e: add NVM update events to AQ clean
Date: Thu, 19 Mar 2015 14:32:01 -0700
Message-ID: <1426800721-23007-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60105 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750830AbbCSVcE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2015 17:32:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Quit complaining about a couple of events that we actually expect to see
during an NVM update.

Reported-by: Stefan Assmann <sassmann@redhat.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c1eaab5..bc87968 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5896,6 +5896,10 @@ static void i40e_clean_adminq_subtask(struct i40e_pf *pf)
 		case i40e_aqc_opc_send_msg_to_peer:
 			dev_info(&pf->pdev->dev, "ARQ: Msg from other pf\n");
 			break;
+		case i40e_aqc_opc_nvm_erase:
+		case i40e_aqc_opc_nvm_update:
+			i40e_debug(&pf->hw, I40E_DEBUG_NVM, "ARQ NVM operation completed\n");
+			break;
 		default:
 			dev_info(&pf->pdev->dev,
 				 "ARQ Error: Unknown event 0x%04x received\n",
-- 
1.9.3
