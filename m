From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Bug in skb_segment: fskb->len != len
Date: Tue, 29 Oct 2013 22:41:00 +0800
Message-ID: <20131029144100.GA28046@gondor.apana.org.au>
References: <20131028115552.GC4408@cpaasch-mac>
 <1382966471.13037.18.camel@edumazet-glaptop.roam.corp.google.com>
 <1383009308.5464.2.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Paasch <christoph.paasch@uclouvain.be>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:33718 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752292Ab3J2OlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 10:41:03 -0400
Content-Disposition: inline
In-Reply-To: <1383009308.5464.2.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 28, 2013 at 06:15:08PM -0700, Eric Dumazet wrote:
> On Mon, 2013-10-28 at 06:21 -0700, Eric Dumazet wrote:
> 
> > But we also need to fix the skb_segment() bug anyway.
> 
> Hi Christoph
> 
> I cooked a minimal patch, could you please try it ?
> 
> I'll refactor skb_segment() to be smarter for the next release
> (linux-3.14).

I think this patch is just papering over a deeper issue.

We should either be building skbs in pages, or using frag_list.
In the latter case each frag_list must be exactly mss bytes,
except for the last one.

So if we're crashing here it means that we got mixed up on the
receive side, either because the driver was sending us bogus skbs
or we're simply buggy.

So we need to figure out why the receive-side (i.e., GRO) is building
these bogus packets, and not papering over them on the transmit-side.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
