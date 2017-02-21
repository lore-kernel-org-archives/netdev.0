From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH net-next 1/2] netfilter: nf_ct_expect: nf_ct_expect_related_report(): Return zero on success,
Date: Tue, 21 Feb 2017 15:25:21 -0800
Message-ID: <1487719522-42844-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org, fgao@ikuai8.com, pablo@netfilter.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:54231 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751452AbdBUXZq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 18:25:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 4dee62b1 ("netfilter: nf_ct_expect: nf_ct_expect_insert()
returns void") inadvertently changed the successful return value of
nf_ct_expect_related_report() from 0 to 1, which caused openvswitch
conntrack integration fail in FTP test cases.

Fix this by always returning zero on the success code path.

Fixes: 4dee62b1 ("netfilter: nf_ct_expect: nf_ct_expect_insert() returns void")
Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 net/netfilter/nf_conntrack_expect.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index e19a697..d6ace69 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -467,7 +467,7 @@ int nf_ct_expect_related_report(struct nf_conntrack_expect *expect,
 
 	spin_unlock_bh(&nf_conntrack_expect_lock);
 	nf_ct_expect_event_report(IPEXP_NEW, expect, portid, report);
-	return ret;
+	return 0;
 out:
 	spin_unlock_bh(&nf_conntrack_expect_lock);
 	return ret;
-- 
2.1.4
