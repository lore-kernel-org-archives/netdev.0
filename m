From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/14] i40e: Clean up dead code
Date: Sat, 11 Feb 2017 21:30:22 -0800
Message-ID: <20170212053028.98581-9-jeffrey.t.kirsher@intel.com>
References: <20170212053028.98581-1-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:30258 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751120AbdBLFad (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 00:30:33 -0500
In-Reply-To: <20170212053028.98581-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

The function i40e_client_prepare() can never return an error. So make it
void and quit checking its return value.

Change-ID: I9ff311e2324dde329eb68648efb2c94aaff856db
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_client.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_client.c b/drivers/net/ethernet/intel/i40e/i40e_client.c
index f6409f9..233627e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_client.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_client.c
@@ -653,13 +653,11 @@ static int i40e_client_release(struct i40e_client *client)
  * i40e_client_prepare - prepare client specific resources
  * @client: pointer to the registered client
  *
- * Return 0 on success or < 0 on error
  **/
-static int i40e_client_prepare(struct i40e_client *client)
+static void i40e_client_prepare(struct i40e_client *client)
 {
 	struct i40e_device *ldev;
 	struct i40e_pf *pf;
-	int ret = 0;
 
 	mutex_lock(&i40e_device_mutex);
 	list_for_each_entry(ldev, &i40e_devices, list) {
@@ -669,7 +667,6 @@ static int i40e_client_prepare(struct i40e_client *client)
 		i40e_service_event_schedule(pf);
 	}
 	mutex_unlock(&i40e_device_mutex);
-	return ret;
 }
 
 /**
@@ -926,13 +923,9 @@ int i40e_register_client(struct i40e_client *client)
 	set_bit(__I40E_CLIENT_REGISTERED, &client->state);
 	mutex_unlock(&i40e_client_mutex);
 
-	if (i40e_client_prepare(client)) {
-		ret = -EIO;
-		goto out;
-	}
+	i40e_client_prepare(client);
 
-	pr_info("i40e: Registered client %s with return code %d\n",
-		client->name, ret);
+	pr_info("i40e: Registered client %s\n", client->name);
 out:
 	return ret;
 }
-- 
2.10.2
