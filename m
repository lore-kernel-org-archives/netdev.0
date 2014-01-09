From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] i40e: accept pf to pf adminq messages
Date: Thu,  9 Jan 2014 04:52:19 -0800
Message-ID: <1389271944-26227-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44616 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754623AbaAIMwh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 07:52:37 -0500
In-Reply-To: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The admin queue can be used to send messages among the physical
function interfaces.  This adds the code to handle that case.

Change-ID: I0700fcc47e41433131a381f0eb72fc7b01b6bd87
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index e782db9..4b75de8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4522,10 +4522,13 @@ static void i40e_clean_adminq_subtask(struct i40e_pf *pf)
 			dev_info(&pf->pdev->dev, "ARQ LAN queue overflow event received\n");
 			i40e_handle_lan_overflow_event(pf, &event);
 			break;
+		case i40e_aqc_opc_send_msg_to_peer:
+			dev_info(&pf->pdev->dev, "ARQ: Msg from other pf\n");
+			break;
 		default:
 			dev_info(&pf->pdev->dev,
-				 "ARQ Error: Unknown event %d received\n",
-				 event.desc.opcode);
+				 "ARQ Error: Unknown event 0x%04x received\n",
+				 opcode);
 			break;
 		}
 	} while (pending && (i++ < pf->adminq_work_limit));
-- 
1.8.3.1
