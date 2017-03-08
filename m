From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 2/5] bonding: initialize work-queues during creation of bond
Date: Wed,  8 Mar 2017 10:55:54 -0800
Message-ID: <20170308185554.23001-1-mahesh@bandewar.net>
Cc: netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Veaceslav Falico <vfalico@gmail.com>,
        Nikolay Aleksandrov <nikolay@redhat.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33711 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753829AbdCHTU7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 14:20:59 -0500
Received: by mail-pg0-f66.google.com with SMTP id 77so4265160pgc.0
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 11:20:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

Initializing work-queues every time ifup operation performed is unnecessary
and can be performed only once when the port is created.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 619f0c65f18a..1329110ed85f 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3270,8 +3270,6 @@ static int bond_open(struct net_device *bond_dev)
 		}
 	}
 
-	bond_work_init_all(bond);
-
 	if (bond_is_lb(bond)) {
 		/* bond_alb_initialize must be called before the timer
 		 * is started.
@@ -4691,6 +4689,8 @@ int bond_create(struct net *net, const char *name)
 
 	netif_carrier_off(bond_dev);
 
+	bond_work_init_all(bond);
+
 	rtnl_unlock();
 	if (res < 0)
 		bond_destructor(bond_dev);
-- 
2.12.0.246.ga2ecc84866-goog
