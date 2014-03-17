From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/38] netfilter: ipset: kernel: uapi: fix MARKMASK attr ABI breakage
Date: Mon, 17 Mar 2014 13:42:35 +0100
Message-ID: <1395060178-11833-16-git-send-email-pablo@netfilter.org>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59394 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933120AbaCQMne (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 08:43:34 -0400
In-Reply-To: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

commit 2dfb973c0dcc6d2211 (add markmask for hash:ip,mark data type)
inserted IPSET_ATTR_MARKMASK in-between other enum values, i.e.
changing values of all further attributes.  This causes 'ipset list'
segfault on existing kernels since ipset no longer finds
IPSET_ATTR_MEMSIZE (it has a different value on kernel side).

Jozsef points out it should be moved below IPSET_ATTR_MARK which
works since there is some extra reserved space after that value.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/uapi/linux/netfilter/ipset/ip_set.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/netfilter/ipset/ip_set.h b/include/uapi/linux/netfilter/ipset/ip_set.h
index a29a378..a1ca244 100644
--- a/include/uapi/linux/netfilter/ipset/ip_set.h
+++ b/include/uapi/linux/netfilter/ipset/ip_set.h
@@ -83,13 +83,13 @@ enum {
 	IPSET_ATTR_CADT_FLAGS,	/* 8 */
 	IPSET_ATTR_CADT_LINENO = IPSET_ATTR_LINENO,	/* 9 */
 	IPSET_ATTR_MARK,	/* 10 */
+	IPSET_ATTR_MARKMASK,	/* 11 */
 	/* Reserve empty slots */
 	IPSET_ATTR_CADT_MAX = 16,
 	/* Create-only specific attributes */
 	IPSET_ATTR_GC,
 	IPSET_ATTR_HASHSIZE,
 	IPSET_ATTR_MAXELEM,
-	IPSET_ATTR_MARKMASK,
 	IPSET_ATTR_NETMASK,
 	IPSET_ATTR_PROBES,
 	IPSET_ATTR_RESIZE,
@@ -139,7 +139,6 @@ enum ipset_errno {
 	IPSET_ERR_EXIST,
 	IPSET_ERR_INVALID_CIDR,
 	IPSET_ERR_INVALID_NETMASK,
-	IPSET_ERR_INVALID_MARKMASK,
 	IPSET_ERR_INVALID_FAMILY,
 	IPSET_ERR_TIMEOUT,
 	IPSET_ERR_REFERENCED,
@@ -147,6 +146,7 @@ enum ipset_errno {
 	IPSET_ERR_IPADDR_IPV6,
 	IPSET_ERR_COUNTER,
 	IPSET_ERR_COMMENT,
+	IPSET_ERR_INVALID_MARKMASK,
 
 	/* Type specific error codes */
 	IPSET_ERR_TYPE_SPECIFIC = 4352,
-- 
1.7.10.4
