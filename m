From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH]: Fix networking scatterlist regressions.
Date: Wed, 31 Oct 2007 09:01:43 +0100
Message-ID: <20071031080143.GD5059@kernel.dk>
References: <20071030.204002.193703502.davem@davemloft.net> <20071031074621.GB5059@kernel.dk> <20071031.005802.204286555.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([87.55.233.238]:9897 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756679AbXJaIEX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 04:04:23 -0400
Content-Disposition: inline
In-Reply-To: <20071031.005802.204286555.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 31 2007, David Miller wrote:
> From: Jens Axboe <jens.axboe@oracle.com>
> Date: Wed, 31 Oct 2007 08:46:21 +0100
> 
> > On Tue, Oct 30 2007, David Miller wrote:
> > > @@ -293,7 +293,7 @@ decryptor(struct scatterlist *sg, void *data)
> > >  	if (thislen == 0)
> > >  		return 0;
> > >  
> > > -	sg_mark_end(desc->frags, desc->fragno);
> > > +	__sg_mark_end(desc->frags, desc->fragno);
> > >  
> > >  	ret = crypto_blkcipher_decrypt_iv(&desc->desc, desc->frags,
> > >  					  desc->frags, thislen);
> > 
> > Hmm? These don't seem right. It also has a weird code sequence:
>  ...
> > Did something go wrong there?
> 
> Yes, I fixed those up after doing some allmodconfig builds.
> 
> Here is the final patch I actually pushed to Linus:

That fixes up the sg_mark_end() bit, but it's still calling
sg_init_table() just a few lines further down. Is that correct?


-- 
Jens Axboe

