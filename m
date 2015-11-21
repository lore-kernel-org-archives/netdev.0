From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 7/9] net: ipmr: remove SLAB_PANIC
Date: Sat, 21 Nov 2015 14:01:40 +0100
Message-ID: <1448110902-28793-8-git-send-email-razor@blackwall.org>
References: <1448110902-28793-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:36450 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759912AbbKUNBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2015 08:01:53 -0500
Received: by wmww144 with SMTP id w144so48196693wmw.1
        for <netdev@vger.kernel.org>; Sat, 21 Nov 2015 05:01:52 -0800 (PST)
In-Reply-To: <1448110902-28793-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

It's not necessary to panic upon allocation failure, returning an error
at that point is okay because user-space won't be able to use any of the
ops since they didn't get registered and the default table is null.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/ipv4/ipmr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index a006d96d6cd9..2c7fa584a274 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2675,7 +2675,7 @@ int __init ip_mr_init(void)
 
 	mrt_cachep = kmem_cache_create("ip_mrt_cache",
 				       sizeof(struct mfc_cache),
-				       0, SLAB_HWCACHE_ALIGN | SLAB_PANIC,
+				       0, SLAB_HWCACHE_ALIGN,
 				       NULL);
 	if (!mrt_cachep)
 		return -ENOMEM;
-- 
2.4.3
