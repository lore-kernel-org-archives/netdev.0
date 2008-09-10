From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Wed, 10 Sep 2008 14:01:07 +1000
Message-ID: <20080910040107.GA29695@gondor.apana.org.au>
References: <20080910031559.GA27430@gondor.apana.org.au> <20080909.202215.197131148.davem@davemloft.net> <20080910032304.GA28580@gondor.apana.org.au> <20080909.203808.112347106.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58063 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1749667AbYIJEBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 00:01:13 -0400
Content-Disposition: inline
In-Reply-To: <20080909.203808.112347106.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 09, 2008 at 08:38:08PM -0700, David Miller wrote:
>
> No problem.  It might be a little bit of a chore because this new
> walker design is intimately tied to the af_key non-atomic dump
> changes.

Actually I was mistaken as to how the original dump worked.  I'd
thought that it actually kept track of which bucket it was in and
resumed from that bucket.  However in reality it only had a global
counter and would always start walking from the beginning up until
the counted value.  So it isn't as easy as just copying the old
code across :)

While it is possible to restore the old order and save a little
bit of memory, I certainly don't think this is very urgent.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
