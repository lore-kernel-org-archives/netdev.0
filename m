From: David Miller <davem@davemloft.net>
Subject: Re: ESP trailer_len calculation
Date: Sun, 26 Sep 2010 18:46:54 -0700 (PDT)
Message-ID: <20100926.184654.232737330.davem@davemloft.net>
References: <20100924.144044.179940003.davem@davemloft.net>
	<20100925062317.GA15565@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60198
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753933Ab0I0Bqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Sep 2010 21:46:34 -0400
In-Reply-To: <20100925062317.GA15565@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 25 Sep 2010 14:23:17 +0800

> The number 17 does look very strange, however, after going through
> the logic it does seem correct.
> 
> To calculate the minimum safe trailer length we need to consider
> the worst-case scenario, and that is a packet where the payload
> just happens to be one byte less than the cipher block size.
> 
> ESP always adds two bytes, then pads to at least the cipher
> block size, follwed by the authentication value.  So in the
> worst case we need to add
> 
> 	2 + (blocksize - 1) + authlen	=
> 	blocksize + 1 + authlen
> 
> which is exactly what Patrick's patch does.

Thanks for explaining this Herbert, but I have to admit it's a bit
disappointing :-)

So what we have is that headerlen is actually a function f() which
depends upon the payload length and the size of any IP options, rather
than a fixed value that can be computed based upon the cipher
blocksize, encap mode, and device MTU.

I guess if we really cared about this we could make headerlen a method
rather than a value, but I doubt it's that much of an issue.
