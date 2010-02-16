From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ipcomp: double free at ipcomp_destroy()
Date: Tue, 16 Feb 2010 13:29:01 +0800
Message-ID: <20100216052901.GB27643@gondor.apana.org.au>
References: <20100214144415.GA8115@x200> <20100215001849.GB15437@gondor.apana.org.au> <b6fcc0a1002142332r1542e04ex250fa238e4a3231a@mail.gmail.com> <20100215080846.GA18446@gondor.apana.org.au> <20100215081052.GA18516@gondor.apana.org.au> <20100215155049.GA4905@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35218 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751105Ab0BPF3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 00:29:06 -0500
Content-Disposition: inline
In-Reply-To: <20100215155049.GA4905@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 15, 2010 at 05:50:49PM +0200, Alexey Dobriyan wrote:
>
> Then checks for NULL ->tunnel, and NULL ->data should be removed.
> In fact, I don't quite understand why destruction was done this way,
> so simply cleared ->data pointer.

I had a look and I don't think we can do that (unless I misunderstood
what you meant).

The NULL ipcd check in ipcomp_destroy is to handle the case where
ipcomp_init_state fails before it even gets to allocating ipcd.

While the NULL tunnel check in xfrm_state_delete_tunnel is for the
case where we failed before successfully attaching a tunnel.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
