From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/8] Revert "igb: Fix a deadlock in igb_sriov_reinit"
Date: Wed,  6 Apr 2016 21:37:33 -0700
Message-ID: <1460003853-133949-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1460003853-133949-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Arika Chen <arika.chen@huawei.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:7189 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752451AbcDGEhi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 00:37:38 -0400
In-Reply-To: <1460003853-133949-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arika Chen <arika.chen@huawei.com>

This reverts commit 3eb14ea8d958 ("igb: Fix a deadlock in
igb_sriov_reinit")
It is the same as commit f468adc944ef ("igb: missing rtnl_unlock in
igb_sriov_reinit()")
There is no rtnl_lock() in igb_resume before, rtnl_unlock will cause a
deadlock.

Signed-off-by: Arika Chen <arika.chen@huawei.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index ff0476c..8e96c35 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -7579,7 +7579,6 @@ static int igb_resume(struct device *dev)
 
 	if (igb_init_interrupt_scheme(adapter, true)) {
 		dev_err(&pdev->dev, "Unable to allocate memory for queues\n");
-		rtnl_unlock();
 		return -ENOMEM;
 	}
 
-- 
2.5.5
