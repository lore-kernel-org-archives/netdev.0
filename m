From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [GIT] Networking
Date: Mon, 10 Jul 2017 18:05:32 +0800
Message-ID: <20170710100531.GA14940@gondor.apana.org.au>
References: <20170708.113644.1272962770645338865.davem@davemloft.net>
 <CA+55aFzocFTX5JR9oG_5uKw-fT6OJUMkD71sypbec7JP=_qwpg@mail.gmail.com>
 <20170709191131.GB22224@oracle.com>
 <20170709.214043.1361767365552001158.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sowmini.varadhan@oracle.com, torvalds@linux-foundation.org,
        akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170709.214043.1361767365552001158.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 09, 2017 at 09:40:43PM +0100, David Miller wrote:
>
> > It look like PF_ALG sets up a ->sk in alg_create() (but this
> > would get over-written in alg_accept()?) 

No it does not.  The struct socket comes from sys_accept() and
AFAICS it doesn't carry a struck sock with it.

> > Cc'ing Herbert to see if this is expected behavior (and PF_ALG
> > somehow does the right thing with the refcount for the ->sk
> > set up in alg_create) in which case I suppose we should drop the 
> > WARN_ON. 
> 
> I think we've found yet another socket leak, this time in
> AF_ALG.

Hmm, I can't see the problem in af_alg_accept.  The struct socket
comes directly from sys_accept() which creates it using sock_alloc.

So the only thing I can think of is that the memory returned by
sock_alloc is not zeroed and therefore the WARN_ON is just reading
garbage.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
