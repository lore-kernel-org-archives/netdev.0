From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Fix networking scatterlist regressions.
Date: Wed, 31 Oct 2007 01:08:42 -0700 (PDT)
Message-ID: <20071031.010842.13648022.davem@davemloft.net>
References: <20071031074621.GB5059@kernel.dk>
	<20071031.005802.204286555.davem@davemloft.net>
	<20071031080143.GD5059@kernel.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	rusty@rustcorp.com.au
To: jens.axboe@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44346
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752859AbXJaIIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 04:08:43 -0400
In-Reply-To: <20071031080143.GD5059@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jens Axboe <jens.axboe@oracle.com>
Date: Wed, 31 Oct 2007 09:01:43 +0100

> On Wed, Oct 31 2007, David Miller wrote:
> > From: Jens Axboe <jens.axboe@oracle.com>
> > Date: Wed, 31 Oct 2007 08:46:21 +0100
> > 
> > > On Tue, Oct 30 2007, David Miller wrote:
> > > > @@ -293,7 +293,7 @@ decryptor(struct scatterlist *sg, void *data)
> > > >  	if (thislen == 0)
> > > >  		return 0;
> > > >  
> > > > -	sg_mark_end(desc->frags, desc->fragno);
> > > > +	__sg_mark_end(desc->frags, desc->fragno);
> > > >  
> > > >  	ret = crypto_blkcipher_decrypt_iv(&desc->desc, desc->frags,
> > > >  					  desc->frags, thislen);
> > > 
> > > Hmm? These don't seem right. It also has a weird code sequence:
> >  ...
> > > Did something go wrong there?
> > 
> > Yes, I fixed those up after doing some allmodconfig builds.
> > 
> > Here is the final patch I actually pushed to Linus:
> 
> That fixes up the sg_mark_end() bit, but it's still calling
> sg_init_table() just a few lines further down. Is that correct?

Absolutely.  It initially using the scatterlist for this
crypto layer call:

	ret = crypto_blkcipher_decrypt_iv(&desc->desc, desc->frags,
					  desc->frags, thislen);
	if (ret)
		return ret;

then it reinits and sets the sglist to the values the caller
wants.

