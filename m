From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable: Fix potential crash on destroy in rhashtable_shrink
Date: Sat, 31 Jan 2015 22:22:09 +1100
Message-ID: <20150131112209.GA29869@gondor.apana.org.au>
References: <20150131093637.GA29106@gondor.apana.org.au>
 <20150131111652.GA22448@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:40650 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbbAaLWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2015 06:22:14 -0500
Content-Disposition: inline
In-Reply-To: <20150131111652.GA22448@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 31, 2015 at 11:16:52AM +0000, Thomas Graf wrote:
> On 01/31/15 at 08:36pm, Herbert Xu wrote:
> > The current being_destroyed check in rhashtable_expand is not
> > enough since if we start a shrinking process after freeing all
> > elements in the table that's also going to crash.
> 
> (The check in expand() is just an optimization to drop out of
>  work cycles if it does not make sense to continue anymore.)
> 
> > 
> > This patch adds a being_destroyed check to the deferred worker
> > thread so that we bail out as soon as we take the lock.
> 
> Shouldn't the cancel_work_sync() in rhashtable_destroy() block
> until the deferred worker is done and cancelled?

That's too late.  nft_hash will have freed all the elements
before rhashtable_destroy gets called.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
