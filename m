From: fgao@ikuai8.com
Subject: [PATCH net-next 1/1] driver: ipvlan: Free the port memory directly with kfree instead of kfree_rcu
Date: Tue,  6 Dec 2016 12:29:07 +0800
Message-ID: <1480998547-9013-1-git-send-email-fgao@ikuai8.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, maheshb@google.com, edumazet@google.com,
        netdev@vger.kernel.org, gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg339.qq.com ([14.17.44.34]:49072 "EHLO smtpbg339.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751668AbcLFE3i (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Dec 2016 23:29:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

There is no one which may reference the "port" in ipvlan_port_create
when netdev_rx_handler_register failed. So it could free it directly
with kfree instead of kfree_rcu.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index c6aa667..1a601151 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -128,7 +128,7 @@ static int ipvlan_port_create(struct net_device *dev)
 	return 0;
 
 err:
-	kfree_rcu(port, rcu);
+	kfree(port);
 	return err;
 }
 
-- 
1.9.1
