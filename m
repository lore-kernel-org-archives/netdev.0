From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] rhashtable: rhashtable_rehash
Date: Mon, 9 Mar 2015 21:13:16 +1100
Message-ID: <20150309101316.GA4661@gondor.apana.org.au>
References: <20150131102150.GA29498@gondor.apana.org.au>
 <20150131102329.GA29520@gondor.apana.org.au>
 <20150202111647.GA25964@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:54692 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753348AbbCIKNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 06:13:21 -0400
Content-Disposition: inline
In-Reply-To: <20150202111647.GA25964@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just going through old emails so this may no longer be relevant.

On Mon, Feb 02, 2015 at 11:16:47AM +0000, Thomas Graf wrote:
> On 01/31/15 at 09:23pm, Herbert Xu wrote:
> > +	new_hash = head_hashfn(ht, new_tbl, entry);
> > +
> > +	new_bucket_lock = bucket_lock(new_tbl, new_hash);
> > +
> > +	spin_lock(new_bucket_lock);
> 
> I realize this is WIP and not fully worked out yet, therefore just a
> thought:
> 
> Unless you change this fundamentally then locking just the new bucket
> lock based on the new hash is not sufficient when you rehash while growing
> as the old bucket will contain entries which will get distributed across
> 2 buckets in the new table and if we change the seed it will map to
> even more buckets. I assume you have an idea how to handle that.

This doesn't matter because we're doing the resize one entry at
a time.  IOW we're moving one entry from the old table to the
new table.  The lock is only needed to avoid parallel additions
to the same bucket in the new table.

Removals will need to scan the old table followed by the new table
just like lookups so they don't care.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
