From: <liujian56@huawei.com>
Subject: [PATCH ] net: frag: print frag_mem_limit value in sockstat proc file
Date: Tue, 29 Aug 2017 21:05:34 +0800
Message-ID: <1504011934-17308-1-git-send-email-liujian56@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kuznet@ms2.inr.ac.ru>, <yoshfuji@linux-ipv6.org>,
        <brouer@redhat.com>, <fw@strlen.de>, <netdev@vger.kernel.org>,
        <liujian56@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga05-in.huawei.com ([45.249.212.191]:5038 "EHLO
        szxga05-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751586AbdH2NG7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 09:06:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: liujian <liujian56@huawei.com>

>From 6d7b857d5( net: use lib/percpu_counter API for fragmentation mem
accounting),
frag_mem_limit and sum_frag_mem_limit have different value if there are
multiple NIC RX CPU.
Print frag_mem_limit value, then we can get more debug info.

Signed-off-by: liujian <liujian56@huawei.com>
---
 net/ipv4/proc.c | 3 ++-
 net/ipv6/proc.c | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 43eb6567..370cda1 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -73,7 +73,8 @@ static int sockstat_seq_show(struct seq_file *seq, void *v)
 	seq_printf(seq, "RAW: inuse %d\n",
 		   sock_prot_inuse_get(net, &raw_prot));
 	frag_mem = ip_frag_mem(net);
-	seq_printf(seq,  "FRAG: inuse %u memory %u\n", !!frag_mem, frag_mem);
+	seq_printf(seq,  "FRAG: inuse %u memory %u current mem_limit %d\n",
+		!!frag_mem, frag_mem, frag_mem_limit(&net->ipv4.frags));
 	return 0;
 }
 
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index e88bcb8..00680bc 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -48,7 +48,8 @@ static int sockstat6_seq_show(struct seq_file *seq, void *v)
 			sock_prot_inuse_get(net, &udplitev6_prot));
 	seq_printf(seq, "RAW6: inuse %d\n",
 		       sock_prot_inuse_get(net, &rawv6_prot));
-	seq_printf(seq, "FRAG6: inuse %u memory %u\n", !!frag_mem, frag_mem);
+	seq_printf(seq, "FRAG6: inuse %u memory %u current mem_limit %d\n",
+		 !!frag_mem, frag_mem, frag_mem_limit(&net->ipv6.frags));
 	return 0;
 }
 
-- 
1.8.3.1
