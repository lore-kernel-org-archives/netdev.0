From: Radheka Godse <radheka.godse@intel.com>
Subject: [PATCH 2.6.12-rc2 3/17] bonding: export some structs to bonding.h
Date: Fri, 8 Apr 2005 16:25:27 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0504081623310.10355@localhost.localdomain>
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


diff -urN -X dontdiff linux-2.6.12-rc2clean/drivers/net/bonding/bonding.h linux-2.6.12-rc2/drivers/net/bonding/bonding.h
--- linux-2.6.12-rc2clean/drivers/net/bonding/bonding.h	2005-04-07 11:24:41.000000000 -0700
+++ linux-2.6.12-rc2/drivers/net/bonding/bonding.h	2005-04-07 14:05:31.000000000 -0700
@@ -147,6 +147,11 @@
  	u32 arp_targets[BOND_MAX_ARP_TARGETS];
  };

+struct bond_parm_tbl {
+	char *modename;
+	int mode;
+};
+
  struct vlan_entry {
  	struct list_head vlan_list;
  	unsigned short vlan_id;
diff -urN -X dontdiff linux-2.6.12-rc2clean/drivers/net/bonding/bond_main.c linux-2.6.12-rc2/drivers/net/bonding/bond_main.c
--- linux-2.6.12-rc2clean/drivers/net/bonding/bond_main.c	2005-04-07 11:24:41.000000000 -0700
+++ linux-2.6.12-rc2/drivers/net/bonding/bond_main.c	2005-04-07 14:35:41.000000000 -0700
@@ -567,7 +567,7 @@
  static const char *version =
  	DRV_DESCRIPTION ": v" DRV_VERSION " (" DRV_RELDATE ")\n";

-static LIST_HEAD(bond_dev_list);
+LIST_HEAD(bond_dev_list);

  #ifdef CONFIG_PROC_FS
  static struct proc_dir_entry *bond_proc_dir = NULL;
@@ -587,18 +587,13 @@
  				   * another ABI version.
  				   */

-struct bond_parm_tbl {
-	char *modename;
-	int mode;
-};
-
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
