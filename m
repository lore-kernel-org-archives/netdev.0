From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/6] netfilter: nf_ct_expect: nf_ct_expect_related_report(): Return zero on success.
Date: Mon, 27 Feb 2017 12:35:40 +0100
Message-ID: <1488195342-2678-5-git-send-email-pablo@netfilter.org>
References: <1488195342-2678-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48534 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752045AbdB0Lgo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Feb 2017 06:36:44 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 35116E64A
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 12:35:59 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 25D65DA795
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 12:35:59 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 4DB73DA7F7
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 12:35:56 +0100 (CET)
In-Reply-To: <1488195342-2678-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jarno@ovn.org>

Commit 4dee62b1b9b4 ("netfilter: nf_ct_expect: nf_ct_expect_insert()
returns void") inadvertently changed the successful return value of
nf_ct_expect_related_report() from 0 to 1, which caused openvswitch
conntrack integration fail in FTP test cases.

Fix this by always returning zero on the success code path.

Fixes: 4dee62b1b9b4 ("netfilter: nf_ct_expect: nf_ct_expect_insert() returns void")
Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
Acked-by: Joe Stringer <joe@ovn.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_expect.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index e19a69787d99..d6ace69d57dc 100644
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
