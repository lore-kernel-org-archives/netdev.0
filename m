From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] ipv4: use seq_puts instead of seq_printf where possible
Date: Tue,  4 Nov 2014 20:31:26 +0100
Message-ID: <1415129486-13185-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay004.isp.belgacom.be ([195.238.6.170]:34673 "EHLO
	mailrelay004.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750985AbaKDTbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 14:31:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/ipv4/proc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 8e3eb39..f0d4eb8 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -296,12 +296,12 @@ static void icmpmsg_put_line(struct seq_file *seq, unsigned long *vals,
 	int j;
 
 	if (count) {
-		seq_printf(seq, "\nIcmpMsg:");
+		seq_puts(seq, "\nIcmpMsg:");
 		for (j = 0; j < count; ++j)
 			seq_printf(seq, " %sType%u",
 				type[j] & 0x100 ? "Out" : "In",
 				type[j] & 0xff);
-		seq_printf(seq, "\nIcmpMsg:");
+		seq_puts(seq, "\nIcmpMsg:");
 		for (j = 0; j < count; ++j)
 			seq_printf(seq, " %lu", vals[j]);
 	}
@@ -342,7 +342,7 @@ static void icmp_put(struct seq_file *seq)
 	seq_puts(seq, "\nIcmp: InMsgs InErrors InCsumErrors");
 	for (i = 0; icmpmibmap[i].name != NULL; i++)
 		seq_printf(seq, " In%s", icmpmibmap[i].name);
-	seq_printf(seq, " OutMsgs OutErrors");
+	seq_puts(seq, " OutMsgs OutErrors");
 	for (i = 0; icmpmibmap[i].name != NULL; i++)
 		seq_printf(seq, " Out%s", icmpmibmap[i].name);
 	seq_printf(seq, "\nIcmp: %lu %lu %lu",
-- 
1.9.3
