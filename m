From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Yet another bridge netfilter crash
Date: Fri, 23 Jul 2010 23:26:09 +0800
Message-ID: <20100723152609.GA7576@gondor.apana.org.au>
References: <20100723134208.GA6655@gondor.apana.org.au> <4C49A4C6.4070503@trash.net> <20100723150041.GA7301@gondor.apana.org.au> <4C49B296.10009@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:40210 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759400Ab0GWP0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 11:26:14 -0400
Content-Disposition: inline
In-Reply-To: <4C49B296.10009@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 23, 2010 at 05:17:42PM +0200, Patrick McHardy wrote:
> 
> No concrete plans yet, but its something I'm definitely planning
> to try at some point.

Great!

> > There's also the matter of fragments jumping between bridges.
> 
> Conntrack zones can be used to avoid that, but that currently needs
> manual configuration.

I think this is something that we need to fix.  Because as it
stands, it can still crash if you get the wrong nf_bridge.

The reason is that skb->dev does not hold a ref count.  So the
reassembly code just throws it away and always uses the dev of
the last fragment.

This breaks when two bridges combine to reassemble a single
packet, as the nf_bridge attribute of the reassembled packet
may come from an skb whose device is now dead.  This is then
used to fill in the skb->dev (via nf_bridge->physindev).

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
