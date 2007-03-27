From: akpm@linux-foundation.org
Subject: [patch 6/7] drivers/net/bonding/bond_main.c:make 3 functions static
Date: Mon, 26 Mar 2007 21:50:02 -0800
Message-ID: <200703270550.l2R5o2A7008391@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, bunk@stusta.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40616 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934043AbXC0FxS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 01:53:18 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>

This patch makes the following needlessly global functions static:
- bond_mode_name()
- bond_sethwaddr()
- bond_mii_monitor()

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/bonding/bond_main.c |    7 ++++---
 drivers/net/bonding/bonding.h   |    3 ---
 2 files changed, 4 insertions(+), 6 deletions(-)

diff -puN drivers/net/bonding/bond_main.c~drivers-net-bonding-bond_maincmake-3-functions-static drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c~drivers-net-bonding-bond_maincmake-3-functions-static
+++ a/drivers/net/bonding/bond_main.c
@@ -188,7 +188,7 @@ static void bond_send_gratuitous_arp(str
 
 /*---------------------------- General routines -----------------------------*/
 
-const char *bond_mode_name(int mode)
+static const char *bond_mode_name(int mode)
 {
 	switch (mode) {
 	case BOND_MODE_ROUNDROBIN :
@@ -1225,7 +1225,8 @@ static void bond_detach_slave(struct bon
 
 /*---------------------------------- IOCTL ----------------------------------*/
 
-int bond_sethwaddr(struct net_device *bond_dev, struct net_device *slave_dev)
+static int bond_sethwaddr(struct net_device *bond_dev,
+			  struct net_device *slave_dev)
 {
 	dprintk("bond_dev=%p\n", bond_dev);
 	dprintk("slave_dev=%p\n", slave_dev);
@@ -2039,7 +2040,7 @@ static int bond_slave_info_query(struct 
 /*-------------------------------- Monitoring -------------------------------*/
 
 /* this function is called regularly to monitor each slave's link. */
-void bond_mii_monitor(struct work_struct *work)
+static void bond_mii_monitor(struct work_struct *work)
 {
 	struct bonding *bond = container_of(work, struct bonding, mii_work.work);
 	struct net_device *bond_dev = bond->dev;
diff -puN drivers/net/bonding/bonding.h~drivers-net-bonding-bond_maincmake-3-functions-static drivers/net/bonding/bonding.h
--- a/drivers/net/bonding/bonding.h~drivers-net-bonding-bond_maincmake-3-functions-static
+++ a/drivers/net/bonding/bonding.h
@@ -301,13 +301,10 @@ int bond_create_slave_symlinks(struct ne
 void bond_destroy_slave_symlinks(struct net_device *master, struct net_device *slave);
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
-int bond_sethwaddr(struct net_device *bond_dev, struct net_device *slave_dev);
-void bond_mii_monitor(struct work_struct *work);
 void bond_loadbalance_arp_mon(struct work_struct *work);
 void bond_activebackup_arp_mon(struct work_struct *work);
 void bond_set_mode_ops(struct bonding *bond, int mode);
 int bond_parse_parm(char *mode_arg, struct bond_parm_tbl *tbl);
-const char *bond_mode_name(int mode);
 void bond_select_active_slave(struct bonding *bond);
 void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
 void bond_register_arp(struct bonding *);
_
