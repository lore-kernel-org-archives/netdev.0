From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/11] i40evf: properly handle multiple AQ messages
Date: Mon,  3 Nov 2014 06:56:30 -0800
Message-ID: <1415026599-16232-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1415026599-16232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Patrick Lu <patrick.lu@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44867 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752665AbaKCO4z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 09:56:55 -0500
In-Reply-To: <1415026599-16232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

When we receive an admin queue message, the msg_size field in the event
struct gets overwritten. Because of this, we need to reinit the field
each time we go through the loop. Without this we may receive truncated
messages due to the firmware thinking we have insufficient buffer size.

Change-ID: I21dcca5114d91365d731169965ce3ffec0e4a190
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Patrick Lu <patrick.lu@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index dabe6a4..b2f01eb 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1647,10 +1647,8 @@ static void i40evf_adminq_task(struct work_struct *work)
 					   v_msg->v_retval, event.msg_buf,
 					   event.msg_size);
 		if (pending != 0) {
-			dev_info(&adapter->pdev->dev,
-				 "%s: ARQ: Pending events %d\n",
-				 __func__, pending);
 			memset(event.msg_buf, 0, I40EVF_MAX_AQ_BUF_SIZE);
+			event.msg_size = I40EVF_MAX_AQ_BUF_SIZE;
 		}
 	} while (pending);
 
-- 
1.9.3
