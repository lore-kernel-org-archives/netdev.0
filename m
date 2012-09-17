From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] netdev: make address const in device address
 management
Date: Mon, 17 Sep 2012 13:03:26 -0700
Message-ID: <20120917130326.028dac29@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55095 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752375Ab2IQUD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2012 16:03:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The internal functions for add/deleting addresses don't change
their argument.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 +-
 drivers/net/macvlan.c                         |    4 +-
 include/linux/netdevice.h                     |   28 +++++++++---------
 net/bridge/br_fdb.c                           |    6 +--
 net/bridge/br_private.h                       |    4 +-
 net/core/dev_addr_lists.c                     |   40 +++++++++++++-------------
 6 files changed, 44 insertions(+), 42 deletions(-)

--- a/drivers/net/macvlan.c	2012-09-17 11:02:16.230810156 -0700
+++ b/drivers/net/macvlan.c	2012-09-17 11:24:34.577369142 -0700
@@ -548,7 +548,7 @@ static int macvlan_vlan_rx_kill_vid(stru
 
 static int macvlan_fdb_add(struct ndmsg *ndm,
 			   struct net_device *dev,
-			   unsigned char *addr,
+			   const unsigned char *addr,
 			   u16 flags)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
@@ -567,7 +567,7 @@ static int macvlan_fdb_add(struct ndmsg
 
 static int macvlan_fdb_del(struct ndmsg *ndm,
 			   struct net_device *dev,
-			   unsigned char *addr)
+			   const unsigned char *addr)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	int err = -EINVAL;
--- a/include/linux/netdevice.h	2012-09-17 11:02:16.230810156 -0700
+++ b/include/linux/netdevice.h	2012-09-17 11:24:34.577369142 -0700
@@ -907,10 +907,10 @@ struct netdev_fcoe_hbainfo {
  *	Must return >0 or -errno if it changed dev->features itself.
  *
  * int (*ndo_fdb_add)(struct ndmsg *ndm, struct net_device *dev,
- *		      unsigned char *addr, u16 flags)
+ *		      const unsigned char *addr, u16 flags)
  *	Adds an FDB entry to dev for addr.
  * int (*ndo_fdb_del)(struct ndmsg *ndm, struct net_device *dev,
- *		      unsigned char *addr)
+ *		      const unsigned char *addr)
  *	Deletes the FDB entry from dev coresponding to addr.
  * int (*ndo_fdb_dump)(struct sk_buff *skb, struct netlink_callback *cb,
  *		       struct net_device *dev, int idx)
@@ -1017,11 +1017,11 @@ struct net_device_ops {
 
 	int			(*ndo_fdb_add)(struct ndmsg *ndm,
 					       struct net_device *dev,
-					       unsigned char *addr,
+					       const unsigned char *addr,
 					       u16 flags);
 	int			(*ndo_fdb_del)(struct ndmsg *ndm,
 					       struct net_device *dev,
-					       unsigned char *addr);
+					       const unsigned char *addr);
 	int			(*ndo_fdb_dump)(struct sk_buff *skb,
 						struct netlink_callback *cb,
 						struct net_device *dev,
@@ -2561,9 +2561,9 @@ extern void __hw_addr_flush(struct netde
 extern void __hw_addr_init(struct netdev_hw_addr_list *list);
 
 /* Functions used for device addresses handling */
-extern int dev_addr_add(struct net_device *dev, unsigned char *addr,
+extern int dev_addr_add(struct net_device *dev, const unsigned char *addr,
 			unsigned char addr_type);
-extern int dev_addr_del(struct net_device *dev, unsigned char *addr,
+extern int dev_addr_del(struct net_device *dev, const unsigned char *addr,
 			unsigned char addr_type);
 extern int dev_addr_add_multiple(struct net_device *to_dev,
 				 struct net_device *from_dev,
@@ -2575,20 +2575,20 @@ extern void dev_addr_flush(struct net_de
 extern int dev_addr_init(struct net_device *dev);
 
 /* Functions used for unicast addresses handling */
-extern int dev_uc_add(struct net_device *dev, unsigned char *addr);
-extern int dev_uc_add_excl(struct net_device *dev, unsigned char *addr);
-extern int dev_uc_del(struct net_device *dev, unsigned char *addr);
+extern int dev_uc_add(struct net_device *dev, const unsigned char *addr);
+extern int dev_uc_add_excl(struct net_device *dev, const unsigned char *addr);
+extern int dev_uc_del(struct net_device *dev, const unsigned char *addr);
 extern int dev_uc_sync(struct net_device *to, struct net_device *from);
 extern void dev_uc_unsync(struct net_device *to, struct net_device *from);
 extern void dev_uc_flush(struct net_device *dev);
 extern void dev_uc_init(struct net_device *dev);
 
 /* Functions used for multicast addresses handling */
-extern int dev_mc_add(struct net_device *dev, unsigned char *addr);
-extern int dev_mc_add_global(struct net_device *dev, unsigned char *addr);
-extern int dev_mc_add_excl(struct net_device *dev, unsigned char *addr);
-extern int dev_mc_del(struct net_device *dev, unsigned char *addr);
-extern int dev_mc_del_global(struct net_device *dev, unsigned char *addr);
+extern int dev_mc_add(struct net_device *dev, const unsigned char *addr);
+extern int dev_mc_add_global(struct net_device *dev, const unsigned char *addr);
+extern int dev_mc_add_excl(struct net_device *dev, const unsigned char *addr);
+extern int dev_mc_del(struct net_device *dev, const unsigned char *addr);
+extern int dev_mc_del_global(struct net_device *dev, const unsigned char *addr);
 extern int dev_mc_sync(struct net_device *to, struct net_device *from);
 extern void dev_mc_unsync(struct net_device *to, struct net_device *from);
 extern void dev_mc_flush(struct net_device *dev);
--- a/net/bridge/br_fdb.c	2012-09-17 11:02:16.230810156 -0700
+++ b/net/bridge/br_fdb.c	2012-09-17 11:24:34.577369142 -0700
@@ -609,7 +609,7 @@ static int fdb_add_entry(struct net_brid
 
 /* Add new permanent fdb entry with RTM_NEWNEIGH */
 int br_fdb_add(struct ndmsg *ndm, struct net_device *dev,
-	       unsigned char *addr, u16 nlh_flags)
+	       const unsigned char *addr, u16 nlh_flags)
 {
 	struct net_bridge_port *p;
 	int err = 0;
@@ -639,7 +639,7 @@ int br_fdb_add(struct ndmsg *ndm, struct
 	return err;
 }
 
-static int fdb_delete_by_addr(struct net_bridge_port *p, u8 *addr)
+static int fdb_delete_by_addr(struct net_bridge_port *p, const u8 *addr)
 {
 	struct net_bridge *br = p->br;
 	struct hlist_head *head = &br->hash[br_mac_hash(addr)];
@@ -655,7 +655,7 @@ static int fdb_delete_by_addr(struct net
 
 /* Remove neighbor entry with RTM_DELNEIGH */
 int br_fdb_delete(struct ndmsg *ndm, struct net_device *dev,
-		  unsigned char *addr)
+		  const unsigned char *addr)
 {
 	struct net_bridge_port *p;
 	int err;
--- a/net/bridge/br_private.h	2012-09-17 11:02:16.230810156 -0700
+++ b/net/bridge/br_private.h	2012-09-17 11:24:34.577369142 -0700
@@ -363,10 +363,10 @@ extern void br_fdb_update(struct net_bri
 
 extern int br_fdb_delete(struct ndmsg *ndm,
 			 struct net_device *dev,
-			 unsigned char *addr);
+			 const unsigned char *addr);
 extern int br_fdb_add(struct ndmsg *nlh,
 		      struct net_device *dev,
-		      unsigned char *addr,
+		      const unsigned char *addr,
 		      u16 nlh_flags);
 extern int br_fdb_dump(struct sk_buff *skb,
 		       struct netlink_callback *cb,
--- a/net/core/dev_addr_lists.c	2012-08-15 08:59:22.934704464 -0700
+++ b/net/core/dev_addr_lists.c	2012-09-17 11:21:55.302968736 -0700
@@ -22,7 +22,7 @@
  */
 
 static int __hw_addr_create_ex(struct netdev_hw_addr_list *list,
-			       unsigned char *addr, int addr_len,
+			       const unsigned char *addr, int addr_len,
 			       unsigned char addr_type, bool global)
 {
 	struct netdev_hw_addr *ha;
@@ -46,7 +46,7 @@ static int __hw_addr_create_ex(struct ne
 }
 
 static int __hw_addr_add_ex(struct netdev_hw_addr_list *list,
-			    unsigned char *addr, int addr_len,
+			    const unsigned char *addr, int addr_len,
 			    unsigned char addr_type, bool global)
 {
 	struct netdev_hw_addr *ha;
@@ -72,14 +72,15 @@ static int __hw_addr_add_ex(struct netde
 	return __hw_addr_create_ex(list, addr, addr_len, addr_type, global);
 }
 
-static int __hw_addr_add(struct netdev_hw_addr_list *list, unsigned char *addr,
-			 int addr_len, unsigned char addr_type)
+static int __hw_addr_add(struct netdev_hw_addr_list *list,
+			 const unsigned char *addr, int addr_len,
+			 unsigned char addr_type)
 {
 	return __hw_addr_add_ex(list, addr, addr_len, addr_type, false);
 }
 
 static int __hw_addr_del_ex(struct netdev_hw_addr_list *list,
-			    unsigned char *addr, int addr_len,
+			    const unsigned char *addr, int addr_len,
 			    unsigned char addr_type, bool global)
 {
 	struct netdev_hw_addr *ha;
@@ -104,8 +105,9 @@ static int __hw_addr_del_ex(struct netde
 	return -ENOENT;
 }
 
-static int __hw_addr_del(struct netdev_hw_addr_list *list, unsigned char *addr,
-			 int addr_len, unsigned char addr_type)
+static int __hw_addr_del(struct netdev_hw_addr_list *list,
+			 const unsigned char *addr, int addr_len,
+			 unsigned char addr_type)
 {
 	return __hw_addr_del_ex(list, addr, addr_len, addr_type, false);
 }
@@ -278,7 +280,7 @@ EXPORT_SYMBOL(dev_addr_init);
  *
  *	The caller must hold the rtnl_mutex.
  */
-int dev_addr_add(struct net_device *dev, unsigned char *addr,
+int dev_addr_add(struct net_device *dev, const unsigned char *addr,
 		 unsigned char addr_type)
 {
 	int err;
@@ -303,7 +305,7 @@ EXPORT_SYMBOL(dev_addr_add);
  *
  *	The caller must hold the rtnl_mutex.
  */
-int dev_addr_del(struct net_device *dev, unsigned char *addr,
+int dev_addr_del(struct net_device *dev, const unsigned char *addr,
 		 unsigned char addr_type)
 {
 	int err;
@@ -390,7 +392,7 @@ EXPORT_SYMBOL(dev_addr_del_multiple);
  *	@dev: device
  *	@addr: address to add
  */
-int dev_uc_add_excl(struct net_device *dev, unsigned char *addr)
+int dev_uc_add_excl(struct net_device *dev, const unsigned char *addr)
 {
 	struct netdev_hw_addr *ha;
 	int err;
@@ -421,7 +423,7 @@ EXPORT_SYMBOL(dev_uc_add_excl);
  *	Add a secondary unicast address to the device or increase
  *	the reference count if it already exists.
  */
-int dev_uc_add(struct net_device *dev, unsigned char *addr)
+int dev_uc_add(struct net_device *dev, const unsigned char *addr)
 {
 	int err;
 
@@ -443,7 +445,7 @@ EXPORT_SYMBOL(dev_uc_add);
  *	Release reference to a secondary unicast address and remove it
  *	from the device if the reference count drops to zero.
  */
-int dev_uc_del(struct net_device *dev, unsigned char *addr)
+int dev_uc_del(struct net_device *dev, const unsigned char *addr)
 {
 	int err;
 
@@ -543,7 +545,7 @@ EXPORT_SYMBOL(dev_uc_init);
  *	@dev: device
  *	@addr: address to add
  */
-int dev_mc_add_excl(struct net_device *dev, unsigned char *addr)
+int dev_mc_add_excl(struct net_device *dev, const unsigned char *addr)
 {
 	struct netdev_hw_addr *ha;
 	int err;
@@ -566,7 +568,7 @@ out:
 }
 EXPORT_SYMBOL(dev_mc_add_excl);
 
-static int __dev_mc_add(struct net_device *dev, unsigned char *addr,
+static int __dev_mc_add(struct net_device *dev, const unsigned char *addr,
 			bool global)
 {
 	int err;
@@ -587,7 +589,7 @@ static int __dev_mc_add(struct net_devic
  *	Add a multicast address to the device or increase
  *	the reference count if it already exists.
  */
-int dev_mc_add(struct net_device *dev, unsigned char *addr)
+int dev_mc_add(struct net_device *dev, const unsigned char *addr)
 {
 	return __dev_mc_add(dev, addr, false);
 }
@@ -600,13 +602,13 @@ EXPORT_SYMBOL(dev_mc_add);
  *
  *	Add a global multicast address to the device.
  */
-int dev_mc_add_global(struct net_device *dev, unsigned char *addr)
+int dev_mc_add_global(struct net_device *dev, const unsigned char *addr)
 {
 	return __dev_mc_add(dev, addr, true);
 }
 EXPORT_SYMBOL(dev_mc_add_global);
 
-static int __dev_mc_del(struct net_device *dev, unsigned char *addr,
+static int __dev_mc_del(struct net_device *dev, const unsigned char *addr,
 			bool global)
 {
 	int err;
@@ -628,7 +630,7 @@ static int __dev_mc_del(struct net_devic
  *	Release reference to a multicast address and remove it
  *	from the device if the reference count drops to zero.
  */
-int dev_mc_del(struct net_device *dev, unsigned char *addr)
+int dev_mc_del(struct net_device *dev, const unsigned char *addr)
 {
 	return __dev_mc_del(dev, addr, false);
 }
@@ -642,7 +644,7 @@ EXPORT_SYMBOL(dev_mc_del);
  *	Release reference to a multicast address and remove it
  *	from the device if the reference count drops to zero.
  */
-int dev_mc_del_global(struct net_device *dev, unsigned char *addr)
+int dev_mc_del_global(struct net_device *dev, const unsigned char *addr)
 {
 	return __dev_mc_del(dev, addr, true);
 }
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c	2012-09-17 11:02:16.230810156 -0700
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c	2012-09-17 11:25:15.112962043 -0700
@@ -6890,7 +6890,7 @@ static int ixgbe_set_features(struct net
 
 static int ixgbe_ndo_fdb_add(struct ndmsg *ndm,
 			     struct net_device *dev,
-			     unsigned char *addr,
+			     const unsigned char *addr,
 			     u16 flags)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
@@ -6927,7 +6927,7 @@ static int ixgbe_ndo_fdb_add(struct ndms
 
 static int ixgbe_ndo_fdb_del(struct ndmsg *ndm,
 			     struct net_device *dev,
-			     unsigned char *addr)
+			     const unsigned char *addr)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 	int err = -EOPNOTSUPP;
