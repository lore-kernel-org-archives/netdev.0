From: Kieran Mansley <kmansley@solarflare.com>
Subject: Re: [PATCH 0/2] Disable forwarding of LRO skbs
Date: Thu, 01 May 2008 12:18:08 +0100
Message-ID: <1209640688.4191.35.camel@moonstone.uk.level5networks.com>
References: <20080430214845.GC14219@solarflare.com>
	 <E1JrWFU-0001ue-00@gondolin.me.apana.org.au>
	 <20080501110225.GG14219@solarflare.com>
	 <1209640128.4191.30.camel@moonstone.uk.level5networks.com>
	 <20080501111247.GA7756@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, davem@davemloft.net,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-237-3-220.orange.nextweb.net ([216.237.3.220]:2721 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753407AbYEALSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 07:18:13 -0400
In-Reply-To: <20080501111247.GA7756@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-05-01 at 19:12 +0800, Herbert Xu wrote:
> On Thu, May 01, 2008 at 12:08:48PM +0100, Kieran Mansley wrote:
> >
> > Yes, everything works fine in that case.  It's only when LRO packets are
> > forwarded to another physical interface that things go wrong.  
> 
> Now this is definitely broken because it fiddles with TCP packets
> in the middle, but still it should *work* in as much as making the
> packet go out.  Well except that you need to fix up the checksum
> so that it only contains the pseudo-header on output.  That's
> probably what you need to address if we failed in avoiding LRO
> on forwarded traffic.

If I remember rightly it also gets upset when it comes to split the
packet because the frag_list is already in use; it expects this not to
be the case for GSO but it's valid for an LRO packet to do this I think.
I don't think there's anything fundamentally difficult here, it's just
that the code has never been written to cope.

Kieran

