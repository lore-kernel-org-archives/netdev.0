From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH] [RFC] netfilter: don't assume NFPROTO_* are like PF_*
Date: Mon, 14 May 2012 14:58:29 +0100
Message-ID: <1337003909-2582-1-git-send-email-alban.crequy@collabora.co.uk>
Cc: Vincent Sanders <vincent.sanders@collabora.co.uk>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Alban Crequy <alban.crequy@collabora.co.uk>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.135.160]:48731 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755663Ab2ENN7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 09:59:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this patch, NFPROTO_* constants don't have the same values as PF_*
constants.

Benefit: it makes NFPROTO_NUMPROTO smaller and saves space as arrays are
smaller.

Issues: might have missed a conversion. I grepped NF_HOOK, nf_register_hook,
nf_register_hooks, and xt_hook_link. So it is probably fine.

NFPROTO_* constants were introduced by commit 7e9c6e.

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
Reviewed-by: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Reviewed-by: Vincent Sanders <vincent.sanders@collabora.co.uk>
---
 include/linux/netfilter.h |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 29734be..89afadb 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -62,11 +62,11 @@ enum nf_inet_hooks {
 
 enum {
 	NFPROTO_UNSPEC =  0,
-	NFPROTO_IPV4   =  2,
-	NFPROTO_ARP    =  3,
-	NFPROTO_BRIDGE =  7,
-	NFPROTO_IPV6   = 10,
-	NFPROTO_DECNET = 12,
+	NFPROTO_IPV4,
+	NFPROTO_ARP,
+	NFPROTO_BRIDGE,
+	NFPROTO_IPV6,
+	NFPROTO_DECNET,
 	NFPROTO_NUMPROTO,
 };
 
-- 
1.7.2.5
