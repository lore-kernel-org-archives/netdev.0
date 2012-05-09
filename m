From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next] e1000e: Fix merge conflict (net->net-next)
Date: Wed,  9 May 2012 02:23:46 -0700
Message-ID: <1336555426-13934-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9592 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758913Ab2EIJXt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 05:23:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During merge of net to net-next the changes in patch:

e1000e: Fix default interrupt throttle rate not set in NIC HW

got munged in param.c of the e1000e driver.  This rectifies the
merge issues.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

This patch is also available on my net-next tree on kernel.org if you
want to pull this patch.

---
 drivers/net/ethernet/intel/e1000e/param.c |   56 ++++++-----------------------
 1 files changed, 11 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/param.c b/drivers/net/ethernet/intel/e1000e/param.c
index 42444d1..55cc156 100644
--- a/drivers/net/ethernet/intel/e1000e/param.c
+++ b/drivers/net/ethernet/intel/e1000e/param.c
@@ -344,50 +344,16 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 
 		if (num_InterruptThrottleRate > bd) {
 			adapter->itr = InterruptThrottleRate[bd];
-			switch (adapter->itr) {
-			case 0:
-				e_info("%s turned off\n", opt.name);
-				break;
-			case 1:
-				e_info("%s set to dynamic mode\n", opt.name);
-				adapter->itr_setting = adapter->itr;
-				adapter->itr = 20000;
-				break;
-			case 3:
-				e_info("%s set to dynamic conservative mode\n",
-					opt.name);
-				adapter->itr_setting = adapter->itr;
-				adapter->itr = 20000;
-				break;
-			case 4:
-				e_info("%s set to simplified (2000-8000 ints) mode\n",
-				       opt.name);
-				adapter->itr_setting = 4;
-				break;
-			default:
-				/*
-				 * Save the setting, because the dynamic bits
-				 * change itr.
-				 */
-				if (e1000_validate_option(&adapter->itr, &opt,
-							  adapter) &&
-				    (adapter->itr == 3)) {
-					/*
-					 * In case of invalid user value,
-					 * default to conservative mode.
-					 */
-					adapter->itr_setting = adapter->itr;
-					adapter->itr = 20000;
-				} else {
-					/*
-					 * Clear the lower two bits because
-					 * they are used as control.
-					 */
-					adapter->itr_setting =
-						adapter->itr & ~3;
-				}
-				break;
-			}
+
+			/*
+			 * Make sure a message is printed for non-special
+			 * values. And in case of an invalid option, display
+			 * warning, use default and go through itr/itr_setting
+			 * adjustment logic below
+			 */
+			if ((adapter->itr > 4) &&
+			    e1000_validate_option(&adapter->itr, &opt, adapter))
+				adapter->itr = opt.def;
 		} else {
 			/*
 			 * If no option specified, use default value and go
@@ -399,7 +365,7 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 			 * Make sure a message is printed for non-special
 			 * default values
 			 */
-			if (adapter->itr > 40)
+			if (adapter->itr > 4)
 				e_info("%s set to default %d\n", opt.name,
 				       adapter->itr);
 		}
-- 
1.7.7.6
