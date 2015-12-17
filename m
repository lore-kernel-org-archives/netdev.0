From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next] nfp: call netif_carrier_off() during init
Date: Thu, 17 Dec 2015 14:18:44 +0000
Message-ID: <1450361924-25223-1-git-send-email-jakub.kicinski@netronome.com>
Cc: simon.horman@netronome.com, rolf.neugebauer@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:36328 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934159AbbLQOSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 09:18:50 -0500
Received: by mail-wm0-f48.google.com with SMTP id p187so23163900wmp.1
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2015 06:18:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Netdevs default to carrier on, we should call netif_carrier_off()
during initialization since we handle carrier state changes in the
driver.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Rolf Neugebauer <rolf.neugebauer@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 6c5af4cb5bdc..43c618bafdb6 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2417,6 +2417,7 @@ int nfp_net_netdev_init(struct net_device *netdev)
 	ether_setup(netdev);
 	netdev->netdev_ops = &nfp_net_netdev_ops;
 	netdev->watchdog_timeo = msecs_to_jiffies(5 * 1000);
+	netif_carrier_off(netdev);
 
 	nfp_net_set_ethtool_ops(netdev);
 	nfp_net_irqs_assign(netdev);
-- 
1.9.1
