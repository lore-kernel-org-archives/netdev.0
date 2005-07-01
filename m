From: Radheka Godse <radheka.godse@intel.com>
Subject: [PATCH 2.6.13-rc1 9/17] bonding: get primary name from slave dev
Date: Fri, 1 Jul 2005 13:49:52 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0507011348460.17459@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch fixes a bug in the proc file handler in bonding. The name of
the primary slave was taken from the command-line options, instead of from 
the dev structure of the primary slave itself. This caused an incorrect 
dispaly if t he primary is set or changed via sysfs.

Signed-off-by: Radheka Godse <radheka.godse@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>

diff -urN -X dontdiff linux-2.6.12post/drivers/net/bonding/bond_main.c linux-2.6.12post-sysfs/drivers/net/bonding/bond_main.c
--- linux-2.6.12post/drivers/net/bonding/bond_main.c	2005-06-28 18:18:03.000000000 -0700
+++ linux-2.6.12post-sysfs/drivers/net/bonding/bond_main.c	2005-06-30 13:53:55.000000000 -0700
@@ -3369,8 +3369,8 @@

  	if (USES_PRIMARY(bond->params.mode)) {
  		seq_printf(seq, "Primary Slave: %s\n",
-			   (bond->params.primary[0]) ?
-			   	bond->params.primary : "None");
+			   (bond->primary_slave) ? 
+			   bond->primary_slave->dev->name : "None");

  		seq_printf(seq, "Currently Active Slave: %s\n",
  			   (curr) ? curr->dev->name : "None");
