From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates
Date: Tue, 23 Oct 2007 21:30:30 -0400
Message-ID: <20071024013030.GA16994@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755839AbXJXBa4@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 MAINTAINERS                      |   31 +--
 drivers/net/Kconfig              |   13 +-
 drivers/net/bonding/bond_3ad.c   |    6 +-
 drivers/net/bonding/bond_3ad.h   |    2 +-
 drivers/net/bonding/bond_alb.c   |  110 ++++--
 drivers/net/bonding/bond_alb.h   |    2 +-
 drivers/net/bonding/bond_main.c  |  330 ++++++++++------
 drivers/net/bonding/bond_sysfs.c |   79 ++---
 drivers/net/bonding/bonding.h    |   14 +-
 drivers/net/cpmac.c              |   31 +-
 drivers/net/defxx.c              |    2 +-
 drivers/net/mipsnet.c            |   44 +--
 drivers/net/mv643xx_eth.c        |  807 +++++++++++++++++++++++++++++++-------
 drivers/net/mv643xx_eth.h        |  370 -----------------
 drivers/net/pasemi_mac.c         |    2 +-
 drivers/net/r8169.c              |  406 +++++++++++++-------
 drivers/net/sky2.c               |    4 +-
 include/linux/mv643xx.h          |  328 +---------------
 include/linux/mv643xx_eth.h      |   31 ++
 include/linux/netdevice.h        |    2 +-
 20 files changed, 1330 insertions(+), 1284 deletions(-)
 delete mode 100644 drivers/net/mv643xx_eth.h
 create mode 100644 include/linux/mv643xx_eth.h

Dale Farnsworth (2):
      mv643xx_eth: Remove obsolete checksum offload comment
      mv643xx_eth: Hook up mv643xx_get_sset_count

Francois Romieu (11):
      r8169: convert bitfield to plain enum mask
      r8169: MSI support
      r8169: remove private net_device_stats structure
      r8169: use the existing symbolic name of vendor PCI ID 0x1259
      r8169: add MAC identifiers
      r8169: remove dead wood
      r8169: make room for more phy init changes
      r8169: phy init for the 8168
      r8169: phy init cleanup
      r8169: update the phy init for the 8168C
      r8169: more phy init for the 8168

Jay Vosburgh (6):
      Convert bonding timers to workqueues
      bonding: Convert balance-rr transmit to new locking
      bonding: Convert miimon to new locking
      bonding: Convert locks to _bh, rework alb locking for new locking
      bonding: Convert more locks to _bh, acquire rtnl, for new locking
      bonding: Acquire correct locks in alb for promisc change

Jeff Garzik (2):
      Update MAINTAINERS to reflect my (jgarzik's) current efforts.
      Remove Andrew Morton from list of net driver maintainers.

Joe Perches (2):
      r8169: add KERN_DEBUG to dprintk (trivial)
      r8169: KERN_XXX vs PFX (trivial)

Lennert Buytenhek (9):
      mv643xx_eth: Split off mv643xx_eth platform device data
      mv643xx_eth: Move ethernet register definitions into private header
      mv643xx_eth: Disable RX/TX byte swapping on little-endian systems
      mv643xx_eth: Enable use on Orion platforms
      mv643xx_eth: Remove SHARED_REGS register address bias
      mv643xx_eth: Remove MV643XX_ETH_ register prefix
      mv643xx_eth: Clean up mv643xx_eth.h
      mv643xx_eth: Remove unused register defines
      mv643xx_eth: Merge drivers/net/mv643xx_eth.h into mv643xx_eth.c

Maciej W. Rozycki (1):
      defxx.c: dfx_bus_init() is __devexit not __devinit

Matteo Croce (1):
      AR7 ethernet: small post-merge cleanups and fixes

Olof Johansson (1):
      pasemi_mac: fix typo

Ralf Baechle (1):
      MIPSnet: Delete all the useless debugging printks.

Stephen Hemminger (1):
      sky2: crash on remove

Ursula Braun (2):
      remove header_ops bug in qeth driver
      s390 MAINTAINERS

diff --git a/MAINTAINERS b/MAINTAINERS
index 40245af..9d0ae8d 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -136,17 +136,6 @@ M:	ajk@iehk.rwth-aachen.de
 L:	linux-hams@vger.kernel.org
 S:	Maintained
 
-8139CP 10/100 FAST ETHERNET DRIVER
-P:	Jeff Garzik
-M:	jgarzik@pobox.com
-S:	Maintained
-
-8139TOO 10/100 FAST ETHERNET DRIVER
-P:	Jeff Garzik
-M:	jgarzik@pobox.com
-W:	http://sourceforge.net/projects/gkernel/
-S:	Maintained
-
 8169 10/100/1000 GIGABIT ETHERNET DRIVER
 P:	Francois Romieu
 M:	romieu@fr.zoreil.com
@@ -1037,12 +1026,6 @@ M:	kernel@wantstofly.org
 L:	netdev@vger.kernel.org
 S:	Maintained
 
-CIRRUS LOGIC GENERIC FBDEV DRIVER
-P:	Jeff Garzik
-M:	jgarzik@pobox.com
-L:	linux-fbdev-devel@lists.sourceforge.net (subscribers-only)
-S:	Odd Fixes
-
 CIRRUS LOGIC EP93XX OHCI USB HOST DRIVER
 P:	Lennert Buytenhek
 M:	kernel@wantstofly.org
@@ -1963,12 +1946,6 @@ M:	adaplas@gmail.com
 L:	linux-fbdev-devel@lists.sourceforge.net (subscribers-only)
 S:	Maintained
 
-INTEL I8XX RANDOM NUMBER GENERATOR SUPPORT
-P:	Jeff Garzik
-M:	jgarzik@pobox.com
-W:	http://sourceforge.net/projects/gkernel/
-S:	Maintained
-
 INTEL IA32 MICROCODE UPDATE SUPPORT
 P:	Tigran Aivazian
 M:	tigran@aivazian.fsnet.co.uk
@@ -2695,8 +2672,6 @@ M:	Paul.Clements@steeleye.com
 S:	Maintained
 
 NETWORK DEVICE DRIVERS
-P:	Andrew Morton
-M:	akpm@linux-foundation.org
 P:	Jeff Garzik
 M:	jgarzik@pobox.com
 L:	netdev@vger.kernel.org
@@ -3248,6 +3223,8 @@ S:	Supported
 S390 NETWORK DRIVERS
 P:	Ursula Braun
 M:	ubraun@linux.vnet.ibm.com
+P:	Frank Blaschka
+M:	blaschka@linux.vnet.ibm.com
 M:	linux390@de.ibm.com
 L:	linux-s390@vger.kernel.org
 W:	http://www.ibm.com/developerworks/linux/linux390/
@@ -4103,10 +4080,6 @@ M:	hirofumi@mail.parknet.co.jp
 L:	linux-kernel@vger.kernel.org
 S:	Maintained
 
-VIA 82Cxxx AUDIO DRIVER (old OSS driver)
-P:	Jeff Garzik
-S:	Odd fixes
-
 VIA RHINE NETWORK DRIVER
 P:	Roger Luethi
 M:	rl@hellgate.ch
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 2538816..86b8641 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2371,13 +2371,16 @@ config UGETH_TX_ON_DEMAND
 	depends on UCC_GETH
 
 config MV643XX_ETH
-	tristate "MV-643XX Ethernet support"
-	depends on MV64360 || MV64X60 || (PPC_MULTIPLATFORM && PPC32)
+	tristate "Marvell Discovery (643XX) and Orion ethernet support"
+	depends on MV64360 || MV64X60 || (PPC_MULTIPLATFORM && PPC32) || ARCH_ORION
 	select MII
 	help
-	  This driver supports the gigabit Ethernet on the Marvell MV643XX
-	  chipset which is used in the Momenco Ocelot C and Jaguar ATX and
-	  Pegasos II, amongst other PPC and MIPS boards.
+	  This driver supports the gigabit ethernet MACs in the
+	  Marvell Discovery PPC/MIPS chipset family (MV643XX) and
+	  in the Marvell Orion ARM SoC family.
+
+	  Some boards that use the Discovery chipset are the Momenco
+	  Ocelot C and Jaguar ATX and Pegasos II.
 
 config QLA3XXX
 	tristate "QLogic QLA3XXX Network Driver Support"
diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 084f029..cb3c6fa 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2076,8 +2076,10 @@ void bond_3ad_unbind_slave(struct slave *slave)
  * times out, and it selects an aggregator for the ports that are yet not
  * related to any aggregator, and selects the active aggregator for a bond.
  */
-void bond_3ad_state_machine_handler(struct bonding *bond)
+void bond_3ad_state_machine_handler(struct work_struct *work)
 {
+	struct bonding *bond = container_of(work, struct bonding,
+					    ad_work.work);
 	struct port *port;
 	struct aggregator *aggregator;
 
@@ -2128,7 +2130,7 @@ void bond_3ad_state_machine_handler(struct bonding *bond)
 	}
 
 re_arm:
-	mod_timer(&(BOND_AD_INFO(bond).ad_timer), jiffies + ad_delta_in_ticks);
+	queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
 out:
 	read_unlock(&bond->lock);
 }
diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
index f165572..b5ee45f 100644
--- a/drivers/net/bonding/bond_3ad.h
+++ b/drivers/net/bonding/bond_3ad.h
@@ -276,7 +276,7 @@ struct ad_slave_info {
 void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution, int lacp_fast);
 int  bond_3ad_bind_slave(struct slave *slave);
 void bond_3ad_unbind_slave(struct slave *slave);
-void bond_3ad_state_machine_handler(struct bonding *bond);
+void bond_3ad_state_machine_handler(struct work_struct *);
 void bond_3ad_adapter_speed_changed(struct slave *slave);
 void bond_3ad_adapter_duplex_changed(struct slave *slave);
 void bond_3ad_handle_link_change(struct slave *slave, char link);
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index aea2217..25b8dbf 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -128,12 +128,12 @@ static inline u8 _simple_hash(const u8 *hash_start, int hash_size)
 
 static inline void _lock_tx_hashtbl(struct bonding *bond)
 {
-	spin_lock(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
+	spin_lock_bh(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
 }
 
 static inline void _unlock_tx_hashtbl(struct bonding *bond)
 {
-	spin_unlock(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
+	spin_unlock_bh(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
 }
 
 /* Caller must hold tx_hashtbl lock */
@@ -305,12 +305,12 @@ static struct slave *tlb_choose_channel(struct bonding *bond, u32 hash_index, u3
 /*********************** rlb specific functions ***************************/
 static inline void _lock_rx_hashtbl(struct bonding *bond)
 {
-	spin_lock(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
+	spin_lock_bh(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
 }
 
 static inline void _unlock_rx_hashtbl(struct bonding *bond)
 {
-	spin_unlock(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
+	spin_unlock_bh(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
 }
 
 /* when an ARP REPLY is received from a client update its info
@@ -472,13 +472,13 @@ static void rlb_clear_slave(struct bonding *bond, struct slave *slave)
 
 	_unlock_rx_hashtbl(bond);
 
-	write_lock(&bond->curr_slave_lock);
+	write_lock_bh(&bond->curr_slave_lock);
 
 	if (slave != bond->curr_active_slave) {
 		rlb_teach_disabled_mac_on_primary(bond, slave->dev->dev_addr);
 	}
 
-	write_unlock(&bond->curr_slave_lock);
+	write_unlock_bh(&bond->curr_slave_lock);
 }
 
 static void rlb_update_client(struct rlb_client_info *client_info)
@@ -959,19 +959,34 @@ static int alb_set_slave_mac_addr(struct slave *slave, u8 addr[], int hw)
 	return 0;
 }
 
-/* Caller must hold bond lock for write or curr_slave_lock for write*/
+/*
+ * Swap MAC addresses between two slaves.
+ *
+ * Called with RTNL held, and no other locks.
+ *
+ */
+
 static void alb_swap_mac_addr(struct bonding *bond, struct slave *slave1, struct slave *slave2)
 {
-	struct slave *disabled_slave = NULL;
 	u8 tmp_mac_addr[ETH_ALEN];
-	int slaves_state_differ;
-
-	slaves_state_differ = (SLAVE_IS_OK(slave1) != SLAVE_IS_OK(slave2));
 
 	memcpy(tmp_mac_addr, slave1->dev->dev_addr, ETH_ALEN);
 	alb_set_slave_mac_addr(slave1, slave2->dev->dev_addr, bond->alb_info.rlb_enabled);
 	alb_set_slave_mac_addr(slave2, tmp_mac_addr, bond->alb_info.rlb_enabled);
 
+}
+
+/*
+ * Send learning packets after MAC address swap.
+ *
+ * Called with RTNL and bond->lock held for read.
+ */
+static void alb_fasten_mac_swap(struct bonding *bond, struct slave *slave1,
+				struct slave *slave2)
+{
+	int slaves_state_differ = (SLAVE_IS_OK(slave1) != SLAVE_IS_OK(slave2));
+	struct slave *disabled_slave = NULL;
+
 	/* fasten the change in the switch */
 	if (SLAVE_IS_OK(slave1)) {
 		alb_send_learning_packets(slave1, slave1->dev->dev_addr);
@@ -1044,7 +1059,9 @@ static void alb_change_hw_addr_on_detach(struct bonding *bond, struct slave *sla
 		}
 
 		if (found) {
+			/* locking: needs RTNL and nothing else */
 			alb_swap_mac_addr(bond, slave, tmp_slave);
+			alb_fasten_mac_swap(bond, slave, tmp_slave);
 		}
 	}
 }
@@ -1375,8 +1392,10 @@ out:
 	return 0;
 }
 
-void bond_alb_monitor(struct bonding *bond)
+void bond_alb_monitor(struct work_struct *work)
 {
+	struct bonding *bond = container_of(work, struct bonding,
+					    alb_work.work);
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 	struct slave *slave;
 	int i;
@@ -1436,16 +1455,16 @@ void bond_alb_monitor(struct bonding *bond)
 
 	/* handle rlb stuff */
 	if (bond_info->rlb_enabled) {
-		/* the following code changes the promiscuity of the
-		 * the curr_active_slave. It needs to be locked with a
-		 * write lock to protect from other code that also
-		 * sets the promiscuity.
-		 */
-		write_lock_bh(&bond->curr_slave_lock);
-
 		if (bond_info->primary_is_promisc &&
 		    (++bond_info->rlb_promisc_timeout_counter >= RLB_PROMISC_TIMEOUT)) {
 
+			/*
+			 * dev_set_promiscuity requires rtnl and
+			 * nothing else.
+			 */
+			read_unlock(&bond->lock);
+			rtnl_lock();
+
 			bond_info->rlb_promisc_timeout_counter = 0;
 
 			/* If the primary was set to promiscuous mode
@@ -1454,9 +1473,10 @@ void bond_alb_monitor(struct bonding *bond)
 			 */
 			dev_set_promiscuity(bond->curr_active_slave->dev, -1);
 			bond_info->primary_is_promisc = 0;
-		}
 
-		write_unlock_bh(&bond->curr_slave_lock);
+			rtnl_unlock();
+			read_lock(&bond->lock);
+		}
 
 		if (bond_info->rlb_rebalance) {
 			bond_info->rlb_rebalance = 0;
@@ -1479,7 +1499,7 @@ void bond_alb_monitor(struct bonding *bond)
 	}
 
 re_arm:
-	mod_timer(&(bond_info->alb_timer), jiffies + alb_delta_in_ticks);
+	queue_delayed_work(bond->wq, &bond->alb_work, alb_delta_in_ticks);
 out:
 	read_unlock(&bond->lock);
 }
@@ -1500,11 +1520,11 @@ int bond_alb_init_slave(struct bonding *bond, struct slave *slave)
 	/* caller must hold the bond lock for write since the mac addresses
 	 * are compared and may be swapped.
 	 */
-	write_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
 
 	res = alb_handle_addr_collision_on_attach(bond, slave);
 
-	write_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 
 	if (res) {
 		return res;
@@ -1569,13 +1589,21 @@ void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char
  * Set the bond->curr_active_slave to @new_slave and handle
  * mac address swapping and promiscuity changes as needed.
  *
- * Caller must hold bond curr_slave_lock for write (or bond lock for write)
+ * If new_slave is NULL, caller must hold curr_slave_lock or
+ * bond->lock for write.
+ *
+ * If new_slave is not NULL, caller must hold RTNL, bond->lock for
+ * read and curr_slave_lock for write.  Processing here may sleep, so
+ * no other locks may be held.
  */
 void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave)
 {
 	struct slave *swap_slave;
 	int i;
 
+	if (new_slave)
+		ASSERT_RTNL();
+
 	if (bond->curr_active_slave == new_slave) {
 		return;
 	}
@@ -1608,6 +1636,19 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 		}
 	}
 
+	/*
+	 * Arrange for swap_slave and new_slave to temporarily be
+	 * ignored so we can mess with their MAC addresses without
+	 * fear of interference from transmit activity.
+	 */
+	if (swap_slave) {
+		tlb_clear_slave(bond, swap_slave, 1);
+	}
+	tlb_clear_slave(bond, new_slave, 1);
+
+	write_unlock_bh(&bond->curr_slave_lock);
+	read_unlock(&bond->lock);
+
 	/* curr_active_slave must be set before calling alb_swap_mac_addr */
 	if (swap_slave) {
 		/* swap mac address */
@@ -1616,11 +1657,23 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 		/* set the new_slave to the bond mac address */
 		alb_set_slave_mac_addr(new_slave, bond->dev->dev_addr,
 				       bond->alb_info.rlb_enabled);
+	}
+
+	read_lock(&bond->lock);
+
+	if (swap_slave) {
+		alb_fasten_mac_swap(bond, swap_slave, new_slave);
+	} else {
 		/* fasten bond mac on new current slave */
 		alb_send_learning_packets(new_slave, bond->dev->dev_addr);
 	}
+
+	write_lock_bh(&bond->curr_slave_lock);
 }
 
+/*
+ * Called with RTNL
+ */
 int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 {
 	struct bonding *bond = bond_dev->priv;
@@ -1657,8 +1710,12 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 		}
 	}
 
+	write_unlock_bh(&bond->curr_slave_lock);
+	read_unlock(&bond->lock);
+
 	if (swap_slave) {
 		alb_swap_mac_addr(bond, swap_slave, bond->curr_active_slave);
+		alb_fasten_mac_swap(bond, swap_slave, bond->curr_active_slave);
 	} else {
 		alb_set_slave_mac_addr(bond->curr_active_slave, bond_dev->dev_addr,
 				       bond->alb_info.rlb_enabled);
@@ -1670,6 +1727,9 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 		}
 	}
 
+	read_lock(&bond->lock);
+	write_lock_bh(&bond->curr_slave_lock);
+
 	return 0;
 }
 
diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
index fd87264..50968f8 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -125,7 +125,7 @@ void bond_alb_deinit_slave(struct bonding *bond, struct slave *slave);
 void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char link);
 void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave);
 int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev);
-void bond_alb_monitor(struct bonding *bond);
+void bond_alb_monitor(struct work_struct *);
 int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr);
 void bond_alb_clear_vlan(struct bonding *bond, unsigned short vlan_id);
 #endif /* __BOND_ALB_H__ */
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6f85cc3..6909bec 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1590,15 +1590,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	case BOND_MODE_TLB:
 	case BOND_MODE_ALB:
 		new_slave->state = BOND_STATE_ACTIVE;
-		if ((!bond->curr_active_slave) &&
-		    (new_slave->link != BOND_LINK_DOWN)) {
-			/* first slave or no active slave yet, and this link
-			 * is OK, so make this interface the active one
-			 */
-			bond_change_active_slave(bond, new_slave);
-		} else {
-			bond_set_slave_inactive_flags(new_slave);
-		}
+		bond_set_slave_inactive_flags(new_slave);
 		break;
 	default:
 		dprintk("This slave is always active in trunk mode\n");
@@ -1754,9 +1746,23 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 		bond_alb_deinit_slave(bond, slave);
 	}
 
-	if (oldcurrent == slave)
+	if (oldcurrent == slave) {
+		/*
+		 * Note that we hold RTNL over this sequence, so there
+		 * is no concern that another slave add/remove event
+		 * will interfere.
+		 */
+		write_unlock_bh(&bond->lock);
+		read_lock(&bond->lock);
+		write_lock_bh(&bond->curr_slave_lock);
+
 		bond_select_active_slave(bond);
 
+		write_unlock_bh(&bond->curr_slave_lock);
+		read_unlock(&bond->lock);
+		write_lock_bh(&bond->lock);
+	}
+
 	if (bond->slave_cnt == 0) {
 		bond_set_carrier(bond);
 
@@ -1840,9 +1846,9 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 */
 void bond_destroy(struct bonding *bond)
 {
+	unregister_netdevice(bond->dev);
 	bond_deinit(bond->dev);
 	bond_destroy_sysfs_entry(bond);
-	unregister_netdevice(bond->dev);
 }
 
 /*
@@ -2012,16 +2018,19 @@ static int bond_ioctl_change_active(struct net_device *bond_dev, struct net_devi
 		return -EINVAL;
 	}
 
-	write_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
 
+	read_lock(&bond->curr_slave_lock);
 	old_active = bond->curr_active_slave;
+	read_unlock(&bond->curr_slave_lock);
+
 	new_active = bond_get_slave_by_dev(bond, slave_dev);
 
 	/*
 	 * Changing to the current active: do nothing; return success.
 	 */
 	if (new_active && (new_active == old_active)) {
-		write_unlock_bh(&bond->lock);
+		read_unlock(&bond->lock);
 		return 0;
 	}
 
@@ -2029,12 +2038,14 @@ static int bond_ioctl_change_active(struct net_device *bond_dev, struct net_devi
 	    (old_active) &&
 	    (new_active->link == BOND_LINK_UP) &&
 	    IS_UP(new_active->dev)) {
+		write_lock_bh(&bond->curr_slave_lock);
 		bond_change_active_slave(bond, new_active);
+		write_unlock_bh(&bond->curr_slave_lock);
 	} else {
 		res = -EINVAL;
 	}
 
-	write_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 
 	return res;
 }
@@ -2046,9 +2057,9 @@ static int bond_info_query(struct net_device *bond_dev, struct ifbond *info)
 	info->bond_mode = bond->params.mode;
 	info->miimon = bond->params.miimon;
 
-	read_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
 	info->num_slaves = bond->slave_cnt;
-	read_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 
 	return 0;
 }
@@ -2063,7 +2074,7 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
 		return -ENODEV;
 	}
 
-	read_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
 
 	bond_for_each_slave(bond, slave, i) {
 		if (i == (int)info->slave_id) {
@@ -2072,7 +2083,7 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
 		}
 	}
 
-	read_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 
 	if (found) {
 		strcpy(info->slave_name, slave->dev->name);
@@ -2088,26 +2099,25 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
 
 /*-------------------------------- Monitoring -------------------------------*/
 
-/* this function is called regularly to monitor each slave's link. */
-void bond_mii_monitor(struct net_device *bond_dev)
+/*
+ * if !have_locks, return nonzero if a failover is necessary.  if
+ * have_locks, do whatever failover activities are needed.
+ *
+ * This is to separate the inspection and failover steps for locking
+ * purposes; failover requires rtnl, but acquiring it for every
+ * inspection is undesirable, so a wrapper first does inspection, and
+ * the acquires the necessary locks and calls again to perform
+ * failover if needed.  Since all locks are dropped, a complete
+ * restart is needed between calls.
+ */
+static int __bond_mii_monitor(struct bonding *bond, int have_locks)
 {
-	struct bonding *bond = bond_dev->priv;
 	struct slave *slave, *oldcurrent;
 	int do_failover = 0;
-	int delta_in_ticks;
 	int i;
 
-	read_lock(&bond->lock);
-
-	delta_in_ticks = (bond->params.miimon * HZ) / 1000;
-
-	if (bond->kill_timers) {
+	if (bond->slave_cnt == 0)
 		goto out;
-	}
-
-	if (bond->slave_cnt == 0) {
-		goto re_arm;
-	}
 
 	/* we will try to read the link status of each of our slaves, and
 	 * set their IFF_RUNNING flag appropriately. For each slave not
@@ -2141,7 +2151,11 @@ void bond_mii_monitor(struct net_device *bond_dev)
 		switch (slave->link) {
 		case BOND_LINK_UP:	/* the link was up */
 			if (link_state == BMSR_LSTATUS) {
-				/* link stays up, nothing more to do */
+				if (!oldcurrent) {
+					if (!have_locks)
+						return 1;
+					do_failover = 1;
+				}
 				break;
 			} else { /* link going down */
 				slave->link  = BOND_LINK_FAIL;
@@ -2156,7 +2170,7 @@ void bond_mii_monitor(struct net_device *bond_dev)
 					       ": %s: link status down for %s "
 					       "interface %s, disabling it in "
 					       "%d ms.\n",
-					       bond_dev->name,
+					       bond->dev->name,
 					       IS_UP(slave_dev)
 					       ? ((bond->params.mode == BOND_MODE_ACTIVEBACKUP)
 						  ? ((slave == oldcurrent)
@@ -2174,6 +2188,9 @@ void bond_mii_monitor(struct net_device *bond_dev)
 			if (link_state != BMSR_LSTATUS) {
 				/* link stays down */
 				if (slave->delay <= 0) {
+					if (!have_locks)
+						return 1;
+
 					/* link down for too long time */
 					slave->link = BOND_LINK_DOWN;
 
@@ -2189,7 +2206,7 @@ void bond_mii_monitor(struct net_device *bond_dev)
 					       ": %s: link status definitely "
 					       "down for interface %s, "
 					       "disabling it\n",
-					       bond_dev->name,
+					       bond->dev->name,
 					       slave_dev->name);
 
 					/* notify ad that the link status has changed */
@@ -2215,7 +2232,7 @@ void bond_mii_monitor(struct net_device *bond_dev)
 				printk(KERN_INFO DRV_NAME
 				       ": %s: link status up again after %d "
 				       "ms for interface %s.\n",
-				       bond_dev->name,
+				       bond->dev->name,
 				       (bond->params.downdelay - slave->delay) * bond->params.miimon,
 				       slave_dev->name);
 			}
@@ -2235,7 +2252,7 @@ void bond_mii_monitor(struct net_device *bond_dev)
 					       ": %s: link status up for "
 					       "interface %s, enabling it "
 					       "in %d ms.\n",
-					       bond_dev->name,
+					       bond->dev->name,
 					       slave_dev->name,
 					       bond->params.updelay * bond->params.miimon);
 				}
@@ -2251,12 +2268,15 @@ void bond_mii_monitor(struct net_device *bond_dev)
 				printk(KERN_INFO DRV_NAME
 				       ": %s: link status down again after %d "
 				       "ms for interface %s.\n",
-				       bond_dev->name,
+				       bond->dev->name,
 				       (bond->params.updelay - slave->delay) * bond->params.miimon,
 				       slave_dev->name);
 			} else {
 				/* link stays up */
 				if (slave->delay == 0) {
+					if (!have_locks)
+						return 1;
+
 					/* now the link has been up for long time enough */
 					slave->link = BOND_LINK_UP;
 					slave->jiffies = jiffies;
@@ -2275,7 +2295,7 @@ void bond_mii_monitor(struct net_device *bond_dev)
 					printk(KERN_INFO DRV_NAME
 					       ": %s: link status definitely "
 					       "up for interface %s.\n",
-					       bond_dev->name,
+					       bond->dev->name,
 					       slave_dev->name);
 
 					/* notify ad that the link status has changed */
@@ -2301,7 +2321,7 @@ void bond_mii_monitor(struct net_device *bond_dev)
 			/* Should not happen */
 			printk(KERN_ERR DRV_NAME
 			       ": %s: Error: %s Illegal value (link=%d)\n",
-			       bond_dev->name,
+			       bond->dev->name,
 			       slave->dev->name,
 			       slave->link);
 			goto out;
@@ -2322,22 +2342,52 @@ void bond_mii_monitor(struct net_device *bond_dev)
 	} /* end of for */
 
 	if (do_failover) {
-		write_lock(&bond->curr_slave_lock);
+		ASSERT_RTNL();
+
+		write_lock_bh(&bond->curr_slave_lock);
 
 		bond_select_active_slave(bond);
 
-		write_unlock(&bond->curr_slave_lock);
+		write_unlock_bh(&bond->curr_slave_lock);
+
 	} else
 		bond_set_carrier(bond);
 
-re_arm:
-	if (bond->params.miimon) {
-		mod_timer(&bond->mii_timer, jiffies + delta_in_ticks);
-	}
 out:
-	read_unlock(&bond->lock);
+	return 0;
 }
 
+/*
+ * bond_mii_monitor
+ *
+ * Really a wrapper that splits the mii monitor into two phases: an
+ * inspection, then (if inspection indicates something needs to be
+ * done) an acquisition of appropriate locks followed by another pass
+ * to implement whatever link state changes are indicated.
+ */
+void bond_mii_monitor(struct work_struct *work)
+{
+	struct bonding *bond = container_of(work, struct bonding,
+					    mii_work.work);
+	unsigned long delay;
+
+	read_lock(&bond->lock);
+	if (bond->kill_timers) {
+		read_unlock(&bond->lock);
+		return;
+	}
+	if (__bond_mii_monitor(bond, 0)) {
+		read_unlock(&bond->lock);
+		rtnl_lock();
+		read_lock(&bond->lock);
+		__bond_mii_monitor(bond, 1);
+		rtnl_unlock();
+	}
+
+	delay = ((bond->params.miimon * HZ) / 1000) ? : 1;
+	read_unlock(&bond->lock);
+	queue_delayed_work(bond->wq, &bond->mii_work, delay);
+}
 
 static __be32 bond_glean_dev_ip(struct net_device *dev)
 {
@@ -2636,9 +2686,10 @@ out:
  * arp is transmitted to generate traffic. see activebackup_arp_monitor for
  * arp monitoring in active backup mode.
  */
-void bond_loadbalance_arp_mon(struct net_device *bond_dev)
+void bond_loadbalance_arp_mon(struct work_struct *work)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = container_of(work, struct bonding,
+					    arp_work.work);
 	struct slave *slave, *oldcurrent;
 	int do_failover = 0;
 	int delta_in_ticks;
@@ -2685,13 +2736,13 @@ void bond_loadbalance_arp_mon(struct net_device *bond_dev)
 					printk(KERN_INFO DRV_NAME
 					       ": %s: link status definitely "
 					       "up for interface %s, ",
-					       bond_dev->name,
+					       bond->dev->name,
 					       slave->dev->name);
 					do_failover = 1;
 				} else {
 					printk(KERN_INFO DRV_NAME
 					       ": %s: interface %s is now up\n",
-					       bond_dev->name,
+					       bond->dev->name,
 					       slave->dev->name);
 				}
 			}
@@ -2715,7 +2766,7 @@ void bond_loadbalance_arp_mon(struct net_device *bond_dev)
 
 				printk(KERN_INFO DRV_NAME
 				       ": %s: interface %s is now down.\n",
-				       bond_dev->name,
+				       bond->dev->name,
 				       slave->dev->name);
 
 				if (slave == oldcurrent) {
@@ -2737,17 +2788,19 @@ void bond_loadbalance_arp_mon(struct net_device *bond_dev)
 	}
 
 	if (do_failover) {
-		write_lock(&bond->curr_slave_lock);
+		rtnl_lock();
+		write_lock_bh(&bond->curr_slave_lock);
 
 		bond_select_active_slave(bond);
 
-		write_unlock(&bond->curr_slave_lock);
+		write_unlock_bh(&bond->curr_slave_lock);
+		rtnl_unlock();
+
 	}
 
 re_arm:
-	if (bond->params.arp_interval) {
-		mod_timer(&bond->arp_timer, jiffies + delta_in_ticks);
-	}
+	if (bond->params.arp_interval)
+		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
 out:
 	read_unlock(&bond->lock);
 }
@@ -2767,9 +2820,10 @@ out:
  * may have received.
  * see loadbalance_arp_monitor for arp monitoring in load balancing mode
  */
-void bond_activebackup_arp_mon(struct net_device *bond_dev)
+void bond_activebackup_arp_mon(struct work_struct *work)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = container_of(work, struct bonding,
+					    arp_work.work);
 	struct slave *slave;
 	int delta_in_ticks;
 	int i;
@@ -2798,7 +2852,9 @@ void bond_activebackup_arp_mon(struct net_device *bond_dev)
 
 				slave->link = BOND_LINK_UP;
 
-				write_lock(&bond->curr_slave_lock);
+				rtnl_lock();
+
+				write_lock_bh(&bond->curr_slave_lock);
 
 				if ((!bond->curr_active_slave) &&
 				    ((jiffies - slave->dev->trans_start) <= delta_in_ticks)) {
@@ -2821,18 +2877,19 @@ void bond_activebackup_arp_mon(struct net_device *bond_dev)
 					printk(KERN_INFO DRV_NAME
 					       ": %s: %s is up and now the "
 					       "active interface\n",
-					       bond_dev->name,
+					       bond->dev->name,
 					       slave->dev->name);
 					netif_carrier_on(bond->dev);
 				} else {
 					printk(KERN_INFO DRV_NAME
 					       ": %s: backup interface %s is "
 					       "now up\n",
-					       bond_dev->name,
+					       bond->dev->name,
 					       slave->dev->name);
 				}
 
-				write_unlock(&bond->curr_slave_lock);
+				write_unlock_bh(&bond->curr_slave_lock);
+				rtnl_unlock();
 			}
 		} else {
 			read_lock(&bond->curr_slave_lock);
@@ -2864,7 +2921,7 @@ void bond_activebackup_arp_mon(struct net_device *bond_dev)
 
 				printk(KERN_INFO DRV_NAME
 				       ": %s: backup interface %s is now down\n",
-				       bond_dev->name,
+				       bond->dev->name,
 				       slave->dev->name);
 			} else {
 				read_unlock(&bond->curr_slave_lock);
@@ -2899,15 +2956,18 @@ void bond_activebackup_arp_mon(struct net_device *bond_dev)
 			printk(KERN_INFO DRV_NAME
 			       ": %s: link status down for active interface "
 			       "%s, disabling it\n",
-			       bond_dev->name,
+			       bond->dev->name,
 			       slave->dev->name);
 
-			write_lock(&bond->curr_slave_lock);
+			rtnl_lock();
+			write_lock_bh(&bond->curr_slave_lock);
 
 			bond_select_active_slave(bond);
 			slave = bond->curr_active_slave;
 
-			write_unlock(&bond->curr_slave_lock);
+			write_unlock_bh(&bond->curr_slave_lock);
+
+			rtnl_unlock();
 
 			bond->current_arp_slave = slave;
 
@@ -2921,14 +2981,17 @@ void bond_activebackup_arp_mon(struct net_device *bond_dev)
 			printk(KERN_INFO DRV_NAME
 			       ": %s: changing from interface %s to primary "
 			       "interface %s\n",
-			       bond_dev->name,
+			       bond->dev->name,
 			       slave->dev->name,
 			       bond->primary_slave->dev->name);
 
 			/* primary is up so switch to it */
-			write_lock(&bond->curr_slave_lock);
+			rtnl_lock();
+			write_lock_bh(&bond->curr_slave_lock);
 			bond_change_active_slave(bond, bond->primary_slave);
-			write_unlock(&bond->curr_slave_lock);
+			write_unlock_bh(&bond->curr_slave_lock);
+
+			rtnl_unlock();
 
 			slave = bond->primary_slave;
 			slave->jiffies = jiffies;
@@ -2985,7 +3048,7 @@ void bond_activebackup_arp_mon(struct net_device *bond_dev)
 					printk(KERN_INFO DRV_NAME
 					       ": %s: backup interface %s is "
 					       "now down.\n",
-					       bond_dev->name,
+					       bond->dev->name,
 					       slave->dev->name);
 				}
 			}
@@ -2994,7 +3057,7 @@ void bond_activebackup_arp_mon(struct net_device *bond_dev)
 
 re_arm:
 	if (bond->params.arp_interval) {
-		mod_timer(&bond->arp_timer, jiffies + delta_in_ticks);
+		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
 	}
 out:
 	read_unlock(&bond->lock);
@@ -3015,7 +3078,7 @@ static void *bond_info_seq_start(struct seq_file *seq, loff_t *pos)
 
 	/* make sure the bond won't be taken away */
 	read_lock(&dev_base_lock);
-	read_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
 
 	if (*pos == 0) {
 		return SEQ_START_TOKEN;
@@ -3049,7 +3112,7 @@ static void bond_info_seq_stop(struct seq_file *seq, void *v)
 {
 	struct bonding *bond = seq->private;
 
-	read_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 	read_unlock(&dev_base_lock);
 }
 
@@ -3582,15 +3645,11 @@ static int bond_xmit_hash_policy_l2(struct sk_buff *skb,
 static int bond_open(struct net_device *bond_dev)
 {
 	struct bonding *bond = bond_dev->priv;
-	struct timer_list *mii_timer = &bond->mii_timer;
-	struct timer_list *arp_timer = &bond->arp_timer;
 
 	bond->kill_timers = 0;
 
 	if ((bond->params.mode == BOND_MODE_TLB) ||
 	    (bond->params.mode == BOND_MODE_ALB)) {
-		struct timer_list *alb_timer = &(BOND_ALB_INFO(bond).alb_timer);
-
 		/* bond_alb_initialize must be called before the timer
 		 * is started.
 		 */
@@ -3599,44 +3658,31 @@ static int bond_open(struct net_device *bond_dev)
 			return -1;
 		}
 
-		init_timer(alb_timer);
-		alb_timer->expires  = jiffies + 1;
-		alb_timer->data     = (unsigned long)bond;
-		alb_timer->function = (void *)&bond_alb_monitor;
-		add_timer(alb_timer);
+		INIT_DELAYED_WORK(&bond->alb_work, bond_alb_monitor);
+		queue_delayed_work(bond->wq, &bond->alb_work, 0);
 	}
 
 	if (bond->params.miimon) {  /* link check interval, in milliseconds. */
-		init_timer(mii_timer);
-		mii_timer->expires  = jiffies + 1;
-		mii_timer->data     = (unsigned long)bond_dev;
-		mii_timer->function = (void *)&bond_mii_monitor;
-		add_timer(mii_timer);
+		INIT_DELAYED_WORK(&bond->mii_work, bond_mii_monitor);
+		queue_delayed_work(bond->wq, &bond->mii_work, 0);
 	}
 
 	if (bond->params.arp_interval) {  /* arp interval, in milliseconds. */
-		init_timer(arp_timer);
-		arp_timer->expires  = jiffies + 1;
-		arp_timer->data     = (unsigned long)bond_dev;
-		if (bond->params.mode == BOND_MODE_ACTIVEBACKUP) {
-			arp_timer->function = (void *)&bond_activebackup_arp_mon;
-		} else {
-			arp_timer->function = (void *)&bond_loadbalance_arp_mon;
-		}
+		if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
+			INIT_DELAYED_WORK(&bond->arp_work,
+					  bond_activebackup_arp_mon);
+		else
+			INIT_DELAYED_WORK(&bond->arp_work,
+					  bond_loadbalance_arp_mon);
+
+		queue_delayed_work(bond->wq, &bond->arp_work, 0);
 		if (bond->params.arp_validate)
 			bond_register_arp(bond);
-
-		add_timer(arp_timer);
 	}
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
-		struct timer_list *ad_timer = &(BOND_AD_INFO(bond).ad_timer);
-		init_timer(ad_timer);
-		ad_timer->expires  = jiffies + 1;
-		ad_timer->data     = (unsigned long)bond;
-		ad_timer->function = (void *)&bond_3ad_state_machine_handler;
-		add_timer(ad_timer);
-
+		INIT_DELAYED_WORK(&bond->ad_work, bond_alb_monitor);
+		queue_delayed_work(bond->wq, &bond->ad_work, 0);
 		/* register to receive LACPDUs */
 		bond_register_lacpdu(bond);
 	}
@@ -3664,25 +3710,21 @@ static int bond_close(struct net_device *bond_dev)
 
 	write_unlock_bh(&bond->lock);
 
-	/* del_timer_sync must run without holding the bond->lock
-	 * because a running timer might be trying to hold it too
-	 */
-
 	if (bond->params.miimon) {  /* link check interval, in milliseconds. */
-		del_timer_sync(&bond->mii_timer);
+		cancel_delayed_work(&bond->mii_work);
 	}
 
 	if (bond->params.arp_interval) {  /* arp interval, in milliseconds. */
-		del_timer_sync(&bond->arp_timer);
+		cancel_delayed_work(&bond->arp_work);
 	}
 
 	switch (bond->params.mode) {
 	case BOND_MODE_8023AD:
-		del_timer_sync(&(BOND_AD_INFO(bond).ad_timer));
+		cancel_delayed_work(&bond->ad_work);
 		break;
 	case BOND_MODE_TLB:
 	case BOND_MODE_ALB:
-		del_timer_sync(&(BOND_ALB_INFO(bond).alb_timer));
+		cancel_delayed_work(&bond->alb_work);
 		break;
 	default:
 		break;
@@ -3779,13 +3821,13 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 		if (mii->reg_num == 1) {
 			struct bonding *bond = bond_dev->priv;
 			mii->val_out = 0;
-			read_lock_bh(&bond->lock);
+			read_lock(&bond->lock);
 			read_lock(&bond->curr_slave_lock);
 			if (netif_carrier_ok(bond->dev)) {
 				mii->val_out = BMSR_LSTATUS;
 			}
 			read_unlock(&bond->curr_slave_lock);
-			read_unlock_bh(&bond->lock);
+			read_unlock(&bond->lock);
 		}
 
 		return 0;
@@ -4077,8 +4119,7 @@ static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev
 {
 	struct bonding *bond = bond_dev->priv;
 	struct slave *slave, *start_at;
-	int i;
-	int res = 1;
+	int i, slave_no, res = 1;
 
 	read_lock(&bond->lock);
 
@@ -4086,29 +4127,29 @@ static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev
 		goto out;
 	}
 
-	read_lock(&bond->curr_slave_lock);
-	slave = start_at = bond->curr_active_slave;
-	read_unlock(&bond->curr_slave_lock);
+	/*
+	 * Concurrent TX may collide on rr_tx_counter; we accept that
+	 * as being rare enough not to justify using an atomic op here
+	 */
+	slave_no = bond->rr_tx_counter++ % bond->slave_cnt;
 
-	if (!slave) {
-		goto out;
+	bond_for_each_slave(bond, slave, i) {
+		slave_no--;
+		if (slave_no < 0) {
+			break;
+		}
 	}
 
+	start_at = slave;
 	bond_for_each_slave_from(bond, slave, i, start_at) {
 		if (IS_UP(slave->dev) &&
 		    (slave->link == BOND_LINK_UP) &&
 		    (slave->state == BOND_STATE_ACTIVE)) {
 			res = bond_dev_queue_xmit(bond, skb, slave->dev);
-
-			write_lock(&bond->curr_slave_lock);
-			bond->curr_active_slave = slave->next;
-			write_unlock(&bond->curr_slave_lock);
-
 			break;
 		}
 	}
 
-
 out:
 	if (res) {
 		/* no suitable interface, frame not sent */
@@ -4340,6 +4381,10 @@ static int bond_init(struct net_device *bond_dev, struct bond_params *params)
 
 	bond->params = *params; /* copy params struct */
 
+	bond->wq = create_singlethread_workqueue(bond_dev->name);
+	if (!bond->wq)
+		return -ENOMEM;
+
 	/* Initialize pointers */
 	bond->first_slave = NULL;
 	bond->curr_active_slave = NULL;
@@ -4428,8 +4473,8 @@ static void bond_free_all(void)
 		bond_mc_list_destroy(bond);
 		/* Release the bonded slaves */
 		bond_release_all(bond_dev);
-		bond_deinit(bond_dev);
 		unregister_netdevice(bond_dev);
+		bond_deinit(bond_dev);
 	}
 
 #ifdef CONFIG_PROC_FS
@@ -4826,10 +4871,32 @@ out_rtnl:
 	return res;
 }
 
+static void bond_work_cancel_all(struct bonding *bond)
+{
+	write_lock_bh(&bond->lock);
+	bond->kill_timers = 1;
+	write_unlock_bh(&bond->lock);
+
+	if (bond->params.miimon && delayed_work_pending(&bond->mii_work))
+		cancel_delayed_work(&bond->mii_work);
+
+	if (bond->params.arp_interval && delayed_work_pending(&bond->arp_work))
+		cancel_delayed_work(&bond->arp_work);
+
+	if (bond->params.mode == BOND_MODE_ALB &&
+	    delayed_work_pending(&bond->alb_work))
+		cancel_delayed_work(&bond->alb_work);
+
+	if (bond->params.mode == BOND_MODE_8023AD &&
+	    delayed_work_pending(&bond->ad_work))
+		cancel_delayed_work(&bond->ad_work);
+}
+
 static int __init bonding_init(void)
 {
 	int i;
 	int res;
+	struct bonding *bond, *nxt;
 
 	printk(KERN_INFO "%s", version);
 
@@ -4856,6 +4923,11 @@ static int __init bonding_init(void)
 
 	goto out;
 err:
+	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list) {
+		bond_work_cancel_all(bond);
+		destroy_workqueue(bond->wq);
+	}
+
 	rtnl_lock();
 	bond_free_all();
 	bond_destroy_sysfs();
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 855dc10..7a06ade 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -229,7 +229,7 @@ static ssize_t bonding_show_slaves(struct device *d,
 	int i, res = 0;
 	struct bonding *bond = to_bond(d);
 
-	read_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
 	bond_for_each_slave(bond, slave, i) {
 		if (res > (PAGE_SIZE - IFNAMSIZ)) {
 			/* not enough space for another interface name */
@@ -240,7 +240,7 @@ static ssize_t bonding_show_slaves(struct device *d,
 		}
 		res += sprintf(buf + res, "%s ", slave->dev->name);
 	}
-	read_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 	res += sprintf(buf + res, "\n");
 	res++;
 	return res;
@@ -282,18 +282,18 @@ static ssize_t bonding_store_slaves(struct device *d,
 
 		/* Got a slave name in ifname.  Is it already in the list? */
 		found = 0;
-		read_lock_bh(&bond->lock);
+		read_lock(&bond->lock);
 		bond_for_each_slave(bond, slave, i)
 			if (strnicmp(slave->dev->name, ifname, IFNAMSIZ) == 0) {
 				printk(KERN_ERR DRV_NAME
 				       ": %s: Interface %s is already enslaved!\n",
 				       bond->dev->name, ifname);
 				ret = -EPERM;
-				read_unlock_bh(&bond->lock);
+				read_unlock(&bond->lock);
 				goto out;
 			}
 
-		read_unlock_bh(&bond->lock);
+		read_unlock(&bond->lock);
 		printk(KERN_INFO DRV_NAME ": %s: Adding slave %s.\n",
 		       bond->dev->name, ifname);
 		dev = dev_get_by_name(&init_net, ifname);
@@ -662,12 +662,9 @@ static ssize_t bonding_store_arp_interval(struct device *d,
 		       "%s Disabling MII monitoring.\n",
 		       bond->dev->name, bond->dev->name);
 		bond->params.miimon = 0;
-		/* Kill MII timer, else it brings bond's link down */
-		if (bond->arp_timer.function) {
-			printk(KERN_INFO DRV_NAME
-			": %s: Kill MII timer, else it brings bond's link down...\n",
-		       bond->dev->name);
-			del_timer_sync(&bond->mii_timer);
+		if (delayed_work_pending(&bond->mii_work)) {
+			cancel_delayed_work(&bond->mii_work);
+			flush_workqueue(bond->wq);
 		}
 	}
 	if (!bond->params.arp_targets[0]) {
@@ -682,25 +679,15 @@ static ssize_t bonding_store_arp_interval(struct device *d,
 		 * timer will get fired off when the open function
 		 * is called.
 		 */
-		if (bond->arp_timer.function) {
-			/* The timer's already set up, so fire it off */
-			mod_timer(&bond->arp_timer, jiffies + 1);
-		} else {
-			/* Set up the timer. */
-			init_timer(&bond->arp_timer);
-			bond->arp_timer.expires = jiffies + 1;
-			bond->arp_timer.data =
-				(unsigned long) bond->dev;
-			if (bond->params.mode == BOND_MODE_ACTIVEBACKUP) {
-				bond->arp_timer.function =
-					(void *)
-					&bond_activebackup_arp_mon;
-			} else {
-				bond->arp_timer.function =
-					(void *)
-					&bond_loadbalance_arp_mon;
-			}
-			add_timer(&bond->arp_timer);
+		if (!delayed_work_pending(&bond->arp_work)) {
+			if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
+				INIT_DELAYED_WORK(&bond->arp_work,
+						  bond_activebackup_arp_mon);
+			else
+				INIT_DELAYED_WORK(&bond->arp_work,
+						  bond_loadbalance_arp_mon);
+
+			queue_delayed_work(bond->wq, &bond->arp_work, 0);
 		}
 	}
 
@@ -1056,12 +1043,9 @@ static ssize_t bonding_store_miimon(struct device *d,
 				bond->params.arp_validate =
 					BOND_ARP_VALIDATE_NONE;
 			}
-			/* Kill ARP timer, else it brings bond's link down */
-			if (bond->mii_timer.function) {
-				printk(KERN_INFO DRV_NAME
-				": %s: Kill ARP timer, else it brings bond's link down...\n",
-			       bond->dev->name);
-				del_timer_sync(&bond->arp_timer);
+			if (delayed_work_pending(&bond->arp_work)) {
+				cancel_delayed_work(&bond->arp_work);
+				flush_workqueue(bond->wq);
 			}
 		}
 
@@ -1071,18 +1055,11 @@ static ssize_t bonding_store_miimon(struct device *d,
 			 * timer will get fired off when the open function
 			 * is called.
 			 */
-			if (bond->mii_timer.function) {
-				/* The timer's already set up, so fire it off */
-				mod_timer(&bond->mii_timer, jiffies + 1);
-			} else {
-				/* Set up the timer. */
-				init_timer(&bond->mii_timer);
-				bond->mii_timer.expires = jiffies + 1;
-				bond->mii_timer.data =
-					(unsigned long) bond->dev;
-				bond->mii_timer.function =
-					(void *) &bond_mii_monitor;
-				add_timer(&bond->mii_timer);
+			if (!delayed_work_pending(&bond->mii_work)) {
+				INIT_DELAYED_WORK(&bond->mii_work,
+						  bond_mii_monitor);
+				queue_delayed_work(bond->wq,
+						   &bond->mii_work, 0);
 			}
 		}
 	}
@@ -1156,6 +1133,9 @@ static ssize_t bonding_store_primary(struct device *d,
 	}
 out:
 	write_unlock_bh(&bond->lock);
+
+	rtnl_unlock();
+
 	return count;
 }
 static DEVICE_ATTR(primary, S_IRUGO | S_IWUSR, bonding_show_primary, bonding_store_primary);
@@ -1213,6 +1193,7 @@ static ssize_t bonding_show_active_slave(struct device *d,
 	struct bonding *bond = to_bond(d);
 	int count;
 
+	rtnl_lock();
 
 	read_lock(&bond->curr_slave_lock);
 	curr = bond->curr_active_slave;
@@ -1292,6 +1273,8 @@ static ssize_t bonding_store_active_slave(struct device *d,
 	}
 out:
 	write_unlock_bh(&bond->lock);
+	rtnl_unlock();
+
 	return count;
 
 }
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index b818060..d1ed14b 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -184,8 +184,6 @@ struct bonding {
 	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
 	rwlock_t lock;
 	rwlock_t curr_slave_lock;
-	struct   timer_list mii_timer;
-	struct   timer_list arp_timer;
 	s8       kill_timers;
 	s8	 send_grat_arp;
 	s8	 setup_by_slave;
@@ -199,12 +197,18 @@ struct bonding {
 	int      (*xmit_hash_policy)(struct sk_buff *, struct net_device *, int);
 	__be32   master_ip;
 	u16      flags;
+	u16      rr_tx_counter;
 	struct   ad_bond_info ad_info;
 	struct   alb_bond_info alb_info;
 	struct   bond_params params;
 	struct   list_head vlan_list;
 	struct   vlan_group *vlgrp;
 	struct   packet_type arp_mon_pt;
+	struct   workqueue_struct *wq;
+	struct   delayed_work mii_work;
+	struct   delayed_work arp_work;
+	struct   delayed_work alb_work;
+	struct   delayed_work ad_work;
 };
 
 /**
@@ -307,9 +311,9 @@ int bond_create_slave_symlinks(struct net_device *master, struct net_device *sla
 void bond_destroy_slave_symlinks(struct net_device *master, struct net_device *slave);
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
-void bond_mii_monitor(struct net_device *bond_dev);
-void bond_loadbalance_arp_mon(struct net_device *bond_dev);
-void bond_activebackup_arp_mon(struct net_device *bond_dev);
+void bond_mii_monitor(struct work_struct *);
+void bond_loadbalance_arp_mon(struct work_struct *);
+void bond_activebackup_arp_mon(struct work_struct *);
 void bond_set_mode_ops(struct bonding *bond, int mode);
 int bond_parse_parm(char *mode_arg, struct bond_parm_tbl *tbl);
 void bond_select_active_slave(struct bonding *bond);
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index ae41973..57541d2 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -460,18 +460,11 @@ static int cpmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct cpmac_desc *desc;
 	struct cpmac_priv *priv = netdev_priv(dev);
 
-	if (unlikely(skb_padto(skb, ETH_ZLEN))) {
-		if (netif_msg_tx_err(priv) && net_ratelimit())
-			printk(KERN_WARNING
-			       "%s: tx: padding failed, dropping\n", dev->name);
-		spin_lock(&priv->lock);
-		dev->stats.tx_dropped++;
-		spin_unlock(&priv->lock);
-		return -ENOMEM;
-	}
+	if (unlikely(skb_padto(skb, ETH_ZLEN)))
+		return NETDEV_TX_OK;
 
 	len = max(skb->len, ETH_ZLEN);
-	queue = skb_get_queue_mapping(skb);
+	queue = skb->queue_mapping;
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	netif_stop_subqueue(dev, queue);
 #else
@@ -481,13 +474,9 @@ static int cpmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	desc = &priv->desc_ring[queue];
 	if (unlikely(desc->dataflags & CPMAC_OWN)) {
 		if (netif_msg_tx_err(priv) && net_ratelimit())
-			printk(KERN_WARNING "%s: tx dma ring full, dropping\n",
+			printk(KERN_WARNING "%s: tx dma ring full\n",
 			       dev->name);
-		spin_lock(&priv->lock);
-		dev->stats.tx_dropped++;
-		spin_unlock(&priv->lock);
-		dev_kfree_skb_any(skb);
-		return -ENOMEM;
+		return NETDEV_TX_BUSY;
 	}
 
 	spin_lock(&priv->lock);
@@ -509,7 +498,7 @@ static int cpmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		cpmac_dump_skb(dev, skb);
 	cpmac_write(priv->regs, CPMAC_TX_PTR(queue), (u32)desc->mapping);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void cpmac_end_xmit(struct net_device *dev, int queue)
@@ -646,12 +635,14 @@ static void cpmac_clear_tx(struct net_device *dev)
 	int i;
 	if (unlikely(!priv->desc_ring))
 		return;
-	for (i = 0; i < CPMAC_QUEUES; i++)
+	for (i = 0; i < CPMAC_QUEUES; i++) {
+		priv->desc_ring[i].dataflags = 0;
 		if (priv->desc_ring[i].skb) {
 			dev_kfree_skb_any(priv->desc_ring[i].skb);
 			if (netif_subqueue_stopped(dev, i))
 			    netif_wake_subqueue(dev, i);
 		}
+	}
 }
 
 static void cpmac_hw_error(struct work_struct *work)
@@ -727,11 +718,13 @@ static void cpmac_tx_timeout(struct net_device *dev)
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	for (i = 0; i < CPMAC_QUEUES; i++)
 		if (priv->desc_ring[i].skb) {
+			priv->desc_ring[i].dataflags = 0;
 			dev_kfree_skb_any(priv->desc_ring[i].skb);
 			netif_wake_subqueue(dev, i);
 			break;
 		}
 #else
+	priv->desc_ring[0].dataflags = 0;
 	if (priv->desc_ring[0].skb)
 		dev_kfree_skb_any(priv->desc_ring[0].skb);
 	netif_wake_queue(dev);
@@ -794,7 +787,7 @@ static int cpmac_set_ringparam(struct net_device *dev, struct ethtool_ringparam*
 {
 	struct cpmac_priv *priv = netdev_priv(dev);
 
-	if (dev->flags && IFF_UP)
+	if (netif_running(dev))
 		return -EBUSY;
 	priv->ring_size = ring->rx_pending;
 	return 0;
diff --git a/drivers/net/defxx.c b/drivers/net/defxx.c
index b07613e..ddc30c4 100644
--- a/drivers/net/defxx.c
+++ b/drivers/net/defxx.c
@@ -805,7 +805,7 @@ static void __devinit dfx_bus_init(struct net_device *dev)
  *   Interrupts are disabled at the adapter bus-specific logic.
  */
 
-static void __devinit dfx_bus_uninit(struct net_device *dev)
+static void __devexit dfx_bus_uninit(struct net_device *dev)
 {
 	DFX_board_t *bp = netdev_priv(dev);
 	struct device *bdev = bp->bus_dev;
diff --git a/drivers/net/mipsnet.c b/drivers/net/mipsnet.c
index 37707a0..aafc3ce 100644
--- a/drivers/net/mipsnet.c
+++ b/drivers/net/mipsnet.c
@@ -30,6 +30,7 @@ static int ioiocpy_frommipsnet(struct net_device *dev, unsigned char *kdata,
 			int len)
 {
 	uint32_t available_len = inl(mipsnet_reg_address(dev, rxDataCount));
+
 	if (available_len < len)
 		return -EFAULT;
 
@@ -45,14 +46,8 @@ static inline ssize_t mipsnet_put_todevice(struct net_device *dev,
 	int count_to_go = skb->len;
 	char *buf_ptr = skb->data;
 
-	pr_debug("%s: %s(): telling MIPSNET txDataCount(%d)\n",
-		 dev->name, __FUNCTION__, skb->len);
-
 	outl(skb->len, mipsnet_reg_address(dev, txDataCount));
 
-	pr_debug("%s: %s(): sending data to MIPSNET txDataBuffer(%d)\n",
-		 dev->name, __FUNCTION__, skb->len);
-
 	for (; count_to_go; buf_ptr++, count_to_go--)
 		outb(*buf_ptr, mipsnet_reg_address(dev, txDataBuffer));
 
@@ -64,10 +59,8 @@ static inline ssize_t mipsnet_put_todevice(struct net_device *dev,
 
 static int mipsnet_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	pr_debug("%s:%s(): transmitting %d bytes\n",
-		 dev->name, __FUNCTION__, skb->len);
-
-	/* Only one packet at a time. Once TXDONE interrupt is serviced, the
+	/*
+	 * Only one packet at a time. Once TXDONE interrupt is serviced, the
 	 * queue will be restarted.
 	 */
 	netif_stop_queue(dev);
@@ -94,8 +87,6 @@ static inline ssize_t mipsnet_get_fromdev(struct net_device *dev, size_t count)
 	skb->protocol = eth_type_trans(skb, dev);
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-	pr_debug("%s:%s(): pushing RXed data to kernel\n",
-		 dev->name, __FUNCTION__);
 	netif_rx(skb);
 
 	dev->stats.rx_packets++;
@@ -112,44 +103,29 @@ static irqreturn_t mipsnet_interrupt(int irq, void *dev_id)
 	uint64_t interruptFlags;
 
 	if (irq == dev->irq) {
-		pr_debug("%s:%s(): irq %d for device\n",
-			 dev->name, __FUNCTION__, irq);
-
 		retval = IRQ_HANDLED;
 
 		interruptFlags =
 		    inl(mipsnet_reg_address(dev, interruptControl));
-		pr_debug("%s:%s(): intCtl=0x%016llx\n", dev->name,
-			 __FUNCTION__, interruptFlags);
 
 		if (interruptFlags & MIPSNET_INTCTL_TXDONE) {
-			pr_debug("%s:%s(): got TXDone\n",
-				 dev->name, __FUNCTION__);
 			outl(MIPSNET_INTCTL_TXDONE,
 			     mipsnet_reg_address(dev, interruptControl));
 			/* only one packet at a time, we are done. */
 			netif_wake_queue(dev);
 		} else if (interruptFlags & MIPSNET_INTCTL_RXDONE) {
-			pr_debug("%s:%s(): got RX data\n",
-				 dev->name, __FUNCTION__);
 			mipsnet_get_fromdev(dev,
 				    inl(mipsnet_reg_address(dev, rxDataCount)));
-			pr_debug("%s:%s(): clearing RX int\n",
-				 dev->name, __FUNCTION__);
 			outl(MIPSNET_INTCTL_RXDONE,
 			     mipsnet_reg_address(dev, interruptControl));
 
 		} else if (interruptFlags & MIPSNET_INTCTL_TESTBIT) {
-			pr_debug("%s:%s(): got test interrupt\n",
-				 dev->name, __FUNCTION__);
 			/*
 			 * TESTBIT is cleared on read.
 			 * And takes effect after a write with 0
 			 */
 			outl(0, mipsnet_reg_address(dev, interruptControl));
 		} else {
-			pr_debug("%s:%s(): no valid fags 0x%016llx\n",
-				 dev->name, __FUNCTION__, interruptFlags);
 			/* Maybe shared IRQ, just ignore, no clearing. */
 			retval = IRQ_NONE;
 		}
@@ -165,22 +141,15 @@ static irqreturn_t mipsnet_interrupt(int irq, void *dev_id)
 static int mipsnet_open(struct net_device *dev)
 {
 	int err;
-	pr_debug("%s: mipsnet_open\n", dev->name);
 
 	err = request_irq(dev->irq, &mipsnet_interrupt,
 			  IRQF_SHARED, dev->name, (void *) dev);
 
 	if (err) {
-		pr_debug("%s: %s(): can't get irq %d\n",
-			 dev->name, __FUNCTION__, dev->irq);
 		release_region(dev->base_addr, MIPSNET_IO_EXTENT);
 		return err;
 	}
 
-	pr_debug("%s: %s(): got IO region at 0x%04lx and irq %d for dev.\n",
-		 dev->name, __FUNCTION__, dev->base_addr, dev->irq);
-
-
 	netif_start_queue(dev);
 
 	/* test interrupt handler */
@@ -193,8 +162,8 @@ static int mipsnet_open(struct net_device *dev)
 
 static int mipsnet_close(struct net_device *dev)
 {
-	pr_debug("%s: %s()\n", dev->name, __FUNCTION__);
 	netif_stop_queue(dev);
+
 	return 0;
 }
 
@@ -229,9 +198,6 @@ static int __init mipsnet_probe(struct device *dev)
 
 	/* Get the io region now, get irq on open() */
 	if (!request_region(netdev->base_addr, MIPSNET_IO_EXTENT, "mipsnet")) {
-		pr_debug("%s: %s(): IO region {start: 0x%04lux, len: %d} "
-			 "for dev is not availble.\n", netdev->name,
-			 __FUNCTION__, netdev->base_addr, MIPSNET_IO_EXTENT);
 		err = -EBUSY;
 		goto out_free_netdev;
 	}
@@ -295,8 +261,6 @@ static int __init mipsnet_init_module(void)
 
 static void __exit mipsnet_exit_module(void)
 {
-	pr_debug("MIPSNet Ethernet driver exiting\n");
-
 	driver_unregister(&mipsnet_driver);
 }
 
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 84f2d63..651c269 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1,5 +1,5 @@
 /*
- * drivers/net/mv643xx_eth.c - Driver for MV643XX ethernet ports
+ * Driver for Marvell Discovery (MV643XX) and Marvell Orion ethernet ports
  * Copyright (C) 2002 Matthew Dharm <mdharm@momenco.com>
  *
  * Based on the 64360 driver from:
@@ -43,14 +43,567 @@
 #include <linux/ethtool.h>
 #include <linux/platform_device.h>
 
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/spinlock.h>
+#include <linux/workqueue.h>
+#include <linux/mii.h>
+
+#include <linux/mv643xx_eth.h>
+
 #include <asm/io.h>
 #include <asm/types.h>
 #include <asm/pgtable.h>
 #include <asm/system.h>
 #include <asm/delay.h>
-#include "mv643xx_eth.h"
+#include <asm/dma-mapping.h>
+
+#define MV643XX_CHECKSUM_OFFLOAD_TX
+#define MV643XX_NAPI
+#define MV643XX_TX_FAST_REFILL
+#undef	MV643XX_COAL
+
+/*
+ * Number of RX / TX descriptors on RX / TX rings.
+ * Note that allocating RX descriptors is done by allocating the RX
+ * ring AND a preallocated RX buffers (skb's) for each descriptor.
+ * The TX descriptors only allocates the TX descriptors ring,
+ * with no pre allocated TX buffers (skb's are allocated by higher layers.
+ */
+
+/* Default TX ring size is 1000 descriptors */
+#define MV643XX_DEFAULT_TX_QUEUE_SIZE 1000
+
+/* Default RX ring size is 400 descriptors */
+#define MV643XX_DEFAULT_RX_QUEUE_SIZE 400
+
+#define MV643XX_TX_COAL 100
+#ifdef MV643XX_COAL
+#define MV643XX_RX_COAL 100
+#endif
+
+#ifdef MV643XX_CHECKSUM_OFFLOAD_TX
+#define MAX_DESCS_PER_SKB	(MAX_SKB_FRAGS + 1)
+#else
+#define MAX_DESCS_PER_SKB	1
+#endif
+
+#define ETH_VLAN_HLEN		4
+#define ETH_FCS_LEN		4
+#define ETH_HW_IP_ALIGN		2		/* hw aligns IP header */
+#define ETH_WRAPPER_LEN		(ETH_HW_IP_ALIGN + ETH_HLEN + \
+					ETH_VLAN_HLEN + ETH_FCS_LEN)
+#define ETH_RX_SKB_SIZE		(dev->mtu + ETH_WRAPPER_LEN + \
+					dma_get_cache_alignment())
+
+/*
+ * Registers shared between all ports.
+ */
+#define PHY_ADDR_REG				0x0000
+#define SMI_REG					0x0004
+
+/*
+ * Per-port registers.
+ */
+#define PORT_CONFIG_REG(p)				(0x0400 + ((p) << 10))
+#define PORT_CONFIG_EXTEND_REG(p)			(0x0404 + ((p) << 10))
+#define MAC_ADDR_LOW(p)					(0x0414 + ((p) << 10))
+#define MAC_ADDR_HIGH(p)				(0x0418 + ((p) << 10))
+#define SDMA_CONFIG_REG(p)				(0x041c + ((p) << 10))
+#define PORT_SERIAL_CONTROL_REG(p)			(0x043c + ((p) << 10))
+#define PORT_STATUS_REG(p)				(0x0444 + ((p) << 10))
+#define TRANSMIT_QUEUE_COMMAND_REG(p)			(0x0448 + ((p) << 10))
+#define MAXIMUM_TRANSMIT_UNIT(p)			(0x0458 + ((p) << 10))
+#define INTERRUPT_CAUSE_REG(p)				(0x0460 + ((p) << 10))
+#define INTERRUPT_CAUSE_EXTEND_REG(p)			(0x0464 + ((p) << 10))
+#define INTERRUPT_MASK_REG(p)				(0x0468 + ((p) << 10))
+#define INTERRUPT_EXTEND_MASK_REG(p)			(0x046c + ((p) << 10))
+#define TX_FIFO_URGENT_THRESHOLD_REG(p)			(0x0474 + ((p) << 10))
+#define RX_CURRENT_QUEUE_DESC_PTR_0(p)			(0x060c + ((p) << 10))
+#define RECEIVE_QUEUE_COMMAND_REG(p)			(0x0680 + ((p) << 10))
+#define TX_CURRENT_QUEUE_DESC_PTR_0(p)			(0x06c0 + ((p) << 10))
+#define MIB_COUNTERS_BASE(p)				(0x1000 + ((p) << 7))
+#define DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(p)	(0x1400 + ((p) << 10))
+#define DA_FILTER_OTHER_MULTICAST_TABLE_BASE(p)		(0x1500 + ((p) << 10))
+#define DA_FILTER_UNICAST_TABLE_BASE(p)			(0x1600 + ((p) << 10))
+
+/* These macros describe Ethernet Port configuration reg (Px_cR) bits */
+#define UNICAST_NORMAL_MODE		(0 << 0)
+#define UNICAST_PROMISCUOUS_MODE	(1 << 0)
+#define DEFAULT_RX_QUEUE(queue)		((queue) << 1)
+#define DEFAULT_RX_ARP_QUEUE(queue)	((queue) << 4)
+#define RECEIVE_BC_IF_NOT_IP_OR_ARP	(0 << 7)
+#define REJECT_BC_IF_NOT_IP_OR_ARP	(1 << 7)
+#define RECEIVE_BC_IF_IP		(0 << 8)
+#define REJECT_BC_IF_IP			(1 << 8)
+#define RECEIVE_BC_IF_ARP		(0 << 9)
+#define REJECT_BC_IF_ARP		(1 << 9)
+#define TX_AM_NO_UPDATE_ERROR_SUMMARY	(1 << 12)
+#define CAPTURE_TCP_FRAMES_DIS		(0 << 14)
+#define CAPTURE_TCP_FRAMES_EN		(1 << 14)
+#define CAPTURE_UDP_FRAMES_DIS		(0 << 15)
+#define CAPTURE_UDP_FRAMES_EN		(1 << 15)
+#define DEFAULT_RX_TCP_QUEUE(queue)	((queue) << 16)
+#define DEFAULT_RX_UDP_QUEUE(queue)	((queue) << 19)
+#define DEFAULT_RX_BPDU_QUEUE(queue)	((queue) << 22)
+
+#define PORT_CONFIG_DEFAULT_VALUE			\
+		UNICAST_NORMAL_MODE		|	\
+		DEFAULT_RX_QUEUE(0)		|	\
+		DEFAULT_RX_ARP_QUEUE(0)		|	\
+		RECEIVE_BC_IF_NOT_IP_OR_ARP	|	\
+		RECEIVE_BC_IF_IP		|	\
+		RECEIVE_BC_IF_ARP		|	\
+		CAPTURE_TCP_FRAMES_DIS		|	\
+		CAPTURE_UDP_FRAMES_DIS		|	\
+		DEFAULT_RX_TCP_QUEUE(0)		|	\
+		DEFAULT_RX_UDP_QUEUE(0)		|	\
+		DEFAULT_RX_BPDU_QUEUE(0)
+
+/* These macros describe Ethernet Port configuration extend reg (Px_cXR) bits*/
+#define CLASSIFY_EN				(1 << 0)
+#define SPAN_BPDU_PACKETS_AS_NORMAL		(0 << 1)
+#define SPAN_BPDU_PACKETS_TO_RX_QUEUE_7		(1 << 1)
+#define PARTITION_DISABLE			(0 << 2)
+#define PARTITION_ENABLE			(1 << 2)
+
+#define PORT_CONFIG_EXTEND_DEFAULT_VALUE		\
+		SPAN_BPDU_PACKETS_AS_NORMAL	|	\
+		PARTITION_DISABLE
+
+/* These macros describe Ethernet Port Sdma configuration reg (SDCR) bits */
+#define RIFB				(1 << 0)
+#define RX_BURST_SIZE_1_64BIT		(0 << 1)
+#define RX_BURST_SIZE_2_64BIT		(1 << 1)
+#define RX_BURST_SIZE_4_64BIT		(2 << 1)
+#define RX_BURST_SIZE_8_64BIT		(3 << 1)
+#define RX_BURST_SIZE_16_64BIT		(4 << 1)
+#define BLM_RX_NO_SWAP			(1 << 4)
+#define BLM_RX_BYTE_SWAP		(0 << 4)
+#define BLM_TX_NO_SWAP			(1 << 5)
+#define BLM_TX_BYTE_SWAP		(0 << 5)
+#define DESCRIPTORS_BYTE_SWAP		(1 << 6)
+#define DESCRIPTORS_NO_SWAP		(0 << 6)
+#define IPG_INT_RX(value)		(((value) & 0x3fff) << 8)
+#define TX_BURST_SIZE_1_64BIT		(0 << 22)
+#define TX_BURST_SIZE_2_64BIT		(1 << 22)
+#define TX_BURST_SIZE_4_64BIT		(2 << 22)
+#define TX_BURST_SIZE_8_64BIT		(3 << 22)
+#define TX_BURST_SIZE_16_64BIT		(4 << 22)
+
+#if defined(__BIG_ENDIAN)
+#define PORT_SDMA_CONFIG_DEFAULT_VALUE		\
+		RX_BURST_SIZE_4_64BIT	|	\
+		IPG_INT_RX(0)		|	\
+		TX_BURST_SIZE_4_64BIT
+#elif defined(__LITTLE_ENDIAN)
+#define PORT_SDMA_CONFIG_DEFAULT_VALUE		\
+		RX_BURST_SIZE_4_64BIT	|	\
+		BLM_RX_NO_SWAP		|	\
+		BLM_TX_NO_SWAP		|	\
+		IPG_INT_RX(0)		|	\
+		TX_BURST_SIZE_4_64BIT
+#else
+#error One of __BIG_ENDIAN or __LITTLE_ENDIAN must be defined
+#endif
+
+/* These macros describe Ethernet Port serial control reg (PSCR) bits */
+#define SERIAL_PORT_DISABLE			(0 << 0)
+#define SERIAL_PORT_ENABLE			(1 << 0)
+#define DO_NOT_FORCE_LINK_PASS			(0 << 1)
+#define FORCE_LINK_PASS				(1 << 1)
+#define ENABLE_AUTO_NEG_FOR_DUPLX		(0 << 2)
+#define DISABLE_AUTO_NEG_FOR_DUPLX		(1 << 2)
+#define ENABLE_AUTO_NEG_FOR_FLOW_CTRL		(0 << 3)
+#define DISABLE_AUTO_NEG_FOR_FLOW_CTRL		(1 << 3)
+#define ADV_NO_FLOW_CTRL			(0 << 4)
+#define ADV_SYMMETRIC_FLOW_CTRL			(1 << 4)
+#define FORCE_FC_MODE_NO_PAUSE_DIS_TX		(0 << 5)
+#define FORCE_FC_MODE_TX_PAUSE_DIS		(1 << 5)
+#define FORCE_BP_MODE_NO_JAM			(0 << 7)
+#define FORCE_BP_MODE_JAM_TX			(1 << 7)
+#define FORCE_BP_MODE_JAM_TX_ON_RX_ERR		(2 << 7)
+#define SERIAL_PORT_CONTROL_RESERVED		(1 << 9)
+#define FORCE_LINK_FAIL				(0 << 10)
+#define DO_NOT_FORCE_LINK_FAIL			(1 << 10)
+#define RETRANSMIT_16_ATTEMPTS			(0 << 11)
+#define RETRANSMIT_FOREVER			(1 << 11)
+#define ENABLE_AUTO_NEG_SPEED_GMII		(0 << 13)
+#define DISABLE_AUTO_NEG_SPEED_GMII		(1 << 13)
+#define DTE_ADV_0				(0 << 14)
+#define DTE_ADV_1				(1 << 14)
+#define DISABLE_AUTO_NEG_BYPASS			(0 << 15)
+#define ENABLE_AUTO_NEG_BYPASS			(1 << 15)
+#define AUTO_NEG_NO_CHANGE			(0 << 16)
+#define RESTART_AUTO_NEG			(1 << 16)
+#define MAX_RX_PACKET_1518BYTE			(0 << 17)
+#define MAX_RX_PACKET_1522BYTE			(1 << 17)
+#define MAX_RX_PACKET_1552BYTE			(2 << 17)
+#define MAX_RX_PACKET_9022BYTE			(3 << 17)
+#define MAX_RX_PACKET_9192BYTE			(4 << 17)
+#define MAX_RX_PACKET_9700BYTE			(5 << 17)
+#define MAX_RX_PACKET_MASK			(7 << 17)
+#define CLR_EXT_LOOPBACK			(0 << 20)
+#define SET_EXT_LOOPBACK			(1 << 20)
+#define SET_HALF_DUPLEX_MODE			(0 << 21)
+#define SET_FULL_DUPLEX_MODE			(1 << 21)
+#define DISABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX	(0 << 22)
+#define ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX	(1 << 22)
+#define SET_GMII_SPEED_TO_10_100		(0 << 23)
+#define SET_GMII_SPEED_TO_1000			(1 << 23)
+#define SET_MII_SPEED_TO_10			(0 << 24)
+#define SET_MII_SPEED_TO_100			(1 << 24)
+
+#define PORT_SERIAL_CONTROL_DEFAULT_VALUE		\
+		DO_NOT_FORCE_LINK_PASS		|	\
+		ENABLE_AUTO_NEG_FOR_DUPLX	|	\
+		DISABLE_AUTO_NEG_FOR_FLOW_CTRL	|	\
+		ADV_SYMMETRIC_FLOW_CTRL		|	\
+		FORCE_FC_MODE_NO_PAUSE_DIS_TX	|	\
+		FORCE_BP_MODE_NO_JAM		|	\
+		(1 << 9) /* reserved */		|	\
+		DO_NOT_FORCE_LINK_FAIL		|	\
+		RETRANSMIT_16_ATTEMPTS		|	\
+		ENABLE_AUTO_NEG_SPEED_GMII	|	\
+		DTE_ADV_0			|	\
+		DISABLE_AUTO_NEG_BYPASS		|	\
+		AUTO_NEG_NO_CHANGE		|	\
+		MAX_RX_PACKET_9700BYTE		|	\
+		CLR_EXT_LOOPBACK		|	\
+		SET_FULL_DUPLEX_MODE		|	\
+		ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX
+
+/* These macros describe Ethernet Serial Status reg (PSR) bits */
+#define PORT_STATUS_MODE_10_BIT		(1 << 0)
+#define PORT_STATUS_LINK_UP		(1 << 1)
+#define PORT_STATUS_FULL_DUPLEX		(1 << 2)
+#define PORT_STATUS_FLOW_CONTROL	(1 << 3)
+#define PORT_STATUS_GMII_1000		(1 << 4)
+#define PORT_STATUS_MII_100		(1 << 5)
+/* PSR bit 6 is undocumented */
+#define PORT_STATUS_TX_IN_PROGRESS	(1 << 7)
+#define PORT_STATUS_AUTONEG_BYPASSED	(1 << 8)
+#define PORT_STATUS_PARTITION		(1 << 9)
+#define PORT_STATUS_TX_FIFO_EMPTY	(1 << 10)
+/* PSR bits 11-31 are reserved */
+
+#define PORT_DEFAULT_TRANSMIT_QUEUE_SIZE	800
+#define PORT_DEFAULT_RECEIVE_QUEUE_SIZE		400
+
+#define DESC_SIZE				64
+
+#define ETH_RX_QUEUES_ENABLED	(1 << 0)	/* use only Q0 for receive */
+#define ETH_TX_QUEUES_ENABLED	(1 << 0)	/* use only Q0 for transmit */
+
+#define ETH_INT_CAUSE_RX_DONE	(ETH_RX_QUEUES_ENABLED << 2)
+#define ETH_INT_CAUSE_RX_ERROR	(ETH_RX_QUEUES_ENABLED << 9)
+#define ETH_INT_CAUSE_RX	(ETH_INT_CAUSE_RX_DONE | ETH_INT_CAUSE_RX_ERROR)
+#define ETH_INT_CAUSE_EXT	0x00000002
+#define ETH_INT_UNMASK_ALL	(ETH_INT_CAUSE_RX | ETH_INT_CAUSE_EXT)
+
+#define ETH_INT_CAUSE_TX_DONE	(ETH_TX_QUEUES_ENABLED << 0)
+#define ETH_INT_CAUSE_TX_ERROR	(ETH_TX_QUEUES_ENABLED << 8)
+#define ETH_INT_CAUSE_TX	(ETH_INT_CAUSE_TX_DONE | ETH_INT_CAUSE_TX_ERROR)
+#define ETH_INT_CAUSE_PHY	0x00010000
+#define ETH_INT_CAUSE_STATE	0x00100000
+#define ETH_INT_UNMASK_ALL_EXT	(ETH_INT_CAUSE_TX | ETH_INT_CAUSE_PHY | \
+					ETH_INT_CAUSE_STATE)
+
+#define ETH_INT_MASK_ALL	0x00000000
+#define ETH_INT_MASK_ALL_EXT	0x00000000
+
+#define PHY_WAIT_ITERATIONS	1000	/* 1000 iterations * 10uS = 10mS max */
+#define PHY_WAIT_MICRO_SECONDS	10
+
+/* Buffer offset from buffer pointer */
+#define RX_BUF_OFFSET				0x2
+
+/* Gigabit Ethernet Unit Global Registers */
+
+/* MIB Counters register definitions */
+#define ETH_MIB_GOOD_OCTETS_RECEIVED_LOW	0x0
+#define ETH_MIB_GOOD_OCTETS_RECEIVED_HIGH	0x4
+#define ETH_MIB_BAD_OCTETS_RECEIVED		0x8
+#define ETH_MIB_INTERNAL_MAC_TRANSMIT_ERR	0xc
+#define ETH_MIB_GOOD_FRAMES_RECEIVED		0x10
+#define ETH_MIB_BAD_FRAMES_RECEIVED		0x14
+#define ETH_MIB_BROADCAST_FRAMES_RECEIVED	0x18
+#define ETH_MIB_MULTICAST_FRAMES_RECEIVED	0x1c
+#define ETH_MIB_FRAMES_64_OCTETS		0x20
+#define ETH_MIB_FRAMES_65_TO_127_OCTETS		0x24
+#define ETH_MIB_FRAMES_128_TO_255_OCTETS	0x28
+#define ETH_MIB_FRAMES_256_TO_511_OCTETS	0x2c
+#define ETH_MIB_FRAMES_512_TO_1023_OCTETS	0x30
+#define ETH_MIB_FRAMES_1024_TO_MAX_OCTETS	0x34
+#define ETH_MIB_GOOD_OCTETS_SENT_LOW		0x38
+#define ETH_MIB_GOOD_OCTETS_SENT_HIGH		0x3c
+#define ETH_MIB_GOOD_FRAMES_SENT		0x40
+#define ETH_MIB_EXCESSIVE_COLLISION		0x44
+#define ETH_MIB_MULTICAST_FRAMES_SENT		0x48
+#define ETH_MIB_BROADCAST_FRAMES_SENT		0x4c
+#define ETH_MIB_UNREC_MAC_CONTROL_RECEIVED	0x50
+#define ETH_MIB_FC_SENT				0x54
+#define ETH_MIB_GOOD_FC_RECEIVED		0x58
+#define ETH_MIB_BAD_FC_RECEIVED			0x5c
+#define ETH_MIB_UNDERSIZE_RECEIVED		0x60
+#define ETH_MIB_FRAGMENTS_RECEIVED		0x64
+#define ETH_MIB_OVERSIZE_RECEIVED		0x68
+#define ETH_MIB_JABBER_RECEIVED			0x6c
+#define ETH_MIB_MAC_RECEIVE_ERROR		0x70
+#define ETH_MIB_BAD_CRC_EVENT			0x74
+#define ETH_MIB_COLLISION			0x78
+#define ETH_MIB_LATE_COLLISION			0x7c
+
+/* Port serial status reg (PSR) */
+#define ETH_INTERFACE_PCM			0x00000001
+#define ETH_LINK_IS_UP				0x00000002
+#define ETH_PORT_AT_FULL_DUPLEX			0x00000004
+#define ETH_RX_FLOW_CTRL_ENABLED		0x00000008
+#define ETH_GMII_SPEED_1000			0x00000010
+#define ETH_MII_SPEED_100			0x00000020
+#define ETH_TX_IN_PROGRESS			0x00000080
+#define ETH_BYPASS_ACTIVE			0x00000100
+#define ETH_PORT_AT_PARTITION_STATE		0x00000200
+#define ETH_PORT_TX_FIFO_EMPTY			0x00000400
+
+/* SMI reg */
+#define ETH_SMI_BUSY		0x10000000	/* 0 - Write, 1 - Read	*/
+#define ETH_SMI_READ_VALID	0x08000000	/* 0 - Write, 1 - Read	*/
+#define ETH_SMI_OPCODE_WRITE	0		/* Completion of Read	*/
+#define ETH_SMI_OPCODE_READ	0x04000000	/* Operation is in progress */
+
+/* Interrupt Cause Register Bit Definitions */
+
+/* SDMA command status fields macros */
+
+/* Tx & Rx descriptors status */
+#define ETH_ERROR_SUMMARY			0x00000001
+
+/* Tx & Rx descriptors command */
+#define ETH_BUFFER_OWNED_BY_DMA			0x80000000
+
+/* Tx descriptors status */
+#define ETH_LC_ERROR				0
+#define ETH_UR_ERROR				0x00000002
+#define ETH_RL_ERROR				0x00000004
+#define ETH_LLC_SNAP_FORMAT			0x00000200
+
+/* Rx descriptors status */
+#define ETH_OVERRUN_ERROR			0x00000002
+#define ETH_MAX_FRAME_LENGTH_ERROR		0x00000004
+#define ETH_RESOURCE_ERROR			0x00000006
+#define ETH_VLAN_TAGGED				0x00080000
+#define ETH_BPDU_FRAME				0x00100000
+#define ETH_UDP_FRAME_OVER_IP_V_4		0x00200000
+#define ETH_OTHER_FRAME_TYPE			0x00400000
+#define ETH_LAYER_2_IS_ETH_V_2			0x00800000
+#define ETH_FRAME_TYPE_IP_V_4			0x01000000
+#define ETH_FRAME_HEADER_OK			0x02000000
+#define ETH_RX_LAST_DESC			0x04000000
+#define ETH_RX_FIRST_DESC			0x08000000
+#define ETH_UNKNOWN_DESTINATION_ADDR		0x10000000
+#define ETH_RX_ENABLE_INTERRUPT			0x20000000
+#define ETH_LAYER_4_CHECKSUM_OK			0x40000000
+
+/* Rx descriptors byte count */
+#define ETH_FRAME_FRAGMENTED			0x00000004
+
+/* Tx descriptors command */
+#define ETH_LAYER_4_CHECKSUM_FIRST_DESC		0x00000400
+#define ETH_FRAME_SET_TO_VLAN			0x00008000
+#define ETH_UDP_FRAME				0x00010000
+#define ETH_GEN_TCP_UDP_CHECKSUM		0x00020000
+#define ETH_GEN_IP_V_4_CHECKSUM			0x00040000
+#define ETH_ZERO_PADDING			0x00080000
+#define ETH_TX_LAST_DESC			0x00100000
+#define ETH_TX_FIRST_DESC			0x00200000
+#define ETH_GEN_CRC				0x00400000
+#define ETH_TX_ENABLE_INTERRUPT			0x00800000
+#define ETH_AUTO_MODE				0x40000000
+
+#define ETH_TX_IHL_SHIFT			11
+
+/* typedefs */
+
+typedef enum _eth_func_ret_status {
+	ETH_OK,			/* Returned as expected.		*/
+	ETH_ERROR,		/* Fundamental error.			*/
+	ETH_RETRY,		/* Could not process request. Try later.*/
+	ETH_END_OF_JOB,		/* Ring has nothing to process.		*/
+	ETH_QUEUE_FULL,		/* Ring resource error.			*/
+	ETH_QUEUE_LAST_RESOURCE	/* Ring resources about to exhaust.	*/
+} ETH_FUNC_RET_STATUS;
+
+typedef enum _eth_target {
+	ETH_TARGET_DRAM,
+	ETH_TARGET_DEVICE,
+	ETH_TARGET_CBS,
+	ETH_TARGET_PCI0,
+	ETH_TARGET_PCI1
+} ETH_TARGET;
+
+/* These are for big-endian machines.  Little endian needs different
+ * definitions.
+ */
+#if defined(__BIG_ENDIAN)
+struct eth_rx_desc {
+	u16 byte_cnt;		/* Descriptor buffer byte count		*/
+	u16 buf_size;		/* Buffer size				*/
+	u32 cmd_sts;		/* Descriptor command status		*/
+	u32 next_desc_ptr;	/* Next descriptor pointer		*/
+	u32 buf_ptr;		/* Descriptor buffer pointer		*/
+};
+
+struct eth_tx_desc {
+	u16 byte_cnt;		/* buffer byte count			*/
+	u16 l4i_chk;		/* CPU provided TCP checksum		*/
+	u32 cmd_sts;		/* Command/status field			*/
+	u32 next_desc_ptr;	/* Pointer to next descriptor		*/
+	u32 buf_ptr;		/* pointer to buffer for this descriptor*/
+};
+#elif defined(__LITTLE_ENDIAN)
+struct eth_rx_desc {
+	u32 cmd_sts;		/* Descriptor command status		*/
+	u16 buf_size;		/* Buffer size				*/
+	u16 byte_cnt;		/* Descriptor buffer byte count		*/
+	u32 buf_ptr;		/* Descriptor buffer pointer		*/
+	u32 next_desc_ptr;	/* Next descriptor pointer		*/
+};
+
+struct eth_tx_desc {
+	u32 cmd_sts;		/* Command/status field			*/
+	u16 l4i_chk;		/* CPU provided TCP checksum		*/
+	u16 byte_cnt;		/* buffer byte count			*/
+	u32 buf_ptr;		/* pointer to buffer for this descriptor*/
+	u32 next_desc_ptr;	/* Pointer to next descriptor		*/
+};
+#else
+#error One of __BIG_ENDIAN or __LITTLE_ENDIAN must be defined
+#endif
+
+/* Unified struct for Rx and Tx operations. The user is not required to	*/
+/* be familier with neither Tx nor Rx descriptors.			*/
+struct pkt_info {
+	unsigned short byte_cnt;	/* Descriptor buffer byte count	*/
+	unsigned short l4i_chk;		/* Tx CPU provided TCP Checksum	*/
+	unsigned int cmd_sts;		/* Descriptor command status	*/
+	dma_addr_t buf_ptr;		/* Descriptor buffer pointer	*/
+	struct sk_buff *return_info;	/* User resource return information */
+};
+
+/* Ethernet port specific information */
+struct mv643xx_mib_counters {
+	u64 good_octets_received;
+	u32 bad_octets_received;
+	u32 internal_mac_transmit_err;
+	u32 good_frames_received;
+	u32 bad_frames_received;
+	u32 broadcast_frames_received;
+	u32 multicast_frames_received;
+	u32 frames_64_octets;
+	u32 frames_65_to_127_octets;
+	u32 frames_128_to_255_octets;
+	u32 frames_256_to_511_octets;
+	u32 frames_512_to_1023_octets;
+	u32 frames_1024_to_max_octets;
+	u64 good_octets_sent;
+	u32 good_frames_sent;
+	u32 excessive_collision;
+	u32 multicast_frames_sent;
+	u32 broadcast_frames_sent;
+	u32 unrec_mac_control_received;
+	u32 fc_sent;
+	u32 good_fc_received;
+	u32 bad_fc_received;
+	u32 undersize_received;
+	u32 fragments_received;
+	u32 oversize_received;
+	u32 jabber_received;
+	u32 mac_receive_error;
+	u32 bad_crc_event;
+	u32 collision;
+	u32 late_collision;
+};
+
+struct mv643xx_private {
+	int port_num;			/* User Ethernet port number	*/
+
+	u32 rx_sram_addr;		/* Base address of rx sram area */
+	u32 rx_sram_size;		/* Size of rx sram area		*/
+	u32 tx_sram_addr;		/* Base address of tx sram area */
+	u32 tx_sram_size;		/* Size of tx sram area		*/
+
+	int rx_resource_err;		/* Rx ring resource error flag */
+
+	/* Tx/Rx rings managment indexes fields. For driver use */
+
+	/* Next available and first returning Rx resource */
+	int rx_curr_desc_q, rx_used_desc_q;
+
+	/* Next available and first returning Tx resource */
+	int tx_curr_desc_q, tx_used_desc_q;
+
+#ifdef MV643XX_TX_FAST_REFILL
+	u32 tx_clean_threshold;
+#endif
+
+	struct eth_rx_desc *p_rx_desc_area;
+	dma_addr_t rx_desc_dma;
+	int rx_desc_area_size;
+	struct sk_buff **rx_skb;
+
+	struct eth_tx_desc *p_tx_desc_area;
+	dma_addr_t tx_desc_dma;
+	int tx_desc_area_size;
+	struct sk_buff **tx_skb;
+
+	struct work_struct tx_timeout_task;
+
+	struct net_device *dev;
+	struct napi_struct napi;
+	struct net_device_stats stats;
+	struct mv643xx_mib_counters mib_counters;
+	spinlock_t lock;
+	/* Size of Tx Ring per queue */
+	int tx_ring_size;
+	/* Number of tx descriptors in use */
+	int tx_desc_count;
+	/* Size of Rx Ring per queue */
+	int rx_ring_size;
+	/* Number of rx descriptors in use */
+	int rx_desc_count;
+
+	/*
+	 * Used in case RX Ring is empty, which can be caused when
+	 * system does not have resources (skb's)
+	 */
+	struct timer_list timeout;
+
+	u32 rx_int_coal;
+	u32 tx_int_coal;
+	struct mii_if_info mii;
+};
 
 /* Static function declarations */
+static void eth_port_init(struct mv643xx_private *mp);
+static void eth_port_reset(unsigned int eth_port_num);
+static void eth_port_start(struct net_device *dev);
+
+static void ethernet_phy_reset(unsigned int eth_port_num);
+
+static void eth_port_write_smi_reg(unsigned int eth_port_num,
+				   unsigned int phy_reg, unsigned int value);
+
+static void eth_port_read_smi_reg(unsigned int eth_port_num,
+				  unsigned int phy_reg, unsigned int *value);
+
+static void eth_clear_mib_counters(unsigned int eth_port_num);
+
+static ETH_FUNC_RET_STATUS eth_port_receive(struct mv643xx_private *mp,
+					    struct pkt_info *p_pkt_info);
+static ETH_FUNC_RET_STATUS eth_rx_return_buff(struct mv643xx_private *mp,
+					      struct pkt_info *p_pkt_info);
+
 static void eth_port_uc_addr_get(unsigned int port_num, unsigned char *p_addr);
 static void eth_port_uc_addr_set(unsigned int port_num, unsigned char *p_addr);
 static void eth_port_set_multicast_list(struct net_device *);
@@ -78,26 +631,19 @@ static const struct ethtool_ops mv643xx_ethtool_ops;
 static char mv643xx_driver_name[] = "mv643xx_eth";
 static char mv643xx_driver_version[] = "1.0";
 
-static void __iomem *mv643xx_eth_shared_base;
+static void __iomem *mv643xx_eth_base;
 
-/* used to protect MV643XX_ETH_SMI_REG, which is shared across ports */
+/* used to protect SMI_REG, which is shared across ports */
 static DEFINE_SPINLOCK(mv643xx_eth_phy_lock);
 
 static inline u32 mv_read(int offset)
 {
-	void __iomem *reg_base;
-
-	reg_base = mv643xx_eth_shared_base - MV643XX_ETH_SHARED_REGS;
-
-	return readl(reg_base + offset);
+	return readl(mv643xx_eth_base + offset);
 }
 
 static inline void mv_write(int offset, u32 data)
 {
-	void __iomem *reg_base;
-
-	reg_base = mv643xx_eth_shared_base - MV643XX_ETH_SHARED_REGS;
-	writel(data, reg_base + offset);
+	writel(data, mv643xx_eth_base + offset);
 }
 
 /*
@@ -221,12 +767,12 @@ static void mv643xx_eth_set_rx_mode(struct net_device *dev)
 	struct mv643xx_private *mp = netdev_priv(dev);
 	u32 config_reg;
 
-	config_reg = mv_read(MV643XX_ETH_PORT_CONFIG_REG(mp->port_num));
+	config_reg = mv_read(PORT_CONFIG_REG(mp->port_num));
 	if (dev->flags & IFF_PROMISC)
-		config_reg |= (u32) MV643XX_ETH_UNICAST_PROMISCUOUS_MODE;
+		config_reg |= (u32) UNICAST_PROMISCUOUS_MODE;
 	else
-		config_reg &= ~(u32) MV643XX_ETH_UNICAST_PROMISCUOUS_MODE;
-	mv_write(MV643XX_ETH_PORT_CONFIG_REG(mp->port_num), config_reg);
+		config_reg &= ~(u32) UNICAST_PROMISCUOUS_MODE;
+	mv_write(PORT_CONFIG_REG(mp->port_num), config_reg);
 
 	eth_port_set_multicast_list(dev);
 }
@@ -462,41 +1008,37 @@ static void mv643xx_eth_update_pscr(struct net_device *dev,
 	u32 o_pscr, n_pscr;
 	unsigned int queues;
 
-	o_pscr = mv_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num));
+	o_pscr = mv_read(PORT_SERIAL_CONTROL_REG(port_num));
 	n_pscr = o_pscr;
 
 	/* clear speed, duplex and rx buffer size fields */
-	n_pscr &= ~(MV643XX_ETH_SET_MII_SPEED_TO_100  |
-		   MV643XX_ETH_SET_GMII_SPEED_TO_1000 |
-		   MV643XX_ETH_SET_FULL_DUPLEX_MODE   |
-		   MV643XX_ETH_MAX_RX_PACKET_MASK);
+	n_pscr &= ~(SET_MII_SPEED_TO_100  |
+		   SET_GMII_SPEED_TO_1000 |
+		   SET_FULL_DUPLEX_MODE   |
+		   MAX_RX_PACKET_MASK);
 
 	if (ecmd->duplex == DUPLEX_FULL)
-		n_pscr |= MV643XX_ETH_SET_FULL_DUPLEX_MODE;
+		n_pscr |= SET_FULL_DUPLEX_MODE;
 
 	if (ecmd->speed == SPEED_1000)
-		n_pscr |= MV643XX_ETH_SET_GMII_SPEED_TO_1000 |
-			  MV643XX_ETH_MAX_RX_PACKET_9700BYTE;
+		n_pscr |= SET_GMII_SPEED_TO_1000 |
+			  MAX_RX_PACKET_9700BYTE;
 	else {
 		if (ecmd->speed == SPEED_100)
-			n_pscr |= MV643XX_ETH_SET_MII_SPEED_TO_100;
-		n_pscr |= MV643XX_ETH_MAX_RX_PACKET_1522BYTE;
+			n_pscr |= SET_MII_SPEED_TO_100;
+		n_pscr |= MAX_RX_PACKET_1522BYTE;
 	}
 
 	if (n_pscr != o_pscr) {
-		if ((o_pscr & MV643XX_ETH_SERIAL_PORT_ENABLE) == 0)
-			mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num),
-								n_pscr);
+		if ((o_pscr & SERIAL_PORT_ENABLE) == 0)
+			mv_write(PORT_SERIAL_CONTROL_REG(port_num), n_pscr);
 		else {
 			queues = mv643xx_eth_port_disable_tx(port_num);
 
-			o_pscr &= ~MV643XX_ETH_SERIAL_PORT_ENABLE;
-			mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num),
-								o_pscr);
-			mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num),
-								n_pscr);
-			mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num),
-								n_pscr);
+			o_pscr &= ~SERIAL_PORT_ENABLE;
+			mv_write(PORT_SERIAL_CONTROL_REG(port_num), o_pscr);
+			mv_write(PORT_SERIAL_CONTROL_REG(port_num), n_pscr);
+			mv_write(PORT_SERIAL_CONTROL_REG(port_num), n_pscr);
 			if (queues)
 				mv643xx_eth_port_enable_tx(port_num, queues);
 		}
@@ -522,13 +1064,13 @@ static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
 	unsigned int port_num = mp->port_num;
 
 	/* Read interrupt cause registers */
-	eth_int_cause = mv_read(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num)) &
+	eth_int_cause = mv_read(INTERRUPT_CAUSE_REG(port_num)) &
 						ETH_INT_UNMASK_ALL;
 	if (eth_int_cause & ETH_INT_CAUSE_EXT) {
 		eth_int_cause_ext = mv_read(
-			MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num)) &
+			INTERRUPT_CAUSE_EXTEND_REG(port_num)) &
 						ETH_INT_UNMASK_ALL_EXT;
-		mv_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num),
+		mv_write(INTERRUPT_CAUSE_EXTEND_REG(port_num),
 							~eth_int_cause_ext);
 	}
 
@@ -556,10 +1098,10 @@ static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
 #ifdef MV643XX_NAPI
 	if (eth_int_cause & ETH_INT_CAUSE_RX) {
 		/* schedule the NAPI poll routine to maintain port */
-		mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num),
-							ETH_INT_MASK_ALL);
+		mv_write(INTERRUPT_MASK_REG(port_num), ETH_INT_MASK_ALL);
+
 		/* wait for previous write to complete */
-		mv_read(MV643XX_ETH_INTERRUPT_MASK_REG(port_num));
+		mv_read(INTERRUPT_MASK_REG(port_num));
 
 		netif_rx_schedule(dev, &mp->napi);
 	}
@@ -611,9 +1153,9 @@ static unsigned int eth_port_set_rx_coal(unsigned int eth_port_num,
 	unsigned int coal = ((t_clk / 1000000) * delay) / 64;
 
 	/* Set RX Coalescing mechanism */
-	mv_write(MV643XX_ETH_SDMA_CONFIG_REG(eth_port_num),
+	mv_write(SDMA_CONFIG_REG(eth_port_num),
 		((coal & 0x3fff) << 8) |
-		(mv_read(MV643XX_ETH_SDMA_CONFIG_REG(eth_port_num))
+		(mv_read(SDMA_CONFIG_REG(eth_port_num))
 			& 0xffc000ff));
 
 	return coal;
@@ -649,8 +1191,7 @@ static unsigned int eth_port_set_tx_coal(unsigned int eth_port_num,
 	unsigned int coal;
 	coal = ((t_clk / 1000000) * delay) / 64;
 	/* Set TX Coalescing mechanism */
-	mv_write(MV643XX_ETH_TX_FIFO_URGENT_THRESHOLD_REG(eth_port_num),
-								coal << 4);
+	mv_write(TX_FIFO_URGENT_THRESHOLD_REG(eth_port_num), coal << 4);
 	return coal;
 }
 
@@ -786,10 +1327,10 @@ static int mv643xx_eth_open(struct net_device *dev)
 	int err;
 
 	/* Clear any pending ethernet port interrupts */
-	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
-	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
+	mv_write(INTERRUPT_CAUSE_REG(port_num), 0);
+	mv_write(INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
 	/* wait for previous write to complete */
-	mv_read (MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num));
+	mv_read (INTERRUPT_CAUSE_EXTEND_REG(port_num));
 
 	err = request_irq(dev->irq, mv643xx_eth_int_handler,
 			IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, dev);
@@ -896,11 +1437,10 @@ static int mv643xx_eth_open(struct net_device *dev)
 		eth_port_set_tx_coal(port_num, 133000000, MV643XX_TX_COAL);
 
 	/* Unmask phy and link status changes interrupts */
-	mv_write(MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG(port_num),
-						ETH_INT_UNMASK_ALL_EXT);
+	mv_write(INTERRUPT_EXTEND_MASK_REG(port_num), ETH_INT_UNMASK_ALL_EXT);
 
 	/* Unmask RX buffer and TX end interrupt */
-	mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);
+	mv_write(INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);
 
 	return 0;
 
@@ -980,9 +1520,9 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	unsigned int port_num = mp->port_num;
 
 	/* Mask all interrupts on ethernet port */
-	mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num), ETH_INT_MASK_ALL);
+	mv_write(INTERRUPT_MASK_REG(port_num), ETH_INT_MASK_ALL);
 	/* wait for previous write to complete */
-	mv_read(MV643XX_ETH_INTERRUPT_MASK_REG(port_num));
+	mv_read(INTERRUPT_MASK_REG(port_num));
 
 #ifdef MV643XX_NAPI
 	napi_disable(&mp->napi);
@@ -1021,16 +1561,15 @@ static int mv643xx_poll(struct napi_struct *napi, int budget)
 #endif
 
 	work_done = 0;
-	if ((mv_read(MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(port_num)))
+	if ((mv_read(RX_CURRENT_QUEUE_DESC_PTR_0(port_num)))
 	    != (u32) mp->rx_used_desc_q)
 		work_done = mv643xx_eth_receive_queue(dev, budget);
 
 	if (work_done < budget) {
 		netif_rx_complete(dev, napi);
-		mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
-		mv_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
-		mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num),
-						ETH_INT_UNMASK_ALL);
+		mv_write(INTERRUPT_CAUSE_REG(port_num), 0);
+		mv_write(INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
+		mv_write(INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);
 	}
 
 	return work_done;
@@ -1233,13 +1772,13 @@ static void mv643xx_netpoll(struct net_device *netdev)
 	struct mv643xx_private *mp = netdev_priv(netdev);
 	int port_num = mp->port_num;
 
-	mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num), ETH_INT_MASK_ALL);
+	mv_write(INTERRUPT_MASK_REG(port_num), ETH_INT_MASK_ALL);
 	/* wait for previous write to complete */
-	mv_read(MV643XX_ETH_INTERRUPT_MASK_REG(port_num));
+	mv_read(INTERRUPT_MASK_REG(port_num));
 
 	mv643xx_eth_int_handler(netdev->irq, netdev);
 
-	mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);
+	mv_write(INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);
 }
 #endif
 
@@ -1357,8 +1896,8 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 
 	/* set default config values */
 	eth_port_uc_addr_get(port_num, dev->dev_addr);
-	mp->rx_ring_size = MV643XX_ETH_PORT_DEFAULT_RECEIVE_QUEUE_SIZE;
-	mp->tx_ring_size = MV643XX_ETH_PORT_DEFAULT_TRANSMIT_QUEUE_SIZE;
+	mp->rx_ring_size = PORT_DEFAULT_RECEIVE_QUEUE_SIZE;
+	mp->tx_ring_size = PORT_DEFAULT_TRANSMIT_QUEUE_SIZE;
 
 	if (is_valid_ether_addr(pd->mac_addr))
 		memcpy(dev->dev_addr, pd->mac_addr, 6);
@@ -1470,9 +2009,8 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 	if (res == NULL)
 		return -ENODEV;
 
-	mv643xx_eth_shared_base = ioremap(res->start,
-						MV643XX_ETH_SHARED_REGS_SIZE);
-	if (mv643xx_eth_shared_base == NULL)
+	mv643xx_eth_base = ioremap(res->start, res->end - res->start + 1);
+	if (mv643xx_eth_base == NULL)
 		return -ENOMEM;
 
 	return 0;
@@ -1481,8 +2019,8 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 
 static int mv643xx_eth_shared_remove(struct platform_device *pdev)
 {
-	iounmap(mv643xx_eth_shared_base);
-	mv643xx_eth_shared_base = NULL;
+	iounmap(mv643xx_eth_base);
+	mv643xx_eth_base = NULL;
 
 	return 0;
 }
@@ -1494,8 +2032,8 @@ static void mv643xx_eth_shutdown(struct platform_device *pdev)
 	unsigned int port_num = mp->port_num;
 
 	/* Mask all interrupts on ethernet port */
-	mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num), 0);
-	mv_read (MV643XX_ETH_INTERRUPT_MASK_REG(port_num));
+	mv_write(INTERRUPT_MASK_REG(port_num), 0);
+	mv_read (INTERRUPT_MASK_REG(port_num));
 
 	eth_port_reset(port_num);
 }
@@ -1762,49 +2300,49 @@ static void eth_port_start(struct net_device *dev)
 
 	/* Assignment of Tx CTRP of given queue */
 	tx_curr_desc = mp->tx_curr_desc_q;
-	mv_write(MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_0(port_num),
+	mv_write(TX_CURRENT_QUEUE_DESC_PTR_0(port_num),
 		(u32)((struct eth_tx_desc *)mp->tx_desc_dma + tx_curr_desc));
 
 	/* Assignment of Rx CRDP of given queue */
 	rx_curr_desc = mp->rx_curr_desc_q;
-	mv_write(MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(port_num),
+	mv_write(RX_CURRENT_QUEUE_DESC_PTR_0(port_num),
 		(u32)((struct eth_rx_desc *)mp->rx_desc_dma + rx_curr_desc));
 
 	/* Add the assigned Ethernet address to the port's address table */
 	eth_port_uc_addr_set(port_num, dev->dev_addr);
 
 	/* Assign port configuration and command. */
-	mv_write(MV643XX_ETH_PORT_CONFIG_REG(port_num),
-			  MV643XX_ETH_PORT_CONFIG_DEFAULT_VALUE);
+	mv_write(PORT_CONFIG_REG(port_num),
+			  PORT_CONFIG_DEFAULT_VALUE);
 
-	mv_write(MV643XX_ETH_PORT_CONFIG_EXTEND_REG(port_num),
-			  MV643XX_ETH_PORT_CONFIG_EXTEND_DEFAULT_VALUE);
+	mv_write(PORT_CONFIG_EXTEND_REG(port_num),
+			  PORT_CONFIG_EXTEND_DEFAULT_VALUE);
 
-	pscr = mv_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num));
+	pscr = mv_read(PORT_SERIAL_CONTROL_REG(port_num));
 
-	pscr &= ~(MV643XX_ETH_SERIAL_PORT_ENABLE | MV643XX_ETH_FORCE_LINK_PASS);
-	mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num), pscr);
+	pscr &= ~(SERIAL_PORT_ENABLE | FORCE_LINK_PASS);
+	mv_write(PORT_SERIAL_CONTROL_REG(port_num), pscr);
 
-	pscr |= MV643XX_ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL |
-		MV643XX_ETH_DISABLE_AUTO_NEG_SPEED_GMII    |
-		MV643XX_ETH_DISABLE_AUTO_NEG_FOR_DUPLX     |
-		MV643XX_ETH_DO_NOT_FORCE_LINK_FAIL	   |
-		MV643XX_ETH_SERIAL_PORT_CONTROL_RESERVED;
+	pscr |= DISABLE_AUTO_NEG_FOR_FLOW_CTRL |
+		DISABLE_AUTO_NEG_SPEED_GMII    |
+		DISABLE_AUTO_NEG_FOR_DUPLX     |
+		DO_NOT_FORCE_LINK_FAIL	   |
+		SERIAL_PORT_CONTROL_RESERVED;
 
-	mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num), pscr);
+	mv_write(PORT_SERIAL_CONTROL_REG(port_num), pscr);
 
-	pscr |= MV643XX_ETH_SERIAL_PORT_ENABLE;
-	mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num), pscr);
+	pscr |= SERIAL_PORT_ENABLE;
+	mv_write(PORT_SERIAL_CONTROL_REG(port_num), pscr);
 
 	/* Assign port SDMA configuration */
-	mv_write(MV643XX_ETH_SDMA_CONFIG_REG(port_num),
-			  MV643XX_ETH_PORT_SDMA_CONFIG_DEFAULT_VALUE);
+	mv_write(SDMA_CONFIG_REG(port_num),
+			  PORT_SDMA_CONFIG_DEFAULT_VALUE);
 
 	/* Enable port Rx. */
 	mv643xx_eth_port_enable_rx(port_num, ETH_RX_QUEUES_ENABLED);
 
 	/* Disable port bandwidth limits by clearing MTU register */
-	mv_write(MV643XX_ETH_MAXIMUM_TRANSMIT_UNIT(port_num), 0);
+	mv_write(MAXIMUM_TRANSMIT_UNIT(port_num), 0);
 
 	/* save phy settings across reset */
 	mv643xx_get_settings(dev, &ethtool_cmd);
@@ -1825,11 +2363,11 @@ static void eth_port_uc_addr_set(unsigned int port_num, unsigned char *p_addr)
 	mac_h = (p_addr[0] << 24) | (p_addr[1] << 16) | (p_addr[2] << 8) |
 							(p_addr[3] << 0);
 
-	mv_write(MV643XX_ETH_MAC_ADDR_LOW(port_num), mac_l);
-	mv_write(MV643XX_ETH_MAC_ADDR_HIGH(port_num), mac_h);
+	mv_write(MAC_ADDR_LOW(port_num), mac_l);
+	mv_write(MAC_ADDR_HIGH(port_num), mac_h);
 
 	/* Accept frames with this address */
-	table = MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE(port_num);
+	table = DA_FILTER_UNICAST_TABLE_BASE(port_num);
 	eth_port_set_filter_table_entry(table, p_addr[5] & 0x0f);
 }
 
@@ -1841,8 +2379,8 @@ static void eth_port_uc_addr_get(unsigned int port_num, unsigned char *p_addr)
 	unsigned int mac_h;
 	unsigned int mac_l;
 
-	mac_h = mv_read(MV643XX_ETH_MAC_ADDR_HIGH(port_num));
-	mac_l = mv_read(MV643XX_ETH_MAC_ADDR_LOW(port_num));
+	mac_h = mv_read(MAC_ADDR_HIGH(port_num));
+	mac_l = mv_read(MAC_ADDR_LOW(port_num));
 
 	p_addr[0] = (mac_h >> 24) & 0xff;
 	p_addr[1] = (mac_h >> 16) & 0xff;
@@ -1902,7 +2440,7 @@ static void eth_port_mc_addr(unsigned int eth_port_num, unsigned char *p_addr)
 
 	if ((p_addr[0] == 0x01) && (p_addr[1] == 0x00) &&
 	    (p_addr[2] == 0x5E) && (p_addr[3] == 0x00) && (p_addr[4] == 0x00)) {
-		table = MV643XX_ETH_DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE
+		table = DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE
 					(eth_port_num);
 		eth_port_set_filter_table_entry(table, p_addr[5]);
 		return;
@@ -1976,7 +2514,7 @@ static void eth_port_mc_addr(unsigned int eth_port_num, unsigned char *p_addr)
 	for (i = 0; i < 8; i++)
 		crc_result = crc_result | (crc[i] << i);
 
-	table = MV643XX_ETH_DA_FILTER_OTHER_MULTICAST_TABLE_BASE(eth_port_num);
+	table = DA_FILTER_OTHER_MULTICAST_TABLE_BASE(eth_port_num);
 	eth_port_set_filter_table_entry(table, crc_result);
 }
 
@@ -2006,7 +2544,7 @@ static void eth_port_set_multicast_list(struct net_device *dev)
 			 * 3-1  Queue	 ETH_Q0=0
 			 * 7-4  Reserved = 0;
 			 */
-			mv_write(MV643XX_ETH_DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(eth_port_num) + table_index, 0x01010101);
+			mv_write(DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(eth_port_num) + table_index, 0x01010101);
 
 			/* Set all entries in DA filter other multicast
 			 * table (Ex_dFOMT)
@@ -2016,7 +2554,7 @@ static void eth_port_set_multicast_list(struct net_device *dev)
 			 * 3-1  Queue	 ETH_Q0=0
 			 * 7-4  Reserved = 0;
 			 */
-			mv_write(MV643XX_ETH_DA_FILTER_OTHER_MULTICAST_TABLE_BASE(eth_port_num) + table_index, 0x01010101);
+			mv_write(DA_FILTER_OTHER_MULTICAST_TABLE_BASE(eth_port_num) + table_index, 0x01010101);
 		}
 		return;
 	}
@@ -2026,11 +2564,11 @@ static void eth_port_set_multicast_list(struct net_device *dev)
 	 */
 	for (table_index = 0; table_index <= 0xFC; table_index += 4) {
 		/* Clear DA filter special multicast table (Ex_dFSMT) */
-		mv_write(MV643XX_ETH_DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE
+		mv_write(DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE
 				(eth_port_num) + table_index, 0);
 
 		/* Clear DA filter other multicast table (Ex_dFOMT) */
-		mv_write(MV643XX_ETH_DA_FILTER_OTHER_MULTICAST_TABLE_BASE
+		mv_write(DA_FILTER_OTHER_MULTICAST_TABLE_BASE
 				(eth_port_num) + table_index, 0);
 	}
 
@@ -2064,15 +2602,15 @@ static void eth_port_init_mac_tables(unsigned int eth_port_num)
 
 	/* Clear DA filter unicast table (Ex_dFUT) */
 	for (table_index = 0; table_index <= 0xC; table_index += 4)
-		mv_write(MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE
+		mv_write(DA_FILTER_UNICAST_TABLE_BASE
 					(eth_port_num) + table_index, 0);
 
 	for (table_index = 0; table_index <= 0xFC; table_index += 4) {
 		/* Clear DA filter special multicast table (Ex_dFSMT) */
-		mv_write(MV643XX_ETH_DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE
+		mv_write(DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE
 					(eth_port_num) + table_index, 0);
 		/* Clear DA filter other multicast table (Ex_dFOMT) */
-		mv_write(MV643XX_ETH_DA_FILTER_OTHER_MULTICAST_TABLE_BASE
+		mv_write(DA_FILTER_OTHER_MULTICAST_TABLE_BASE
 					(eth_port_num) + table_index, 0);
 	}
 }
@@ -2101,12 +2639,12 @@ static void eth_clear_mib_counters(unsigned int eth_port_num)
 	/* Perform dummy reads from MIB counters */
 	for (i = ETH_MIB_GOOD_OCTETS_RECEIVED_LOW; i < ETH_MIB_LATE_COLLISION;
 									i += 4)
-		mv_read(MV643XX_ETH_MIB_COUNTERS_BASE(eth_port_num) + i);
+		mv_read(MIB_COUNTERS_BASE(eth_port_num) + i);
 }
 
 static inline u32 read_mib(struct mv643xx_private *mp, int offset)
 {
-	return mv_read(MV643XX_ETH_MIB_COUNTERS_BASE(mp->port_num) + offset);
+	return mv_read(MIB_COUNTERS_BASE(mp->port_num) + offset);
 }
 
 static void eth_update_mib_counters(struct mv643xx_private *mp)
@@ -2191,7 +2729,7 @@ static int ethernet_phy_get(unsigned int eth_port_num)
 {
 	unsigned int reg_data;
 
-	reg_data = mv_read(MV643XX_ETH_PHY_ADDR_REG);
+	reg_data = mv_read(PHY_ADDR_REG);
 
 	return ((reg_data >> (5 * eth_port_num)) & 0x1f);
 }
@@ -2218,10 +2756,10 @@ static void ethernet_phy_set(unsigned int eth_port_num, int phy_addr)
 	u32 reg_data;
 	int addr_shift = 5 * eth_port_num;
 
-	reg_data = mv_read(MV643XX_ETH_PHY_ADDR_REG);
+	reg_data = mv_read(PHY_ADDR_REG);
 	reg_data &= ~(0x1f << addr_shift);
 	reg_data |= (phy_addr & 0x1f) << addr_shift;
-	mv_write(MV643XX_ETH_PHY_ADDR_REG, reg_data);
+	mv_write(PHY_ADDR_REG, reg_data);
 }
 
 /*
@@ -2259,13 +2797,13 @@ static void ethernet_phy_reset(unsigned int eth_port_num)
 static void mv643xx_eth_port_enable_tx(unsigned int port_num,
 					unsigned int queues)
 {
-	mv_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num), queues);
+	mv_write(TRANSMIT_QUEUE_COMMAND_REG(port_num), queues);
 }
 
 static void mv643xx_eth_port_enable_rx(unsigned int port_num,
 					unsigned int queues)
 {
-	mv_write(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num), queues);
+	mv_write(RECEIVE_QUEUE_COMMAND_REG(port_num), queues);
 }
 
 static unsigned int mv643xx_eth_port_disable_tx(unsigned int port_num)
@@ -2273,21 +2811,18 @@ static unsigned int mv643xx_eth_port_disable_tx(unsigned int port_num)
 	u32 queues;
 
 	/* Stop Tx port activity. Check port Tx activity. */
-	queues = mv_read(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num))
-							& 0xFF;
+	queues = mv_read(TRANSMIT_QUEUE_COMMAND_REG(port_num)) & 0xFF;
 	if (queues) {
 		/* Issue stop command for active queues only */
-		mv_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num),
-							(queues << 8));
+		mv_write(TRANSMIT_QUEUE_COMMAND_REG(port_num), (queues << 8));
 
 		/* Wait for all Tx activity to terminate. */
 		/* Check port cause register that all Tx queues are stopped */
-		while (mv_read(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num))
-							& 0xFF)
+		while (mv_read(TRANSMIT_QUEUE_COMMAND_REG(port_num)) & 0xFF)
 			udelay(PHY_WAIT_MICRO_SECONDS);
 
 		/* Wait for Tx FIFO to empty */
-		while (mv_read(MV643XX_ETH_PORT_STATUS_REG(port_num)) &
+		while (mv_read(PORT_STATUS_REG(port_num)) &
 							ETH_PORT_TX_FIFO_EMPTY)
 			udelay(PHY_WAIT_MICRO_SECONDS);
 	}
@@ -2300,17 +2835,14 @@ static unsigned int mv643xx_eth_port_disable_rx(unsigned int port_num)
 	u32 queues;
 
 	/* Stop Rx port activity. Check port Rx activity. */
-	queues = mv_read(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num))
-							& 0xFF;
+	queues = mv_read(RECEIVE_QUEUE_COMMAND_REG(port_num)) & 0xFF;
 	if (queues) {
 		/* Issue stop command for active queues only */
-		mv_write(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num),
-							(queues << 8));
+		mv_write(RECEIVE_QUEUE_COMMAND_REG(port_num), (queues << 8));
 
 		/* Wait for all Rx activity to terminate. */
 		/* Check port cause register that all Rx queues are stopped */
-		while (mv_read(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num))
-							& 0xFF)
+		while (mv_read(RECEIVE_QUEUE_COMMAND_REG(port_num)) & 0xFF)
 			udelay(PHY_WAIT_MICRO_SECONDS);
 	}
 
@@ -2346,11 +2878,11 @@ static void eth_port_reset(unsigned int port_num)
 	eth_clear_mib_counters(port_num);
 
 	/* Reset the Enable bit in the Configuration Register */
-	reg_data = mv_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num));
-	reg_data &= ~(MV643XX_ETH_SERIAL_PORT_ENABLE		|
-			MV643XX_ETH_DO_NOT_FORCE_LINK_FAIL	|
-			MV643XX_ETH_FORCE_LINK_PASS);
-	mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num), reg_data);
+	reg_data = mv_read(PORT_SERIAL_CONTROL_REG(port_num));
+	reg_data &= ~(SERIAL_PORT_ENABLE		|
+			DO_NOT_FORCE_LINK_FAIL	|
+			FORCE_LINK_PASS);
+	mv_write(PORT_SERIAL_CONTROL_REG(port_num), reg_data);
 }
 
 
@@ -2385,7 +2917,7 @@ static void eth_port_read_smi_reg(unsigned int port_num,
 	spin_lock_irqsave(&mv643xx_eth_phy_lock, flags);
 
 	/* wait for the SMI register to become available */
-	for (i = 0; mv_read(MV643XX_ETH_SMI_REG) & ETH_SMI_BUSY; i++) {
+	for (i = 0; mv_read(SMI_REG) & ETH_SMI_BUSY; i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
 			printk("mv643xx PHY busy timeout, port %d\n", port_num);
 			goto out;
@@ -2393,11 +2925,11 @@ static void eth_port_read_smi_reg(unsigned int port_num,
 		udelay(PHY_WAIT_MICRO_SECONDS);
 	}
 
-	mv_write(MV643XX_ETH_SMI_REG,
+	mv_write(SMI_REG,
 		(phy_addr << 16) | (phy_reg << 21) | ETH_SMI_OPCODE_READ);
 
 	/* now wait for the data to be valid */
-	for (i = 0; !(mv_read(MV643XX_ETH_SMI_REG) & ETH_SMI_READ_VALID); i++) {
+	for (i = 0; !(mv_read(SMI_REG) & ETH_SMI_READ_VALID); i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
 			printk("mv643xx PHY read timeout, port %d\n", port_num);
 			goto out;
@@ -2405,7 +2937,7 @@ static void eth_port_read_smi_reg(unsigned int port_num,
 		udelay(PHY_WAIT_MICRO_SECONDS);
 	}
 
-	*value = mv_read(MV643XX_ETH_SMI_REG) & 0xffff;
+	*value = mv_read(SMI_REG) & 0xffff;
 out:
 	spin_unlock_irqrestore(&mv643xx_eth_phy_lock, flags);
 }
@@ -2443,7 +2975,7 @@ static void eth_port_write_smi_reg(unsigned int eth_port_num,
 	spin_lock_irqsave(&mv643xx_eth_phy_lock, flags);
 
 	/* wait for the SMI register to become available */
-	for (i = 0; mv_read(MV643XX_ETH_SMI_REG) & ETH_SMI_BUSY; i++) {
+	for (i = 0; mv_read(SMI_REG) & ETH_SMI_BUSY; i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
 			printk("mv643xx PHY busy timeout, port %d\n",
 								eth_port_num);
@@ -2452,7 +2984,7 @@ static void eth_port_write_smi_reg(unsigned int eth_port_num,
 		udelay(PHY_WAIT_MICRO_SECONDS);
 	}
 
-	mv_write(MV643XX_ETH_SMI_REG, (phy_addr << 16) | (phy_reg << 21) |
+	mv_write(SMI_REG, (phy_addr << 16) | (phy_reg << 21) |
 				ETH_SMI_OPCODE_WRITE | (value & 0xffff));
 out:
 	spin_unlock_irqrestore(&mv643xx_eth_phy_lock, flags);
@@ -2742,6 +3274,7 @@ static const struct ethtool_ops mv643xx_ethtool_ops = {
 	.get_drvinfo            = mv643xx_get_drvinfo,
 	.get_link               = mv643xx_eth_get_link,
 	.set_sg			= ethtool_op_set_sg,
+	.get_sset_count		= mv643xx_get_sset_count,
 	.get_ethtool_stats      = mv643xx_get_ethtool_stats,
 	.get_strings            = mv643xx_get_strings,
 	.nway_reset		= mv643xx_eth_nway_restart,
diff --git a/drivers/net/mv643xx_eth.h b/drivers/net/mv643xx_eth.h
deleted file mode 100644
index be669eb..0000000
--- a/drivers/net/mv643xx_eth.h
+++ /dev/null
@@ -1,370 +0,0 @@
-#ifndef __MV643XX_ETH_H__
-#define __MV643XX_ETH_H__
-
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/spinlock.h>
-#include <linux/workqueue.h>
-#include <linux/mii.h>
-
-#include <linux/mv643xx.h>
-
-#include <asm/dma-mapping.h>
-
-/* Checksum offload for Tx works for most packets, but
- * fails if previous packet sent did not use hw csum
- */
-#define	MV643XX_CHECKSUM_OFFLOAD_TX
-#define	MV643XX_NAPI
-#define	MV643XX_TX_FAST_REFILL
-#undef	MV643XX_COAL
-
-/*
- * Number of RX / TX descriptors on RX / TX rings.
- * Note that allocating RX descriptors is done by allocating the RX
- * ring AND a preallocated RX buffers (skb's) for each descriptor.
- * The TX descriptors only allocates the TX descriptors ring,
- * with no pre allocated TX buffers (skb's are allocated by higher layers.
- */
-
-/* Default TX ring size is 1000 descriptors */
-#define MV643XX_DEFAULT_TX_QUEUE_SIZE 1000
-
-/* Default RX ring size is 400 descriptors */
-#define MV643XX_DEFAULT_RX_QUEUE_SIZE 400
-
-#define MV643XX_TX_COAL 100
-#ifdef MV643XX_COAL
-#define MV643XX_RX_COAL 100
-#endif
-
-#ifdef MV643XX_CHECKSUM_OFFLOAD_TX
-#define MAX_DESCS_PER_SKB	(MAX_SKB_FRAGS + 1)
-#else
-#define MAX_DESCS_PER_SKB	1
-#endif
-
-#define ETH_VLAN_HLEN		4
-#define ETH_FCS_LEN		4
-#define ETH_HW_IP_ALIGN		2		/* hw aligns IP header */
-#define ETH_WRAPPER_LEN		(ETH_HW_IP_ALIGN + ETH_HLEN + \
-					ETH_VLAN_HLEN + ETH_FCS_LEN)
-#define ETH_RX_SKB_SIZE		(dev->mtu + ETH_WRAPPER_LEN + dma_get_cache_alignment())
-
-#define ETH_RX_QUEUES_ENABLED	(1 << 0)	/* use only Q0 for receive */
-#define ETH_TX_QUEUES_ENABLED	(1 << 0)	/* use only Q0 for transmit */
-
-#define ETH_INT_CAUSE_RX_DONE	(ETH_RX_QUEUES_ENABLED << 2)
-#define ETH_INT_CAUSE_RX_ERROR	(ETH_RX_QUEUES_ENABLED << 9)
-#define ETH_INT_CAUSE_RX	(ETH_INT_CAUSE_RX_DONE | ETH_INT_CAUSE_RX_ERROR)
-#define ETH_INT_CAUSE_EXT	0x00000002
-#define ETH_INT_UNMASK_ALL	(ETH_INT_CAUSE_RX | ETH_INT_CAUSE_EXT)
-
-#define ETH_INT_CAUSE_TX_DONE	(ETH_TX_QUEUES_ENABLED << 0)
-#define ETH_INT_CAUSE_TX_ERROR	(ETH_TX_QUEUES_ENABLED << 8)
-#define ETH_INT_CAUSE_TX	(ETH_INT_CAUSE_TX_DONE | ETH_INT_CAUSE_TX_ERROR)
-#define ETH_INT_CAUSE_PHY	0x00010000
-#define ETH_INT_CAUSE_STATE	0x00100000
-#define ETH_INT_UNMASK_ALL_EXT	(ETH_INT_CAUSE_TX | ETH_INT_CAUSE_PHY | \
-					ETH_INT_CAUSE_STATE)
-
-#define ETH_INT_MASK_ALL	0x00000000
-#define ETH_INT_MASK_ALL_EXT	0x00000000
-
-#define PHY_WAIT_ITERATIONS	1000	/* 1000 iterations * 10uS = 10mS max */
-#define PHY_WAIT_MICRO_SECONDS	10
-
-/* Buffer offset from buffer pointer */
-#define RX_BUF_OFFSET				0x2
-
-/* Gigabit Ethernet Unit Global Registers */
-
-/* MIB Counters register definitions */
-#define ETH_MIB_GOOD_OCTETS_RECEIVED_LOW	0x0
-#define ETH_MIB_GOOD_OCTETS_RECEIVED_HIGH	0x4
-#define ETH_MIB_BAD_OCTETS_RECEIVED		0x8
-#define ETH_MIB_INTERNAL_MAC_TRANSMIT_ERR	0xc
-#define ETH_MIB_GOOD_FRAMES_RECEIVED		0x10
-#define ETH_MIB_BAD_FRAMES_RECEIVED		0x14
-#define ETH_MIB_BROADCAST_FRAMES_RECEIVED	0x18
-#define ETH_MIB_MULTICAST_FRAMES_RECEIVED	0x1c
-#define ETH_MIB_FRAMES_64_OCTETS		0x20
-#define ETH_MIB_FRAMES_65_TO_127_OCTETS		0x24
-#define ETH_MIB_FRAMES_128_TO_255_OCTETS	0x28
-#define ETH_MIB_FRAMES_256_TO_511_OCTETS	0x2c
-#define ETH_MIB_FRAMES_512_TO_1023_OCTETS	0x30
-#define ETH_MIB_FRAMES_1024_TO_MAX_OCTETS	0x34
-#define ETH_MIB_GOOD_OCTETS_SENT_LOW		0x38
-#define ETH_MIB_GOOD_OCTETS_SENT_HIGH		0x3c
-#define ETH_MIB_GOOD_FRAMES_SENT		0x40
-#define ETH_MIB_EXCESSIVE_COLLISION		0x44
-#define ETH_MIB_MULTICAST_FRAMES_SENT		0x48
-#define ETH_MIB_BROADCAST_FRAMES_SENT		0x4c
-#define ETH_MIB_UNREC_MAC_CONTROL_RECEIVED	0x50
-#define ETH_MIB_FC_SENT				0x54
-#define ETH_MIB_GOOD_FC_RECEIVED		0x58
-#define ETH_MIB_BAD_FC_RECEIVED			0x5c
-#define ETH_MIB_UNDERSIZE_RECEIVED		0x60
-#define ETH_MIB_FRAGMENTS_RECEIVED		0x64
-#define ETH_MIB_OVERSIZE_RECEIVED		0x68
-#define ETH_MIB_JABBER_RECEIVED			0x6c
-#define ETH_MIB_MAC_RECEIVE_ERROR		0x70
-#define ETH_MIB_BAD_CRC_EVENT			0x74
-#define ETH_MIB_COLLISION			0x78
-#define ETH_MIB_LATE_COLLISION			0x7c
-
-/* Port serial status reg (PSR) */
-#define ETH_INTERFACE_PCM			0x00000001
-#define ETH_LINK_IS_UP				0x00000002
-#define ETH_PORT_AT_FULL_DUPLEX			0x00000004
-#define ETH_RX_FLOW_CTRL_ENABLED		0x00000008
-#define ETH_GMII_SPEED_1000			0x00000010
-#define ETH_MII_SPEED_100			0x00000020
-#define ETH_TX_IN_PROGRESS			0x00000080
-#define ETH_BYPASS_ACTIVE			0x00000100
-#define ETH_PORT_AT_PARTITION_STATE		0x00000200
-#define ETH_PORT_TX_FIFO_EMPTY			0x00000400
-
-/* SMI reg */
-#define ETH_SMI_BUSY		0x10000000	/* 0 - Write, 1 - Read	*/
-#define ETH_SMI_READ_VALID	0x08000000	/* 0 - Write, 1 - Read	*/
-#define ETH_SMI_OPCODE_WRITE	0		/* Completion of Read	*/
-#define ETH_SMI_OPCODE_READ 	0x04000000	/* Operation is in progress */
-
-/* Interrupt Cause Register Bit Definitions */
-
-/* SDMA command status fields macros */
-
-/* Tx & Rx descriptors status */
-#define ETH_ERROR_SUMMARY			0x00000001
-
-/* Tx & Rx descriptors command */
-#define ETH_BUFFER_OWNED_BY_DMA			0x80000000
-
-/* Tx descriptors status */
-#define ETH_LC_ERROR				0
-#define ETH_UR_ERROR				0x00000002
-#define ETH_RL_ERROR				0x00000004
-#define ETH_LLC_SNAP_FORMAT			0x00000200
-
-/* Rx descriptors status */
-#define ETH_OVERRUN_ERROR			0x00000002
-#define ETH_MAX_FRAME_LENGTH_ERROR		0x00000004
-#define ETH_RESOURCE_ERROR			0x00000006
-#define ETH_VLAN_TAGGED				0x00080000
-#define ETH_BPDU_FRAME				0x00100000
-#define ETH_UDP_FRAME_OVER_IP_V_4		0x00200000
-#define ETH_OTHER_FRAME_TYPE			0x00400000
-#define ETH_LAYER_2_IS_ETH_V_2			0x00800000
-#define ETH_FRAME_TYPE_IP_V_4			0x01000000
-#define ETH_FRAME_HEADER_OK			0x02000000
-#define ETH_RX_LAST_DESC			0x04000000
-#define ETH_RX_FIRST_DESC			0x08000000
-#define ETH_UNKNOWN_DESTINATION_ADDR		0x10000000
-#define ETH_RX_ENABLE_INTERRUPT			0x20000000
-#define ETH_LAYER_4_CHECKSUM_OK			0x40000000
-
-/* Rx descriptors byte count */
-#define ETH_FRAME_FRAGMENTED			0x00000004
-
-/* Tx descriptors command */
-#define ETH_LAYER_4_CHECKSUM_FIRST_DESC		0x00000400
-#define ETH_FRAME_SET_TO_VLAN			0x00008000
-#define ETH_UDP_FRAME				0x00010000
-#define ETH_GEN_TCP_UDP_CHECKSUM		0x00020000
-#define ETH_GEN_IP_V_4_CHECKSUM			0x00040000
-#define ETH_ZERO_PADDING			0x00080000
-#define ETH_TX_LAST_DESC			0x00100000
-#define ETH_TX_FIRST_DESC			0x00200000
-#define ETH_GEN_CRC				0x00400000
-#define ETH_TX_ENABLE_INTERRUPT			0x00800000
-#define ETH_AUTO_MODE				0x40000000
-
-#define ETH_TX_IHL_SHIFT			11
-
-/* typedefs */
-
-typedef enum _eth_func_ret_status {
-	ETH_OK,			/* Returned as expected.		*/
-	ETH_ERROR,		/* Fundamental error.			*/
-	ETH_RETRY,		/* Could not process request. Try later.*/
-	ETH_END_OF_JOB,		/* Ring has nothing to process.		*/
-	ETH_QUEUE_FULL,		/* Ring resource error.			*/
-	ETH_QUEUE_LAST_RESOURCE	/* Ring resources about to exhaust.	*/
-} ETH_FUNC_RET_STATUS;
-
-typedef enum _eth_target {
-	ETH_TARGET_DRAM,
-	ETH_TARGET_DEVICE,
-	ETH_TARGET_CBS,
-	ETH_TARGET_PCI0,
-	ETH_TARGET_PCI1
-} ETH_TARGET;
-
-/* These are for big-endian machines.  Little endian needs different
- * definitions.
- */
-#if defined(__BIG_ENDIAN)
-struct eth_rx_desc {
-	u16 byte_cnt;		/* Descriptor buffer byte count		*/
-	u16 buf_size;		/* Buffer size				*/
-	u32 cmd_sts;		/* Descriptor command status		*/
-	u32 next_desc_ptr;	/* Next descriptor pointer		*/
-	u32 buf_ptr;		/* Descriptor buffer pointer		*/
-};
-
-struct eth_tx_desc {
-	u16 byte_cnt;		/* buffer byte count			*/
-	u16 l4i_chk;		/* CPU provided TCP checksum		*/
-	u32 cmd_sts;		/* Command/status field			*/
-	u32 next_desc_ptr;	/* Pointer to next descriptor		*/
-	u32 buf_ptr;		/* pointer to buffer for this descriptor*/
-};
-
-#elif defined(__LITTLE_ENDIAN)
-struct eth_rx_desc {
-	u32 cmd_sts;		/* Descriptor command status		*/
-	u16 buf_size;		/* Buffer size				*/
-	u16 byte_cnt;		/* Descriptor buffer byte count		*/
-	u32 buf_ptr;		/* Descriptor buffer pointer		*/
-	u32 next_desc_ptr;	/* Next descriptor pointer		*/
-};
-
-struct eth_tx_desc {
-	u32 cmd_sts;		/* Command/status field			*/
-	u16 l4i_chk;		/* CPU provided TCP checksum		*/
-	u16 byte_cnt;		/* buffer byte count			*/
-	u32 buf_ptr;		/* pointer to buffer for this descriptor*/
-	u32 next_desc_ptr;	/* Pointer to next descriptor		*/
-};
-#else
-#error One of __BIG_ENDIAN or __LITTLE_ENDIAN must be defined
-#endif
-
-/* Unified struct for Rx and Tx operations. The user is not required to	*/
-/* be familier with neither Tx nor Rx descriptors.			*/
-struct pkt_info {
-	unsigned short byte_cnt;	/* Descriptor buffer byte count	*/
-	unsigned short l4i_chk;		/* Tx CPU provided TCP Checksum	*/
-	unsigned int cmd_sts;		/* Descriptor command status	*/
-	dma_addr_t buf_ptr;		/* Descriptor buffer pointer	*/
-	struct sk_buff *return_info;	/* User resource return information */
-};
-
-/* Ethernet port specific information */
-
-struct mv643xx_mib_counters {
-	u64 good_octets_received;
-	u32 bad_octets_received;
-	u32 internal_mac_transmit_err;
-	u32 good_frames_received;
-	u32 bad_frames_received;
-	u32 broadcast_frames_received;
-	u32 multicast_frames_received;
-	u32 frames_64_octets;
-	u32 frames_65_to_127_octets;
-	u32 frames_128_to_255_octets;
-	u32 frames_256_to_511_octets;
-	u32 frames_512_to_1023_octets;
-	u32 frames_1024_to_max_octets;
-	u64 good_octets_sent;
-	u32 good_frames_sent;
-	u32 excessive_collision;
-	u32 multicast_frames_sent;
-	u32 broadcast_frames_sent;
-	u32 unrec_mac_control_received;
-	u32 fc_sent;
-	u32 good_fc_received;
-	u32 bad_fc_received;
-	u32 undersize_received;
-	u32 fragments_received;
-	u32 oversize_received;
-	u32 jabber_received;
-	u32 mac_receive_error;
-	u32 bad_crc_event;
-	u32 collision;
-	u32 late_collision;
-};
-
-struct mv643xx_private {
-	int port_num;			/* User Ethernet port number	*/
-
-	u32 rx_sram_addr;		/* Base address of rx sram area */
-	u32 rx_sram_size;		/* Size of rx sram area		*/
-	u32 tx_sram_addr;		/* Base address of tx sram area */
-	u32 tx_sram_size;		/* Size of tx sram area		*/
-
-	int rx_resource_err;		/* Rx ring resource error flag */
-
-	/* Tx/Rx rings managment indexes fields. For driver use */
-
-	/* Next available and first returning Rx resource */
-	int rx_curr_desc_q, rx_used_desc_q;
-
-	/* Next available and first returning Tx resource */
-	int tx_curr_desc_q, tx_used_desc_q;
-
-#ifdef MV643XX_TX_FAST_REFILL
-	u32 tx_clean_threshold;
-#endif
-
-	struct eth_rx_desc *p_rx_desc_area;
-	dma_addr_t rx_desc_dma;
-	int rx_desc_area_size;
-	struct sk_buff **rx_skb;
-
-	struct eth_tx_desc *p_tx_desc_area;
-	dma_addr_t tx_desc_dma;
-	int tx_desc_area_size;
-	struct sk_buff **tx_skb;
-
-	struct work_struct tx_timeout_task;
-
-	struct net_device *dev;
-	struct napi_struct napi;
-	struct net_device_stats stats;
-	struct mv643xx_mib_counters mib_counters;
-	spinlock_t lock;
-	/* Size of Tx Ring per queue */
-	int tx_ring_size;
-	/* Number of tx descriptors in use */
-	int tx_desc_count;
-	/* Size of Rx Ring per queue */
-	int rx_ring_size;
-	/* Number of rx descriptors in use */
-	int rx_desc_count;
-
-	/*
-	 * Used in case RX Ring is empty, which can be caused when
-	 * system does not have resources (skb's)
-	 */
-	struct timer_list timeout;
-
-	u32 rx_int_coal;
-	u32 tx_int_coal;
-	struct mii_if_info mii;
-};
-
-/* Port operation control routines */
-static void eth_port_init(struct mv643xx_private *mp);
-static void eth_port_reset(unsigned int eth_port_num);
-static void eth_port_start(struct net_device *dev);
-
-/* PHY and MIB routines */
-static void ethernet_phy_reset(unsigned int eth_port_num);
-
-static void eth_port_write_smi_reg(unsigned int eth_port_num,
-				   unsigned int phy_reg, unsigned int value);
-
-static void eth_port_read_smi_reg(unsigned int eth_port_num,
-				  unsigned int phy_reg, unsigned int *value);
-
-static void eth_clear_mib_counters(unsigned int eth_port_num);
-
-/* Port data flow control routines */
-static ETH_FUNC_RET_STATUS eth_port_receive(struct mv643xx_private *mp,
-					    struct pkt_info *p_pkt_info);
-static ETH_FUNC_RET_STATUS eth_rx_return_buff(struct mv643xx_private *mp,
-					      struct pkt_info *p_pkt_info);
-
-#endif				/* __MV643XX_ETH_H__ */
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 9f9a421..ab4d309 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -550,7 +550,7 @@ static int pasemi_mac_clean_rx(struct pasemi_mac *mac, int limit)
 
 	n = mac->rx->next_to_clean;
 
-	prefetch(RX_RING(mac, n));
+	prefetch(&RX_RING(mac, n));
 
 	for (count = 0; count < limit; count++) {
 		macrx = RX_RING(mac, n);
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 419c00c..e8960f2 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -44,7 +44,8 @@
 		printk( "Assertion failed! %s,%s,%s,line=%d\n",	\
 		#expr,__FILE__,__FUNCTION__,__LINE__);		\
 	}
-#define dprintk(fmt, args...)	do { printk(PFX fmt, ## args); } while (0)
+#define dprintk(fmt, args...) \
+	do { printk(KERN_DEBUG PFX fmt, ## args); } while (0)
 #else
 #define assert(expr) do {} while (0)
 #define dprintk(fmt, args...)	do {} while (0)
@@ -111,19 +112,15 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_05 = 0x05, // 8110SCd
 	RTL_GIGA_MAC_VER_06 = 0x06, // 8110SCe
 	RTL_GIGA_MAC_VER_11 = 0x0b, // 8168Bb
-	RTL_GIGA_MAC_VER_12 = 0x0c, // 8168Be 8168Bf
-	RTL_GIGA_MAC_VER_13 = 0x0d, // 8101Eb 8101Ec
-	RTL_GIGA_MAC_VER_14 = 0x0e, // 8101
-	RTL_GIGA_MAC_VER_15 = 0x0f  // 8101
-};
-
-enum phy_version {
-	RTL_GIGA_PHY_VER_C = 0x03, /* PHY Reg 0x03 bit0-3 == 0x0000 */
-	RTL_GIGA_PHY_VER_D = 0x04, /* PHY Reg 0x03 bit0-3 == 0x0000 */
-	RTL_GIGA_PHY_VER_E = 0x05, /* PHY Reg 0x03 bit0-3 == 0x0000 */
-	RTL_GIGA_PHY_VER_F = 0x06, /* PHY Reg 0x03 bit0-3 == 0x0001 */
-	RTL_GIGA_PHY_VER_G = 0x07, /* PHY Reg 0x03 bit0-3 == 0x0002 */
-	RTL_GIGA_PHY_VER_H = 0x08, /* PHY Reg 0x03 bit0-3 == 0x0003 */
+	RTL_GIGA_MAC_VER_12 = 0x0c, // 8168Be
+	RTL_GIGA_MAC_VER_13 = 0x0d, // 8101Eb
+	RTL_GIGA_MAC_VER_14 = 0x0e, // 8101 ?
+	RTL_GIGA_MAC_VER_15 = 0x0f, // 8101 ?
+	RTL_GIGA_MAC_VER_16 = 0x11, // 8101Ec
+	RTL_GIGA_MAC_VER_17 = 0x10, // 8168Bf
+	RTL_GIGA_MAC_VER_18 = 0x12, // 8168CP
+	RTL_GIGA_MAC_VER_19 = 0x13, // 8168C
+	RTL_GIGA_MAC_VER_20 = 0x14  // 8168C
 };
 
 #define _R(NAME,MAC,MASK) \
@@ -144,7 +141,12 @@ static const struct {
 	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_12, 0xff7e1880), // PCI-E
 	_R("RTL8101e",		RTL_GIGA_MAC_VER_13, 0xff7e1880), // PCI-E 8139
 	_R("RTL8100e",		RTL_GIGA_MAC_VER_14, 0xff7e1880), // PCI-E 8139
-	_R("RTL8100e",		RTL_GIGA_MAC_VER_15, 0xff7e1880)  // PCI-E 8139
+	_R("RTL8100e",		RTL_GIGA_MAC_VER_15, 0xff7e1880), // PCI-E 8139
+	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_17, 0xff7e1880), // PCI-E
+	_R("RTL8101e",		RTL_GIGA_MAC_VER_16, 0xff7e1880), // PCI-E
+	_R("RTL8168cp/8111cp",	RTL_GIGA_MAC_VER_18, 0xff7e1880), // PCI-E
+	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_19, 0xff7e1880), // PCI-E
+	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_20, 0xff7e1880)  // PCI-E
 };
 #undef _R
 
@@ -165,7 +167,7 @@ static struct pci_device_id rtl8169_pci_tbl[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8168), 0, 0, RTL_CFG_1 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8169), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4300), 0, 0, RTL_CFG_0 },
-	{ PCI_DEVICE(0x1259,			0xc107), 0, 0, RTL_CFG_0 },
+	{ PCI_DEVICE(PCI_VENDOR_ID_AT,		0xc107), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(0x16ec,			0x0116), 0, 0, RTL_CFG_0 },
 	{ PCI_VENDOR_ID_LINKSYS,		0x1032,
 		PCI_ANY_ID, 0x0024, 0, 0, RTL_CFG_0 },
@@ -277,6 +279,7 @@ enum rtl_register_content {
 	TxDMAShift = 8,	/* DMA burst value (0-7) is shift this many bits */
 
 	/* Config1 register p.24 */
+	MSIEnable	= (1 << 5),	/* Enable Message Signaled Interrupt */
 	PMEnable	= (1 << 0),	/* Power Management Enable */
 
 	/* Config2 register p. 25 */
@@ -380,17 +383,20 @@ struct ring_info {
 	u8		__pad[sizeof(void *) - sizeof(u32)];
 };
 
+enum features {
+	RTL_FEATURE_WOL	= (1 << 0),
+	RTL_FEATURE_MSI	= (1 << 1),
+};
+
 struct rtl8169_private {
 	void __iomem *mmio_addr;	/* memory map physical address */
 	struct pci_dev *pci_dev;	/* Index of PCI device */
 	struct net_device *dev;
 	struct napi_struct napi;
-	struct net_device_stats stats;	/* statistics of net device */
 	spinlock_t lock;		/* spin lock flag */
 	u32 msg_enable;
 	int chipset;
 	int mac_version;
-	int phy_version;
 	u32 cur_rx; /* Index into the Rx descriptor buffer of next Rx pkt. */
 	u32 cur_tx; /* Index into the Tx descriptor buffer of next Rx pkt. */
 	u32 dirty_rx;
@@ -420,7 +426,7 @@ struct rtl8169_private {
 	unsigned int (*phy_reset_pending)(void __iomem *);
 	unsigned int (*link_ok)(void __iomem *);
 	struct delayed_work task;
-	unsigned wol_enabled : 1;
+	unsigned features;
 };
 
 MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
@@ -626,7 +632,10 @@ static int rtl8169_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
-	tp->wol_enabled = (wol->wolopts) ? 1 : 0;
+	if (wol->wolopts)
+		tp->features |= RTL_FEATURE_WOL;
+	else
+		tp->features &= ~RTL_FEATURE_WOL;
 
 	spin_unlock_irq(&tp->lock);
 
@@ -707,7 +716,8 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 
 		/* This tweak comes straight from Realtek's driver. */
 		if ((speed == SPEED_100) && (duplex == DUPLEX_HALF) &&
-		    (tp->mac_version == RTL_GIGA_MAC_VER_13)) {
+		    ((tp->mac_version == RTL_GIGA_MAC_VER_13) ||
+		     (tp->mac_version == RTL_GIGA_MAC_VER_16))) {
 			auto_nego = ADVERTISE_100HALF | ADVERTISE_CSMA;
 		}
 	}
@@ -715,7 +725,8 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 	/* The 8100e/8101e do Fast Ethernet only. */
 	if ((tp->mac_version == RTL_GIGA_MAC_VER_13) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_14) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_15)) {
+	    (tp->mac_version == RTL_GIGA_MAC_VER_15) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_16)) {
 		if ((giga_ctrl & (ADVERTISE_1000FULL | ADVERTISE_1000HALF)) &&
 		    netif_msg_link(tp)) {
 			printk(KERN_INFO "%s: PHY does not support 1000Mbps.\n",
@@ -726,7 +737,8 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 
 	auto_nego |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_12) {
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_12) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_17)) {
 		/* Vendor specific (0x1f) and reserved (0x0e) MII registers. */
 		mdio_write(ioaddr, 0x1f, 0x0000);
 		mdio_write(ioaddr, 0x0e, 0x0000);
@@ -1104,26 +1116,51 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 	 */
 	const struct {
 		u32 mask;
+		u32 val;
 		int mac_version;
 	} mac_info[] = {
-		{ 0x38800000,	RTL_GIGA_MAC_VER_15 },
-		{ 0x38000000,	RTL_GIGA_MAC_VER_12 },
-		{ 0x34000000,	RTL_GIGA_MAC_VER_13 },
-		{ 0x30800000,	RTL_GIGA_MAC_VER_14 },
-		{ 0x30000000,	RTL_GIGA_MAC_VER_11 },
-		{ 0x98000000,	RTL_GIGA_MAC_VER_06 },
-		{ 0x18000000,	RTL_GIGA_MAC_VER_05 },
-		{ 0x10000000,	RTL_GIGA_MAC_VER_04 },
-		{ 0x04000000,	RTL_GIGA_MAC_VER_03 },
-		{ 0x00800000,	RTL_GIGA_MAC_VER_02 },
-		{ 0x00000000,	RTL_GIGA_MAC_VER_01 }	/* Catch-all */
+		/* 8168B family. */
+		{ 0x7c800000, 0x3c800000,	RTL_GIGA_MAC_VER_18 },
+		{ 0x7cf00000, 0x3c000000,	RTL_GIGA_MAC_VER_19 },
+		{ 0x7cf00000, 0x3c200000,	RTL_GIGA_MAC_VER_20 },
+		{ 0x7c800000, 0x3c000000,	RTL_GIGA_MAC_VER_20 },
+
+		/* 8168B family. */
+		{ 0x7cf00000, 0x38000000,	RTL_GIGA_MAC_VER_12 },
+		{ 0x7cf00000, 0x38500000,	RTL_GIGA_MAC_VER_17 },
+		{ 0x7c800000, 0x38000000,	RTL_GIGA_MAC_VER_17 },
+		{ 0x7c800000, 0x30000000,	RTL_GIGA_MAC_VER_11 },
+
+		/* 8101 family. */
+		{ 0x7cf00000, 0x34000000,	RTL_GIGA_MAC_VER_13 },
+		{ 0x7cf00000, 0x34200000,	RTL_GIGA_MAC_VER_16 },
+		{ 0x7c800000, 0x34000000,	RTL_GIGA_MAC_VER_16 },
+		/* FIXME: where did these entries come from ? -- FR */
+		{ 0xfc800000, 0x38800000,	RTL_GIGA_MAC_VER_15 },
+		{ 0xfc800000, 0x30800000,	RTL_GIGA_MAC_VER_14 },
+
+		/* 8110 family. */
+		{ 0xfc800000, 0x98000000,	RTL_GIGA_MAC_VER_06 },
+		{ 0xfc800000, 0x18000000,	RTL_GIGA_MAC_VER_05 },
+		{ 0xfc800000, 0x10000000,	RTL_GIGA_MAC_VER_04 },
+		{ 0xfc800000, 0x04000000,	RTL_GIGA_MAC_VER_03 },
+		{ 0xfc800000, 0x00800000,	RTL_GIGA_MAC_VER_02 },
+		{ 0xfc800000, 0x00000000,	RTL_GIGA_MAC_VER_01 },
+
+		{ 0x00000000, 0x00000000,	RTL_GIGA_MAC_VER_01 }	/* Catch-all */
 	}, *p = mac_info;
 	u32 reg;
 
-	reg = RTL_R32(TxConfig) & 0xfc800000;
-	while ((reg & p->mask) != p->mask)
+	reg = RTL_R32(TxConfig);
+	while ((reg & p->mask) != p->val)
 		p++;
 	tp->mac_version = p->mac_version;
+
+	if (p->mask == 0x00000000) {
+		struct pci_dev *pdev = tp->pci_dev;
+
+		dev_info(&pdev->dev, "unknown MAC (%08x)\n", reg);
+	}
 }
 
 static void rtl8169_print_mac_version(struct rtl8169_private *tp)
@@ -1131,54 +1168,21 @@ static void rtl8169_print_mac_version(struct rtl8169_private *tp)
 	dprintk("mac_version = 0x%02x\n", tp->mac_version);
 }
 
-static void rtl8169_get_phy_version(struct rtl8169_private *tp,
-				    void __iomem *ioaddr)
-{
-	const struct {
-		u16 mask;
-		u16 set;
-		int phy_version;
-	} phy_info[] = {
-		{ 0x000f, 0x0002, RTL_GIGA_PHY_VER_G },
-		{ 0x000f, 0x0001, RTL_GIGA_PHY_VER_F },
-		{ 0x000f, 0x0000, RTL_GIGA_PHY_VER_E },
-		{ 0x0000, 0x0000, RTL_GIGA_PHY_VER_D } /* Catch-all */
-	}, *p = phy_info;
+struct phy_reg {
 	u16 reg;
+	u16 val;
+};
 
-	reg = mdio_read(ioaddr, MII_PHYSID2) & 0xffff;
-	while ((reg & p->mask) != p->set)
-		p++;
-	tp->phy_version = p->phy_version;
-}
-
-static void rtl8169_print_phy_version(struct rtl8169_private *tp)
+static void rtl_phy_write(void __iomem *ioaddr, struct phy_reg *regs, int len)
 {
-	struct {
-		int version;
-		char *msg;
-		u32 reg;
-	} phy_print[] = {
-		{ RTL_GIGA_PHY_VER_G, "RTL_GIGA_PHY_VER_G", 0x0002 },
-		{ RTL_GIGA_PHY_VER_F, "RTL_GIGA_PHY_VER_F", 0x0001 },
-		{ RTL_GIGA_PHY_VER_E, "RTL_GIGA_PHY_VER_E", 0x0000 },
-		{ RTL_GIGA_PHY_VER_D, "RTL_GIGA_PHY_VER_D", 0x0000 },
-		{ 0, NULL, 0x0000 }
-	}, *p;
-
-	for (p = phy_print; p->msg; p++) {
-		if (tp->phy_version == p->version) {
-			dprintk("phy_version == %s (%04x)\n", p->msg, p->reg);
-			return;
-		}
+	while (len-- > 0) {
+		mdio_write(ioaddr, regs->reg, regs->val);
+		regs++;
 	}
-	dprintk("phy_version == Unknown\n");
 }
 
-static void rtl8169_hw_phy_config(struct net_device *dev)
+static void rtl8169s_hw_phy_config(void __iomem *ioaddr)
 {
-	struct rtl8169_private *tp = netdev_priv(dev);
-	void __iomem *ioaddr = tp->mmio_addr;
 	struct {
 		u16 regs[5]; /* Beware of bit-sign propagation */
 	} phy_magic[5] = { {
@@ -1211,33 +1215,9 @@ static void rtl8169_hw_phy_config(struct net_device *dev)
 	}, *p = phy_magic;
 	unsigned int i;
 
-	rtl8169_print_mac_version(tp);
-	rtl8169_print_phy_version(tp);
-
-	if (tp->mac_version <= RTL_GIGA_MAC_VER_01)
-		return;
-	if (tp->phy_version >= RTL_GIGA_PHY_VER_H)
-		return;
-
-	dprintk("MAC version != 0 && PHY version == 0 or 1\n");
-	dprintk("Do final_reg2.cfg\n");
-
-	/* Shazam ! */
-
-	if (tp->mac_version == RTL_GIGA_MAC_VER_04) {
-		mdio_write(ioaddr, 31, 0x0002);
-		mdio_write(ioaddr,  1, 0x90d0);
-		mdio_write(ioaddr, 31, 0x0000);
-		return;
-	}
-
-	if ((tp->mac_version != RTL_GIGA_MAC_VER_02) &&
-	    (tp->mac_version != RTL_GIGA_MAC_VER_03))
-		return;
-
-	mdio_write(ioaddr, 31, 0x0001);			//w 31 2 0 1
-	mdio_write(ioaddr, 21, 0x1000);			//w 21 15 0 1000
-	mdio_write(ioaddr, 24, 0x65c7);			//w 24 15 0 65c7
+	mdio_write(ioaddr, 0x1f, 0x0001);		//w 31 2 0 1
+	mdio_write(ioaddr, 0x15, 0x1000);		//w 21 15 0 1000
+	mdio_write(ioaddr, 0x18, 0x65c7);		//w 24 15 0 65c7
 	rtl8169_write_gmii_reg_bit(ioaddr, 4, 11, 0);	//w 4 11 11 0
 
 	for (i = 0; i < ARRAY_SIZE(phy_magic); i++, p++) {
@@ -1250,7 +1230,115 @@ static void rtl8169_hw_phy_config(struct net_device *dev)
 		rtl8169_write_gmii_reg_bit(ioaddr, 4, 11, 1); //w 4 11 11 1
 		rtl8169_write_gmii_reg_bit(ioaddr, 4, 11, 0); //w 4 11 11 0
 	}
-	mdio_write(ioaddr, 31, 0x0000); //w 31 2 0 0
+	mdio_write(ioaddr, 0x1f, 0x0000); //w 31 2 0 0
+}
+
+static void rtl8169sb_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0002 },
+		{ 0x01, 0x90d0 },
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+static void rtl8168b_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0000 },
+		{ 0x10, 0xf41b },
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
+static void rtl8168cp_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0000 },
+		{ 0x1d, 0x0f00 },
+		{ 0x1f, 0x0002 },
+		{ 0x0c, 0x1ec8 },
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
+static void rtl8168c_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0001 },
+		{ 0x12, 0x2300 },
+		{ 0x1f, 0x0002 },
+		{ 0x00, 0x88d4 },
+		{ 0x01, 0x82b1 },
+		{ 0x03, 0x7002 },
+		{ 0x08, 0x9e30 },
+		{ 0x09, 0x01f0 },
+		{ 0x0a, 0x5500 },
+		{ 0x0c, 0x00c8 },
+		{ 0x1f, 0x0003 },
+		{ 0x12, 0xc096 },
+		{ 0x16, 0x000a },
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
+static void rtl8168cx_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0000 },
+		{ 0x12, 0x2300 },
+		{ 0x1f, 0x0003 },
+		{ 0x16, 0x0f0a },
+		{ 0x1f, 0x0000 },
+		{ 0x1f, 0x0002 },
+		{ 0x0c, 0x7eb8 },
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
+static void rtl_hw_phy_config(struct net_device *dev)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	rtl8169_print_mac_version(tp);
+
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_01:
+		break;
+	case RTL_GIGA_MAC_VER_02:
+	case RTL_GIGA_MAC_VER_03:
+		rtl8169s_hw_phy_config(ioaddr);
+		break;
+	case RTL_GIGA_MAC_VER_04:
+		rtl8169sb_hw_phy_config(ioaddr);
+		break;
+	case RTL_GIGA_MAC_VER_11:
+	case RTL_GIGA_MAC_VER_12:
+	case RTL_GIGA_MAC_VER_17:
+		rtl8168b_hw_phy_config(ioaddr);
+		break;
+	case RTL_GIGA_MAC_VER_18:
+		rtl8168cp_hw_phy_config(ioaddr);
+		break;
+	case RTL_GIGA_MAC_VER_19:
+		rtl8168c_hw_phy_config(ioaddr);
+		break;
+	case RTL_GIGA_MAC_VER_20:
+		rtl8168cx_hw_phy_config(ioaddr);
+		break;
+	default:
+		break;
+	}
 }
 
 static void rtl8169_phy_timer(unsigned long __opaque)
@@ -1262,7 +1350,6 @@ static void rtl8169_phy_timer(unsigned long __opaque)
 	unsigned long timeout = RTL8169_PHY_TIMEOUT;
 
 	assert(tp->mac_version > RTL_GIGA_MAC_VER_01);
-	assert(tp->phy_version < RTL_GIGA_PHY_VER_H);
 
 	if (!(tp->phy_1000_ctrl_reg & ADVERTISE_1000FULL))
 		return;
@@ -1297,8 +1384,7 @@ static inline void rtl8169_delete_timer(struct net_device *dev)
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct timer_list *timer = &tp->timer;
 
-	if ((tp->mac_version <= RTL_GIGA_MAC_VER_01) ||
-	    (tp->phy_version >= RTL_GIGA_PHY_VER_H))
+	if (tp->mac_version <= RTL_GIGA_MAC_VER_01)
 		return;
 
 	del_timer_sync(timer);
@@ -1309,8 +1395,7 @@ static inline void rtl8169_request_timer(struct net_device *dev)
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct timer_list *timer = &tp->timer;
 
-	if ((tp->mac_version <= RTL_GIGA_MAC_VER_01) ||
-	    (tp->phy_version >= RTL_GIGA_PHY_VER_H))
+	if (tp->mac_version <= RTL_GIGA_MAC_VER_01)
 		return;
 
 	mod_timer(timer, jiffies + RTL8169_PHY_TIMEOUT);
@@ -1362,7 +1447,7 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 
-	rtl8169_hw_phy_config(dev);
+	rtl_hw_phy_config(dev);
 
 	dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
 	RTL_W8(0x82, 0x01);
@@ -1457,6 +1542,7 @@ static const struct rtl_cfg_info {
 	unsigned int align;
 	u16 intr_event;
 	u16 napi_event;
+	unsigned msi;
 } rtl_cfg_infos [] = {
 	[RTL_CFG_0] = {
 		.hw_start	= rtl_hw_start_8169,
@@ -1464,7 +1550,8 @@ static const struct rtl_cfg_info {
 		.align		= 0,
 		.intr_event	= SYSErr | LinkChg | RxOverflow |
 				  RxFIFOOver | TxErr | TxOK | RxOK | RxErr,
-		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow
+		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow,
+		.msi		= 0
 	},
 	[RTL_CFG_1] = {
 		.hw_start	= rtl_hw_start_8168,
@@ -1472,7 +1559,8 @@ static const struct rtl_cfg_info {
 		.align		= 8,
 		.intr_event	= SYSErr | LinkChg | RxOverflow |
 				  TxErr | TxOK | RxOK | RxErr,
-		.napi_event	= TxErr | TxOK | RxOK | RxOverflow
+		.napi_event	= TxErr | TxOK | RxOK | RxOverflow,
+		.msi		= RTL_FEATURE_MSI
 	},
 	[RTL_CFG_2] = {
 		.hw_start	= rtl_hw_start_8101,
@@ -1480,10 +1568,39 @@ static const struct rtl_cfg_info {
 		.align		= 8,
 		.intr_event	= SYSErr | LinkChg | RxOverflow | PCSTimeout |
 				  RxFIFOOver | TxErr | TxOK | RxOK | RxErr,
-		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow
+		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow,
+		.msi		= RTL_FEATURE_MSI
 	}
 };
 
+/* Cfg9346_Unlock assumed. */
+static unsigned rtl_try_msi(struct pci_dev *pdev, void __iomem *ioaddr,
+			    const struct rtl_cfg_info *cfg)
+{
+	unsigned msi = 0;
+	u8 cfg2;
+
+	cfg2 = RTL_R8(Config2) & ~MSIEnable;
+	if (cfg->msi) {
+		if (pci_enable_msi(pdev)) {
+			dev_info(&pdev->dev, "no MSI. Back to INTx.\n");
+		} else {
+			cfg2 |= MSIEnable;
+			msi = RTL_FEATURE_MSI;
+		}
+	}
+	RTL_W8(Config2, cfg2);
+	return msi;
+}
+
+static void rtl_disable_msi(struct pci_dev *pdev, struct rtl8169_private *tp)
+{
+	if (tp->features & RTL_FEATURE_MSI) {
+		pci_disable_msi(pdev);
+		tp->features &= ~RTL_FEATURE_MSI;
+	}
+}
+
 static int __devinit
 rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -1596,10 +1713,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* Identify chip attached to board */
 	rtl8169_get_mac_version(tp, ioaddr);
-	rtl8169_get_phy_version(tp, ioaddr);
 
 	rtl8169_print_mac_version(tp);
-	rtl8169_print_phy_version(tp);
 
 	for (i = ARRAY_SIZE(rtl_chip_info) - 1; i >= 0; i--) {
 		if (tp->mac_version == rtl_chip_info[i].mac_version)
@@ -1619,6 +1734,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 	RTL_W8(Config1, RTL_R8(Config1) | PMEnable);
 	RTL_W8(Config5, RTL_R8(Config5) & PMEStatus);
+	tp->features |= rtl_try_msi(pdev, ioaddr, cfg);
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
 	if (RTL_R8(PHYstatus) & TBI_Enable) {
@@ -1686,7 +1802,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	rc = register_netdev(dev);
 	if (rc < 0)
-		goto err_out_unmap_5;
+		goto err_out_msi_5;
 
 	pci_set_drvdata(pdev, dev);
 
@@ -1709,7 +1825,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 out:
 	return rc;
 
-err_out_unmap_5:
+err_out_msi_5:
+	rtl_disable_msi(pdev, tp);
 	iounmap(ioaddr);
 err_out_free_res_4:
 	pci_release_regions(pdev);
@@ -1730,6 +1847,7 @@ static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
 	flush_scheduled_work();
 
 	unregister_netdev(dev);
+	rtl_disable_msi(pdev, tp);
 	rtl8169_release_board(pdev, dev, tp->mmio_addr);
 	pci_set_drvdata(pdev, NULL);
 }
@@ -1773,7 +1891,8 @@ static int rtl8169_open(struct net_device *dev)
 
 	smp_mb();
 
-	retval = request_irq(dev->irq, rtl8169_interrupt, IRQF_SHARED,
+	retval = request_irq(dev->irq, rtl8169_interrupt,
+			     (tp->features & RTL_FEATURE_MSI) ? 0 : IRQF_SHARED,
 			     dev->name, dev);
 	if (retval < 0)
 		goto err_release_ring_2;
@@ -1933,7 +2052,7 @@ static void rtl_hw_start_8169(struct net_device *dev)
 
 	if ((tp->mac_version == RTL_GIGA_MAC_VER_02) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_03)) {
-		dprintk(KERN_INFO PFX "Set MAC Reg C+CR Offset 0xE0. "
+		dprintk("Set MAC Reg C+CR Offset 0xE0. "
 			"Bit-3 and bit-14 MUST be 1\n");
 		tp->cp_cmd |= (1 << 14);
 	}
@@ -2029,7 +2148,8 @@ static void rtl_hw_start_8101(struct net_device *dev)
 	void __iomem *ioaddr = tp->mmio_addr;
 	struct pci_dev *pdev = tp->pci_dev;
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_13) {
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_13) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_16)) {
 		pci_write_config_word(pdev, 0x68, 0x00);
 		pci_write_config_word(pdev, 0x69, 0x08);
 	}
@@ -2259,7 +2379,7 @@ static void rtl8169_tx_clear(struct rtl8169_private *tp)
 				dev_kfree_skb(skb);
 				tx_skb->skb = NULL;
 			}
-			tp->stats.tx_dropped++;
+			tp->dev->stats.tx_dropped++;
 		}
 	}
 	tp->cur_tx = tp->dirty_tx = 0;
@@ -2310,7 +2430,7 @@ static void rtl8169_reinit_task(struct work_struct *work)
 	ret = rtl8169_open(dev);
 	if (unlikely(ret < 0)) {
 		if (net_ratelimit() && netif_msg_drv(tp)) {
-			printk(PFX KERN_ERR "%s: reinit failure (status = %d)."
+			printk(KERN_ERR PFX "%s: reinit failure (status = %d)."
 			       " Rescheduling.\n", dev->name, ret);
 		}
 		rtl8169_schedule_work(dev, rtl8169_reinit_task);
@@ -2340,9 +2460,10 @@ static void rtl8169_reset_task(struct work_struct *work)
 		rtl8169_init_ring_indexes(tp);
 		rtl_hw_start(dev);
 		netif_wake_queue(dev);
+		rtl8169_check_link_status(dev, tp, tp->mmio_addr);
 	} else {
 		if (net_ratelimit() && netif_msg_intr(tp)) {
-			printk(PFX KERN_EMERG "%s: Rx buffers shortage\n",
+			printk(KERN_EMERG PFX "%s: Rx buffers shortage\n",
 			       dev->name);
 		}
 		rtl8169_schedule_work(dev, rtl8169_reset_task);
@@ -2496,7 +2617,7 @@ err_stop:
 	netif_stop_queue(dev);
 	ret = NETDEV_TX_BUSY;
 err_update_stats:
-	tp->stats.tx_dropped++;
+	dev->stats.tx_dropped++;
 	goto out;
 }
 
@@ -2571,8 +2692,8 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 		if (status & DescOwn)
 			break;
 
-		tp->stats.tx_bytes += len;
-		tp->stats.tx_packets++;
+		dev->stats.tx_bytes += len;
+		dev->stats.tx_packets++;
 
 		rtl8169_unmap_tx_skb(tp->pci_dev, tx_skb, tp->TxDescArray + entry);
 
@@ -2672,14 +2793,14 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 				       "%s: Rx ERROR. status = %08x\n",
 				       dev->name, status);
 			}
-			tp->stats.rx_errors++;
+			dev->stats.rx_errors++;
 			if (status & (RxRWT | RxRUNT))
-				tp->stats.rx_length_errors++;
+				dev->stats.rx_length_errors++;
 			if (status & RxCRC)
-				tp->stats.rx_crc_errors++;
+				dev->stats.rx_crc_errors++;
 			if (status & RxFOVF) {
 				rtl8169_schedule_work(dev, rtl8169_reset_task);
-				tp->stats.rx_fifo_errors++;
+				dev->stats.rx_fifo_errors++;
 			}
 			rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
 		} else {
@@ -2694,8 +2815,8 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 			 * sized frames.
 			 */
 			if (unlikely(rtl8169_fragmented_frame(status))) {
-				tp->stats.rx_dropped++;
-				tp->stats.rx_length_errors++;
+				dev->stats.rx_dropped++;
+				dev->stats.rx_length_errors++;
 				rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
 				continue;
 			}
@@ -2719,8 +2840,8 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 				rtl8169_rx_skb(skb);
 
 			dev->last_rx = jiffies;
-			tp->stats.rx_bytes += pkt_size;
-			tp->stats.rx_packets++;
+			dev->stats.rx_bytes += pkt_size;
+			dev->stats.rx_packets++;
 		}
 
 		/* Work around for AMD plateform. */
@@ -2881,7 +3002,7 @@ core_down:
 	rtl8169_asic_down(ioaddr);
 
 	/* Update the error counts. */
-	tp->stats.rx_missed_errors += RTL_R32(RxMissed);
+	dev->stats.rx_missed_errors += RTL_R32(RxMissed);
 	RTL_W32(RxMissed, 0);
 
 	spin_unlock_irq(&tp->lock);
@@ -2984,7 +3105,9 @@ static void rtl_set_rx_mode(struct net_device *dev)
 	    (tp->mac_version == RTL_GIGA_MAC_VER_12) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_13) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_14) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_15)) {
+	    (tp->mac_version == RTL_GIGA_MAC_VER_15) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_16) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_17)) {
 		mc_filter[0] = 0xffffffff;
 		mc_filter[1] = 0xffffffff;
 	}
@@ -3011,12 +3134,12 @@ static struct net_device_stats *rtl8169_get_stats(struct net_device *dev)
 
 	if (netif_running(dev)) {
 		spin_lock_irqsave(&tp->lock, flags);
-		tp->stats.rx_missed_errors += RTL_R32(RxMissed);
+		dev->stats.rx_missed_errors += RTL_R32(RxMissed);
 		RTL_W32(RxMissed, 0);
 		spin_unlock_irqrestore(&tp->lock, flags);
 	}
 
-	return &tp->stats;
+	return &dev->stats;
 }
 
 #ifdef CONFIG_PM
@@ -3037,14 +3160,15 @@ static int rtl8169_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	rtl8169_asic_down(ioaddr);
 
-	tp->stats.rx_missed_errors += RTL_R32(RxMissed);
+	dev->stats.rx_missed_errors += RTL_R32(RxMissed);
 	RTL_W32(RxMissed, 0);
 
 	spin_unlock_irq(&tp->lock);
 
 out_pci_suspend:
 	pci_save_state(pdev);
-	pci_enable_wake(pdev, pci_choose_state(pdev, state), tp->wol_enabled);
+	pci_enable_wake(pdev, pci_choose_state(pdev, state),
+		(tp->features & RTL_FEATURE_WOL) ? 1 : 0);
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
 
 	return 0;
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 24cfb62..c27c7d6 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -4271,7 +4271,7 @@ static void __devexit sky2_remove(struct pci_dev *pdev)
 	del_timer_sync(&hw->watchdog_timer);
 	cancel_work_sync(&hw->restart_work);
 
-	for (i = hw->ports; i >= 0; --i)
+	for (i = hw->ports-1; i >= 0; --i)
 		unregister_netdev(hw->dev[i]);
 
 	sky2_write32(hw, B0_IMSK, 0);
@@ -4289,7 +4289,7 @@ static void __devexit sky2_remove(struct pci_dev *pdev)
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 
-	for (i = hw->ports; i >= 0; --i)
+	for (i = hw->ports-1; i >= 0; --i)
 		free_netdev(hw->dev[i]);
 
 	iounmap(hw->regs);
diff --git a/include/linux/mv643xx.h b/include/linux/mv643xx.h
index 9c80490..d2ae618 100644
--- a/include/linux/mv643xx.h
+++ b/include/linux/mv643xx.h
@@ -14,6 +14,7 @@
 #define __ASM_MV643XX_H
 
 #include <asm/types.h>
+#include <linux/mv643xx_eth.h>
 
 /****************************************/
 /* Processor Address Space              */
@@ -658,120 +659,6 @@
 /*        Ethernet Unit Registers  		*/
 /****************************************/
 
-#define MV643XX_ETH_SHARED_REGS                                     0x2000
-#define MV643XX_ETH_SHARED_REGS_SIZE                                0x2000
-
-#define MV643XX_ETH_PHY_ADDR_REG                                    0x2000
-#define MV643XX_ETH_SMI_REG                                         0x2004
-#define MV643XX_ETH_UNIT_DEFAULT_ADDR_REG                           0x2008
-#define MV643XX_ETH_UNIT_DEFAULTID_REG                              0x200c
-#define MV643XX_ETH_UNIT_INTERRUPT_CAUSE_REG                        0x2080
-#define MV643XX_ETH_UNIT_INTERRUPT_MASK_REG                         0x2084
-#define MV643XX_ETH_UNIT_INTERNAL_USE_REG                           0x24fc
-#define MV643XX_ETH_UNIT_ERROR_ADDR_REG                             0x2094
-#define MV643XX_ETH_BAR_0                                           0x2200
-#define MV643XX_ETH_BAR_1                                           0x2208
-#define MV643XX_ETH_BAR_2                                           0x2210
-#define MV643XX_ETH_BAR_3                                           0x2218
-#define MV643XX_ETH_BAR_4                                           0x2220
-#define MV643XX_ETH_BAR_5                                           0x2228
-#define MV643XX_ETH_SIZE_REG_0                                      0x2204
-#define MV643XX_ETH_SIZE_REG_1                                      0x220c
-#define MV643XX_ETH_SIZE_REG_2                                      0x2214
-#define MV643XX_ETH_SIZE_REG_3                                      0x221c
-#define MV643XX_ETH_SIZE_REG_4                                      0x2224
-#define MV643XX_ETH_SIZE_REG_5                                      0x222c
-#define MV643XX_ETH_HEADERS_RETARGET_BASE_REG                       0x2230
-#define MV643XX_ETH_HEADERS_RETARGET_CONTROL_REG                    0x2234
-#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_0                           0x2280
-#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_1                           0x2284
-#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_2                           0x2288
-#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_3                           0x228c
-#define MV643XX_ETH_BASE_ADDR_ENABLE_REG                            0x2290
-#define MV643XX_ETH_ACCESS_PROTECTION_REG(port)                    (0x2294 + (port<<2))
-#define MV643XX_ETH_MIB_COUNTERS_BASE(port)                        (0x3000 + (port<<7))
-#define MV643XX_ETH_PORT_CONFIG_REG(port)                          (0x2400 + (port<<10))
-#define MV643XX_ETH_PORT_CONFIG_EXTEND_REG(port)                   (0x2404 + (port<<10))
-#define MV643XX_ETH_MII_SERIAL_PARAMETRS_REG(port)                 (0x2408 + (port<<10))
-#define MV643XX_ETH_GMII_SERIAL_PARAMETRS_REG(port)                (0x240c + (port<<10))
-#define MV643XX_ETH_VLAN_ETHERTYPE_REG(port)                       (0x2410 + (port<<10))
-#define MV643XX_ETH_MAC_ADDR_LOW(port)                             (0x2414 + (port<<10))
-#define MV643XX_ETH_MAC_ADDR_HIGH(port)                            (0x2418 + (port<<10))
-#define MV643XX_ETH_SDMA_CONFIG_REG(port)                          (0x241c + (port<<10))
-#define MV643XX_ETH_DSCP_0(port)                                   (0x2420 + (port<<10))
-#define MV643XX_ETH_DSCP_1(port)                                   (0x2424 + (port<<10))
-#define MV643XX_ETH_DSCP_2(port)                                   (0x2428 + (port<<10))
-#define MV643XX_ETH_DSCP_3(port)                                   (0x242c + (port<<10))
-#define MV643XX_ETH_DSCP_4(port)                                   (0x2430 + (port<<10))
-#define MV643XX_ETH_DSCP_5(port)                                   (0x2434 + (port<<10))
-#define MV643XX_ETH_DSCP_6(port)                                   (0x2438 + (port<<10))
-#define MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port)                  (0x243c + (port<<10))
-#define MV643XX_ETH_VLAN_PRIORITY_TAG_TO_PRIORITY(port)            (0x2440 + (port<<10))
-#define MV643XX_ETH_PORT_STATUS_REG(port)                          (0x2444 + (port<<10))
-#define MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port)               (0x2448 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_FIXED_PRIORITY(port)                  (0x244c + (port<<10))
-#define MV643XX_ETH_PORT_TX_TOKEN_BUCKET_RATE_CONFIG(port)         (0x2450 + (port<<10))
-#define MV643XX_ETH_MAXIMUM_TRANSMIT_UNIT(port)                    (0x2458 + (port<<10))
-#define MV643XX_ETH_PORT_MAXIMUM_TOKEN_BUCKET_SIZE(port)           (0x245c + (port<<10))
-#define MV643XX_ETH_INTERRUPT_CAUSE_REG(port)                      (0x2460 + (port<<10))
-#define MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port)               (0x2464 + (port<<10))
-#define MV643XX_ETH_INTERRUPT_MASK_REG(port)                       (0x2468 + (port<<10))
-#define MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG(port)                (0x246c + (port<<10))
-#define MV643XX_ETH_RX_FIFO_URGENT_THRESHOLD_REG(port)             (0x2470 + (port<<10))
-#define MV643XX_ETH_TX_FIFO_URGENT_THRESHOLD_REG(port)             (0x2474 + (port<<10))
-#define MV643XX_ETH_RX_MINIMAL_FRAME_SIZE_REG(port)                (0x247c + (port<<10))
-#define MV643XX_ETH_RX_DISCARDED_FRAMES_COUNTER(port)              (0x2484 + (port<<10))
-#define MV643XX_ETH_PORT_DEBUG_0_REG(port)                         (0x248c + (port<<10))
-#define MV643XX_ETH_PORT_DEBUG_1_REG(port)                         (0x2490 + (port<<10))
-#define MV643XX_ETH_PORT_INTERNAL_ADDR_ERROR_REG(port)             (0x2494 + (port<<10))
-#define MV643XX_ETH_INTERNAL_USE_REG(port)                         (0x24fc + (port<<10))
-#define MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port)                (0x2680 + (port<<10))
-#define MV643XX_ETH_CURRENT_SERVED_TX_DESC_PTR(port)               (0x2684 + (port<<10))      
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(port)              (0x260c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_1(port)              (0x261c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_2(port)              (0x262c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_3(port)              (0x263c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_4(port)              (0x264c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_5(port)              (0x265c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_6(port)              (0x266c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_7(port)              (0x267c + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_0(port)              (0x26c0 + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_1(port)              (0x26c4 + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_2(port)              (0x26c8 + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_3(port)              (0x26cc + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_4(port)              (0x26d0 + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_5(port)              (0x26d4 + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_6(port)              (0x26d8 + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_7(port)              (0x26dc + (port<<10))     
-#define MV643XX_ETH_TX_QUEUE_0_TOKEN_BUCKET_COUNT(port)            (0x2700 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_1_TOKEN_BUCKET_COUNT(port)            (0x2710 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_2_TOKEN_BUCKET_COUNT(port)            (0x2720 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_3_TOKEN_BUCKET_COUNT(port)            (0x2730 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_4_TOKEN_BUCKET_COUNT(port)            (0x2740 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_5_TOKEN_BUCKET_COUNT(port)            (0x2750 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_6_TOKEN_BUCKET_COUNT(port)            (0x2760 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_7_TOKEN_BUCKET_COUNT(port)            (0x2770 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_0_TOKEN_BUCKET_CONFIG(port)           (0x2704 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_1_TOKEN_BUCKET_CONFIG(port)           (0x2714 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_2_TOKEN_BUCKET_CONFIG(port)           (0x2724 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_3_TOKEN_BUCKET_CONFIG(port)           (0x2734 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_4_TOKEN_BUCKET_CONFIG(port)           (0x2744 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_5_TOKEN_BUCKET_CONFIG(port)           (0x2754 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_6_TOKEN_BUCKET_CONFIG(port)           (0x2764 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_7_TOKEN_BUCKET_CONFIG(port)           (0x2774 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_0_ARBITER_CONFIG(port)                (0x2708 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_1_ARBITER_CONFIG(port)                (0x2718 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_2_ARBITER_CONFIG(port)                (0x2728 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_3_ARBITER_CONFIG(port)                (0x2738 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_4_ARBITER_CONFIG(port)                (0x2748 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_5_ARBITER_CONFIG(port)                (0x2758 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_6_ARBITER_CONFIG(port)                (0x2768 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_7_ARBITER_CONFIG(port)                (0x2778 + (port<<10))
-#define MV643XX_ETH_PORT_TX_TOKEN_BUCKET_COUNT(port)               (0x2780 + (port<<10))
-#define MV643XX_ETH_DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(port)   (0x3400 + (port<<10))
-#define MV643XX_ETH_DA_FILTER_OTHER_MULTICAST_TABLE_BASE(port)     (0x3500 + (port<<10))
-#define MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE(port)             (0x3600 + (port<<10))
-
 /*******************************************/
 /*          CUNIT  Registers               */
 /*******************************************/
@@ -1089,219 +976,6 @@ struct mv64xxx_i2c_pdata {
 	u32	retries;
 };
 
-/* These macros describe Ethernet Port configuration reg (Px_cR) bits */
-#define MV643XX_ETH_UNICAST_NORMAL_MODE		0
-#define MV643XX_ETH_UNICAST_PROMISCUOUS_MODE	(1<<0)
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_0		0
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_1		(1<<1)
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_2		(1<<2)
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_3		((1<<2) | (1<<1))
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_4		(1<<3)
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_5		((1<<3) | (1<<1))
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_6		((1<<3) | (1<<2))
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_7		((1<<3) | (1<<2) | (1<<1))
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_0	0
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_1	(1<<4)
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_2	(1<<5)
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_3	((1<<5) | (1<<4))
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_4	(1<<6)
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_5	((1<<6) | (1<<4))
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_6	((1<<6) | (1<<5))
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_7	((1<<6) | (1<<5) | (1<<4))
-#define MV643XX_ETH_RECEIVE_BC_IF_NOT_IP_OR_ARP	0
-#define MV643XX_ETH_REJECT_BC_IF_NOT_IP_OR_ARP	(1<<7)
-#define MV643XX_ETH_RECEIVE_BC_IF_IP		0
-#define MV643XX_ETH_REJECT_BC_IF_IP		(1<<8)
-#define MV643XX_ETH_RECEIVE_BC_IF_ARP		0
-#define MV643XX_ETH_REJECT_BC_IF_ARP		(1<<9)
-#define MV643XX_ETH_TX_AM_NO_UPDATE_ERROR_SUMMARY (1<<12)
-#define MV643XX_ETH_CAPTURE_TCP_FRAMES_DIS	0
-#define MV643XX_ETH_CAPTURE_TCP_FRAMES_EN	(1<<14)
-#define MV643XX_ETH_CAPTURE_UDP_FRAMES_DIS	0
-#define MV643XX_ETH_CAPTURE_UDP_FRAMES_EN	(1<<15)
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_0	0
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_1	(1<<16)
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_2	(1<<17)
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_3	((1<<17) | (1<<16))
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_4	(1<<18)
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_5	((1<<18) | (1<<16))
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_6	((1<<18) | (1<<17))
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_7	((1<<18) | (1<<17) | (1<<16))
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_0	0
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_1	(1<<19)
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_2	(1<<20)
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_3	((1<<20) | (1<<19))
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_4	(1<<21)
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_5	((1<<21) | (1<<19))
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_6	((1<<21) | (1<<20))
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_7	((1<<21) | (1<<20) | (1<<19))
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_0	0
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_1	(1<<22)
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_2	(1<<23)
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_3	((1<<23) | (1<<22))
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_4	(1<<24)
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_5	((1<<24) | (1<<22))
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_6	((1<<24) | (1<<23))
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_7	((1<<24) | (1<<23) | (1<<22))
-
-#define	MV643XX_ETH_PORT_CONFIG_DEFAULT_VALUE			\
-		MV643XX_ETH_UNICAST_NORMAL_MODE		|	\
-		MV643XX_ETH_DEFAULT_RX_QUEUE_0		|	\
-		MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_0	|	\
-		MV643XX_ETH_RECEIVE_BC_IF_NOT_IP_OR_ARP	|	\
-		MV643XX_ETH_RECEIVE_BC_IF_IP		|	\
-		MV643XX_ETH_RECEIVE_BC_IF_ARP		|	\
-		MV643XX_ETH_CAPTURE_TCP_FRAMES_DIS	|	\
-		MV643XX_ETH_CAPTURE_UDP_FRAMES_DIS	|	\
-		MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_0	|	\
-		MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_0	|	\
-		MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_0
-
-/* These macros describe Ethernet Port configuration extend reg (Px_cXR) bits*/
-#define MV643XX_ETH_CLASSIFY_EN				(1<<0)
-#define MV643XX_ETH_SPAN_BPDU_PACKETS_AS_NORMAL		0
-#define MV643XX_ETH_SPAN_BPDU_PACKETS_TO_RX_QUEUE_7	(1<<1)
-#define MV643XX_ETH_PARTITION_DISABLE			0
-#define MV643XX_ETH_PARTITION_ENABLE			(1<<2)
-
-#define	MV643XX_ETH_PORT_CONFIG_EXTEND_DEFAULT_VALUE		\
-		MV643XX_ETH_SPAN_BPDU_PACKETS_AS_NORMAL	|	\
-		MV643XX_ETH_PARTITION_DISABLE
-
-/* These macros describe Ethernet Port Sdma configuration reg (SDCR) bits */
-#define MV643XX_ETH_RIFB			(1<<0)
-#define MV643XX_ETH_RX_BURST_SIZE_1_64BIT		0
-#define MV643XX_ETH_RX_BURST_SIZE_2_64BIT		(1<<1)
-#define MV643XX_ETH_RX_BURST_SIZE_4_64BIT		(1<<2)
-#define MV643XX_ETH_RX_BURST_SIZE_8_64BIT		((1<<2) | (1<<1))
-#define MV643XX_ETH_RX_BURST_SIZE_16_64BIT		(1<<3)
-#define MV643XX_ETH_BLM_RX_NO_SWAP			(1<<4)
-#define MV643XX_ETH_BLM_RX_BYTE_SWAP			0
-#define MV643XX_ETH_BLM_TX_NO_SWAP			(1<<5)
-#define MV643XX_ETH_BLM_TX_BYTE_SWAP			0
-#define MV643XX_ETH_DESCRIPTORS_BYTE_SWAP		(1<<6)
-#define MV643XX_ETH_DESCRIPTORS_NO_SWAP			0
-#define MV643XX_ETH_TX_BURST_SIZE_1_64BIT		0
-#define MV643XX_ETH_TX_BURST_SIZE_2_64BIT		(1<<22)
-#define MV643XX_ETH_TX_BURST_SIZE_4_64BIT		(1<<23)
-#define MV643XX_ETH_TX_BURST_SIZE_8_64BIT		((1<<23) | (1<<22))
-#define MV643XX_ETH_TX_BURST_SIZE_16_64BIT		(1<<24)
-
-#define	MV643XX_ETH_IPG_INT_RX(value) ((value & 0x3fff) << 8)
-
-#define	MV643XX_ETH_PORT_SDMA_CONFIG_DEFAULT_VALUE		\
-		MV643XX_ETH_RX_BURST_SIZE_4_64BIT	|	\
-		MV643XX_ETH_IPG_INT_RX(0)		|	\
-		MV643XX_ETH_TX_BURST_SIZE_4_64BIT
-
-/* These macros describe Ethernet Port serial control reg (PSCR) bits */
-#define MV643XX_ETH_SERIAL_PORT_DISABLE			0
-#define MV643XX_ETH_SERIAL_PORT_ENABLE			(1<<0)
-#define MV643XX_ETH_FORCE_LINK_PASS			(1<<1)
-#define MV643XX_ETH_DO_NOT_FORCE_LINK_PASS		0
-#define MV643XX_ETH_ENABLE_AUTO_NEG_FOR_DUPLX		0
-#define MV643XX_ETH_DISABLE_AUTO_NEG_FOR_DUPLX		(1<<2)
-#define MV643XX_ETH_ENABLE_AUTO_NEG_FOR_FLOW_CTRL	0
-#define MV643XX_ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL	(1<<3)
-#define MV643XX_ETH_ADV_NO_FLOW_CTRL			0
-#define MV643XX_ETH_ADV_SYMMETRIC_FLOW_CTRL		(1<<4)
-#define MV643XX_ETH_FORCE_FC_MODE_NO_PAUSE_DIS_TX	0
-#define MV643XX_ETH_FORCE_FC_MODE_TX_PAUSE_DIS		(1<<5)
-#define MV643XX_ETH_FORCE_BP_MODE_NO_JAM		0
-#define MV643XX_ETH_FORCE_BP_MODE_JAM_TX		(1<<7)
-#define MV643XX_ETH_FORCE_BP_MODE_JAM_TX_ON_RX_ERR	(1<<8)
-#define MV643XX_ETH_SERIAL_PORT_CONTROL_RESERVED	(1<<9)
-#define MV643XX_ETH_FORCE_LINK_FAIL			0
-#define MV643XX_ETH_DO_NOT_FORCE_LINK_FAIL		(1<<10)
-#define MV643XX_ETH_RETRANSMIT_16_ATTEMPTS		0
-#define MV643XX_ETH_RETRANSMIT_FOREVER			(1<<11)
-#define MV643XX_ETH_DISABLE_AUTO_NEG_SPEED_GMII		(1<<13)
-#define MV643XX_ETH_ENABLE_AUTO_NEG_SPEED_GMII		0
-#define MV643XX_ETH_DTE_ADV_0				0
-#define MV643XX_ETH_DTE_ADV_1				(1<<14)
-#define MV643XX_ETH_DISABLE_AUTO_NEG_BYPASS		0
-#define MV643XX_ETH_ENABLE_AUTO_NEG_BYPASS		(1<<15)
-#define MV643XX_ETH_AUTO_NEG_NO_CHANGE			0
-#define MV643XX_ETH_RESTART_AUTO_NEG			(1<<16)
-#define MV643XX_ETH_MAX_RX_PACKET_1518BYTE		0
-#define MV643XX_ETH_MAX_RX_PACKET_1522BYTE		(1<<17)
-#define MV643XX_ETH_MAX_RX_PACKET_1552BYTE		(1<<18)
-#define MV643XX_ETH_MAX_RX_PACKET_9022BYTE		((1<<18) | (1<<17))
-#define MV643XX_ETH_MAX_RX_PACKET_9192BYTE		(1<<19)
-#define MV643XX_ETH_MAX_RX_PACKET_9700BYTE		((1<<19) | (1<<17))
-#define MV643XX_ETH_SET_EXT_LOOPBACK			(1<<20)
-#define MV643XX_ETH_CLR_EXT_LOOPBACK			0
-#define MV643XX_ETH_SET_FULL_DUPLEX_MODE		(1<<21)
-#define MV643XX_ETH_SET_HALF_DUPLEX_MODE		0
-#define MV643XX_ETH_ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX (1<<22)
-#define MV643XX_ETH_DISABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX 0
-#define MV643XX_ETH_SET_GMII_SPEED_TO_10_100		0
-#define MV643XX_ETH_SET_GMII_SPEED_TO_1000		(1<<23)
-#define MV643XX_ETH_SET_MII_SPEED_TO_10			0
-#define MV643XX_ETH_SET_MII_SPEED_TO_100		(1<<24)
-
-#define MV643XX_ETH_MAX_RX_PACKET_MASK			(0x7<<17)
-
-#define	MV643XX_ETH_PORT_SERIAL_CONTROL_DEFAULT_VALUE		\
-		MV643XX_ETH_DO_NOT_FORCE_LINK_PASS	|	\
-		MV643XX_ETH_ENABLE_AUTO_NEG_FOR_DUPLX	|	\
-		MV643XX_ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL |	\
-		MV643XX_ETH_ADV_SYMMETRIC_FLOW_CTRL	|	\
-		MV643XX_ETH_FORCE_FC_MODE_NO_PAUSE_DIS_TX |	\
-		MV643XX_ETH_FORCE_BP_MODE_NO_JAM	|	\
-		(1<<9)	/* reserved */			|	\
-		MV643XX_ETH_DO_NOT_FORCE_LINK_FAIL	|	\
-		MV643XX_ETH_RETRANSMIT_16_ATTEMPTS	|	\
-		MV643XX_ETH_ENABLE_AUTO_NEG_SPEED_GMII	|	\
-		MV643XX_ETH_DTE_ADV_0			|	\
-		MV643XX_ETH_DISABLE_AUTO_NEG_BYPASS	|	\
-		MV643XX_ETH_AUTO_NEG_NO_CHANGE		|	\
-		MV643XX_ETH_MAX_RX_PACKET_9700BYTE	|	\
-		MV643XX_ETH_CLR_EXT_LOOPBACK		|	\
-		MV643XX_ETH_SET_FULL_DUPLEX_MODE	|	\
-		MV643XX_ETH_ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX
-
-/* These macros describe Ethernet Serial Status reg (PSR) bits */
-#define MV643XX_ETH_PORT_STATUS_MODE_10_BIT		(1<<0)
-#define MV643XX_ETH_PORT_STATUS_LINK_UP			(1<<1)
-#define MV643XX_ETH_PORT_STATUS_FULL_DUPLEX		(1<<2)
-#define MV643XX_ETH_PORT_STATUS_FLOW_CONTROL		(1<<3)
-#define MV643XX_ETH_PORT_STATUS_GMII_1000		(1<<4)
-#define MV643XX_ETH_PORT_STATUS_MII_100			(1<<5)
-/* PSR bit 6 is undocumented */
-#define MV643XX_ETH_PORT_STATUS_TX_IN_PROGRESS		(1<<7)
-#define MV643XX_ETH_PORT_STATUS_AUTONEG_BYPASSED	(1<<8)
-#define MV643XX_ETH_PORT_STATUS_PARTITION		(1<<9)
-#define MV643XX_ETH_PORT_STATUS_TX_FIFO_EMPTY		(1<<10)
-/* PSR bits 11-31 are reserved */
-
-#define	MV643XX_ETH_PORT_DEFAULT_TRANSMIT_QUEUE_SIZE	800
-#define	MV643XX_ETH_PORT_DEFAULT_RECEIVE_QUEUE_SIZE	400
-
-#define MV643XX_ETH_DESC_SIZE				64
-
-#define MV643XX_ETH_SHARED_NAME	"mv643xx_eth_shared"
-#define MV643XX_ETH_NAME	"mv643xx_eth"
-
-struct mv643xx_eth_platform_data {
-	int		port_number;
-	u16		force_phy_addr;	/* force override if phy_addr == 0 */
-	u16		phy_addr;
-
-	/* If speed is 0, then speed and duplex are autonegotiated. */
-	int		speed;		/* 0, SPEED_10, SPEED_100, SPEED_1000 */
-	int		duplex;		/* DUPLEX_HALF or DUPLEX_FULL */
-
-	/* non-zero values of the following fields override defaults */
-	u32		tx_queue_size;
-	u32		rx_queue_size;
-	u32		tx_sram_addr;
-	u32		tx_sram_size;
-	u32		rx_sram_addr;
-	u32		rx_sram_size;
-	u8		mac_addr[6];	/* mac address if non-zero*/
-};
-
 /* Watchdog Platform Device, Driver Data */
 #define	MV64x60_WDT_NAME			"mv64x60_wdt"
 
diff --git a/include/linux/mv643xx_eth.h b/include/linux/mv643xx_eth.h
new file mode 100644
index 0000000..3f27239
--- /dev/null
+++ b/include/linux/mv643xx_eth.h
@@ -0,0 +1,31 @@
+/*
+ * MV-643XX ethernet platform device data definition file.
+ */
+#ifndef __LINUX_MV643XX_ETH_H
+#define __LINUX_MV643XX_ETH_H
+
+#define MV643XX_ETH_SHARED_NAME		"mv643xx_eth_shared"
+#define MV643XX_ETH_NAME		"mv643xx_eth"
+#define MV643XX_ETH_SHARED_REGS		0x2000
+#define MV643XX_ETH_SHARED_REGS_SIZE	0x2000
+
+struct mv643xx_eth_platform_data {
+	int		port_number;
+	u16		force_phy_addr;	/* force override if phy_addr == 0 */
+	u16		phy_addr;
+
+	/* If speed is 0, then speed and duplex are autonegotiated. */
+	int		speed;		/* 0, SPEED_10, SPEED_100, SPEED_1000 */
+	int		duplex;		/* DUPLEX_HALF or DUPLEX_FULL */
+
+	/* non-zero values of the following fields override defaults */
+	u32		tx_queue_size;
+	u32		rx_queue_size;
+	u32		tx_sram_addr;
+	u32		tx_sram_size;
+	u32		rx_sram_addr;
+	u32		rx_sram_size;
+	u8		mac_addr[6];	/* mac address if non-zero*/
+};
+
+#endif /* __LINUX_MV643XX_ETH_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4a3f54e..c4de536 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -834,7 +834,7 @@ static inline int dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 				  const void *daddr, const void *saddr,
 				  unsigned len)
 {
-	if (!dev->header_ops)
+	if (!dev->header_ops || !dev->header_ops->create)
 		return 0;
 
 	return dev->header_ops->create(skb, dev, type, daddr, saddr, len);
