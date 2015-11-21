From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next v2 7/9] net: ipmr: drop ip_mr_init() mrt_cachep null check as we'll panic if it fails
Date: Sat, 21 Nov 2015 15:57:30 +0100
Message-ID: <1448117852-4254-8-git-send-email-razor@blackwall.org>
References: <1448117852-4254-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37099 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761037AbbKUO7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2015 09:59:31 -0500
Received: by wmww144 with SMTP id w144so54416134wmw.0
        for <netdev@vger.kernel.org>; Sat, 21 Nov 2015 06:59:30 -0800 (PST)
In-Reply-To: <1448117852-4254-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

It's not necessary to check for null as SLAB_PANIC is used and we'll
panic if the alloc fails, so just drop it.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v2: new patch, keep SLAB_PANIC and drop the unnecessary null check

 net/ipv4/ipmr.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index a006d96d6cd9..50aec313119d 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2677,8 +2677,6 @@ int __init ip_mr_init(void)
 				       sizeof(struct mfc_cache),
 				       0, SLAB_HWCACHE_ALIGN | SLAB_PANIC,
 				       NULL);
-	if (!mrt_cachep)
-		return -ENOMEM;
 
 	err = register_pernet_subsys(&ipmr_net_ops);
 	if (err)
-- 
2.4.3
