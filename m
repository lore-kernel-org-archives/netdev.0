From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 1/4] vrf: don't panic on cache create failure
Date: Wed, 19 Aug 2015 06:27:07 +0300
Message-ID: <1439954830-24947-2-git-send-email-razor@blackwall.org>
References: <1439954830-24947-1-git-send-email-razor@blackwall.org>
Cc: dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:38642 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753263AbbHSPAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 11:00:48 -0400
Received: by wicja10 with SMTP id ja10so10983687wic.1
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 08:00:47 -0700 (PDT)
In-Reply-To: <1439954830-24947-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

It's pointless to panic on cache create failure when that case is handled
and even more so since it's not a kernel-wide fatal problem so don't
panic.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 drivers/net/vrf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 4aa06450fafa..01dc91562a88 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -649,7 +649,7 @@ static int __init vrf_init_module(void)
 	vrf_dst_ops.kmem_cachep =
 		kmem_cache_create("vrf_ip_dst_cache",
 				  sizeof(struct rtable), 0,
-				  SLAB_HWCACHE_ALIGN | SLAB_PANIC,
+				  SLAB_HWCACHE_ALIGN,
 				  NULL);
 
 	if (!vrf_dst_ops.kmem_cachep)
-- 
2.4.3
