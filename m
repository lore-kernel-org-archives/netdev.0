From: Colin King <colin.king@canonical.com>
Subject: [PATCH] i40e: fix memcpy with swapped arguments
Date: Mon, 20 Mar 2017 14:46:27 +0000
Message-ID: <20170320144627.11524-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:35669 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753509AbdCTOqd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 10:46:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

The current code copies an uninitialized params into
cdev->lan_info.params and then passes the uninitialized params
to the call cdev->client->ops->l2_param_change.  I believe the
order of the source and destination in the memcpy is the wrong
way around and should be swapped.

Detected with static analysis by cppcheck

Fixes: 0ef2d5afb12d ("i40e: KISS the client interface")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/intel/i40e/i40e_client.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_client.c b/drivers/net/ethernet/intel/i40e/i40e_client.c
index a9f0d22a7cf4..191580ed946d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_client.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_client.c
@@ -147,7 +147,7 @@ void i40e_notify_client_of_l2_param_changes(struct i40e_vsi *vsi)
 		dev_dbg(&vsi->back->pdev->dev, "Client is not open, abort l2 param change\n");
 		return;
 	}
-	memcpy(&cdev->lan_info.params, &params, sizeof(struct i40e_params));
+	memcpy(&params, &cdev->lan_info.params, sizeof(struct i40e_params));
 	cdev->client->ops->l2_param_change(&cdev->lan_info, cdev->client,
 					   &params);
 }
-- 
2.11.0
