From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] e1000e: Fix not generating an error on invalid load parameter
Date: Sat,  8 Mar 2014 01:25:36 -0800
Message-ID: <1394270741-29926-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <davidx.m.ertman@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:23968 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751545AbaCHJZy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Mar 2014 04:25:54 -0500
In-Reply-To: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <davidx.m.ertman@intel.com>

Valid values for InterruptThrottleRate are 10-100000, or one of
0, 1, 3, 4.  '2' is not valid.  This is a legacy from the branching
from the e1000 driver code that e1000e was based from.

Prior to this patch, if the e1000e driver  was loaded with a forced
invalid InterruptThrottleRate of '2', then no throttle rate would be
set and no error message generated.

Now, a message will be generated that an invalid value was used and the
value for InterruptThrottleRate will be set to the default value.

Signed-off-by: Dave Ertman <davidx.m.ertman@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/param.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/param.c b/drivers/net/ethernet/intel/e1000e/param.c
index 01797b7..d0ac0f3 100644
--- a/drivers/net/ethernet/intel/e1000e/param.c
+++ b/drivers/net/ethernet/intel/e1000e/param.c
@@ -374,6 +374,12 @@ void e1000e_check_options(struct e1000_adapter *adapter)
 				 "%s set to dynamic mode\n", opt.name);
 			adapter->itr = 20000;
 			break;
+		case 2:
+			dev_info(&adapter->pdev->dev,
+				 "%s Invalid mode - setting default\n",
+				 opt.name);
+			adapter->itr_setting = opt.def;
+			/* fall-through */
 		case 3:
 			dev_info(&adapter->pdev->dev,
 				 "%s set to dynamic conservative mode\n",
-- 
1.8.3.1
