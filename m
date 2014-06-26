From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/14] i40e: rename i40e_ptp_enable to i40e_ptp_feature_enable
Date: Thu, 26 Jun 2014 05:13:46 -0700
Message-ID: <1403784834-23301-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403784834-23301-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:10401 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757365AbaFZMO2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2014 08:14:28 -0400
In-Reply-To: <1403784834-23301-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Reduces possible confusion and ambiguity in purpose of the ancillary
feature control entry point function.

Change-ID: I21d773c1a86878f6d061505185b596c788d1b7cc
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ptp.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index 101f439..6f7d73b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -216,7 +216,7 @@ static int i40e_ptp_settime(struct ptp_clock_info *ptp,
 }
 
 /**
- * i40e_ptp_enable - Enable/disable ancillary features of the PHC subsystem
+ * i40e_ptp_feature_enable - Enable/disable ancillary features of the PHC subsystem
  * @ptp: The PTP clock structure
  * @rq: The requested feature to change
  * @on: Enable/disable flag
@@ -224,8 +224,8 @@ static int i40e_ptp_settime(struct ptp_clock_info *ptp,
  * The XL710 does not support any of the ancillary features of the PHC
  * subsystem, so this function may just return.
  **/
-static int i40e_ptp_enable(struct ptp_clock_info *ptp,
-			   struct ptp_clock_request *rq, int on)
+static int i40e_ptp_feature_enable(struct ptp_clock_info *ptp,
+				   struct ptp_clock_request *rq, int on)
 {
 	return -EOPNOTSUPP;
 }
@@ -560,7 +560,7 @@ void i40e_ptp_init(struct i40e_pf *pf)
 	pf->ptp_caps.adjtime = i40e_ptp_adjtime;
 	pf->ptp_caps.gettime = i40e_ptp_gettime;
 	pf->ptp_caps.settime = i40e_ptp_settime;
-	pf->ptp_caps.enable = i40e_ptp_enable;
+	pf->ptp_caps.enable = i40e_ptp_feature_enable;
 
 	/* Attempt to register the clock before enabling the hardware. */
 	pf->ptp_clock = ptp_clock_register(&pf->ptp_caps, &pf->pdev->dev);
-- 
1.9.3
