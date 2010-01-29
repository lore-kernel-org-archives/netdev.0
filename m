From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH] Optimize TCP sendmsg in favour of fast devices?
Date: Fri, 29 Jan 2010 22:06:25 +1300
Message-ID: <20100129090625.GD23140@gondor.apana.org.au>
References: <20100121.012520.254679483.davem@davemloft.net> <20100121094157.GA15262@gondor.apana.org.au> <OF7EA723DA.DC2FF4FC-ON652576B8.002064CB-652576B8.00267739@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47774 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754464Ab0A2JSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 04:18:46 -0500
Content-Disposition: inline
In-Reply-To: <OF7EA723DA.DC2FF4FC-ON652576B8.002064CB-652576B8.00267739@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 27, 2010 at 12:42:12PM +0530, Krishna Kumar2 wrote:
> 
> OK, I unset F_SG and set F_GSO (in driver). With this, tcpdump shows
> GSO is enabled - the tcp packet sizes builds up to 65160 bytes.
> 
> I ran 5 serial netperf's with 16K and another 5 serial netperfs
> with 64K I/O sizes, and the aggregate result is:
> 
> 0. Driver unsets F_SG but sets F_GSO:
>       Original code with 16K: 19471.65
>       New code with 16K:      19409.70
>       Original code with 64K: 21357.23
>       New code with 64K:      22050.42

OK this is more in line with what I was expecting, namely that
enabling GSO is actually beneficial even without SG.

It would be good to get the CPU utilisation figures so we can
see the complete picture.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
