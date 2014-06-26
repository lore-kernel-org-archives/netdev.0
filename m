From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/14] i40evf: don't stop watchdog if it hasn't started
Date: Thu, 26 Jun 2014 05:13:42 -0700
Message-ID: <1403784834-23301-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403784834-23301-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:10390 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756280AbaFZMO2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2014 08:14:28 -0400
In-Reply-To: <1403784834-23301-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

If the VF driver fails to complete early init, then rmmod can cause a
softlock when the driver tries to stop a watchdog timer that never even
got initialized.

Add a check to see if the timer is actually initialized before stopping
it.

Change-ID: Id9d550aa8838e07f4b02afe7bc017ef983779efc
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index b473172..36b1ad7 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2408,7 +2408,9 @@ static void i40evf_remove(struct pci_dev *pdev)
 		i40evf_reset_interrupt_capability(adapter);
 	}
 
-	del_timer_sync(&adapter->watchdog_timer);
+	if (adapter->watchdog_timer.function)
+		del_timer_sync(&adapter->watchdog_timer);
+
 	flush_scheduled_work();
 
 	if (hw->aq.asq.count)
-- 
1.9.3
