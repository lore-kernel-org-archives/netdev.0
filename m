From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/35] netfilter: xt_CT: don't put back reference to timeout policy object
Date: Sat, 17 Oct 2015 13:32:47 +0200
Message-ID: <1445081590-2924-13-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48366 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752624AbbJQL0U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 07:26:20 -0400
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On success, this shouldn't put back the timeout policy object, otherwise
we may have module refcount overflow and we allow deletion of timeout
that are still in use.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_CT.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index faf32d8..a03924c 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -171,6 +171,9 @@ xt_ct_set_timeout(struct nf_conn *ct, const struct xt_tgchk_param *par,
 	if (timeout_ext == NULL)
 		ret = -ENOMEM;
 
+	rcu_read_unlock();
+	return ret;
+
 err_put_timeout:
 	__xt_ct_tg_timeout_put(timeout);
 out:
-- 
2.1.4
