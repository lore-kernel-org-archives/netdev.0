From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 21/53] netfilter: nf_nat: Fix return NF_DROP in nfnetlink_parse_nat_setup
Date: Mon,  1 May 2017 12:46:48 +0200
Message-ID: <1493635640-24325-22-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49648 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S378878AbdEAKsA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 06:48:00 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 8B78E20991C
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:46 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7B7E391F2
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:46 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 5B9CBFF124
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:44 +0200 (CEST)
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

The __nf_nat_alloc_null_binding invokes nf_nat_setup_info which may
return NF_DROP when memory is exhausted, so convert NF_DROP to -ENOMEM
to make ctnetlink happy. Or ctnetlink_setup_nat treats it as a success
when one error NF_DROP happens actully.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_nat_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index fb0e65411785..5e35643da650 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -806,7 +806,7 @@ nfnetlink_parse_nat_setup(struct nf_conn *ct,
 
 	/* No NAT information has been passed, allocate the null-binding */
 	if (attr == NULL)
-		return __nf_nat_alloc_null_binding(ct, manip);
+		return __nf_nat_alloc_null_binding(ct, manip) == NF_DROP ? -ENOMEM : 0;
 
 	err = nfnetlink_parse_nat(attr, ct, &range, l3proto);
 	if (err < 0)
-- 
2.1.4
