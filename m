From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] net: Convert SEQ_START_TOKEN/seq_printf to seq_puts
Date: Tue, 04 Nov 2014 15:37:03 -0800
Message-ID: <1415144223.1508.1.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0226.hostedemail.com ([216.40.44.226]:53113 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751435AbaKDXhG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 18:37:06 -0500
Received: from filter.hostedemail.com (unknown [216.40.38.60])
	by smtprelay03.hostedemail.com (Postfix) with ESMTP id 971136A9C4
	for <netdev@vger.kernel.org>; Tue,  4 Nov 2014 23:37:05 +0000 (UTC)
Received: from joe-X200MA.home (pool-71-103-235-196.lsanca.fios.verizon.net [71.103.235.196])
	(Authenticated sender: joe@perches.com)
	by omf12.hostedemail.com (Postfix) with ESMTPA
	for <netdev@vger.kernel.org>; Tue,  4 Nov 2014 23:37:04 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using a single fixed string is smaller code size than using
a format and many string arguments.

Reduces overall code size a little.

$ size net/ipv4/igmp.o* net/ipv6/mcast.o* net/ipv6/ip6_flowlabel.o*
   text	   data	    bss	    dec	    hex	filename
  34269	   7012	  14824	  56105	   db29	net/ipv4/igmp.o.new
  34315	   7012	  14824	  56151	   db57	net/ipv4/igmp.o.old
  30078	   7869	  13200	  51147	   c7cb	net/ipv6/mcast.o.new
  30105	   7869	  13200	  51174	   c7e6	net/ipv6/mcast.o.old
  11434	   3748	   8580	  23762	   5cd2	net/ipv6/ip6_flowlabel.o.new
  11491	   3748	   8580	  23819	   5d0b	net/ipv6/ip6_flowlabel.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---

Done by using printf with these formats and args

 net/ipv4/igmp.c          | 6 +-----
 net/ipv6/ip6_flowlabel.c | 3 +--
 net/ipv6/mcast.c         | 6 +-----
 3 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 3f80513..1e4adae 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2687,11 +2687,7 @@ static int igmp_mcf_seq_show(struct seq_file *seq, void *v)
 	struct igmp_mcf_iter_state *state = igmp_mcf_seq_private(seq);
 
 	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq,
-			   "%3s %6s "
-			   "%10s %10s %6s %6s\n", "Idx",
-			   "Device", "MCA",
-			   "SRC", "INC", "EXC");
+		seq_puts(seq, "Idx Device        MCA        SRC    INC    EXC\n");
 	} else {
 		seq_printf(seq,
 			   "%3d %6.6s 0x%08x "
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index c143437..7221021 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -770,8 +770,7 @@ static int ip6fl_seq_show(struct seq_file *seq, void *v)
 {
 	struct ip6fl_iter_state *state = ip6fl_seq_private(seq);
 	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq, "%-5s %-1s %-6s %-6s %-6s %-8s %-32s %s\n",
-			   "Label", "S", "Owner", "Users", "Linger", "Expires", "Dst", "Opt");
+		seq_puts(seq, "Label S Owner  Users  Linger Expires  Dst                              Opt\n");
 	} else {
 		struct ip6_flowlabel *fl = v;
 		seq_printf(seq,
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 9648de2..e04f184 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2823,11 +2823,7 @@ static int igmp6_mcf_seq_show(struct seq_file *seq, void *v)
 	struct igmp6_mcf_iter_state *state = igmp6_mcf_seq_private(seq);
 
 	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq,
-			   "%3s %6s "
-			   "%32s %32s %6s %6s\n", "Idx",
-			   "Device", "Multicast Address",
-			   "Source Address", "INC", "EXC");
+		seq_puts(seq, "Idx Device                Multicast Address                   Source Address    INC    EXC\n");
 	} else {
 		seq_printf(seq,
 			   "%3d %6.6s %pi6 %pi6 %6lu %6lu\n",
