From: David Miller <davem@davemloft.net>
Subject: Re: GRO after RPS?
Date: Sun, 25 Apr 2010 18:17:57 -0700 (PDT)
Message-ID: <20100425.181757.10149105.davem@davemloft.net>
References: <20100425.170933.190068177.davem@davemloft.net>
	<20100426004934.GA12525@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55330
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752853Ab0DZBRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 21:17:52 -0400
In-Reply-To: <20100426004934.GA12525@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 26 Apr 2010 08:49:34 +0800

> On Sun, Apr 25, 2010 at 05:09:33PM -0700, David Miller wrote:
>> 
>> Herbert, after thinking about some ideas we've been discussing and
>> some suggestions from folks like Tom Herbert, I'm thinking of changing
>> it such that we do GRO after RPS sends the packet to a remove cpu.
> 
> Actually, I'd've thought that doing GRO before RPS would be a
> better solution as it means that RPS would have a lot less work
> to do.

Either GRO walks the skb->rxhash values one by one, or GRO does, the
cost is going to be roughly equivalent I think.

And when the packets do match, you can't just trust the ->rxhash in
the GRO code, since a hash match only indicates that the packets might
have the same flow.  So you're going to have to touch the packet
headers in that case on the pre-RPS cpu.

The goal is to eliminate all packet header references from the pre-RPS
path, and let the post-RPS cpu do it.
