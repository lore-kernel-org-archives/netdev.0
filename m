From: David Miller <davem@davemloft.net>
Subject: Re: TX pre-headers...
Date: Mon, 09 Feb 2009 02:14:03 -0800 (PST)
Message-ID: <20090209.021403.56830306.davem@davemloft.net>
References: <20090206.014107.231141422.davem@davemloft.net>
	<20090209100713.GA8299@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54750
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750741AbZBIKOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 05:14:10 -0500
In-Reply-To: <20090209100713.GA8299@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 9 Feb 2009 21:07:13 +1100

> David Miller <davem@davemloft.net> wrote:
> >
> > I think the way to solve this is to have each device indicate how
> > much TX slack space it neads for it's preheaders.  On device
> > registration we have some global "netdev_max_tx_hdr_space" that
> > records the maximum value seen.
> 
> We can already solve it right now with dev->needed_headroom.
> 
> Of course it's not optimal because it involves a copy so we
> might still need your solution.

Indeed, I noticed needed_headroom when I set out to start coding
things up. :)

There are all sorts of cases that won't work well, as you implicitly
suggest.  For example, forwarding to a path that encapsulates to a GRE
or other type of tunnel.

For IPSEC we're predominantly COW'ing the data anyways, so...
