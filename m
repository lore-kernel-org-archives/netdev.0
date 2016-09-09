From: Jia He <hejianet@gmail.com>
Subject: [RFC PATCH v3 7/7] net: Suppress the "Comparison to NULL could be written" warning
Date: Fri,  9 Sep 2016 14:34:02 +0800
Message-ID: <1473402842-1987-8-git-send-email-hejianet@gmail.com>
References: <1473402842-1987-1-git-send-email-hejianet@gmail.com>
Cc: linux-sctp@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        marcelo.leitner@gmail.com, Jia He <hejianet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473402842-1987-1-git-send-email-hejianet@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is to suppress the checkpatch.pl warning "Comparison to NULL
could be written". No functional changes here.

Signed-off-by: Jia He <hejianet@gmail.com>
---
 net/ipv4/proc.c | 32 ++++++++++++++++----------------
 net/sctp/proc.c |  2 +-
 2 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index c6fc80e..c6ee8a2 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -357,22 +357,22 @@ static void icmp_put(struct seq_file *seq)
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
@@ -389,7 +389,7 @@ static int snmp_seq_show_ipstats(struct seq_file *seq, void *v)
 	memset(buff64, 0, IPSTATS_MIB_MAX * sizeof(u64));
 
 	seq_puts(seq, "Ip: Forwarding DefaultTTL");
-	for (i = 0; snmp4_ipstats_list[i].name != NULL; i++)
+	for (i = 0; snmp4_ipstats_list[i].name; i++)
 		seq_printf(seq, " %s", snmp4_ipstats_list[i].name);
 
 	seq_printf(seq, "\nIp: %d %d",
@@ -400,7 +400,7 @@ static int snmp_seq_show_ipstats(struct seq_file *seq, void *v)
 	snmp_get_cpu_field64_batch(buff64, snmp4_ipstats_list,
 				   net->mib.ip_statistics,
 				   offsetof(struct ipstats_mib, syncp));
-	for (i = 0; snmp4_ipstats_list[i].name != NULL; i++)
+	for (i = 0; snmp4_ipstats_list[i].name; i++)
 		seq_printf(seq, " %llu", buff64[i]);
 
 	return 0;
@@ -415,13 +415,13 @@ static int snmp_seq_show_tcp_udp(struct seq_file *seq, void *v)
 	memset(buff, 0, TCPUDP_MIB_MAX * sizeof(unsigned long));
 
 	seq_puts(seq, "\nTcp:");
-	for (i = 0; snmp4_tcp_list[i].name != NULL; i++)
+	for (i = 0; snmp4_tcp_list[i].name; i++)
 		seq_printf(seq, " %s", snmp4_tcp_list[i].name);
 
 	seq_puts(seq, "\nTcp:");
 	snmp_get_cpu_field_batch(buff, snmp4_tcp_list,
 				 net->mib.tcp_statistics);
-	for (i = 0; snmp4_tcp_list[i].name != NULL; i++) {
+	for (i = 0; snmp4_tcp_list[i].name; i++) {
 		/* MaxConn field is signed, RFC 2012 */
 		if (snmp4_tcp_list[i].entry == TCP_MIB_MAXCONN)
 			seq_printf(seq, " %ld", buff[i]);
@@ -434,10 +434,10 @@ static int snmp_seq_show_tcp_udp(struct seq_file *seq, void *v)
 	snmp_get_cpu_field_batch(buff, snmp4_udp_list,
 				 net->mib.udp_statistics);
 	seq_puts(seq, "\nUdp:");
-	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
+	for (i = 0; snmp4_udp_list[i].name; i++)
 		seq_printf(seq, " %s", snmp4_udp_list[i].name);
 	seq_puts(seq, "\nUdp:");
-	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
+	for (i = 0; snmp4_udp_list[i].name; i++)
 		seq_printf(seq, " %lu", buff[i]);
 
 	memset(buff, 0, TCPUDP_MIB_MAX * sizeof(unsigned long));
@@ -446,10 +446,10 @@ static int snmp_seq_show_tcp_udp(struct seq_file *seq, void *v)
 	seq_puts(seq, "\nUdpLite:");
 	snmp_get_cpu_field_batch(buff, snmp4_udp_list,
 				 net->mib.udplite_statistics);
-	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
+	for (i = 0; snmp4_udp_list[i].name; i++)
 		seq_printf(seq, " %s", snmp4_udp_list[i].name);
 	seq_puts(seq, "\nUdpLite:");
-	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
+	for (i = 0; snmp4_udp_list[i].name; i++)
 		seq_printf(seq, " %lu", buff[i]);
 
 	seq_putc(seq, '\n');
@@ -493,13 +493,13 @@ static int netstat_seq_show_tcpext(struct seq_file *seq, void *v)
 	memset(buff, 0, sizeof(unsigned long) * LINUX_MIB_MAX);
 
 	seq_puts(seq, "TcpExt:");
-	for (i = 0; snmp4_net_list[i].name != NULL; i++)
+	for (i = 0; snmp4_net_list[i].name; i++)
 		seq_printf(seq, " %s", snmp4_net_list[i].name);
 
 	seq_puts(seq, "\nTcpExt:");
 	snmp_get_cpu_field_batch(buff, snmp4_net_list,
 				 net->mib.net_statistics);
-	for (i = 0; snmp4_net_list[i].name != NULL; i++)
+	for (i = 0; snmp4_net_list[i].name; i++)
 		seq_printf(seq, " %lu", buff[i]);
 
 	return 0;
@@ -512,14 +512,14 @@ static int netstat_seq_show_ipext(struct seq_file *seq, void *v)
 	struct net *net = seq->private;
 
 	seq_puts(seq, "\nIpExt:");
-	for (i = 0; snmp4_ipextstats_list[i].name != NULL; i++)
+	for (i = 0; snmp4_ipextstats_list[i].name; i++)
 		seq_printf(seq, " %s", snmp4_ipextstats_list[i].name);
 
 	seq_puts(seq, "\nIpExt:");
 	snmp_get_cpu_field64_batch(buff64, snmp4_ipextstats_list,
 				   net->mib.ip_statistics,
 				   offsetof(struct ipstats_mib, syncp));
-	for (i = 0; snmp4_ipextstats_list[i].name != NULL; i++)
+	for (i = 0; snmp4_ipextstats_list[i].name; i++)
 		seq_printf(seq, " %llu", buff64[i]);
 
 	seq_putc(seq, '\n');
diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 0487c01..f596407 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -81,7 +81,7 @@ static int sctp_snmp_seq_show(struct seq_file *seq, void *v)
 
 	snmp_get_cpu_field_batch(buff, sctp_snmp_list,
 				 net->sctp.sctp_statistics);
-	for (i = 0; sctp_snmp_list[i].name != NULL; i++)
+	for (i = 0; sctp_snmp_list[i].name; i++)
 		seq_printf(seq, "%-32s\t%ld\n", sctp_snmp_list[i].name,
 						buff[i]);
 
-- 
1.8.3.1
