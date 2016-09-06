From: Andrei Vagin <avagin@openvz.org>
Subject: [PATCH net-next] netlink: don't forget to release a rhashtable_iter structure
Date: Tue,  6 Sep 2016 11:23:39 -0700
Message-ID: <1473186219-13061-1-git-send-email-avagin@openvz.org>
Cc: "David S. Miller" <davem@davemloft.net>,
        Andrei Vagin <avagin@openvz.org>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:35681 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964810AbcIFSXq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 14:23:46 -0400
Received: by mail-lf0-f66.google.com with SMTP id s64so1581841lfs.2
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 11:23:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This bug was detected by kmemleak:
unreferenced object 0xffff8804269cc3c0 (size 64):
  comm "criu", pid 1042, jiffies 4294907360 (age 13.713s)
  hex dump (first 32 bytes):
    a0 32 cc 2c 04 88 ff ff 00 00 00 00 00 00 00 00  .2.,............
    00 01 00 00 00 00 ad de 00 02 00 00 00 00 ad de  ................
  backtrace:
    [<ffffffff8184dffa>] kmemleak_alloc+0x4a/0xa0
    [<ffffffff8124720f>] kmem_cache_alloc_trace+0x10f/0x280
    [<ffffffffa02864cc>] __netlink_diag_dump+0x26c/0x290 [netlink_diag]

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Fixes: ad202074320c ("netlink: Use rhashtable walk interface in diag dump")
Signed-off-by: Andrei Vagin <avagin@openvz.org>
---
 net/netlink/diag.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netlink/diag.c b/net/netlink/diag.c
index 3e3e253..951670c 100644
--- a/net/netlink/diag.c
+++ b/net/netlink/diag.c
@@ -127,6 +127,7 @@ stop:
 		goto done;
 
 	rhashtable_walk_exit(hti);
+	kfree(hti);
 	cb->args[2] = 0;
 	num++;
 
-- 
2.5.5
