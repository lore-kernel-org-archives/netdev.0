From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] i40e: Correcting mutex usage in client code
Date: Fri, 19 Aug 2016 23:19:49 -0700
Message-ID: <1471673991-117115-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471673991-117115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Avinash Dayanand <avinash.dayanand@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:64536 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753022AbcHTGwW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 20 Aug 2016 02:52:22 -0400
In-Reply-To: <1471673991-117115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Avinash Dayanand <avinash.dayanand@intel.com>

Correcting the mutex usage, in client_subtask(), mutex_unlock has
to be called just before client_del_instance() since this function opens
and later closes the same mutex again.
Similarly in client_is_registered removing the mutex since it closes
the mutex twice.

This is a patch suggested by RDMA team.

Change-ID: Icce519c266e4221b8a2a72a15ba5bf01750e5852
Signed-off-by: Avinash Dayanand <avinash.dayanand@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_client.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_client.c b/drivers/net/ethernet/intel/i40e/i40e_client.c
index 09a37cf..5404b32 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_client.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_client.c
@@ -576,6 +576,7 @@ void i40e_client_subtask(struct i40e_pf *pf)
 			set_bit(__I40E_CLIENT_INSTANCE_OPENED, &cdev->state);
 		} else {
 			/* remove client instance */
+			mutex_unlock(&i40e_client_instance_mutex);
 			i40e_client_del_instance(pf, client);
 			atomic_dec(&client->ref_cnt);
 			continue;
-- 
2.7.4
