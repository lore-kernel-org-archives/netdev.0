From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] i40e: fix passing wrong error code to i40e_open()
Date: Wed, 21 May 2014 05:01:13 -0700
Message-ID: <1400673673-31626-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jean Sacren <sakiwit@gmail.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3720 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752342AbaEUMBr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 08:01:47 -0400
In-Reply-To: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>

The commit 6c167f582ea9 ("i40e: Refactor and cleanup i40e_open(),
adding i40e_vsi_open()") introduced a new function i40e_vsi_open()
with the regression by a typo. Due to the commit, the wrong error
code would be passed to i40e_open(). Fix this error in
i40e_vsi_open() by turning the macro into a negative value so that
i40e_open() could return the pertinent error code correctly.

Fixes: 6c167f582ea9 ("i40e: Refactor and cleanup i40e_open(), adding i40e_vsi_open()")
Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 0b34e8b..e0e5c6a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4333,7 +4333,7 @@ int i40e_vsi_open(struct i40e_vsi *vsi)
 			 dev_driver_string(&pf->pdev->dev));
 		err = i40e_vsi_request_irq(vsi, int_name);
 	} else {
-		err = EINVAL;
+		err = -EINVAL;
 		goto err_setup_rx;
 	}
 
-- 
1.9.0
