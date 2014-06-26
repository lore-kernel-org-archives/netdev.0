From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/14] i40evf: resend FW request if no response
Date: Thu, 26 Jun 2014 05:13:45 -0700
Message-ID: <1403784834-23301-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403784834-23301-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:10421 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757392AbaFZMOc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2014 08:14:32 -0400
In-Reply-To: <1403784834-23301-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Sometimes the firmware will not indicate an error but fail to pass a
message between the VF and the PF driver. If this happens, just resend
the request.

This fixes an initialization failure if many VFs are instantiated at the
same time and the VF module is autoloaded.

Change-ID: Idd1ad8da2fd5137859244685c355941427d317d7
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 7138ab4..8082a9f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2018,6 +2018,10 @@ static void i40evf_init_task(struct work_struct *work)
 		if (err) {
 			dev_info(&pdev->dev, "Unable to verify API version (%d), retrying\n",
 				err);
+			if (err == I40E_ERR_ADMIN_QUEUE_NO_WORK) {
+				dev_info(&pdev->dev, "Resending request\n");
+				err = i40evf_send_api_ver(adapter);
+			}
 			goto err;
 		}
 		err = i40evf_send_vf_config_msg(adapter);
-- 
1.9.3
