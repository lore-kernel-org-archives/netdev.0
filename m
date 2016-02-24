From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 18/20] igbvf: remove "link is Up" message when registering mcast address
Date: Tue, 23 Feb 2016 20:26:22 -0800
Message-ID: <1456287984-10459-19-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1456287984-10459-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jon Maxwell <jmaxwell37@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:12818 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757509AbcBXE0f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 23:26:35 -0500
In-Reply-To: <1456287984-10459-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maxwell <jmaxwell37@gmail.com>

A similar issue was addressed a few years ago in the following thread:

http://www.spinics.net/lists/netdev/msg245877.html

At that time there were concerns that removing this statement may cause other
side effects. However the submitter addressed those concerns. But the dialogue
went cold. We have a new case where a customers application is registering and
un-registering multicast addresses every few seconds. This is leading to many
"Link is Up" messages in the logs as a result of the
"netif_carrier_off(netdev)" statement called by igbvf_msix_other(). Also on
some kernels it is interfering with the bonding driver causing it to failover
and subsequently affecting connectivity.

The Sourgeforge driver does not make this call and is therefore not affected.
If there were any side effects I would expect that driver to also be affected.
I have tested re-loading the igbvf driver and downing the adapter with the PF
entity on the host where the VM has this patch. When I bring it back up again
connectivity is restored as expected. Therefore I request that this patch gets
submitted.

Signed-off-by: Jon Maxwell <jmaxwell37@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igbvf/netdev.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index aa34865..c124422 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -877,7 +877,6 @@ static irqreturn_t igbvf_msix_other(int irq, void *data)
 
 	adapter->int_counter1++;
 
-	netif_carrier_off(netdev);
 	hw->mac.get_link_status = 1;
 	if (!test_bit(__IGBVF_DOWN, &adapter->state))
 		mod_timer(&adapter->watchdog_timer, jiffies + 1);
-- 
2.5.0
