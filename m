From: Jia He <hejianet@gmail.com>
Subject: [RFC PATCH v2 6/6] net: Suppress the "Comparison to NULL could be written" warning
Date: Tue,  6 Sep 2016 10:30:09 +0800
Message-ID: <1473129009-20478-7-git-send-email-hejianet@gmail.com>
References: <1473129009-20478-1-git-send-email-hejianet@gmail.com>
Cc: linux-sctp@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Jia He <hejianet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473129009-20478-1-git-send-email-hejianet@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is to suppress the checkpatch.pl warning "Comparison to NULL
could be written". No functional changes here.

Signed-off-by: Jia He <hejianet@gmail.com>
---
 net/ipv4/proc.c      | 44 ++++++++++++++++++++++----------------------
 net/sctp/proc.c      |  4 ++--
 net/xfrm/xfrm_proc.c |  4 ++--
 3 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index f413fdc..bf0bb22 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -358,22 +358,22 @@ static void icmp_put(struct seq_file *seq)
 	atomic_long_t *ptr = net->mib.icmpmsg_statistics->mibs;
 
 	seq_puts(seq, "\nIcmp: InMsgs InErrors InCsumErrors");
-	for (i = 0; icmpmibmap[i].name != NULL; i++)
+	for (i = 0; icmpmibmap[i].name; i++)
 		seq_printf(seq, " In%s", icmpmibmap[i].name);
 	seq_puts(seq, " OutMsgs OutErrors");
-	for (i = 0; icmpmibmap[i].name != NULL; i++)
+	for (i = 0; icmpmibmap[i].name; i++)
 		seq_printf(seq, " Out%s", icmpmibmap[i].name);
 	seq_printf(seq, "\nIcmp: %lu %lu %lu",
 		snmp_fold_field(net->mib.icmp_statistics, ICMP_MIB_INMSGS),
 		snmp_fold_field(net->mib.icmp_statistics, ICMP_MIB_INERRORS),
 		snmp_fold_field(net->mib.icmp_statistics, ICMP_MIB_CSUMERRORS));
-	for (i = 0; icmpmibmap[i].name != NULL; i++)
+	for (i = 0; icmpmibmap[i].name; i++)
 		seq_printf(seq, " %lu",
 			   atomic_long_read(ptr + icmpmibmap[i].index));
 	seq_printf(seq, " %lu %lu",
 		snmp_fold_field(net->mib.icmp_statistics, ICMP_MIB_OUTMSGS),
 		snmp_fold_field(net->mib.icmp_statistics, ICMP_MIB_OUTERRORS));
-	for (i = 0; icmpmibmap[i].name != NULL; i++)
+	for (i = 0; icmpmibmap[i].name; i++)
 		seq_printf(seq, " %lu",
 			   atomic_long_read(ptr + (icmpmibmap[i].index | 0x100)));
 }
@@ -390,7 +390,7 @@ static int snmp_seq_show_ipstats(struct seq_file *seq, void *v)
 	memset(buff64, 0, IPSTATS_MIB_MAX * sizeof(u64));
 
 	seq_puts(seq, "Ip: Forwarding DefaultTTL");
-	for (i = 0; snmp4_ipstats_list[i].name != NULL; i++)
+	for (i = 0; snmp4_ipstats_list[i].name; i++)
 		seq_printf(seq, " %s", snmp4_ipstats_list[i].name);
 
 	seq_printf(seq, "\nIp: %d %d",
@@ -400,13 +400,13 @@ static int snmp_seq_show_ipstats(struct seq_file *seq, void *v)
 	BUILD_BUG_ON(offsetof(struct ipstats_mib, mibs) != 0);
 
 	for_each_possible_cpu(c) {
-		for (i = 0; snmp4_ipstats_list[i].name != NULL; i++)
+		for (i = 0; snmp4_ipstats_list[i].name; i++)
 			buff64[i] += snmp_get_cpu_field64(
 					net->mib.ip_statistics,
 					c, snmp4_ipstats_list[i].entry,
 					offsetof(struct ipstats_mib, syncp));
 	}
-	for (i = 0; snmp4_ipstats_list[i].name != NULL; i++)
+	for (i = 0; snmp4_ipstats_list[i].name; i++)
 		seq_printf(seq, " %llu", buff64[i]);
 
 	return 0;
@@ -421,17 +421,17 @@ static int snmp_seq_show_tcp_udp(struct seq_file *seq, void *v)
 	memset(buff, 0, TCPUDP_MIB_MAX * sizeof(unsigned long));
 
 	seq_puts(seq, "\nTcp:");
-	for (i = 0; snmp4_tcp_list[i].name != NULL; i++)
+	for (i = 0; snmp4_tcp_list[i].name; i++)
 		seq_printf(seq, " %s", snmp4_tcp_list[i].name);
 
 	seq_puts(seq, "\nTcp:");
 	for_each_possible_cpu(c) {
-		for (i = 0; snmp4_tcp_list[i].name != NULL; i++)
+		for (i = 0; snmp4_tcp_list[i].name; i++)
 			buff[i] += snmp_get_cpu_field(net->mib.tcp_statistics,
 						c, snmp4_tcp_list[i].entry);
 	}
 
-	for (i = 0; snmp4_tcp_list[i].name != NULL; i++) {
+	for (i = 0; snmp4_tcp_list[i].name; i++) {
 		/* MaxConn field is signed, RFC 2012 */
 		if (snmp4_tcp_list[i].entry == TCP_MIB_MAXCONN)
 			seq_printf(seq, " %ld", buff[i]);
@@ -442,15 +442,15 @@ static int snmp_seq_show_tcp_udp(struct seq_file *seq, void *v)
 	memset(buff, 0, TCPUDP_MIB_MAX * sizeof(unsigned long));
 
 	for_each_possible_cpu(c) {
-		for (i = 0; snmp4_udp_list[i].name != NULL; i++)
+		for (i = 0; snmp4_udp_list[i].name; i++)
 			buff[i] += snmp_get_cpu_field(net->mib.udp_statistics,
 						c, snmp4_udp_list[i].entry);
 	}
 	seq_puts(seq, "\nUdp:");
-	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
+	for (i = 0; snmp4_udp_list[i].name; i++)
 		seq_printf(seq, " %s", snmp4_udp_list[i].name);
 	seq_puts(seq, "\nUdp:");
-	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
+	for (i = 0; snmp4_udp_list[i].name; i++)
 		seq_printf(seq, " %lu", buff[i]);
 
 	memset(buff, 0, TCPUDP_MIB_MAX * sizeof(unsigned long));
@@ -458,14 +458,14 @@ static int snmp_seq_show_tcp_udp(struct seq_file *seq, void *v)
 	/* the UDP and UDP-Lite MIBs are the same */
 	seq_puts(seq, "\nUdpLite:");
 	for_each_possible_cpu(c) {
-		for (i = 0; snmp4_udp_list[i].name != NULL; i++)
+		for (i = 0; snmp4_udp_list[i].name; i++)
 			buff[i] += snmp_get_cpu_field(net->mib.udplite_statistics,
 						c, snmp4_udp_list[i].entry);
 	}
-	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
+	for (i = 0; snmp4_udp_list[i].name; i++)
 		seq_printf(seq, " %s", snmp4_udp_list[i].name);
 	seq_puts(seq, "\nUdpLite:");
-	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
+	for (i = 0; snmp4_udp_list[i].name; i++)
 		seq_printf(seq, " %lu", buff[i]);
 
 	seq_putc(seq, '\n');
@@ -513,29 +513,29 @@ static int netstat_seq_show(struct seq_file *seq, void *v)
 	memset(buff64, 0, sizeof(u64) * IPSTATS_MIB_MAX);
 
 	seq_puts(seq, "TcpExt:");
-	for (i = 0; snmp4_net_list[i].name != NULL; i++)
+	for (i = 0; snmp4_net_list[i].name; i++)
 		seq_printf(seq, " %s", snmp4_net_list[i].name);
 
 	seq_puts(seq, "\nTcpExt:");
 	for_each_possible_cpu(c)
-		for (i = 0; snmp4_net_list[i].name != NULL; i++)
+		for (i = 0; snmp4_net_list[i].name; i++)
 			buff[i] += snmp_get_cpu_field(net->mib.net_statistics,
 						c, snmp4_net_list[i].entry);
-	for (i = 0; snmp4_net_list[i].name != NULL; i++)
+	for (i = 0; snmp4_net_list[i].name; i++)
 		seq_printf(seq, " %lu", buff[i]);
 
 	seq_puts(seq, "\nIpExt:");
-	for (i = 0; snmp4_ipextstats_list[i].name != NULL; i++)
+	for (i = 0; snmp4_ipextstats_list[i].name; i++)
 		seq_printf(seq, " %s", snmp4_ipextstats_list[i].name);
 
 	seq_puts(seq, "\nIpExt:");
 	for_each_possible_cpu(c)
-		for (i = 0; snmp4_ipextstats_list[i].name != NULL; i++)
+		for (i = 0; snmp4_ipextstats_list[i].name; i++)
 			buff64[i] += snmp_get_cpu_field64(
 					net->mib.ip_statistics,
 					c, snmp4_ipextstats_list[i].entry,
 					offsetof(struct ipstats_mib, syncp));
-	for (i = 0; snmp4_ipextstats_list[i].name != NULL; i++)
+	for (i = 0; snmp4_ipextstats_list[i].name; i++)
 		seq_printf(seq, " %llu", buff64[i]);
 
 	seq_putc(seq, '\n');
diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 085fb95..816a5e8 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -80,11 +80,11 @@ static int sctp_snmp_seq_show(struct seq_file *seq, void *v)
 	memset(buff, 0, sizeof(unsigned long) * SCTP_MIB_MAX);
 
 	for_each_possible_cpu(c)
-		for (i = 0; sctp_snmp_list[i].name != NULL; i++)
+		for (i = 0; sctp_snmp_list[i].name; i++)
 			buff[i] += snmp_get_cpu_field(
 						net->sctp.sctp_statistics,
 						c, sctp_snmp_list[i].entry);
-	for (i = 0; sctp_snmp_list[i].name != NULL; i++)
+	for (i = 0; sctp_snmp_list[i].name; i++)
 		seq_printf(seq, "%-32s\t%ld\n", sctp_snmp_list[i].name,
 						buff[i]);
 
diff --git a/net/xfrm/xfrm_proc.c b/net/xfrm/xfrm_proc.c
index c9df546..2f1da2d 100644
--- a/net/xfrm/xfrm_proc.c
+++ b/net/xfrm/xfrm_proc.c
@@ -57,11 +57,11 @@ static int xfrm_statistics_seq_show(struct seq_file *seq, void *v)
 	memset(buff, 0, sizeof(unsigned long) * LINUX_MIB_XFRMMAX);
 
 	for_each_possible_cpu(c)
-		for (i = 0; xfrm_mib_list[i].name != NULL; i++)
+		for (i = 0; xfrm_mib_list[i].name; i++)
 			buff[i] += snmp_get_cpu_field(
 						net->mib.xfrm_statistics,
 						c, xfrm_mib_list[i].entry);
-	for (i = 0; xfrm_mib_list[i].name != NULL; i++)
+	for (i = 0; xfrm_mib_list[i].name; i++)
 		seq_printf(seq, "%-24s\t%lu\n", xfrm_mib_list[i].name,
 						buff[i]);
 
-- 
1.8.3.1
