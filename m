From: junwei.zhang@6wind.com
Subject: [PATCH 2/2] netns: exclude ipvs from struct net when IPVS disabled
Date: Fri, 21 Jun 2013 10:19:17 +0800
Message-ID: <1371781157-16743-2-git-send-email-junwei.zhang@6wind.com>
References: <1371781157-16743-1-git-send-email-junwei.zhang@6wind.com>
Cc: horms@verge.net.au, ja@ssi.bg, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org, JunweiZhang <junwei.zhang@6wind.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: wensong@linux-vs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:40599 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161377Ab3FUCQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 22:16:55 -0400
Received: by mail-pa0-f50.google.com with SMTP id fb1so6990378pad.23
        for <netdev@vger.kernel.org>; Thu, 20 Jun 2013 19:16:54 -0700 (PDT)
In-Reply-To: <1371781157-16743-1-git-send-email-junwei.zhang@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: JunweiZhang <junwei.zhang@6wind.com>

no real problem is fixed, just save a few bytes in
net_namespace structure.

Signed-off-by: JunweiZhang <junwei.zhang@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/net_namespace.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index b176978..c2bf266 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -115,7 +115,9 @@ struct net {
 #ifdef CONFIG_XFRM
 	struct netns_xfrm	xfrm;
 #endif
+#if IS_ENABLED(CONFIG_IP_VS)
 	struct netns_ipvs	*ipvs;
+#endif
 	struct sock		*diag_nlsk;
 	atomic_t		rt_genid;
 };
-- 
1.8.1.2
