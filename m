From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: fix tiny output corruption of /proc/net/snmp6
Date: Thu, 20 Nov 2008 12:08:07 +0300
Message-ID: <20081120090807.GD1927@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:24842 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754536AbYKTJEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 04:04:25 -0500
Received: by ug-out-1314.google.com with SMTP id 39so211754ugf.37
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2008 01:04:23 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because "name" is static, it can be occasionally be filled with
somewhat garbage if two processes read /proc/net/snmp6.

Also, remove useless casts and "-1" -- snprintf() correctly terminates it's
output.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv6/proc.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -132,7 +132,7 @@ static struct snmp_mib snmp6_udplite6_list[] = {
 
 static void snmp6_seq_show_icmpv6msg(struct seq_file *seq, void **mib)
 {
-	static char name[32];
+	char name[32];
 	int i;
 
 	/* print by name -- deprecated items */
@@ -144,7 +144,7 @@ static void snmp6_seq_show_icmpv6msg(struct seq_file *seq, void **mib)
 		p = icmp6type2name[icmptype];
 		if (!p)	/* don't print un-named types here */
 			continue;
-		(void) snprintf(name, sizeof(name)-1, "Icmp6%s%s",
+		snprintf(name, sizeof(name), "Icmp6%s%s",
 			i & 0x100 ? "Out" : "In", p);
 		seq_printf(seq, "%-32s\t%lu\n", name,
 			snmp_fold_field(mib, i));
@@ -157,7 +157,7 @@ static void snmp6_seq_show_icmpv6msg(struct seq_file *seq, void **mib)
 		val = snmp_fold_field(mib, i);
 		if (!val)
 			continue;
-		(void) snprintf(name, sizeof(name)-1, "Icmp6%sType%u",
+		snprintf(name, sizeof(name), "Icmp6%sType%u",
 			i & 0x100 ?  "Out" : "In", i & 0xff);
 		seq_printf(seq, "%-32s\t%lu\n", name, val);
 	}
