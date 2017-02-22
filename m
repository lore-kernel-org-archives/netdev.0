From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 2/4] bonding: initialize work-queues during creation of bond
Date: Tue, 21 Feb 2017 17:08:25 -0800
Message-ID: <20170222010825.9815-1-mahesh@bandewar.net>
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
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33122 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753484AbdBVBI3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 20:08:29 -0500
Received: by mail-pg0-f68.google.com with SMTP id 5so20835287pgj.0
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 17:08:29 -0800 (PST)
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
index 4e03807bb0d6..b7a344ffc1de 100644
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
@@ -4690,6 +4688,8 @@ int bond_create(struct net *net, const char *name)
 
 	netif_carrier_off(bond_dev);
 
+	bond_work_init_all(bond);
+
 	rtnl_unlock();
 	if (res < 0)
 		bond_destructor(bond_dev);
-- 
2.11.0.483.g087da7b7c-goog
