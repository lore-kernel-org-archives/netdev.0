From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPsec replay sequence number overflow behavior? (RFC4303 section 3.3.3)
Date: Mon, 10 Dec 2007 11:06:53 +0800
Message-ID: <20071210030653.GA31566@gondor.apana.org.au>
References: <E1J1Bfw-0006Kw-00@gondolin.me.apana.org.au> <200712090937.56599.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, latten@us.ibm.com
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4576 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751216AbXLJDG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2007 22:06:59 -0500
Content-Disposition: inline
In-Reply-To: <200712090937.56599.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 09, 2007 at 09:37:56AM -0500, Paul Moore wrote:
>
> Thanks for clearing that up, I'll send a patch this week; complete with an 
> unlikely (similar to the RFC quality IPsec audit patch I sent on Friday) and 
> a decrement to the sequence counter in case of rollover.

Actually I think we should just use the SA expire mechanism
to do this.  The reason is that the overflow we want to detect
only applies to 32-bit sequence numbers.  In future we will be
making our sequence numbers 64-bit.

When we do that we can no longer just check against wrapping
to zero since we need to know whether ESNs are in use or not.

The easiest fix is to just force the hard_packet_limit to 2^32.
upon SA creation.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
