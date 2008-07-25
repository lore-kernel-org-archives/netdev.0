From: David Miller <davem@davemloft.net>
Subject: Re: ipsec: ipcomp - Decompress into frags if necessary
Date: Fri, 25 Jul 2008 02:58:01 -0700 (PDT)
Message-ID: <20080725.025801.229691344.davem@davemloft.net>
References: <E1KM0Wl-0001zC-00@gondolin.me.apana.org.au>
	<20080725074109.GA16747@gondor.apana.org.au>
	<20080725074328.GB16747@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pupilla@hotmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33329
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755834AbYGYJ6C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 05:58:02 -0400
In-Reply-To: <20080725074328.GB16747@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 25 Jul 2008 15:43:28 +0800

> On Fri, Jul 25, 2008 at 03:41:09PM +0800, Herbert Xu wrote:
> >
> > Here is the first part:
> 
> And finally:
> 
> ipsec: ipcomp - Decompress into frags if necessary
> 
> When decompressing extremely large packets allocating them through
> kmalloc is prone to failure.  Therefore it's better to use page
> frags instead.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Also applied, nice work Herbert.

About MAX_SKB_FRAGS, if we go over that limit we probably need to
log a message or something because we'll likely get that same kind
of huge sized packet that we can't handle in future retransmits.
There is no way to figure out that this is what is happening.

Actually I wonder if it's even possible.  Our limit is 64K anyways
(and that's our scratch buffer size) and MAX_SKB_FRAGS is always
large enough to accomodate at least 64K of data.

So perhaps it wants a WARN_ON :-)
