From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/13] i40evf: free rings in remove function
Date: Sat, 18 Feb 2017 22:33:32 -0800
Message-ID: <20170219063341.8039-5-jeffrey.t.kirsher@intel.com>
References: <20170219063341.8039-1-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:39180 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750978AbdBSGeL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 19 Feb 2017 01:34:11 -0500
In-Reply-To: <20170219063341.8039-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

When the i40evf_remove() calls netdev close, the device doesn't actually
close - it schedules the work for the watchdog to perform. Since we're
stopping the watchdog, this work doesn't get done. However, we're
resetting the part, so we can free resources after the reset request has
gone through. This plugs a memory leak.

Change-ID: Id5335dcaf76ce00d2a4c3d26e9faf711d7f051cf
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 920c1cb06a92..5673dbd2cf7d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2871,7 +2871,8 @@ static void i40evf_remove(struct pci_dev *pdev)
 		i40evf_request_reset(adapter);
 		msleep(50);
 	}
-
+	i40evf_free_all_tx_resources(adapter);
+	i40evf_free_all_rx_resources(adapter);
 	i40evf_misc_irq_disable(adapter);
 	i40evf_free_misc_irq(adapter);
 	i40evf_reset_interrupt_capability(adapter);
-- 
2.11.0
