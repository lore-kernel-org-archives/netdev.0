From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: RPS and forwarding
Date: Mon, 26 Apr 2010 14:31:36 +0800
Message-ID: <20100426063136.GA22401@gondor.apana.org.au>
References: <z2w65634d661004252144z1bf72880wdf7a0143b8490ddf@mail.gmail.com> <20100426045316.GA21810@gondor.apana.org.au> <r2n65634d661004252200x4e7a49f1h181cdd69b3e4ebc0@mail.gmail.com> <20100425.232857.145290769.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:59961 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753038Ab0DZGbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 02:31:43 -0400
Content-Disposition: inline
In-Reply-To: <20100425.232857.145290769.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 25, 2010 at 11:28:57PM -0700, David Miller wrote:
>
> Right, none of this stuff is on by default.

Great, that puts my mind at ease :)

> It might be possible to somehow make the sock table get bypassed for
> forwarded traffic, but I can't think of a cheap way to do that at
> the moment.

Yeah I thought about that too but as we need to go through the
routing table before we know whether something is forwarded or
not, it certainly seems non-trivial.

Hmm, maybe if we used a routing cache keyed by rxhash we could
make an appromixation? After all, we only need to make sure that
no forwarded traffic is redirected, and not the reverse.  IOW,
it's OK if we incorrectly classify some local traffic as forwarded.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
