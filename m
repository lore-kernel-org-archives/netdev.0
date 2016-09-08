From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] netlink: don't forget to release a
 rhashtable_iter structure
Date: Wed, 07 Sep 2016 17:29:51 -0700 (PDT)
Message-ID: <20160907.172951.1700786437214504565.davem@davemloft.net>
References: <20160906.174137.1869816645707925029.davem@davemloft.net>
        <1473222677-24761-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: avagin@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50382 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752328AbcIHA3w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 20:29:52 -0400
In-Reply-To: <1473222677-24761-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrei Vagin <avagin@openvz.org>
Date: Tue,  6 Sep 2016 21:31:17 -0700

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
> v2: don't remove a reference on a rhashtable_iter structure to
>     release it from netlink_diag_dump_done
> 
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Fixes: ad202074320c ("netlink: Use rhashtable walk interface in diag dump")
> Signed-off-by: Andrei Vagin <avagin@openvz.org>

Applied, thanks.
