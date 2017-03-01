From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH] netfilter: nf_conntrack_sip: fix wrong memory initialisation
Date: Wed,  1 Mar 2017 15:33:26 +0100 (CET)
Message-ID: <20170301143327.2C90B6BD30@localhost.localdomain>
Cc: linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        stable@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>, Gao Feng <fgao@ikuai8.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pegase1.c-s.fr ([93.17.236.30]:12204 "EHLO pegase1.c-s.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751542AbdCAOdd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Mar 2017 09:33:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 82de0be6862cd ("netfilter: Add helper array
register/unregister functions"),
struct nf_conntrack_helper sip[MAX_PORTS][4] was changed to
sip[MAX_PORTS * 4], so the memory init should have been changed to
memset(&sip[4 * i], 0, 4 * sizeof(sip[i]));

But as the sip[] table is allocated in the BSS, it is already set to 0

Fixes: 82de0be6862cd ("netfilter: Add helper array
register/unregister functions")
Cc: stable@vger.kernel.org

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
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
2.12.0
