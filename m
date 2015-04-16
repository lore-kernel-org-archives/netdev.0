From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH -next 0/3] net: cap size to original frag size when
 refragmenting
Date: Thu, 16 Apr 2015 12:56:22 +0800
Message-ID: <20150416045622.GA12454@gondor.apana.org.au>
References: <20150413.135348.461869719021663434.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:36086 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752664AbbDPE4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 00:56:31 -0400
Content-Disposition: inline
In-Reply-To: <20150413.135348.461869719021663434.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> 
> Because then there is no ambiguity at all, you preserve on output
> exactly what you had on input.  The same geometry, the same
> everything.  No special checks, no max frag len, none of this crap.
> Those are all hacks trying to work around the _fundamental_ issue
> which is that we potentially change the thing when we refrag.

Agreed.  Doing anything other than preserving the original geometry
is simply wrong.

However, this doesn't mean that netfilter has to process each
fragment.  What we could do is to preserve the original fragments
in frag_list and then process the overall skb as a unit in netfilter.

On output we simply fragment according to the original frag_list.

The only thing to watch out for is to eliminate anything in the
middle that tries to linearise the skb.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
