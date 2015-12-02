From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/17] i40evf: rename VF adapter specific RSS function
Date: Wed,  2 Dec 2015 00:25:23 -0800
Message-ID: <1449044735-68599-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449044735-68599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Helin Zhang <helin.zhang@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:13263 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756580AbbLBIZj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 03:25:39 -0500
In-Reply-To: <1449044735-68599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Helin Zhang <helin.zhang@intel.com>

This patch renames old VF adapter specific RSS function to clarify
its scope.

Change-ID: Ie5253083a44c677ebb7709a8a3a18402ad2dc6a6
Signed-off-by: Helin Zhang <helin.zhang@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 6ad6265..1b38c88 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1295,10 +1295,10 @@ static void i40evf_configure_rss_reg(struct i40evf_adapter *adapter,
 }
 
 /**
- * i40evf_configure_rss - Prepare for RSS
+ * i40evf_init_rss - Prepare for RSS
  * @adapter: board private structure
  **/
-static void i40evf_configure_rss(struct i40evf_adapter *adapter)
+static void i40evf_init_rss(struct i40evf_adapter *adapter)
 {
 	struct i40e_hw *hw = &adapter->hw;
 	u8 seed[I40EVF_HKEY_ARRAY_SIZE];
@@ -1564,7 +1564,7 @@ static void i40evf_watchdog_task(struct work_struct *work)
 		 * PF, so we don't have to set current_op as we will
 		 * not get a response through the ARQ.
 		 */
-		i40evf_configure_rss(adapter);
+		i40evf_init_rss(adapter);
 		adapter->aq_required &= ~I40EVF_FLAG_AQ_CONFIGURE_RSS;
 		goto watchdog_done;
 	}
@@ -2312,7 +2312,7 @@ static void i40evf_init_task(struct work_struct *work)
 		    I40E_VIRTCHNL_VF_OFFLOAD_WB_ON_ITR)
 		adapter->flags |= I40EVF_FLAG_WB_ON_ITR_CAPABLE;
 	if (!RSS_AQ(adapter))
-		i40evf_configure_rss(adapter);
+		i40evf_init_rss(adapter);
 	err = i40evf_request_misc_irq(adapter);
 	if (err)
 		goto err_sw_init;
@@ -2342,7 +2342,7 @@ static void i40evf_init_task(struct work_struct *work)
 		adapter->aq_required |= I40EVF_FLAG_AQ_CONFIGURE_RSS;
 		mod_timer_pending(&adapter->watchdog_timer, jiffies + 1);
 	} else {
-		i40evf_configure_rss(adapter);
+		i40evf_init_rss(adapter);
 	}
 	return;
 restart:
-- 
2.5.0
