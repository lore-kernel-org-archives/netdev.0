From: pablo@netfilter.org
Subject: [PATCH 8/8] netfilter: xt_CT: fix wrong checking in the timeout assignment path
Date: Mon, 30 Apr 2012 17:16:55 +0200
Message-ID: <1335799015-2003-9-git-send-email-pablo@netfilter.org>
References: <1335799015-2003-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34564 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756084Ab2D3PRg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2012 11:17:36 -0400
In-Reply-To: <1335799015-2003-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

The current checking always succeeded. We have to check the first
character of the string to check that it's empty, thus, skipping
the timeout path.

This fixes the use of the CT target without the timeout option.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_CT.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 59530e9..3746d8b 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -227,7 +227,7 @@ static int xt_ct_tg_check_v1(const struct xt_tgchk_param *par)
 	}
 
 #ifdef CONFIG_NF_CONNTRACK_TIMEOUT
-	if (info->timeout) {
+	if (info->timeout[0]) {
 		typeof(nf_ct_timeout_find_get_hook) timeout_find_get;
 		struct nf_conn_timeout *timeout_ext;
 
-- 
1.7.9.5
