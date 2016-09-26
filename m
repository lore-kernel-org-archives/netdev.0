From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH nf-next 2/2] nf_set_hooks_head: acommodate different kconfig
Date: Mon, 26 Sep 2016 12:24:31 -0400
Message-ID: <1474907071-13591-3-git-send-email-aconole@bytheb.org>
References: <1474907071-13591-1-git-send-email-aconole@bytheb.org>
Cc: Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:33690 "EHLO
        mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1422838AbcIZQYo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 12:24:44 -0400
Received: by mail-yw0-f194.google.com with SMTP id g192so9196548ywh.0
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 09:24:44 -0700 (PDT)
In-Reply-To: <1474907071-13591-1-git-send-email-aconole@bytheb.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CONFIG_NETFILTER_INGRESS is unset (or no), we need to handle
the request for registration properly by dropping the hook.  This
releases the entry during the set.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
---
 net/netfilter/core.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index e58e420..1d0a4c9 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -90,10 +90,14 @@ static void nf_set_hooks_head(struct net *net, const struct nf_hook_ops *reg,
 {
 	switch (reg->pf) {
 	case NFPROTO_NETDEV:
+#ifdef CONFIG_NETFILTER_INGRESS
 		/* We already checked in nf_register_net_hook() that this is
 		 * used from ingress.
 		 */
 		rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
+#else
+		kfree(entry);
+#endif
 		break;
 	default:
 		rcu_assign_pointer(net->nf.hooks[reg->pf][reg->hooknum],
-- 
2.5.5
