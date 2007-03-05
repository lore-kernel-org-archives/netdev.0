From: Adrian Bunk <bunk@stusta.de>
Subject: [-mm patch] drivers/net/bonding/bond_main.c:make 3 functions static
Date: Mon, 5 Mar 2007 02:49:21 +0100
Message-ID: <20070305014921.GW3441@stusta.de>
References: <20070302030026.5eef0c92.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Jaroslav Kysela <perex@suse.cz>
To: Andrew Morton <akpm@linux-foundation.org>,
	ctindel@users.sourceforge.net, fubar@us.ibm.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752067AbXCEBtr@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070302030026.5eef0c92.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes the following needlessly global functions static:
- bond_mode_name()
- bond_sethwaddr()
- bond_mii_monitor()

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 drivers/net/bonding/bond_main.c |    7 ++++---
 drivers/net/bonding/bonding.h   |    3 ---
 2 files changed, 4 insertions(+), 6 deletions(-)

--- linux-2.6.21-rc2-mm1/drivers/net/bonding/bonding.h.old	2007-03-04 21:33:14.000000000 +0100
+++ linux-2.6.21-rc2-mm1/drivers/net/bonding/bonding.h	2007-03-04 21:34:46.000000000 +0100
@@ -301,13 +301,10 @@
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
--- linux-2.6.21-rc2-mm1/drivers/net/bonding/bond_main.c.old	2007-03-04 21:33:29.000000000 +0100
+++ linux-2.6.21-rc2-mm1/drivers/net/bonding/bond_main.c	2007-03-04 21:34:56.000000000 +0100
@@ -187,7 +187,7 @@
 
 /*---------------------------- General routines -----------------------------*/
 
-const char *bond_mode_name(int mode)
+static const char *bond_mode_name(int mode)
 {
 	switch (mode) {
 	case BOND_MODE_ROUNDROBIN :
@@ -1200,7 +1200,8 @@
 
 /*---------------------------------- IOCTL ----------------------------------*/
 
-int bond_sethwaddr(struct net_device *bond_dev, struct net_device *slave_dev)
+static int bond_sethwaddr(struct net_device *bond_dev,
+			  struct net_device *slave_dev)
 {
 	dprintk("bond_dev=%p\n", bond_dev);
 	dprintk("slave_dev=%p\n", slave_dev);
@@ -2014,7 +2015,7 @@
 /*-------------------------------- Monitoring -------------------------------*/
 
 /* this function is called regularly to monitor each slave's link. */
-void bond_mii_monitor(struct work_struct *work)
+static void bond_mii_monitor(struct work_struct *work)
 {
 	struct bonding *bond = container_of(work, struct bonding, mii_work.work);
 	struct net_device *bond_dev = bond->dev;
