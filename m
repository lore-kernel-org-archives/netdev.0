From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/4] netfilter: nf_conntrack_sip: fix wrong memory initialisation
Date: Fri,  3 Mar 2017 20:22:23 +0100
Message-ID: <1488568945-4177-3-git-send-email-pablo@netfilter.org>
References: <1488568945-4177-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39700 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752340AbdCCTXF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Mar 2017 14:23:05 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 037581C501A
        for <netdev@vger.kernel.org>; Fri,  3 Mar 2017 20:22:37 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id E8654DA807
        for <netdev@vger.kernel.org>; Fri,  3 Mar 2017 20:22:36 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 9343BDA808
        for <netdev@vger.kernel.org>; Fri,  3 Mar 2017 20:22:34 +0100 (CET)
In-Reply-To: <1488568945-4177-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christophe Leroy <christophe.leroy@c-s.fr>

In commit 82de0be6862cd ("netfilter: Add helper array
register/unregister functions"),
struct nf_conntrack_helper sip[MAX_PORTS][4] was changed to
sip[MAX_PORTS * 4], so the memory init should have been changed to
memset(&sip[4 * i], 0, 4 * sizeof(sip[i]));

But as the sip[] table is allocated in the BSS, it is already set to 0

Fixes: 82de0be6862cd ("netfilter: Add helper array register/unregister functions")
Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_sip.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 24174c520239..0d17894798b5 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1628,8 +1628,6 @@ static int __init nf_conntrack_sip_init(void)
 		ports[ports_c++] = SIP_PORT;
 
 	for (i = 0; i < ports_c; i++) {
-		memset(&sip[i], 0, sizeof(sip[i]));
-
 		nf_ct_helper_init(&sip[4 * i], AF_INET, IPPROTO_UDP, "sip",
 				  SIP_PORT, ports[i], i, sip_exp_policy,
 				  SIP_EXPECT_MAX,
-- 
2.1.4
