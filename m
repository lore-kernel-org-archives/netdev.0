From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/14] i40e: don't check params until after checking for client instance
Date: Sat, 11 Feb 2017 21:30:15 -0800
Message-ID: <20170212053028.98581-2-jeffrey.t.kirsher@intel.com>
References: <20170212053028.98581-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:30258 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750717AbdBLFab (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 00:30:31 -0500
In-Reply-To: <20170212053028.98581-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

We can avoid the minor bit of work by calling check params after we
check for the client instance, since we're about to return early in
cases where we do not have a client.

Change-ID: I56f8ea2ba48d4f571fa331c9ace50819a022fa1c
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_client.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_client.c b/drivers/net/ethernet/intel/i40e/i40e_client.c
index 7ca048f..f6409f9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_client.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_client.c
@@ -174,8 +174,6 @@ void i40e_notify_client_of_l2_param_changes(struct i40e_vsi *vsi)
 
 	if (!vsi)
 		return;
-	memset(&params, 0, sizeof(params));
-	i40e_client_get_params(vsi, &params);
 	mutex_lock(&i40e_client_instance_mutex);
 	list_for_each_entry(cdev, &i40e_client_instances, list) {
 		if (cdev->lan_info.pf == vsi->back) {
@@ -186,6 +184,8 @@ void i40e_notify_client_of_l2_param_changes(struct i40e_vsi *vsi)
 					"Cannot locate client instance l2_param_change routine\n");
 				continue;
 			}
+	memset(&params, 0, sizeof(params));
+	i40e_client_get_params(vsi, &params);
 			if (!test_bit(__I40E_CLIENT_INSTANCE_OPENED,
 				      &cdev->state)) {
 				dev_dbg(&vsi->back->pdev->dev, "Client is not open, abort l2 param change\n");
-- 
2.10.2
