From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Subject: Re: [UDP6]: Restore sk_filter optimisation
Date: Thu, 1 Nov 2007 22:34:14 +0900
Message-ID: <20071101223414.3d9a92ec.mitch@linux.vnet.ibm.com>
References: <20070306012010.GA25763@gondor.apana.org.au>
	<20071029153320.d2c00f62.mitch@linux.vnet.ibm.com>
	<20071029125328.GA5453@gondor.apana.org.au>
	<20071031230545.9be711d4.mitch@linux.vnet.ibm.com>
	<20071031144256.GA28137@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:58970 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751550AbXKANeX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2007 09:34:23 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA1DZsBF014981
	for <netdev@vger.kernel.org>; Thu, 1 Nov 2007 09:35:54 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA1DYK1O426674
	for <netdev@vger.kernel.org>; Thu, 1 Nov 2007 09:34:20 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA1DYJwt015582
	for <netdev@vger.kernel.org>; Thu, 1 Nov 2007 09:34:20 -0400
In-Reply-To: <20071031144256.GA28137@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 31 Oct 2007 22:42:57 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Wed, Oct 31, 2007 at 11:05:45PM +0900, Mitsuru Chinen wrote:
> >
> > > >  1. udp6InDatagrams is incremented instead of udpInErrors
> > > >  2. In userland, recvfrom() replies an error with EAGAIN.
> > > >     recvfrom() wasn't aware of such a packet before.
> > > > 
> > > > Are these changes intentional?
> >
> > As far as I tested, this doesn't happen with the old code even if
> > a filter is attached. However, this happen with the new code
> > without a filter and I don't see this rather when a filter is
> > attached. So, I'm afraid it's new.
> 
> Sorry, I read the patch the wrong way around :)
> 
> 1) is just an accounting issue.  It shouldn't be too difficult
> to fix it up.  In fact, I think udpInErrors will still be
> incremented once we detect the error.
> 
> 2) shouldn't be an issue because we've already solved the
> problem by making poll/select do the checksum verification
> before indiciating that the socket is readable.
> 
> > > And, we're not sure how much the "optimization"'s benefit is.
> > > It is even worse when we are hand
> 
> The checksum verification is costly because we have to bring
> the payload into cache.  Since filters are very rare it's
> worthwhile to postpone the checksum verification for the common
> case.
> 
> Also as a general rule, we want to avoid divergent behaviour
> between IPv4 and IPv6.  So for changes like this we should
> really modify both stacks in future rather than have each
> stack do its own thing.

I got it. OK. I will submit a patch to postpone the udpInError
counter incrementation, either.

Thanks for your detailed explanation!

Best Regards,
----
Mitsuru Chinen <mitch@linux.vnet.ibm.com>
