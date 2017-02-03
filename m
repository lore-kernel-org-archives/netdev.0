From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [next-queu 12/19] i40e: remove unused function
Date: Thu,  2 Feb 2017 23:25:46 -0800
Message-ID: <20170203072553.168372-13-jeffrey.t.kirsher@intel.com>
References: <20170203072553.168372-1-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:23823 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752718AbdBCHZ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 02:25:58 -0500
In-Reply-To: <20170203072553.168372-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

After refactoring the client open and close code, this is no longer
needed. Remove it.

Change-ID: If8e6e32baa354d857c2fd8b2f19404f1786011c4
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h        |  1 -
 drivers/net/ethernet/intel/i40e/i40e_client.c | 35 ---------------------------
 2 files changed, 36 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index cdf812c..fdd9069 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -792,7 +792,6 @@ int i40e_lan_add_device(struct i40e_pf *pf);
 int i40e_lan_del_device(struct i40e_pf *pf);
 void i40e_client_subtask(struct i40e_pf *pf);
 void i40e_notify_client_of_l2_param_changes(struct i40e_vsi *vsi);
-void i40e_notify_client_of_netdev_open(struct i40e_vsi *vsi);
 void i40e_notify_client_of_netdev_close(struct i40e_vsi *vsi, bool reset);
 void i40e_notify_client_of_vf_enable(struct i40e_pf *pf, u32 num_vfs);
 void i40e_notify_client_of_vf_reset(struct i40e_pf *pf, u32 vf_id);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_client.c b/drivers/net/ethernet/intel/i40e/i40e_client.c
index 7fe72ab..7ca048f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_client.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_client.c
@@ -201,41 +201,6 @@ void i40e_notify_client_of_l2_param_changes(struct i40e_vsi *vsi)
 }
 
 /**
- * i40e_notify_client_of_netdev_open - call the client open callback
- * @vsi: the VSI with netdev opened
- *
- * If there is a client to this netdev, call the client with open
- **/
-void i40e_notify_client_of_netdev_open(struct i40e_vsi *vsi)
-{
-	struct i40e_client_instance *cdev;
-	int ret = 0;
-
-	if (!vsi)
-		return;
-	mutex_lock(&i40e_client_instance_mutex);
-	list_for_each_entry(cdev, &i40e_client_instances, list) {
-		if (cdev->lan_info.netdev == vsi->netdev) {
-			if (!cdev->client ||
-			    !cdev->client->ops || !cdev->client->ops->open) {
-				dev_dbg(&vsi->back->pdev->dev,
-					"Cannot locate client instance open routine\n");
-				continue;
-			}
-			if (!(test_bit(__I40E_CLIENT_INSTANCE_OPENED,
-				       &cdev->state))) {
-				ret = cdev->client->ops->open(&cdev->lan_info,
-							      cdev->client);
-				if (!ret)
-					set_bit(__I40E_CLIENT_INSTANCE_OPENED,
-						&cdev->state);
-			}
-		}
-	}
-	mutex_unlock(&i40e_client_instance_mutex);
-}
-
-/**
  * i40e_client_release_qvlist
  * @ldev: pointer to L2 context.
  *
-- 
2.10.2
