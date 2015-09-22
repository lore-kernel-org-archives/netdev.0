From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/17] e1000e: Enable TSO for stacked VLAN
Date: Tue, 22 Sep 2015 16:54:29 -0700
Message-ID: <1442966076-14359-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:50474 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934926AbbIVXyl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 19:54:41 -0400
In-Reply-To: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Setting ndo_features_check to passthru_features_check allows the driver
to skip the check for multiple tagged TSO packets and enables stacked
VLAN TSO.
Tested with I217-LM.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index faf4b3f..2e2ddec0 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6952,6 +6952,7 @@ static const struct net_device_ops e1000e_netdev_ops = {
 #endif
 	.ndo_set_features = e1000_set_features,
 	.ndo_fix_features = e1000_fix_features,
+	.ndo_features_check	= passthru_features_check,
 };
 
 /**
-- 
2.4.3
