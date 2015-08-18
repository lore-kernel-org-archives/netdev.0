From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] igb: Fix a deadlock in igb_sriov_reinit
Date: Tue, 18 Aug 2015 14:09:16 -0700
Message-ID: <1439932162-1995-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1439932162-1995-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jia-Ju Bai <baijiaju1990@163.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:61611 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752868AbbHRVJo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 17:09:44 -0400
In-Reply-To: <1439932162-1995-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jia-Ju Bai <baijiaju1990@163.com>

When igb_init_interrupt_scheme in igb_sriov_reinit is failed, the lock
acquired by rtnl_lock() is not released, which causes a deadlock.
This patch adds rtnl_unlock() in error handling to fix it.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 8d22298..17c1c84 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -7413,6 +7413,7 @@ static int igb_resume(struct device *dev)
 
 	if (igb_init_interrupt_scheme(adapter, true)) {
 		dev_err(&pdev->dev, "Unable to allocate memory for queues\n");
+		rtnl_unlock();
 		return -ENOMEM;
 	}
 
-- 
2.4.3
