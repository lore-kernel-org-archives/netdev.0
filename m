From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: skb_splice_bits() and large chunks in pipe (was Re:
 xfs_file_splice_read: possible circular locking dependency detected
Date: Tue, 20 Sep 2016 17:51:02 +0800
Message-ID: <20160920095102.GA21088@gondor.apana.org.au>
References: <20160919002258.GJ2356@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, axboe@kernel.dk, npiggin@gmail.com,
        linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
        edumazet@google.com
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160919002258.GJ2356@ZenIV.linux.org.uk>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Al Viro <viro@zeniv.linux.org.uk> wrote:
>
>        * shoved into scatterlist, which gets fed into crypto/*.c machinery.
> No way for a pipe_buffer stuff to get there, fortunately, because I would
> be very surprised if it works correctly with compound pages and large
> ranges in those.

FWIW the crypto API has always been supposed to handle SG entries
that cross page boundaries.  There were a couple of bugs in this
area but AFAIK they've all been fixed.

Of course I cannot guarantee that every crypto driver also handles
it correctly, but at least we have a few test vectors which test
the page-crossing case specifically.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
