From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 7/10] [bonding 2.6] embed stats struct inside bonding private struct
Date: Thu, 4 Sep 2003 20:45:17 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309042045.17273.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Thu Sep  4 20:18:08 2003
+++ b/drivers/net/bonding/bond_main.c	Thu Sep  4 20:18:09 2003
@@ -3295,10 +3295,10 @@ static int bond_xmit_activebackup(struct
 static struct net_device_stats *bond_get_stats(struct net_device *dev)
 {
 	bonding_t *bond = dev->priv;
-	struct net_device_stats *stats = bond->stats, *sstats;
+	struct net_device_stats *stats = &(bond->stats), *sstats;
 	slave_t *slave;
 
-	memset(bond->stats, 0, sizeof(struct net_device_stats));
+	memset(stats, 0, sizeof(struct net_device_stats));
 
 	read_lock_bh(&bond->lock);
 
@@ -3493,9 +3493,7 @@ static int __init bond_init(struct net_d
 	/* initialize rwlocks */
 	rwlock_init(&bond->lock);
 	rwlock_init(&bond->ptrlock);
-	
-	/* space is reserved for stats in alloc_netdev call. */
-	bond->stats = (struct net_device_stats *)(bond + 1);
+
 	bond->next = bond->prev = (slave_t *)bond;
 	bond->current_slave = NULL;
 	bond->current_arp_slave = NULL;
@@ -3868,8 +3866,7 @@ static int __init bonding_init(void)
 
 		snprintf(name, IFNAMSIZ, "bond%d", no);
 
-		dev = alloc_netdev(sizeof(bonding_t) 
-				   + sizeof(struct net_device_stats),
+		dev = alloc_netdev(sizeof(struct bonding),
 				   name, ether_setup);
 		if (!dev)
 			return -ENOMEM;
diff -Nuarp a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
--- a/drivers/net/bonding/bonding.h	Thu Sep  4 20:18:08 2003
+++ b/drivers/net/bonding/bonding.h	Thu Sep  4 20:18:09 2003
@@ -99,7 +99,7 @@ typedef struct bonding {
 	rwlock_t ptrlock;
 	struct timer_list mii_timer;
 	struct timer_list arp_timer;
-	struct net_device_stats *stats;
+	struct net_device_stats stats;
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry *bond_proc_dir;
 	struct proc_dir_entry *bond_proc_info_file;
