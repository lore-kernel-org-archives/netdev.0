From: Radheka Godse <radheka.godse@intel.com>
Subject: [PATCH 2.6.12-rc2 r15/17] bonding: include ARP information in /proc
 file
Date: Fri, 8 Apr 2005 17:10:30 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0504081707430.10355@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


For bonds configured to do ARP monitoring, this patch displays polling 
interval and ip targets info in their respective proc files. This 
information was missing in the proc file.

Signed-off-by: Radheka Godse <radheka.godse@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>


diff -urN -X dontdiff linux-2.6.12-rc2clean/drivers/net/bonding/bond_main.c linux-2.6.12-rc2/drivers/net/bonding/bond_main.c
--- linux-2.6.12-rc2clean/drivers/net/bonding/bond_main.c	2005-04-07 11:24:41.000000000 -0700
+++ linux-2.6.12-rc2/drivers/net/bonding/bond_main.c	2005-04-07 14:35:41.000000000 -0700
@@ -3167,6 +3167,8 @@
  {
  	struct bonding *bond = seq->private;
  	struct slave *curr;
+	int i;
+	u32 target;

  	read_lock(&bond->curr_slave_lock);
  	curr = bond->curr_active_slave;
@@ -3191,6 +3193,24 @@
  	seq_printf(seq, "Down Delay (ms): %d\n",
  		   bond->params.downdelay * bond->params.miimon);

+
+	// ARP information
+	if(bond->params.arp_interval > 0) {
+		seq_printf(seq, "ARP Polling Interval (ms): %d\n", 
+				bond->params.arp_interval);
+ 
+		seq_printf(seq, "ARP IP target/s (n.n.n.n form):");
+ 
+		for(i = 0; (i < BOND_MAX_ARP_TARGETS) && bond->params.arp_targets[i] ;i++) {
+			target = ntohl(bond->params.arp_targets[i]);
+			seq_printf(seq, " %d.%d.%d.%d", HIPQUAD(target));
+			if((i+1 < BOND_MAX_ARP_TARGETS) && bond->params.arp_targets[i+1]) 
+				seq_printf(seq, ",");
+			else
+				seq_printf(seq, "\n");
+		}
+	}
+
  	if (bond->params.mode == BOND_MODE_8023AD) {
  		struct ad_info ad_info;
