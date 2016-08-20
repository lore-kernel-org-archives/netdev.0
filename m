From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] i40e: Initialize pointer in client_release function
Date: Fri, 19 Aug 2016 23:19:47 -0700
Message-ID: <1471673991-117115-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471673991-117115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Harshitha Ramamurthy <harshitha.ramamurthy@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:14738 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751164AbcHTGv5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 20 Aug 2016 02:51:57 -0400
In-Reply-To: <1471673991-117115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harshitha Ramamurthy <harshitha.ramamurthy@intel.com>

The function i40e_client_release has a print statement that uses an
adapter pointer which is not initialized if a previous if statement
is not true. Hence, intialize it in the right place.

Change-ID: I1afdaa2c46771ac42be56edcc41bb56b455b06c8
Signed-off-by: Harshitha Ramamurthy <harshitha.ramamurthy@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_client.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_client.c b/drivers/net/ethernet/intel/i40e/i40e_client.c
index 1035f88..09a37cf 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_client.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_client.c
@@ -662,7 +662,7 @@ int i40e_lan_del_device(struct i40e_pf *pf)
 static int i40e_client_release(struct i40e_client *client)
 {
 	struct i40e_client_instance *cdev, *tmp;
-	struct i40e_pf *pf = NULL;
+	struct i40e_pf *pf;
 	int ret = 0;
 
 	LIST_HEAD(cdevs_tmp);
@@ -672,12 +672,12 @@ static int i40e_client_release(struct i40e_client *client)
 		if (strncmp(cdev->client->name, client->name,
 			    I40E_CLIENT_STR_LENGTH))
 			continue;
+		pf = (struct i40e_pf *)cdev->lan_info.pf;
 		if (test_bit(__I40E_CLIENT_INSTANCE_OPENED, &cdev->state)) {
 			if (atomic_read(&cdev->ref_cnt) > 0) {
 				ret = I40E_ERR_NOT_READY;
 				goto out;
 			}
-			pf = (struct i40e_pf *)cdev->lan_info.pf;
 			if (client->ops && client->ops->close)
 				client->ops->close(&cdev->lan_info, client,
 						   false);
-- 
2.7.4
