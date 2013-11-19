From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/3] igb: Update queue reinit function to call dev_close when init of queues fails
Date: Tue, 19 Nov 2013 07:40:54 -0800
Message-ID: <1384875654-7795-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1384875654-7795-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:11437 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753089Ab3KSPk7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Nov 2013 10:40:59 -0500
In-Reply-To: <1384875654-7795-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch adds a call to dev_close if the queue reinit fails in order
to make clearer to the user that the device is down.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index ebe6370..40320bd 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -7847,6 +7847,7 @@ int igb_reinit_queues(struct igb_adapter *adapter)
 
 	if (igb_init_interrupt_scheme(adapter, true)) {
 		dev_err(&pdev->dev, "Unable to allocate memory for queues\n");
+		dev_close(netdev);
 		return -ENOMEM;
 	}
 
-- 
1.8.3.1
