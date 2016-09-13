From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/4] netfilter: nf_nat: handle NF_DROP from nfnetlink_parse_nat_setup()
Date: Tue, 13 Sep 2016 11:05:16 +0200
Message-ID: <1473757517-3764-4-git-send-email-pablo@netfilter.org>
References: <1473757517-3764-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59284 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757377AbcIMJFc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Sep 2016 05:05:32 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id E655E18CDC5
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 11:05:31 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id CCDFB179E28
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 11:05:31 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7285916E40A
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 11:05:25 +0200 (CEST)
In-Reply-To: <1473757517-3764-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nf_nat_setup_info() returns NF_* verdicts, so convert them to error
codes that is what ctnelink expects. This has passed overlook without
having any impact since this nf_nat_setup_info() has always returned
NF_ACCEPT so far. Since 870190a9ec90 ("netfilter: nat: convert nat bysrc
hash to rhashtable"), this is problem.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_nat_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index de31818..19c081e 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -807,7 +807,7 @@ nfnetlink_parse_nat_setup(struct nf_conn *ct,
 	if (err < 0)
 		return err;
 
-	return nf_nat_setup_info(ct, &range, manip);
+	return nf_nat_setup_info(ct, &range, manip) == NF_DROP ? -ENOMEM : 0;
 }
 #else
 static int
-- 
2.1.4
