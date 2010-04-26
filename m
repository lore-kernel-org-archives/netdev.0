From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: GRO after RPS?
Date: Mon, 26 Apr 2010 08:49:34 +0800
Message-ID: <20100426004934.GA12525@gondor.apana.org.au>
References: <20100425.170933.190068177.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:47660 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751629Ab0DZAti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 20:49:38 -0400
Content-Disposition: inline
In-Reply-To: <20100425.170933.190068177.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 25, 2010 at 05:09:33PM -0700, David Miller wrote:
> 
> Herbert, after thinking about some ideas we've been discussing and
> some suggestions from folks like Tom Herbert, I'm thinking of changing
> it such that we do GRO after RPS sends the packet to a remove cpu.

Actually, I'd've thought that doing GRO before RPS would be a
better solution as it means that RPS would have a lot less work
to do.

> The idea being that, this way, if we have a device provided ->rxhash
> we can elide touching the packet headers entirely.

Yes not touching the headers was also the plan for GRO, I just
never got around to it.  So we would only examine a packet if
its hash matched one already processed in the current NAPI window.

Of course we'd need to change the way we currently store packets
in GRO and use a data structure more efficient than a linked list.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
