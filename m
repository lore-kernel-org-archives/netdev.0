From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 0/2] Disable forwarding of LRO skbs
Date: Thu, 1 May 2008 13:08:51 +0100
Message-ID: <20080501120850.GH14219@solarflare.com>
References: <20080430214845.GC14219@solarflare.com> <E1JrWFU-0001ue-00@gondolin.me.apana.org.au> <20080501110225.GG14219@solarflare.com> <1209640128.4191.30.camel@moonstone.uk.level5networks.com> <20080501111247.GA7756@gondor.apana.org.au> <1209640688.4191.35.camel@moonstone.uk.level5networks.com> <20080501113716.GA7955@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kieran Mansley <kmansley@solarflare.com>, davem@davemloft.net,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:37883 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756733AbYEAMJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 08:09:34 -0400
Content-Disposition: inline
In-Reply-To: <20080501113716.GA7955@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, May 01, 2008 at 12:18:08PM +0100, Kieran Mansley wrote:
> >
> > If I remember rightly it also gets upset when it comes to split the
> > packet because the frag_list is already in use; it expects this not to
> > be the case for GSO but it's valid for an LRO packet to do this I think.
> > I don't think there's anything fundamentally difficult here, it's just
> > that the code has never been written to cope.
> 
> Oh so LRO packets still preserve the original packet boundaries?
> That's even easier.  We could just make the GSO output code detect
> the presence of frag_list and fragment based on that.

Depending on the driver, the packets may be received into skbs which are
then attached to frag_list, or into page buffers which go in the frags
array.  If most packets can be merged by LRO, deferring skb allocation
and using the frags array is a performance win.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
