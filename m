From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/13] i40evf: make messages less dire
Date: Fri,  6 Jun 2014 02:04:13 -0700
Message-ID: <1402045462-10304-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402045462-10304-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47817 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752634AbaFFJE5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jun 2014 05:04:57 -0400
In-Reply-To: <1402045462-10304-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Depending on the timing of what the PF driver is doing, it make take a
few tries before the VF driver is able to communicate with the PF driver
on init or reset recovery. In order to prevent confusion, make the most
common messages less scary by lowering them to a less terrifying log
level and indicate that the driver will retry.

Change-ID: I1ec22aa59a68f4469aabe14775a1bfc1ab4b7f2f
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index d24f40f..f6a2bdc 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1963,7 +1963,7 @@ static void i40evf_init_task(struct work_struct *work)
 		}
 		err = i40evf_check_reset_complete(hw);
 		if (err) {
-			dev_err(&pdev->dev, "Device is still in reset (%d)\n",
+			dev_info(&pdev->dev, "Device is still in reset (%d), retrying\n",
 				err);
 			goto err;
 		}
@@ -1996,7 +1996,7 @@ static void i40evf_init_task(struct work_struct *work)
 		/* aq msg sent, awaiting reply */
 		err = i40evf_verify_api_ver(adapter);
 		if (err) {
-			dev_err(&pdev->dev, "Unable to verify API version (%d)\n",
+			dev_info(&pdev->dev, "Unable to verify API version (%d), retrying\n",
 				err);
 			goto err;
 		}
-- 
1.9.3
