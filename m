From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/12] i40e: only warn once of PTP nonsupport in 100Mbit speed
Date: Fri, 14 Nov 2014 22:08:24 -0800
Message-ID: <1416031715-32498-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4893 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751056AbaKOGIi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Nov 2014 01:08:38 -0500
In-Reply-To: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Only warn once that PTP is not supported when linked at 100Mbit.

Yes, using a static this way means that this once-only message is not
port specific, but once only for the life of the driver, regardless of
the number of ports.  That should be plenty.

Change-ID: Ie6476530056df408452e195ef06afd4f57caa4b2
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ptp.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index 537b621..f9151037 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -382,11 +382,17 @@ void i40e_ptp_set_increment(struct i40e_pf *pf)
 		incval = I40E_PTP_1GB_INCVAL;
 		break;
 	case I40E_LINK_SPEED_100MB:
-		dev_warn(&pf->pdev->dev,
-			 "%s: 1588 functionality is not supported at 100 Mbps. Stopping the PHC.\n",
-			 __func__);
+	{
+		static int warn_once;
+
+		if (!warn_once) {
+			dev_warn(&pf->pdev->dev,
+				 "1588 functionality is not supported at 100 Mbps. Stopping the PHC.\n");
+			warn_once++;
+		}
 		incval = 0;
 		break;
+	}
 	case I40E_LINK_SPEED_40GB:
 	default:
 		incval = I40E_PTP_40GB_INCVAL;
-- 
1.9.3
