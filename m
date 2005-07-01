From: Radheka Godse <radheka.godse@intel.com>
Subject: [PATCH 2.6.13-rc1 13/17] bonding: make error messages more consistent
Date: Fri, 1 Jul 2005 13:53:51 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0507011353020.17459@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch attempts to make error reporting more consistent, removes/adds 
newlines as appropriate, adds bonding: <bondname>: prefix if missing 
(especially in alb, ad) messages.

Signed-off-by: Radheka Godse <radheka.godse@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>

diff -urN -X dontdiff linux-2.6.12post/drivers/net/bonding/bond_3ad.c linux-2.6.12post-sysfs/drivers/net/bonding/bond_3ad.c
--- linux-2.6.12post/drivers/net/bonding/bond_3ad.c	2005-06-28 18:18:03.000000000 -0700
+++ linux-2.6.12post-sysfs/drivers/net/bonding/bond_3ad.c	2005-06-28 18:21:34.000000000 -0700
@@ -1198,10 +1198,10 @@
  			// detect loopback situation
  			if (!MAC_ADDRESS_COMPARE(&(lacpdu->actor_system), &(port->actor_system))) {
  				// INFO_RECEIVED_LOOPBACK_FRAMES
-				printk(KERN_ERR DRV_NAME ": An illegal loopback occurred on adapter (%s)\n",
-						port->slave->dev->name);
-				printk(KERN_ERR "Check the configuration to verify that all Adapters "
-						"are connected to 802.3ad compliant switch ports\n");
+				printk(KERN_ERR DRV_NAME ": %s: An illegal loopback occurred on "
+				       "adapter (%s). Check the configuration to verify that all "
+				       "Adapters are connected to 802.3ad compliant switch ports\n",
+				       port->slave->dev->master->name, port->slave->dev->name);
  				__release_rx_machine_lock(port);
  				return;
  			}
diff -urN -X dontdiff linux-2.6.12post/drivers/net/bonding/bond_alb.c linux-2.6.12post-sysfs/drivers/net/bonding/bond_alb.c
--- linux-2.6.12post/drivers/net/bonding/bond_alb.c	2005-06-17 12:48:29.000000000 -0700
+++ linux-2.6.12post-sysfs/drivers/net/bonding/bond_alb.c	2005-06-28 18:21:35.000000000 -0700
@@ -206,7 +206,7 @@
  	new_hashtbl = kmalloc(size, GFP_KERNEL);
  	if (!new_hashtbl) {
  		printk(KERN_ERR DRV_NAME
-		       ": Error: %s: Failed to allocate TLB hash table\n",
+		       ": %s: Error: Failed to allocate TLB hash table\n",
  		       bond->dev->name);
  		return -1;
  	}
@@ -811,7 +798,7 @@
  	new_hashtbl = kmalloc(size, GFP_KERNEL);
  	if (!new_hashtbl) {
  		printk(KERN_ERR DRV_NAME
-		       ": Error: %s: Failed to allocate RLB hash table\n",
+		       ": %s: Error: Failed to allocate RLB hash table\n",
  		       bond->dev->name);
  		return -1;
  	}
diff -urN -X dontdiff linux-2.6.12post/drivers/net/bonding/bond_main.c linux-2.6.12post-sysfs/drivers/net/bonding/bond_main.c
--- linux-2.6.12post/drivers/net/bonding/bond_main.c	2005-06-28 18:18:03.000000000 -0700
+++ linux-2.6.12post-sysfs/drivers/net/bonding/bond_main.c	2005-06-30 13:53:55.000000000 -0700
@@ -919,7 +919,7 @@
  	res = bond_add_vlan(bond, vid);
  	if (res) {
  		printk(KERN_ERR DRV_NAME
-		       ": %s: Failed to add vlan id %d\n",
+		       ": %s: Error: Failed to add vlan id %d\n",
  		       bond_dev->name, vid);
  	}
  }
@@ -953,7 +953,7 @@
  	res = bond_del_vlan(bond, vid);
  	if (res) {
  		printk(KERN_ERR DRV_NAME
-		       ": %s: Failed to remove vlan id %d\n",
+		       ": %s: Error: Failed to remove vlan id %d\n",
  		       bond_dev->name, vid);
  	}
  }
@@ -1690,11 +1698,10 @@

  		if (slave_dev->set_mac_address == NULL) {
  			printk(KERN_ERR DRV_NAME
-			       ": Error: The slave device you specified does "
-			       "not support setting the MAC address.\n");
-			printk(KERN_ERR
+			       ": %s: Error: The slave device you specified does "
+			       "not support setting the MAC address. "
  			       "Your kernel likely does not support slave "
-			       "devices.\n");
+			       "devices.\n", bond_dev->name);

  			res = -EOPNOTSUPP;
  			goto err_undo_flags;
@@ -2059,7 +2058,7 @@
  	if (!(slave_dev->flags & IFF_SLAVE) ||
  	    (slave_dev->master != bond_dev)) {
  		printk(KERN_ERR DRV_NAME
-		       ": Error: %s: cannot release %s.\n",
+		       ": %s: Error: cannot release %s.\n",
  		       bond_dev->name, slave_dev->name);
  		return -EINVAL;
  	}
@@ -4758,7 +4757,7 @@
  	if (max_bonds < 1 || max_bonds > INT_MAX) {
  		printk(KERN_WARNING DRV_NAME
  		       ": Warning: max_bonds (%d) not in range %d-%d, so it "
-		       "was reset to BOND_DEFAULT_MAX_BONDS (%d)",
+		       "was reset to BOND_DEFAULT_MAX_BONDS (%d)\n",
  		       max_bonds, 1, INT_MAX, BOND_DEFAULT_MAX_BONDS);
  		max_bonds = BOND_DEFAULT_MAX_BONDS;
  	}
