From: Radheka Godse <radheka.godse@intel.com>
Subject: [PATCH 2.6.13-rc1 3/17] bonding: export some structs to bonding.h
Date: Fri, 1 Jul 2005 13:39:31 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0507011338120.17459@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This patch exposes some data structures for use by the sysfs interface.

Signed-off-by: Radheka Godse <radheka.godse@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>

diff -urN -X dontdiff linux-2.6.12post/drivers/net/bonding/bonding.h linux-2.6.12post-sysfs/drivers/net/bonding/bonding.h
--- linux-2.6.12post/drivers/net/bonding/bonding.h	2005-06-28 18:18:03.000000000 -0700
+++ linux-2.6.12post-sysfs/drivers/net/bonding/bonding.h	2005-06-30 13:58:27.000000000 -0700
@@ -152,6 +152,11 @@
  	u32 arp_targets[BOND_MAX_ARP_TARGETS];
  };

+struct bond_parm_tbl {
+	char *modename;
+	int mode;
+};
+
  struct vlan_entry {
  	struct list_head vlan_list;
  	u32 vlan_ip;
diff -urN -X dontdiff linux-2.6.12post/drivers/net/bonding/bond_main.c linux-2.6.12post-sysfs/drivers/net/bonding/bond_main.c
--- linux-2.6.12post/drivers/net/bonding/bond_main.c	2005-06-28 18:18:03.000000000 -0700
+++ linux-2.6.12post-sysfs/drivers/net/bonding/bond_main.c	2005-06-30 13:53:55.000000000 -0700
@@ -585,7 +585,7 @@
  static const char *version =
  	DRV_DESCRIPTION ": v" DRV_VERSION " (" DRV_RELDATE ")\n";

-static LIST_HEAD(bond_dev_list);
+LIST_HEAD(bond_dev_list);

  #ifdef CONFIG_PROC_FS
  static struct proc_dir_entry *bond_proc_dir = NULL;
@@ -604,18 +604,14 @@
  				   * command comes from an application using
  				   * another ABI version.
  				   */
-struct bond_parm_tbl {
-	char *modename;
-	int mode;
-};

-static struct bond_parm_tbl bond_lacp_tbl[] = {
+struct bond_parm_tbl bond_lacp_tbl[] = {
  {	"slow",		AD_LACP_SLOW},
  {	"fast",		AD_LACP_FAST},
  {	NULL,		-1},
  };

-static struct bond_parm_tbl bond_mode_tbl[] = {
+struct bond_parm_tbl bond_mode_tbl[] = {
  {	"balance-rr",		BOND_MODE_ROUNDROBIN},
  {	"active-backup",	BOND_MODE_ACTIVEBACKUP},
  {	"balance-xor",		BOND_MODE_XOR},
@@ -626,7 +622,7 @@
  {	NULL,			-1},
  };

-static struct bond_parm_tbl xmit_hashtype_tbl[] = {
+struct bond_parm_tbl xmit_hashtype_tbl[] = {
  {	"layer2",		BOND_XMIT_POLICY_LAYER2},
  {	"layer3+4",		BOND_XMIT_POLICY_LAYER34},
  {	NULL,			-1},
@@ -634,12 +630,11 @@

  /*-------------------------- Forward declarations ---------------------------*/

-static inline void bond_set_mode_ops(struct bonding *bond, int mode);
  static void bond_send_gratuitous_arp(struct bonding *bond);

  /*---------------------------- General routines -----------------------------*/

-static const char *bond_mode_name(int mode)
+const char *bond_mode_name(int mode)
  {
  	switch (mode) {
  	case BOND_MODE_ROUNDROBIN :
