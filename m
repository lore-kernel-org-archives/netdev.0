From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 5/5] bonding: avoid printing while holding a spinlock
Date: Mon, 27 Mar 2017 11:37:40 -0700
Message-ID: <20170327183740.31056-1-mahesh@bandewar.net>
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
Received: from mail-pg0-f65.google.com ([74.125.83.65]:32818 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752149AbdC0SiL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 14:38:11 -0400
Received: by mail-pg0-f65.google.com with SMTP id 79so15027604pgf.0
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 11:37:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_3ad.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 508713b4e533..c5fd4259da33 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2446,9 +2446,9 @@ void bond_3ad_adapter_speed_duplex_changed(struct slave *slave)
 
 	spin_lock_bh(&slave->bond->mode_lock);
 	ad_update_actor_keys(port, false);
+	spin_unlock_bh(&slave->bond->mode_lock);
 	netdev_dbg(slave->bond->dev, "Port %d slave %s changed speed/duplex\n",
 		   port->actor_port_number, slave->dev->name);
-	spin_unlock_bh(&slave->bond->mode_lock);
 }
 
 /**
@@ -2492,12 +2492,12 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 	agg = __get_first_agg(port);
 	ad_agg_selection_logic(agg, &dummy);
 
+	spin_unlock_bh(&slave->bond->mode_lock);
+
 	netdev_dbg(slave->bond->dev, "Port %d changed link status to %s\n",
 		   port->actor_port_number,
 		   link == BOND_LINK_UP ? "UP" : "DOWN");
 
-	spin_unlock_bh(&slave->bond->mode_lock);
-
 	/* RTNL is held and mode_lock is released so it's safe
 	 * to update slave_array here.
 	 */
-- 
2.12.1.578.ge9c3154ca4-goog
