From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH -next] net: preserve geometry of fragment sizes when
 forwarding
Date: Tue, 19 May 2015 06:50:44 +0800
Message-ID: <20150518225043.GA25702@gondor.apana.org.au>
References: <20150518200637.GB20709@breakpoint.cc>
 <20150518.162854.1116793790405432801.davem@davemloft.net>
 <20150518204049.GC20709@breakpoint.cc>
 <20150518.165550.359134808190719687.davem@davemloft.net>
 <20150518213329.GA2335@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	hannes@stressinduktion.org, edumazet@google.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:48701 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753333AbbERWuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 18:50:51 -0400
Content-Disposition: inline
In-Reply-To: <20150518213329.GA2335@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 18, 2015 at 11:33:29PM +0200, Florian Westphal wrote:
>
> > Every objection has been of the form "this special case" (this time
> > SIP) is not easy.
> 
> Yes, but these objections are not some random hand-waving gesture.
> It presents us with certain dilemmas, e.g. single udp packet:
> 
> 1280 1280 1280 542
> 
> sip nat helper has to do nat/pat and replaces 10.2.3.4 with 192.168.2.3
> (lets assume we'd have helpers that deal with addresses split over 2
>  fragmented skbs so we can deal with 10.2 appearing in fragment #2
>   and .3.4 in fragment #3)
> 
> We can then end up with something like
> 1283 1281 1282 542
> 
> ... and what should we do then?

I think what David is saying that you can apply your special
logic to these edge cases, e.g., linearise them and on output
use your MTU cap to refragment.

However, for the vast majority of fragments that you receive,
which would not be modified by NAT, they should retain their
original geometry.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
