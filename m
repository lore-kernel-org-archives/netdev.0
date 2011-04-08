From: Sasikanth V <sasikanth.v19@gmail.com>
Subject: [PATCH] IPV4:Removed the unnecessary loops and made /proc/net/snmp ouput more readable
Date: Sat,  9 Apr 2011 04:21:39 +0530
Message-ID: <1302303099-6880-1-git-send-email-sasikanth.v19@gmail.com>
Cc: netdev@vger.kernel.org, Sasikanth V <sasikanth.v19@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:48441 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752630Ab1DHWvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 18:51:49 -0400
Received: by iyb14 with SMTP id 14so3857918iyb.19
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2011 15:51:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sasikanth V <sasikanth.v19@gmail.com>
---
 net/ipv4/proc.c |   75 ++++++++++++++++++++----------------------------------
 1 files changed, 28 insertions(+), 47 deletions(-)

diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index b14ec7d..b4eda92 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -265,12 +265,9 @@ static void icmpmsg_put_line(struct seq_file *seq, unsigned long *vals,
 	if (count) {
 		seq_printf(seq, "\nIcmpMsg:");
 		for (j = 0; j < count; ++j)
-			seq_printf(seq, " %sType%u",
+			seq_printf(seq, " %sType%u\t%lu",
 				type[j] & 0x100 ? "Out" : "In",
-				type[j] & 0xff);
-		seq_printf(seq, "\nIcmpMsg:");
-		for (j = 0; j < count; ++j)
-			seq_printf(seq, " %lu", vals[j]);
+				type[j] & 0xff, vals[j]);
 	}
 }
 
@@ -305,26 +302,26 @@ static void icmp_put(struct seq_file *seq)
 	int i;
 	struct net *net = seq->private;
 
-	seq_puts(seq, "\nIcmp: InMsgs InErrors");
-	for (i=0; icmpmibmap[i].name != NULL; i++)
-		seq_printf(seq, " In%s", icmpmibmap[i].name);
-	seq_printf(seq, " OutMsgs OutErrors");
-	for (i=0; icmpmibmap[i].name != NULL; i++)
-		seq_printf(seq, " Out%s", icmpmibmap[i].name);
-	seq_printf(seq, "\nIcmp: %lu %lu",
+	seq_puts(seq, "Icmp:\n");
+	seq_printf(seq, "%-32s\t%lu\n%-32s\t%lu\n","InMsgs",
 		snmp_fold_field((void __percpu **) net->mib.icmp_statistics, ICMP_MIB_INMSGS),
+		"InErrors",
 		snmp_fold_field((void __percpu **) net->mib.icmp_statistics, ICMP_MIB_INERRORS));
+
 	for (i=0; icmpmibmap[i].name != NULL; i++)
-		seq_printf(seq, " %lu",
-			snmp_fold_field((void __percpu **) net->mib.icmpmsg_statistics,
-				icmpmibmap[i].index));
-	seq_printf(seq, " %lu %lu",
+		seq_printf(seq, "%s%-32s\t%lu\n", "In",icmpmibmap[i].name,
+			   snmp_fold_field((void __percpu **) net->mib.icmpmsg_statistics,
+			 	           icmpmibmap[i].index));
+
+	seq_printf(seq, "%-32s\t%lu\n%-32s\t%lu\n","OutMsgs",
 		snmp_fold_field((void __percpu **) net->mib.icmp_statistics, ICMP_MIB_OUTMSGS),
+		"OutErrors",
 		snmp_fold_field((void __percpu **) net->mib.icmp_statistics, ICMP_MIB_OUTERRORS));
+
 	for (i=0; icmpmibmap[i].name != NULL; i++)
-		seq_printf(seq, " %lu",
-			snmp_fold_field((void __percpu **) net->mib.icmpmsg_statistics,
-				icmpmibmap[i].index | 0x100));
+		seq_printf(seq, "%s%-32s\t%lu\n", "Out", icmpmibmap[i].name,
+			   snmp_fold_field((void __percpu **) net->mib.icmpmsg_statistics,
+				          icmpmibmap[i].index | 0x100));
 }
 
 /*
@@ -335,18 +332,15 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 	int i;
 	struct net *net = seq->private;
 
-	seq_puts(seq, "Ip: Forwarding DefaultTTL");
-
-	for (i = 0; snmp4_ipstats_list[i].name != NULL; i++)
-		seq_printf(seq, " %s", snmp4_ipstats_list[i].name);
-
-	seq_printf(seq, "\nIp: %d %d",
-		   IPV4_DEVCONF_ALL(net, FORWARDING) ? 1 : 2,
+	seq_puts(seq, "Ip:\n");
+	seq_printf(seq, "%-32s\t%d\n%-32s\t%d\n", "Forwarding",
+		   IPV4_DEVCONF_ALL(net, FORWARDING) ? 1 : 2,"DefaultTTL",
 		   sysctl_ip_default_ttl);
 
 	BUILD_BUG_ON(offsetof(struct ipstats_mib, mibs) != 0);
+
 	for (i = 0; snmp4_ipstats_list[i].name != NULL; i++)
-		seq_printf(seq, " %llu",
+		seq_printf(seq, "%-32s\t%llu\n", snmp4_ipstats_list[i].name,
 			   snmp_fold_field64((void __percpu **)net->mib.ip_statistics,
 					     snmp4_ipstats_list[i].entry,
 					     offsetof(struct ipstats_mib, syncp)));
@@ -354,45 +348,32 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 	icmp_put(seq);	/* RFC 2011 compatibility */
 	icmpmsg_put(seq);
 
-	seq_puts(seq, "\nTcp:");
-	for (i = 0; snmp4_tcp_list[i].name != NULL; i++)
-		seq_printf(seq, " %s", snmp4_tcp_list[i].name);
-
-	seq_puts(seq, "\nTcp:");
+	seq_puts(seq, "Tcp:\n");
 	for (i = 0; snmp4_tcp_list[i].name != NULL; i++) {
 		/* MaxConn field is signed, RFC 2012 */
 		if (snmp4_tcp_list[i].entry == TCP_MIB_MAXCONN)
-			seq_printf(seq, " %ld",
+			seq_printf(seq, "%-32s\t%lu\n", snmp4_tcp_list[i].name,
 				   snmp_fold_field((void __percpu **)net->mib.tcp_statistics,
 						   snmp4_tcp_list[i].entry));
 		else
-			seq_printf(seq, " %lu",
+			seq_printf(seq, "%-32s\t%lu\n", snmp4_tcp_list[i].name,
 				   snmp_fold_field((void __percpu **)net->mib.tcp_statistics,
 						   snmp4_tcp_list[i].entry));
 	}
 
-	seq_puts(seq, "\nUdp:");
-	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
-		seq_printf(seq, " %s", snmp4_udp_list[i].name);
-
-	seq_puts(seq, "\nUdp:");
+	seq_puts(seq, "Udp:\n");
 	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
-		seq_printf(seq, " %lu",
+		seq_printf(seq, "%-32s\t%lu\n", snmp4_udp_list[i].name,
 			   snmp_fold_field((void __percpu **)net->mib.udp_statistics,
 					   snmp4_udp_list[i].entry));
 
 	/* the UDP and UDP-Lite MIBs are the same */
-	seq_puts(seq, "\nUdpLite:");
-	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
-		seq_printf(seq, " %s", snmp4_udp_list[i].name);
-
-	seq_puts(seq, "\nUdpLite:");
+	seq_puts(seq, "UdpLite:\n");
 	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
-		seq_printf(seq, " %lu",
+		seq_printf(seq, "%-32s\t%lu\n", snmp4_udp_list[i].name,
 			   snmp_fold_field((void __percpu **)net->mib.udplite_statistics,
 					   snmp4_udp_list[i].entry));
 
-	seq_putc(seq, '\n');
 	return 0;
 }
 
-- 
1.7.3.4

