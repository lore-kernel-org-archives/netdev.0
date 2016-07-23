From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 18/25] netfilter: nft_log: check the validity of log level
Date: Sat, 23 Jul 2016 13:08:32 +0200
Message-ID: <1469272119-29942-19-git-send-email-pablo@netfilter.org>
References: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35930 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751699AbcGWLJe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 07:09:34 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 61247E7DAE
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:33 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 500D0FB469
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:33 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id C915FFF148
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:29 +0200 (CEST)
In-Reply-To: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

User can specify the log level larger than 7(debug level) via
nfnetlink, this is invalid. So in this case, we should report
EINVAL to the userspace.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_log.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/netfilter/nft_log.c b/net/netfilter/nft_log.c
index e1b34ff..5f6f088 100644
--- a/net/netfilter/nft_log.c
+++ b/net/netfilter/nft_log.c
@@ -79,6 +79,11 @@ static int nft_log_init(const struct nft_ctx *ctx,
 		} else {
 			li->u.log.level = LOGLEVEL_WARNING;
 		}
+		if (li->u.log.level > LOGLEVEL_DEBUG) {
+			err = -EINVAL;
+			goto err1;
+		}
+
 		if (tb[NFTA_LOG_FLAGS] != NULL) {
 			li->u.log.logflags =
 				ntohl(nla_get_be32(tb[NFTA_LOG_FLAGS]));
-- 
2.1.4
