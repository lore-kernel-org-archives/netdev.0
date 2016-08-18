From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] i40e: remove a stray unlock
Date: Thu, 18 Aug 2016 14:57:35 -0700
Message-ID: <1471557456-136741-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471557456-136741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:15913 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753119AbcHSAsf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 Aug 2016 20:48:35 -0400
In-Reply-To: <1471557456-136741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>

We shifted the locking around a bit but forgot to delete this unlock so
now it can unlock twice.

Fixes: cd3be169a5ff ('i40e: Move the mutex lock in i40e_client_unregister')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_client.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_client.c b/drivers/net/ethernet/intel/i40e/i40e_client.c
index 90b435c..677dae5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_client.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_client.c
@@ -992,7 +992,6 @@ int i40e_unregister_client(struct i40e_client *client)
 	if (!i40e_client_is_registered(client)) {
 		pr_info("i40e: Client %s has not been registered\n",
 			client->name);
-		mutex_unlock(&i40e_client_mutex);
 		ret = -ENODEV;
 		goto out;
 	}
-- 
2.7.4
