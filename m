From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv6: fix per device IP snmp counters
Date: Tue, 17 Jan 2012 23:45:36 +0100
Message-ID: <1326840336.2606.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36742 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755241Ab2AQWpk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 17:45:40 -0500
Received: by wgbdq11 with SMTP id dq11so2485955wgb.1
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2012 14:45:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 4ce3c183fca (snmp: 64bit ipstats_mib for all arches), I forgot
to change the /proc/net/dev_snmp6/xxx output for IP counters.

percpu array is 64bit per counter but the folding still used the 'long'
variant, and output garbage on 32bit arches.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/proc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index fdeb6d0..da2e92d 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -237,8 +237,8 @@ static int snmp6_dev_seq_show(struct seq_file *seq, void *v)
 	struct inet6_dev *idev = (struct inet6_dev *)seq->private;
 
 	seq_printf(seq, "%-32s\t%u\n", "ifIndex", idev->dev->ifindex);
-	snmp6_seq_show_item(seq, (void __percpu **)idev->stats.ipv6, NULL,
-			    snmp6_ipstats_list);
+	snmp6_seq_show_item64(seq, (void __percpu **)idev->stats.ipv6,
+			    snmp6_ipstats_list, offsetof(struct ipstats_mib, syncp));
 	snmp6_seq_show_item(seq, NULL, idev->stats.icmpv6dev->mibs,
 			    snmp6_icmp6_list);
 	snmp6_seq_show_icmpv6msg(seq, idev->stats.icmpv6msgdev->mibs);
