From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] snmp: fix some left over of snmp stats
Date: Mon, 12 May 2014 16:52:02 -0700
Message-ID: <1399938722-809-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:42579 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752461AbaELXw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 19:52:26 -0400
Received: by mail-pb0-f43.google.com with SMTP id up15so237135pbc.2
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 16:52:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fengguang reported the following sparse warning:

>> net/ipv6/proc.c:198:41: sparse: incorrect type in argument 1 (different address spaces)
   net/ipv6/proc.c:198:41:    expected void [noderef] <asn:3>*mib
   net/ipv6/proc.c:198:41:    got void [noderef] <asn:3>**pcpumib

Fixes: commit 698365fa1874aa7635d51667a3 (net: clean up snmp stats code)
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv6/proc.c | 8 ++++----
 net/sctp/proc.c | 2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 69cb476..3317440 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -186,7 +186,7 @@ static void snmp6_seq_show_icmpv6msg(struct seq_file *seq, atomic_long_t *smib)
 /* can be called either with percpu mib (pcpumib != NULL),
  * or shared one (smib != NULL)
  */
-static void snmp6_seq_show_item(struct seq_file *seq, void __percpu **pcpumib,
+static void snmp6_seq_show_item(struct seq_file *seq, void __percpu *pcpumib,
 				atomic_long_t *smib,
 				const struct snmp_mib *itemlist)
 {
@@ -217,12 +217,12 @@ static int snmp6_seq_show(struct seq_file *seq, void *v)
 
 	snmp6_seq_show_item64(seq, net->mib.ipv6_statistics,
 			    snmp6_ipstats_list, offsetof(struct ipstats_mib, syncp));
-	snmp6_seq_show_item(seq, (void __percpu **)net->mib.icmpv6_statistics,
+	snmp6_seq_show_item(seq, net->mib.icmpv6_statistics,
 			    NULL, snmp6_icmp6_list);
 	snmp6_seq_show_icmpv6msg(seq, net->mib.icmpv6msg_statistics->mibs);
-	snmp6_seq_show_item(seq, (void __percpu **)net->mib.udp_stats_in6,
+	snmp6_seq_show_item(seq, net->mib.udp_stats_in6,
 			    NULL, snmp6_udp6_list);
-	snmp6_seq_show_item(seq, (void __percpu **)net->mib.udplite_stats_in6,
+	snmp6_seq_show_item(seq, net->mib.udplite_stats_in6,
 			    NULL, snmp6_udplite6_list);
 	return 0;
 }
diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 0947f1e..34229ee 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -78,7 +78,7 @@ static int sctp_snmp_seq_show(struct seq_file *seq, void *v)
 
 	for (i = 0; sctp_snmp_list[i].name != NULL; i++)
 		seq_printf(seq, "%-32s\t%ld\n", sctp_snmp_list[i].name,
-			   snmp_fold_field((void __percpu **)net->sctp.sctp_statistics,
+			   snmp_fold_field(net->sctp.sctp_statistics,
 				      sctp_snmp_list[i].entry));
 
 	return 0;
-- 
1.8.3.1
