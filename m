From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH]: Fix networking scatterlist regressions.
Date: Wed, 31 Oct 2007 10:29:29 +0100
Message-ID: <20071031092929.GG5059@kernel.dk>
References: <20071031074621.GB5059@kernel.dk> <20071031.005802.204286555.davem@davemloft.net> <20071031081428.GF5059@kernel.dk> <20071031.022643.118035583.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([87.55.233.238]:27652 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754267AbXJaJcJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 05:32:09 -0400
Content-Disposition: inline
In-Reply-To: <20071031.022643.118035583.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 31 2007, David Miller wrote:
> From: Jens Axboe <jens.axboe@oracle.com>
> Date: Wed, 31 Oct 2007 09:14:28 +0100
> 
> > Subject: [PATCH] [SG] Get rid of __sg_mark_end()
> > 
> > sg_mark_end() overwrites the page_link information, but all users want
> > __sg_mark_end() behaviour where we just set the end bit. That is the most
> > natural way to use the sg list, since you'll fill it in and then mark the
> > end point.
> > 
> > So change sg_mark_end() to only set the termination bit. Add a sg_magic
> > debug check as well, and clear a chain pointer if it is set.
> > 
> > Signed-off-by: Jens Axboe <jens.axboe@oracle.com>
> 
> It doesn't build.  I suspect there is something else in your tree
> that is necessary for this patch to work on it's own.

Builds here. But yes, it's on top of other patches, it was merely for
demonstration purposes that I posted it. Locally sg_init_one() uses
sg_init_table() here, it doesn't open code the init:

static inline void sg_init_one(struct scatterlist *sg, const void *buf,
                               unsigned int buflen)
{
        sg_init_table(sg, 1);
        sg_set_buf(sg, buf, buflen);
}


-- 
Jens Axboe

