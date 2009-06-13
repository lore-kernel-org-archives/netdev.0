From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/9] bonding: initialize before registration
Date: Fri, 12 Jun 2009 22:02:45 -0700
Message-ID: <20090613050421.608811423@vyatta.com>
References: <20090613050243.100086546@vyatta.com>
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Jay Vosburg <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49224 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751698AbZFMFGN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Jun 2009 01:06:13 -0400
Content-Disposition: inline; filename=bond-prereg.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid a unnecessary carrier state transistion that happens when device
is registered.
Lockdep works better if initialization is done before registration as well.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/bonding/bond_main.c	2009-06-12 07:26:44.441927853 -0700
+++ b/drivers/net/bonding/bond_main.c	2009-06-12 07:27:12.459766764 -0700
@@ -5164,15 +5164,15 @@ int bond_create(const char *name)
 		goto out_netdev;
 	}
 
+	bond_set_lockdep_class(bond_dev);
+
+	netif_carrier_off(bond_dev);
+
 	res = register_netdevice(bond_dev);
 	if (res < 0) {
 		goto out_bond;
 	}
 
-	bond_set_lockdep_class(bond_dev);
-
-	netif_carrier_off(bond_dev);
-
 	up_write(&bonding_rwsem);
 	rtnl_unlock(); /* allows sysfs registration of net device */
 	res = bond_create_sysfs_entry(netdev_priv(bond_dev));

-- 

