From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] net: remove duplicate add_device_randomness() call
Date: Wed, 17 May 2017 17:23:26 +0800
Message-ID: <1495013006-3011-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:52488 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751398AbdEQJfM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 05:35:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since register_netdevice() already call add_device_randomness() and
dev_set_mac_address() will call it after mac address change.
It's not necessary to call at device UP.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 net/core/dev.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 35a06ce..cb48e40 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1347,7 +1347,6 @@ static int __dev_open(struct net_device *dev)
 		dev->flags |= IFF_UP;
 		dev_set_rx_mode(dev);
 		dev_activate(dev);
-		add_device_randomness(dev->dev_addr, dev->addr_len);
 	}
 
 	return ret;
-- 
1.8.3.1
