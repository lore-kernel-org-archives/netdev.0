From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ipvs -- print statistics in decimal.
Date: Mon, 15 Sep 2003 14:41:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030915144154.26b9bad5.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lvs-users@LinuxVirtualServer.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Most of of us read decimal better than hex ;-)

Assumes earlier seq_file patch.
diff -Nru a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
--- a/net/ipv4/ipvs/ip_vs_ctl.c	Mon Sep 15 14:31:43 2003
+++ b/net/ipv4/ipvs/ip_vs_ctl.c	Mon Sep 15 14:31:43 2003
@@ -1716,22 +1716,22 @@
 #ifdef CONFIG_PROC_FS
 static int ip_vs_stats_show(struct seq_file *seq, void *v)
 {
+	static const char hfmt[]
+		= "%10s %10s %10s %20s %20s\n";
 
-/*               01234567 01234567 01234567 0123456701234567 0123456701234567 */
-	seq_puts(seq,
-		 "   Total Incoming Outgoing         Incoming         Outgoing\n");
-	seq_printf(seq, 	   
-		   "   Conns  Packets  Packets            Bytes            Bytes\n");
+	seq_printf(seq, hfmt, "Total", "Incoming", "Outgoing", 
+		   "Incoming" ,"Outgoing");
+	seq_printf(seq, hfmt, "Conns", "Packets","Packets","Bytes","Bytes");
 
 	spin_lock_bh(&ip_vs_stats.lock);
-	seq_printf(seq, "%8X %8X %8X %16LX %16LX\n\n", ip_vs_stats.conns,
+	seq_printf(seq, "%10u %10u %10u %20llu %20llu\n\n", 
+		   ip_vs_stats.conns,
 		   ip_vs_stats.inpkts, ip_vs_stats.outpkts,
 		   ip_vs_stats.inbytes, ip_vs_stats.outbytes);
 
-/*                 01234567 01234567 01234567 0123456701234567 0123456701234567 */
-	seq_puts(seq,
-		   " Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s\n");
-	seq_printf(seq,"%8X %8X %8X %16X %16X\n",
+	seq_printf(seq, hfmt, "Conns/s", "Pkts/s","Pkts/s", 
+		   "Bytes/s","Bytes/s");
+	seq_printf(seq,"%10u %10u %10u %20u %20u\n",
 			ip_vs_stats.cps,
 			ip_vs_stats.inpps,
 			ip_vs_stats.outpps,
