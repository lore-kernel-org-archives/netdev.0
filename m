From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Subject: [PATCH net-next] skbuff: Add BUG_ON in skb_init.
Date: Wed,  9 Aug 2017 05:04:38 -0700
Message-ID: <1502280278-9970-2-git-send-email-xiangxia.m.yue@gmail.com>
References: <1502280278-9970-1-git-send-email-xiangxia.m.yue@gmail.com>
Cc: Tonghao Zhang <xiangxia.m.yue@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:37891 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752602AbdHIMFI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 08:05:08 -0400
Received: by mail-pg0-f65.google.com with SMTP id 123so5725772pga.5
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 05:05:07 -0700 (PDT)
In-Reply-To: <1502280278-9970-1-git-send-email-xiangxia.m.yue@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When initializing the skbuff SLAB cache, we should make
sure it is successful. Adding BUG_ON to check it and
init_inodecache() is in the same case.

Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
---
 net/core/skbuff.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 42b62c716a33..9513de519870 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3904,6 +3904,8 @@ void __init skb_init(void)
 						0,
 						SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 						NULL);
+	BUG_ON(skbuff_head_cache == NULL);
+	BUG_ON(skbuff_fclone_cache == NULL);
 }
 
 static int
-- 
2.13.4
