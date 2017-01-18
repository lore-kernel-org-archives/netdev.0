From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 3/3] macvlan: use netdev_is_rx_handler_busy instead of checking specific type
Date: Wed, 18 Jan 2017 15:02:55 -0800
Message-ID: <20170118230255.20882-1-mahesh@bandewar.net>
Cc: Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34610 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751077AbdARXLa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 18:11:30 -0500
Received: by mail-pf0-f193.google.com with SMTP id y143so1943940pfb.1
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 15:11:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

netdev_is_rx_handler_busy() check is a superset of netif_is_ipvlan_port()
check and hence should be preferred.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/macvlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 440ab3d8adf7..cbfc1be23a0e 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1110,7 +1110,7 @@ static int macvlan_port_create(struct net_device *dev)
 	if (dev->type != ARPHRD_ETHER || dev->flags & IFF_LOOPBACK)
 		return -EINVAL;
 
-	if (netif_is_ipvlan_port(dev))
+	if (netdev_is_rx_handler_busy(dev))
 		return -EBUSY;
 
 	port = kzalloc(sizeof(*port), GFP_KERNEL);
-- 
2.11.0.483.g087da7b7c-goog
