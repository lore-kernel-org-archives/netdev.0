From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 14/15] i40evf: remove unnecessary else
Date: Thu, 20 Nov 2014 15:09:12 -0800
Message-ID: <1416524953-15161-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416524953-15161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:41156 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757598AbaKTXJX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 18:09:23 -0500
In-Reply-To: <1416524953-15161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Since the if part of this statement contains a break, there's no reason
for the else. Clean up the code and make it more obvious that the delay
happens each time through the loop.

Change-ID: I9292eaf7dd687688bdc401b8bd8d1d14f6944460
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 233710c..8e01009 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1513,8 +1513,7 @@ static void i40evf_reset_task(struct work_struct *work)
 		if ((rstat_val != I40E_VFR_VFACTIVE) &&
 		    (rstat_val != I40E_VFR_COMPLETED))
 			break;
-		else
-			msleep(I40EVF_RESET_WAIT_MS);
+		msleep(I40EVF_RESET_WAIT_MS);
 	}
 	if (i == I40EVF_RESET_WAIT_COUNT) {
 		adapter->flags &= ~I40EVF_FLAG_RESET_PENDING;
@@ -1528,8 +1527,7 @@ static void i40evf_reset_task(struct work_struct *work)
 		if ((rstat_val == I40E_VFR_VFACTIVE) ||
 		    (rstat_val == I40E_VFR_COMPLETED))
 			break;
-		else
-			msleep(I40EVF_RESET_WAIT_MS);
+		msleep(I40EVF_RESET_WAIT_MS);
 	}
 	if (i == I40EVF_RESET_WAIT_COUNT) {
 		struct i40evf_mac_filter *f, *ftmp;
-- 
1.9.3
