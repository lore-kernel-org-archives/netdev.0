From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable: Fix reader/rehash race
Date: Fri, 13 Mar 2015 21:36:15 +1100
Message-ID: <20150313103615.GB1559@gondor.apana.org.au>
References: <20150312110749.GA19285@gondor.apana.org.au>
 <20150312133749.GB21620@casper.infradead.org>
 <20150312214944.GA20117@gondor.apana.org.au>
 <20150313103259.GC11089@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:54473 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547AbbCMKgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 06:36:18 -0400
Content-Disposition: inline
In-Reply-To: <20150313103259.GC11089@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 13, 2015 at 10:32:59AM +0000, Thomas Graf wrote:
>
> One last question though. What about rhashtable_remove()?
> The spin_unlock_bh() in __rhashtable_remove() only guarantees
> for loads before the release to be completed. The future_tbl
> load could still be reordered before the traversal is complete.
> I think it needs an smp_rmb() as well.

rhashtable_remove is fine because the rehasher has to take the
same lock to move things over.  That's what guarantees the new
future_tbl to be visible if it moved the to-be-removed object
over to the new table.

IOW if rhashtable_remove couldn't see the future_tbl then that
can only mean that the rehasher has yet to take the lock on that
bucket which implies that the object if it existed at all is still
in that bucket.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
