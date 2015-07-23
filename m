From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] e1000e: Cleanup qos request in error handling of e1000_open
Date: Thu, 23 Jul 2015 06:52:31 -0700
Message-ID: <1437659564-48822-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1437659564-48822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jia-Ju Bai <baijiaju1990@163.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:45580 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752542AbbGWNwr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 09:52:47 -0400
In-Reply-To: <1437659564-48822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jia-Ju Bai <baijiaju1990@163.com>

The driver lacks pm_qos_remove_request in error handling (err_req_irq) of
e1000_open, and qos request inserted by pm_qos_add_request is not removed.
This patch add pm_qos_remove_request in error handling to fix it.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 89d788d..fea1601 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4588,6 +4588,7 @@ static int e1000_open(struct net_device *netdev)
 	return 0;
 
 err_req_irq:
+	pm_qos_remove_request(&adapter->pm_qos_req);
 	e1000e_release_hw_control(adapter);
 	e1000_power_down_phy(adapter);
 	e1000e_free_rx_resources(adapter->rx_ring);
-- 
2.4.3
