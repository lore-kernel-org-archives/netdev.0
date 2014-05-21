From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next 1/2] bonding: populate essential new_slave->bond/dev early
Date: Wed, 21 May 2014 17:42:00 +0200
Message-ID: <1400686921-5698-2-git-send-email-vfalico@gmail.com>
References: <1400686921-5698-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17235 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751137AbaEUPqq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 11:46:46 -0400
In-Reply-To: <1400686921-5698-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new bond_free_slave() needs new_slave->bond to verify if additional
structures were allocated, so populate it early so that, in case of failure
in bond_enslave(), we would be able to get it.

Also populate the new_slave->dev field, as it's too one of the most needed
things to assign early.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/bond_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7123205..923cdd5a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1325,6 +1325,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		goto err_undo_flags;
 	}
 
+	new_slave->bond = bond;
+	new_slave->dev = slave_dev;
 	/*
 	 * Set the new_slave's queue_id to be zero.  Queue ID mapping
 	 * is set via sysfs or module option if desired.
@@ -1368,8 +1370,6 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		goto err_restore_mac;
 	}
 
-	new_slave->bond = bond;
-	new_slave->dev = slave_dev;
 	slave_dev->priv_flags |= IFF_BONDING;
 
 	if (bond_is_lb(bond)) {
-- 
1.8.4
