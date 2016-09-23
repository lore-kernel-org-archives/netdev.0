From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 10/10] i40evf: remove unnecessary error checking against i40e_shutdown_adminq
Date: Thu, 22 Sep 2016 22:45:42 -0700
Message-ID: <1474609542-121940-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474609542-121940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Lihong Yang <lihong.yang@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:40400 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754378AbcIWFpt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 01:45:49 -0400
In-Reply-To: <1474609542-121940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lihong Yang <lihong.yang@intel.com>

The i40e_shutdown_adminq function never returns failure. There is no need to
check the non-0 return value. Clean up the unnecessary error checking and
warning against it.

Change-ID: Ibb616f09cfb93bd1a872ebf3241a15fb8354b31b
Signed-off-by: Lihong Yang <lihong.yang@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 9906775..99833f3 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1785,8 +1785,7 @@ continue_reset:
 	i40evf_free_all_tx_resources(adapter);
 
 	/* kill and reinit the admin queue */
-	if (i40evf_shutdown_adminq(hw))
-		dev_warn(&adapter->pdev->dev, "Failed to shut down adminq\n");
+	i40evf_shutdown_adminq(hw);
 	adapter->current_op = I40E_VIRTCHNL_OP_UNKNOWN;
 	err = i40evf_init_adminq(hw);
 	if (err)
-- 
2.7.4
