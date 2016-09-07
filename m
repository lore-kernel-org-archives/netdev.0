From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netlink: don't forget to release a
 rhashtable_iter structure
Date: Tue, 06 Sep 2016 17:41:37 -0700 (PDT)
Message-ID: <20160906.174137.1869816645707925029.davem@davemloft.net>
References: <1473186219-13061-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: avagin@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57538 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754028AbcIGAlj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 20:41:39 -0400
In-Reply-To: <1473186219-13061-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrei Vagin <avagin@openvz.org>
Date: Tue,  6 Sep 2016 11:23:39 -0700

> This bug was detected by kmemleak:
> unreferenced object 0xffff8804269cc3c0 (size 64):
>   comm "criu", pid 1042, jiffies 4294907360 (age 13.713s)
>   hex dump (first 32 bytes):
>     a0 32 cc 2c 04 88 ff ff 00 00 00 00 00 00 00 00  .2.,............
>     00 01 00 00 00 00 ad de 00 02 00 00 00 00 ad de  ................
>   backtrace:
>     [<ffffffff8184dffa>] kmemleak_alloc+0x4a/0xa0
>     [<ffffffff8124720f>] kmem_cache_alloc_trace+0x10f/0x280
>     [<ffffffffa02864cc>] __netlink_diag_dump+0x26c/0x290 [netlink_diag]
> 
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Fixes: ad202074320c ("netlink: Use rhashtable walk interface in diag dump")
> Signed-off-by: Andrei Vagin <avagin@openvz.org>

Hmmm, why isn't this handled by netlink_diag_dump_done()?

It seems like the intent is to have the hashtable iter be cached
across multiple __netlink_diag_dump() calls within a single
netlink_diag_dump invocation.
