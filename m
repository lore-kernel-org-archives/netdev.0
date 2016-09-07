From: Andrei Vagin <avagin@openvz.org>
Subject: [PATCH net-next v2] netlink: don't forget to release a rhashtable_iter structure
Date: Tue,  6 Sep 2016 21:31:17 -0700
Message-ID: <1473222677-24761-1-git-send-email-avagin@openvz.org>
References: <20160906.174137.1869816645707925029.davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>,
        Andrei Vagin <avagin@openvz.org>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:36673 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751125AbcIGEbX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 00:31:23 -0400
Received: by mail-lf0-f67.google.com with SMTP id j41so160665lfi.3
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 21:31:22 -0700 (PDT)
In-Reply-To: <20160906.174137.1869816645707925029.davem@davemloft.net>
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

v2: don't remove a reference on a rhashtable_iter structure to
    release it from netlink_diag_dump_done

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Fixes: ad202074320c ("netlink: Use rhashtable walk interface in diag dump")
Signed-off-by: Andrei Vagin <avagin@openvz.org>
---
 net/netlink/diag.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/netlink/diag.c b/net/netlink/diag.c
index 3e3e253..b2f0e98 100644
--- a/net/netlink/diag.c
+++ b/net/netlink/diag.c
@@ -127,7 +127,6 @@ stop:
 		goto done;
 
 	rhashtable_walk_exit(hti);
-	cb->args[2] = 0;
 	num++;
 
 mc_list:
-- 
2.5.5
