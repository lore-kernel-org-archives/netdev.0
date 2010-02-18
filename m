From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 06/09: ebt_limit: add CONFIG_COMPAT support
Date: Thu, 18 Feb 2010 19:21:11 +0100 (MET)
Message-ID: <20100218182111.21826.41534.sendpatchset@x2.localnet>
References: <20100218182103.21826.17908.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38168 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753362Ab0BRSVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 13:21:12 -0500
In-Reply-To: <20100218182103.21826.17908.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 314ddca3b172fdb9c23a25c545505dbde557602e
Author: Florian Westphal <fw@strlen.de>
Date:   Wed Jan 27 14:38:32 2010 +0100

    netfilter: ebt_limit: add CONFIG_COMPAT support
    
    ebt_limit structure is larger on 64 bit systems due
    to "long" type used in the (kernel-only) data section.
    
    Setting .compatsize is enough in this case, these values
    have no meaning in userspace.
    
    Signed-off-by: Florian Westphal <fwestphal@astaro.com>

diff --git a/net/bridge/netfilter/ebt_limit.c b/net/bridge/netfilter/ebt_limit.c
index 9dd16e6..7a81827 100644
--- a/net/bridge/netfilter/ebt_limit.c
+++ b/net/bridge/netfilter/ebt_limit.c
@@ -84,6 +84,19 @@ static bool ebt_limit_mt_check(const struct xt_mtchk_param *par)
 	return true;
 }
 
+
+#ifdef CONFIG_COMPAT
+/*
+ * no conversion function needed --
+ * only avg/burst have meaningful values in userspace.
+ */
+struct ebt_compat_limit_info {
+	compat_uint_t avg, burst;
+	compat_ulong_t prev;
+	compat_uint_t credit, credit_cap, cost;
+};
+#endif
+
 static struct xt_match ebt_limit_mt_reg __read_mostly = {
 	.name		= "limit",
 	.revision	= 0,
@@ -91,6 +104,9 @@ static struct xt_match ebt_limit_mt_reg __read_mostly = {
 	.match		= ebt_limit_mt,
 	.checkentry	= ebt_limit_mt_check,
 	.matchsize	= sizeof(struct ebt_limit_info),
+#ifdef CONFIG_COMPAT
+	.compatsize	= sizeof(struct ebt_compat_limit_info),
+#endif
 	.me		= THIS_MODULE,
 };
 
