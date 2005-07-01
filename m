From: Radheka Godse <radheka.godse@intel.com>
Subject: [PATCH 2.6.13-rc1 11/17] bonding: add driver name to log messages
Date: Fri, 1 Jul 2005 13:51:49 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0507011350531.17459@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Trivial fix to include DRVNAME in logs printed to /var/log/messages

Signed-off-by: Radheka Godse <radheka.godse@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>

diff -urN -X dontdiff linux-2.6.12post/drivers/net/bonding/bond_3ad.c linux-2.6.12post-sysfs/drivers/net/bonding/bond_3ad.c
--- linux-2.6.12post/drivers/net/bonding/bond_3ad.c	2005-06-28 18:18:03.000000000 -0700
+++ linux-2.6.12post-sysfs/drivers/net/bonding/bond_3ad.c	2005-06-28 18:21:34.000000000 -0700
@@ -1915,7 +1915,8 @@
  	struct aggregator *aggregator;

  	if (bond == NULL) {
-		printk(KERN_ERR "The slave %s is not attached to its bond\n", slave->dev->name);
+		printk(KERN_ERR DRV_NAME ": %s: The slave %s is not attached to its bond\n",
+		       slave->dev->master->name, slave->dev->name);
  		return -1;
  	}

@@ -2085,7 +2086,8 @@
  					// clear the aggregator
  					ad_clear_agg(temp_aggregator);
  					if (select_new_active_agg) {
-						printk(KERN_INFO "Removing an active aggregator\n");
+						printk(KERN_INFO DRV_NAME ": %s: Removing an active aggregator\n",
+						       slave->dev->master->name);
  						// select new active aggregator
  						ad_agg_selection_logic(__get_first_agg(port));
  					}
@@ -2230,8 +2232,9 @@

  	// if slave is null, the whole port is not initialized
  	if (!port->slave) {
-		printk(KERN_WARNING DRV_NAME ": Warning: speed changed for uninitialized port on %s\n",
-		       slave->dev->name);
+		printk(KERN_WARNING DRV_NAME ": Warning: %s: speed "
+		       "changed for uninitialized port on %s\n", 
+		       slave->dev->master->name, slave->dev->name);
  		return;
  	}

@@ -2257,8 +2260,9 @@

  	// if slave is null, the whole port is not initialized
  	if (!port->slave) {
-		printk(KERN_WARNING DRV_NAME ": Warning: duplex changed for uninitialized port on %s\n",
-		       slave->dev->name);
+		printk(KERN_WARNING DRV_NAME ": %s: Warning: duplex changed "
+		       "for uninitialized port on %s\n",
+		       slave->dev->master->name, slave->dev->name);
  		return;
  	}

@@ -2363,7 +2367,8 @@
  	}

  	if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
-		printk(KERN_DEBUG "ERROR: bond_3ad_get_active_agg_info failed\n");
+		printk(KERN_DEBUG DRV_NAME ": %s: Error: "
+		       "bond_3ad_get_active_agg_info failed\n", dev->name);
  		goto out;
  	}

@@ -2372,7 +2377,9 @@

  	if (slaves_in_agg == 0) {
  		/*the aggregator is empty*/
-		printk(KERN_DEBUG "ERROR: active aggregator is empty\n");
+		printk(KERN_DEBUG DRV_NAME ": %s: Error: active "
+		       "aggregator is empty\n",
+		       dev->name);
  		goto out;
  	}

diff -urN -X dontdiff linux-2.6.12post/drivers/net/bonding/bond_main.c linux-2.6.12post-sysfs/drivers/net/bonding/bond_main.c
--- linux-2.6.12post/drivers/net/bonding/bond_main.c	2005-06-28 18:18:03.000000000 -0700
+++ linux-2.6.12post-sysfs/drivers/net/bonding/bond_main.c	2005-06-30 13:53:55.000000000 -0700
@@ -1884,10 +1884,10 @@
  		       new_slave->dev->name);

  		if (bond->params.mode == BOND_MODE_8023AD) {
-			printk(KERN_WARNING
-			       "Operation of 802.3ad mode requires ETHTOOL "
+			printk(KERN_WARNING DRV_NAME
+			       ": %s: Warning: Operation of 802.3ad mode requires ETHTOOL "
  			       "support in base driver for proper aggregator "
-			       "selection.\n");
+			       "selection.\n", bond_dev->name);
  		}
  	}

@@ -2716,8 +2706,11 @@
  			break;
  		default:
  			/* Should not happen */
-			printk(KERN_ERR "bonding: Error: %s  Illegal value (link=%d)\n",
-			       slave->dev->name, slave->link);
+			printk(KERN_ERR DRV_NAME 
+			       ": %s: Error: %s Illegal value (link=%d)\n",
+			       bond_dev->name,
+			       slave->dev->name, 
+			       slave->link);
  			goto out;
  		} /* end of switch (slave->link) */
