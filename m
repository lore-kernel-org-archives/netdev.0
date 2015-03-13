From: Thomas Graf <tgraf@suug.ch>
Subject: Re: rhashtable: Fix reader/rehash race
Date: Fri, 13 Mar 2015 10:32:59 +0000
Message-ID: <20150313103259.GC11089@casper.infradead.org>
References: <20150312110749.GA19285@gondor.apana.org.au>
 <20150312133749.GB21620@casper.infradead.org>
 <20150312214944.GA20117@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56000 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941AbbCMKdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 06:33:02 -0400
Content-Disposition: inline
In-Reply-To: <20150312214944.GA20117@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/15 at 08:49am, Herbert Xu wrote:
> It doesn't matter.  The wmb/smb guarauntees that if the reader
> cannot find the element in the old table then it must see the
> new table pointer.  Vice versa if it cannot see the new table
> pointer then the element (if it existed at all) must be in the
> old table.

I understand what you are doing now. I was still thinking
of entries being on both lists in parallel.

One last question though. What about rhashtable_remove()?
The spin_unlock_bh() in __rhashtable_remove() only guarantees
for loads before the release to be completed. The future_tbl
load could still be reordered before the traversal is complete.
I think it needs an smp_rmb() as well.
