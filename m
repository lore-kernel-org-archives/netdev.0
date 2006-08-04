From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM]: Improve MTU estimation
Date: Fri, 4 Aug 2006 21:25:44 +1000
Message-ID: <20060804112544.GA28774@gondor.apana.org.au>
References: <44D30A48.4050403@trash.net> <44D312EF.8010202@trash.net> <20060804100121.GA17239@gondor.apana.org.au> <44D31CCE.7020301@trash.net> <20060804101345.GA17583@gondor.apana.org.au> <44D32B57.2000304@trash.net> <20060804111604.GA25693@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55826 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932493AbWHDLZs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 07:25:48 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <20060804111604.GA25693@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 04, 2006 at 09:16:04PM +1000, herbert wrote:
>
> Are you talking about the ESP padding case, or transport mode in
> general?

I've reread your patches and your handling of ESP padding is spot on.
It's anyone's guess whether the current code gets it right or not :)

However, I believe that the transport mode handling does run into
problems with IP options.  Basically, your calculation returns a
length that is a precise multiple of block size minus 2.

Now imagine that we have 4 bytes of IP options, given a block size
of 8 taking away 4 bytes from inside the encrypted area simply causes
them to be padded out so the encrypted length does not change.  However,
we have to put those 4 bytes outside the encrypted area.  The problem is
that we may not have those 4 bytes given the MTU.

For a standard 1500 MTU and the block size of 8 it just happens that
we do have 4 bytes (because 1500 % 8 == 4).  However, this breaks down
if you start with say 1480 (standard MTU for 1500 with IPIP on the
outside).

You run into problems even with 1500 if your block size happens to be
16 (AES).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
