From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/16] i40evf: clean up init error messages
Date: Fri, 21 Mar 2014 05:09:54 -0700
Message-ID: <1395403806-29302-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:15182 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965474AbaCUMKM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2014 08:10:12 -0400
In-Reply-To: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Add an error message when the admin queue message never completes, and
fix formatting on another one that was unnecessarily wrapped.

Change-ID: I8b8a4eb7629d741f09357250144023cd4a72231f
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 4d547ab..d3eafa3 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1968,8 +1968,7 @@ static void i40evf_init_task(struct work_struct *work)
 		}
 		err = i40evf_send_api_ver(adapter);
 		if (err) {
-			dev_err(&pdev->dev, "Unable to send to PF (%d)\n",
-				err);
+			dev_err(&pdev->dev, "Unable to send to PF (%d)\n", err);
 			i40evf_shutdown_adminq(hw);
 			goto err;
 		}
@@ -1977,8 +1976,10 @@ static void i40evf_init_task(struct work_struct *work)
 		goto restart;
 		break;
 	case __I40EVF_INIT_VERSION_CHECK:
-		if (!i40evf_asq_done(hw))
+		if (!i40evf_asq_done(hw)) {
+			dev_err(&pdev->dev, "Admin queue command never completed.\n");
 			goto err;
+		}
 
 		/* aq msg sent, awaiting reply */
 		err = i40evf_verify_api_ver(adapter);
-- 
1.8.3.1
