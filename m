From: Andrei Vagin <avagin@virtuozzo.com>
Subject: Re: [PATCH net-next] netlink: don't forget to release a
 rhashtable_iter structure
Date: Tue, 6 Sep 2016 21:28:11 -0700
Message-ID: <20160907042810.GA15590@outlook.office365.com>
References: <1473186219-13061-1-git-send-email-avagin@openvz.org>
 <20160906.174137.1869816645707925029.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="koi8-r"
Cc: <avagin@openvz.org>, <netdev@vger.kernel.org>,
        <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0098.outbound.protection.outlook.com ([104.47.2.98]:48320
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753899AbcIGOCE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Sep 2016 10:02:04 -0400
Content-Disposition: inline
In-Reply-To: <20160906.174137.1869816645707925029.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 06, 2016 at 05:41:37PM -0700, David Miller wrote:
> From: Andrei Vagin <avagin@openvz.org>
> Date: Tue,  6 Sep 2016 11:23:39 -0700
> 
> > This bug was detected by kmemleak:
> > unreferenced object 0xffff8804269cc3c0 (size 64):
> >   comm "criu", pid 1042, jiffies 4294907360 (age 13.713s)
> >   hex dump (first 32 bytes):
> >     a0 32 cc 2c 04 88 ff ff 00 00 00 00 00 00 00 00  .2.,............
> >     00 01 00 00 00 00 ad de 00 02 00 00 00 00 ad de  ................
> >   backtrace:
> >     [<ffffffff8184dffa>] kmemleak_alloc+0x4a/0xa0
> >     [<ffffffff8124720f>] kmem_cache_alloc_trace+0x10f/0x280
> >     [<ffffffffa02864cc>] __netlink_diag_dump+0x26c/0x290 [netlink_diag]
> > 
> > Cc: Herbert Xu <herbert@gondor.apana.org.au>
> > Fixes: ad202074320c ("netlink: Use rhashtable walk interface in diag dump")
> > Signed-off-by: Andrei Vagin <avagin@openvz.org>
> 
> Hmmm, why isn't this handled by netlink_diag_dump_done()?
> 
> It seems like the intent is to have the hashtable iter be cached
> across multiple __netlink_diag_dump() calls within a single
> netlink_diag_dump invocation.

I read the code again and I think you are right. I didn't get the
idea at the first time.

Thanks,
Andrei
