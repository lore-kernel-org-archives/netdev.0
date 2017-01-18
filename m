From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 2/3] ipvlan: use netdev_is_rx_handler_busy instead of checking specific type
Date: Wed, 18 Jan 2017 15:02:53 -0800
Message-ID: <20170118230253.20811-1-mahesh@bandewar.net>
Cc: Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33941 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750846AbdARXKw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 18:10:52 -0500
Received: by mail-pg0-f66.google.com with SMTP id t6so2429468pgt.1
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 15:09:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

IPvlan checks if the master device is already used by checking a
specific device (here it's macvlan device). This is technically not
sufficient and it should just ensure the rx_handler is busy or not.
This would be a super check that includes macvlan and any other that
has already registered rx-handler.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index b5c390f0f2b3..95b18f4602cf 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -102,8 +102,8 @@ static int ipvlan_port_create(struct net_device *dev)
 		return -EINVAL;
 	}
 
-	if (netif_is_macvlan_port(dev)) {
-		netdev_err(dev, "Master is a macvlan port.\n");
+	if (netdev_is_rx_handler_busy(dev)) {
+		netdev_err(dev, "Device is already in use.\n");
 		return -EBUSY;
 	}
 
-- 
2.11.0.483.g087da7b7c-goog
