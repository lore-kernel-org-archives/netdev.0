From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/13] netfilter: nf_tables: underflow in nft_parse_u32_check()
Date: Fri, 21 Oct 2016 12:12:17 +0200
Message-ID: <1477044743-18948-8-git-send-email-pablo@netfilter.org>
References: <1477044743-18948-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36298 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754035AbcJUKMo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Oct 2016 06:12:44 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id D2ED426E11
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 12:12:42 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id C258DDA847
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 12:12:42 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 8B6A4BAC48
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 12:12:40 +0200 (CEST)
In-Reply-To: <1477044743-18948-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>

We don't want to allow negatives here.

Fixes: 36b701fae12a ('netfilter: nf_tables: validate maximum value of u32 netlink attributes')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index b70d3ea1430e..24db22257586 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -4423,7 +4423,7 @@ static int nf_tables_check_loops(const struct nft_ctx *ctx,
  */
 unsigned int nft_parse_u32_check(const struct nlattr *attr, int max, u32 *dest)
 {
-	int val;
+	u32 val;
 
 	val = ntohl(nla_get_be32(attr));
 	if (val > max)
-- 
2.1.4
