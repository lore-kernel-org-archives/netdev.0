From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH] atmel: unregister_netdev() on error
Date: Sat, 10 Jul 2010 17:11:47 +0400
Message-ID: <1278767508-10164-1-git-send-email-segooon@gmail.com>
Cc: Simon Kelley <simon@thekelleys.org.uk>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:59856 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754989Ab0GJNMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jul 2010 09:12:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We must unregister registered device if probe_atmel_card() fails.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/wireless/atmel.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index c8f7090..b9334a3 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -1626,7 +1626,7 @@ struct net_device *init_atmel_card(unsigned short irq, unsigned long port,
 
 	if (!probe_atmel_card(dev)) {
 		unregister_netdev(dev);
-		goto err_out_res;
+		goto err_out_unreg;
 	}
 
 	netif_carrier_off(dev);
@@ -1640,6 +1640,9 @@ struct net_device *init_atmel_card(unsigned short irq, unsigned long port,
 
 	return dev;
 
+err_out_unreg:
+	unregister_netdev(dev);
+
 err_out_res:
 	release_region(dev->base_addr, 32);
 err_out_irq:
-- 
1.7.0.4

