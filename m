From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] i40evf: remove unnecessary error checking against i40evf_up_complete
Date: Tue, 20 Sep 2016 20:43:50 -0700
Message-ID: <1474429432-102772-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bimmy Pujari <bimmy.pujari@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:8873 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754893AbcIUDn7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 23:43:59 -0400
In-Reply-To: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bimmy Pujari <bimmy.pujari@intel.com>

Function i40evf_up_complete() always returns success. Changed this to a
void type and removed the code that checks the return status and prints
an error message.

Change-ID: I8c400f174786b9c855f679e470f35af292fb50ad
Signed-off-by: Bimmy Pujari <bimmy.pujari@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index e0a8cd8..9906775 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1007,7 +1007,7 @@ static void i40evf_configure(struct i40evf_adapter *adapter)
  * i40evf_up_complete - Finish the last steps of bringing up a connection
  * @adapter: board private structure
  **/
-static int i40evf_up_complete(struct i40evf_adapter *adapter)
+static void i40evf_up_complete(struct i40evf_adapter *adapter)
 {
 	adapter->state = __I40EVF_RUNNING;
 	clear_bit(__I40E_DOWN, &adapter->vsi.state);
@@ -1016,7 +1016,6 @@ static int i40evf_up_complete(struct i40evf_adapter *adapter)
 
 	adapter->aq_required |= I40EVF_FLAG_AQ_ENABLE_QUEUES;
 	mod_timer_pending(&adapter->watchdog_timer, jiffies + 1);
-	return 0;
 }
 
 /**
@@ -1827,9 +1826,7 @@ continue_reset:
 
 		i40evf_configure(adapter);
 
-		err = i40evf_up_complete(adapter);
-		if (err)
-			goto reset_err;
+		i40evf_up_complete(adapter);
 
 		i40evf_irq_enable(adapter, true);
 	} else {
@@ -2059,9 +2056,7 @@ static int i40evf_open(struct net_device *netdev)
 	i40evf_add_filter(adapter, adapter->hw.mac.addr);
 	i40evf_configure(adapter);
 
-	err = i40evf_up_complete(adapter);
-	if (err)
-		goto err_req_irq;
+	i40evf_up_complete(adapter);
 
 	i40evf_irq_enable(adapter, true);
 
-- 
2.7.4
