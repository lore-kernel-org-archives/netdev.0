From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/3] net: Kill skb_copy_datagram_const_iovec
Date: Mon, 3 Nov 2014 13:37:51 +0800
Message-ID: <20141103053751.GA27845@gondor.apana.org.au>
References: <20141102230552.GA26095@gondor.apana.org.au>
 <20141103001634.GV7996@ZenIV.linux.org.uk>
 <20141103002207.GA26588@gondor.apana.org.au>
 <20141103004503.GX7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Benjamin LaHaise <bcrl@kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141103004503.GX7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 03, 2014 at 12:45:03AM +0000, Al Viro wrote:
>
> Note, BTW, that there's a damn good reason to convert the socket side of
> things to iov_iter - as it is, ->splice_write() there is basically done with
> page-by-page mapping and doing kernel_sendmsg(); being able to deal with
> "map and copy" stuff *inside* ->sendmsg() would not only reduce the overhead,
> it would allow to get rid of ->sendpage() completely.  Basically, let
> ->sendmsg() instances check the iov_iter type and play zerocopy games if
> it's an "array of kernel pages" kind.  Compare ->sendpage() and ->sendmsg()
> instances for the protocols that have nontrivial ->sendpage(); you'll see
> that there's a lot of duplication.  Merging them looks very feasible, with
> divergence happening only very deep in the call chain.

Honestly I don't really care which way we end up going as long as
we pick one solution and stick with it.  Right now we have an
abomination in the form of skb_copy_datagram_const_iovec which is
the worst of both worlds, plus it duplicates tons of code.

So here's a few patches to kill this crap.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
