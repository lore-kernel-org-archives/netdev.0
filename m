From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH] e1000e: Cleanup qos request in error handling of e1000_open
Date: Wed,  3 Jun 2015 10:35:15 +0800
Message-ID: <1433298915-8189-1-git-send-email-baijiaju1990@163.com>
Cc: baijiaju1990@163.com, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-17.163.com ([220.181.12.17]:53655 "EHLO m12-17.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751905AbbFCCfc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2015 22:35:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver lacks pm_qos_remove_request in error handling (err_req_irq)
of e1000_open, and qos request inserted by pm_qos_add_request is not removed.
This patch add pm_qos_remove_request in error handling to fix it.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index c509a5c..f8c0dc4 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4451,6 +4451,7 @@ static int e1000_open(struct net_device *netdev)
 	return 0;
 
 err_req_irq:
+	pm_qos_remove_request(&adapter->pm_qos_req);
 	e1000e_release_hw_control(adapter);
 	e1000_power_down_phy(adapter);
 	e1000e_free_rx_resources(adapter->rx_ring);
-- 
1.7.9.5
