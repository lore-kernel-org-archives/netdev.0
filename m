From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 5/5] ipv4: Don't use the cached pmtu informations for
	input routes
Date: Wed, 23 Nov 2011 23:52:45 +0800
Message-ID: <20111123155245.GA11638@gondor.apana.org.au>
References: <20111123121450.GE6348@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:49175 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755711Ab1KWPwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 10:52:51 -0500
Content-Disposition: inline
In-Reply-To: <20111123121450.GE6348@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steffen Klassert <steffen.klassert@secunet.com> wrote:
> The pmtu informations on the inetpeer are visible for output and
> input routes. On packet forwarding, we might propagate a learned
> pmtu to the sender. As we update the pmtu informations of the
> inetpeer on demand, the original sender of the forwarded packets
> might never notice when the pmtu to that inetpeer increases.
> So use the mtu of the outgoing device on packet forwarding instead
> of the pmtu to the final destination.

I disagree.  MTU increases are detected by the source retrying,
so they most certainly should notice if our cached value expires.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
