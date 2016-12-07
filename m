From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 27/50] netfilter: nft_fib_ipv4: initialize *dest to zero
Date: Wed,  7 Dec 2016 22:52:33 +0100
Message-ID: <1481147576-5690-28-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60216 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933370AbcLGVxp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 16:53:45 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id BD689A7D59
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:41 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id ADD41DA848
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:41 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 87841DA849
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:39 +0100 (CET)
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

Otherwise, if fib lookup fail, *dest will be filled with garbage value,
so reverse path filtering will not work properly:
 # nft add rule x prerouting fib saddr oif eq 0 drop

Fixes: f6d0cbcf09c5 ("netfilter: nf_tables: add fib expression")
Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Acked-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nft_fib_ipv4.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/netfilter/nft_fib_ipv4.c b/net/ipv4/netfilter/nft_fib_ipv4.c
index bfffa742f397..258136364f5e 100644
--- a/net/ipv4/netfilter/nft_fib_ipv4.c
+++ b/net/ipv4/netfilter/nft_fib_ipv4.c
@@ -122,6 +122,8 @@ void nft_fib4_eval(const struct nft_expr *expr, struct nft_regs *regs,
 		fl4.saddr = get_saddr(iph->daddr);
 	}
 
+	*dest = 0;
+
 	if (fib_lookup(nft_net(pkt), &fl4, &res, FIB_LOOKUP_IGNORE_LINKSTATE))
 		return;
 
-- 
2.1.4
