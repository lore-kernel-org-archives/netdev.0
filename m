From: Radheka Godse <radheka.godse@intel.com>
Subject: [PATCH 2.6.13-rc1 1/17] bonding: make some functions not static
Date: Fri, 1 Jul 2005 13:36:19 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0507011333270.17459@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch prepares for adding sysfs functionality to bonding by making
some functions in bond_main non-static and adding protos into the header.

Signed-off-by: Radheka Godse <radheka.godse@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>

diff -urN -X dontdiff linux-2.6.12post/drivers/net/bonding/bonding.h linux-2.6.12post-sysfs/drivers/net/bonding/bonding.h
--- linux-2.6.12post/drivers/net/bonding/bonding.h	2005-06-28 18:18:03.000000000 -0700
+++ linux-2.6.12post-sysfs/drivers/net/bonding/bonding.h	2005-06-30 13:58:27.000000000 -0700
@@ -255,6 +255,17 @@

  struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr);
  int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
+void bond_deinit(struct net_device *bond_dev);
+int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
+int bond_sethwaddr(struct net_device *bond_dev, struct net_device *slave_dev);
+void bond_mii_monitor(struct net_device *bond_dev);
+void bond_loadbalance_arp_mon(struct net_device *bond_dev);
+void bond_activebackup_arp_mon(struct net_device *bond_dev);
+void bond_set_mode_ops(struct bonding *bond, int mode);
+int bond_parse_parm(char *mode_arg, struct bond_parm_tbl *tbl);
+const char *bond_mode_name(int mode);
+void bond_select_active_slave(struct bonding *bond);
+void bond_change_active_slave(struct bonding *bond, struct slave *new_active);

  #endif /* _LINUX_BONDING_H */

diff -urN -X dontdiff linux-2.6.12post/drivers/net/bonding/bond_main.c linux-2.6.12post-sysfs/drivers/net/bonding/bond_main.c
--- linux-2.6.12post/drivers/net/bonding/bond_main.c	2005-06-28 18:18:03.000000000 -0700
+++ linux-2.6.12post-sysfs/drivers/net/bonding/bond_main.c	2005-06-30 13:53:55.000000000 -0700
@@ -1453,7 +1453,7 @@
   *
   * Warning: Caller must hold curr_slave_lock for writing.
   */
-static void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
+void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
  {
  	struct slave *old_active = bond->curr_active_slave;

@@ -1527,7 +1527,7 @@
   *
   * Warning: Caller must hold curr_slave_lock for writing.
   */
-static void bond_select_active_slave(struct bonding *bond)
+void bond_select_active_slave(struct bonding *bond)
  {
  	struct slave *best_slave;

@@ -1595,7 +1595,7 @@

  /*---------------------------------- IOCTL ----------------------------------*/

-static int bond_sethwaddr(struct net_device *bond_dev, struct net_device *slave_dev)
+int bond_sethwaddr(struct net_device *bond_dev, struct net_device *slave_dev)
  {
  	dprintk("bond_dev=%p\n", bond_dev);
  	dprintk("slave_dev=%p\n", slave_dev);
@@ -2030,7 +2030,7 @@
   *   for Bonded connections:
   *     The first up interface should be left on and all others downed.
   */
-static int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
+int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
  {
  	struct bonding *bond = bond_dev->priv;
  	struct slave *slave, *oldcurrent;
@@ -2479,7 +2479,7 @@
  /*-------------------------------- Monitoring -------------------------------*/

  /* this function is called regularly to monitor each slave's link. */
-static void bond_mii_monitor(struct net_device *bond_dev)
+void bond_mii_monitor(struct net_device *bond_dev)
  {
  	struct bonding *bond = bond_dev->priv;
  	struct slave *slave, *oldcurrent;
@@ -2904,7 +2904,7 @@
   * arp is transmitted to generate traffic. see activebackup_arp_monitor for
   * arp monitoring in active backup mode.
   */
-static void bond_loadbalance_arp_mon(struct net_device *bond_dev)
+void bond_loadbalance_arp_mon(struct net_device *bond_dev)
  {
  	struct bonding *bond = bond_dev->priv;
  	struct slave *slave, *oldcurrent;
@@ -3042,7 +3042,7 @@
   * may have received.
   * see loadbalance_arp_monitor for arp monitoring in load balancing mode
   */
-static void bond_activebackup_arp_mon(struct net_device *bond_dev)
+void bond_activebackup_arp_mon(struct net_device *bond_dev)
  {
  	struct bonding *bond = bond_dev->priv;
  	struct slave *slave;
@@ -4484,7 +4484,7 @@
  /*
   * set bond mode specific net device operations
   */
-static inline void bond_set_mode_ops(struct bonding *bond, int mode)
+void bond_set_mode_ops(struct bonding *bond, int mode)
  {
  	struct net_device *bond_dev = bond->dev;

@@ -4603,7 +4603,7 @@
  /* De-initialize device specific data.
   * Caller must hold rtnl_lock.
   */
-static inline void bond_deinit(struct net_device *bond_dev)
+void bond_deinit(struct net_device *bond_dev)
  {
  	struct bonding *bond = bond_dev->priv;

@@ -4639,7 +4639,7 @@
   * Convert string input module parms.  Accept either the
   * number of the mode or its string name.
   */
-static inline int bond_parse_parm(char *mode_arg, struct bond_parm_tbl *tbl)
+int bond_parse_parm(char *mode_arg, struct bond_parm_tbl *tbl)
  {
  	int i;
