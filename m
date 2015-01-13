From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/15] i40evf: Remove some scary log messages
Date: Tue, 13 Jan 2015 11:58:01 -0800
Message-ID: <1421179093-10932-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421179093-10932-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch A Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52238 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753828AbbAMT6R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 14:58:17 -0500
In-Reply-To: <1421179093-10932-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch A Williams <mitch.a.williams@intel.com>

These messages may be triggered during normal init of the driver if the
PF or FW take a long time to respond. There's nothing really wrong, so
don't freak people out logging messages.

If the communication channel really is dead, then we'll retry a few
times and give up. This will log a different more scary message that
should cause consternation. This allows the user to more easily detect a
genuine failure.

v2: remove un-needed {} based on feedback from Sergei Shtylyov

Change-ID: I6e2b758d4234a3a09c1015c82c8f2442a697cbdb
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c     | 7 +------
 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c | 3 ---
 2 files changed, 1 insertion(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index ee0db59..6c73acf 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2026,12 +2026,8 @@ static void i40evf_init_task(struct work_struct *work)
 		/* aq msg sent, awaiting reply */
 		err = i40evf_verify_api_ver(adapter);
 		if (err) {
-			dev_info(&pdev->dev, "Unable to verify API version (%d), retrying\n",
-				 err);
-			if (err == I40E_ERR_ADMIN_QUEUE_NO_WORK) {
-				dev_info(&pdev->dev, "Resending request\n");
+			if (err == I40E_ERR_ADMIN_QUEUE_NO_WORK)
 				err = i40evf_send_api_ver(adapter);
-			}
 			goto err;
 		}
 		err = i40evf_send_vf_config_msg(adapter);
@@ -2054,7 +2050,6 @@ static void i40evf_init_task(struct work_struct *work)
 		}
 		err = i40evf_get_vf_config(adapter);
 		if (err == I40E_ERR_ADMIN_QUEUE_NO_WORK) {
-			dev_info(&pdev->dev, "Resending VF config request\n");
 			err = i40evf_send_vf_config_msg(adapter);
 			goto err;
 		}
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index 5fde5a7..3aeb633 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -715,9 +715,6 @@ void i40evf_virtchnl_completion(struct i40evf_adapter *adapter,
 		}
 		return;
 	}
-	if (v_opcode != adapter->current_op)
-		dev_info(&adapter->pdev->dev, "Pending op is %d, received %d\n",
-			 adapter->current_op, v_opcode);
 	if (v_retval) {
 		dev_err(&adapter->pdev->dev, "%s: PF returned error %d to our request %d\n",
 			__func__, v_retval, v_opcode);
-- 
1.9.3
