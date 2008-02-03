From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_input() and ->seq oddities
Date: Sun, 3 Feb 2008 14:05:16 +1100
Message-ID: <20080203030516.GA5685@gondor.apana.org.au>
References: <20080202211635.GF9375@cs181133002.pp.htv.fi> <20080202222226.GB31388@gondor.apana.org.au> <20080202235827.GP27894@ZenIV.linux.org.uk> <20080203002019.GA32295@gondor.apana.org.au> <20080203003718.GQ27894@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35158 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933945AbYBCDFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2008 22:05:22 -0500
Content-Disposition: inline
In-Reply-To: <20080203003718.GQ27894@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 03, 2008 at 12:37:19AM +0000, Al Viro wrote:
>
> This is still very odd...  Where do you initialize ->seq.input?  What

In xfrm_input.

> guarantees that async call of xfrm_input() will be always preceded by
> at least one non-async one?

OK I admit it isn't pretty.  But the encap_type argument is reused to
indicate async resumption.  That is, if we enter with encap_type < 0,
it means that we're resuming a previous operation and seq.input has
therefore been set by the previous xfrm_input call.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
