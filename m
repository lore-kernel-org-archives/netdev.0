From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH net-next] igbvf: do not force carrier off in igbvf_msix_other()
Date: Thu,  8 Aug 2013 13:56:42 +0200
Message-ID: <1375963002-1624-1-git-send-email-sassmann@kpanic.de>
Cc: e1000-devel@lists.sourceforge.net, davem@davemloft.net,
	alexander.h.duyck@intel.com, carolyn.wyborny@intel.com,
	jeffrey.t.kirsher@intel.com, gregory.v.rose@intel.com,
	sassmann@kpanic.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23668 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752541Ab3HHL5y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Aug 2013 07:57:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently carrier is forced off in igbvf_msix_other(). This seems
unnecessary and causes multiple calls to igbvf_watchdog_task(), resulting
in multiple link up messages when calling dhclient for example.
[  111.818106] igbvf 0000:00:04.0: Link is Up 1000 Mbps Full Duplex
[  111.819347] IPv6: ADDRCONF(NETDEV_UP): eth5: link is not ready
[  111.820509] IPv6: ADDRCONF(NETDEV_CHANGE): eth5: link becomes ready
[  111.822983] igbvf 0000:00:04.0: Link is Up 1000 Mbps Full Duplex
[  115.152421] igbvf 0000:00:04.0: Link is Up 1000 Mbps Full Duplex
compared to
[ 1040.422161] igbvf 0000:00:04.0: Link is Up 1000 Mbps Full Duplex
[ 1040.423447] IPv6: ADDRCONF(NETDEV_UP): eth5: link is not ready
[ 1040.424622] IPv6: ADDRCONF(NETDEV_CHANGE): eth5: link becomes ready
when this patch is applied.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
---
 drivers/net/ethernet/intel/igbvf/netdev.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 93eb7ee..f041586 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -876,8 +876,6 @@ static irqreturn_t igbvf_msix_other(int irq, void *data)
 
 	adapter->int_counter1++;
 
-	netif_carrier_off(netdev);
-	hw->mac.get_link_status = 1;
 	if (!test_bit(__IGBVF_DOWN, &adapter->state))
 		mod_timer(&adapter->watchdog_timer, jiffies + 1);
 
-- 
1.8.3.1
