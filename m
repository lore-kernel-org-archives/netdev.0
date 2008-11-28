From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH] virtio_net: large tx MTU support
Date: Fri, 28 Nov 2008 09:29:55 +0000
Message-ID: <1227864595.3643.13.camel@blaa>
References: <1227707891.9579.44.camel@blaa>
	 <200811272300.58151.rusty@rustcorp.com.au> <1227794225.24571.36.camel@blaa>
	 <200811281052.33474.rusty@rustcorp.com.au>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	virtualization <virtualization@lists.linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42419 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750815AbYK1JcG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Nov 2008 04:32:06 -0500
In-Reply-To: <200811281052.33474.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-11-28 at 10:52 +1030, Rusty Russell wrote:
> On Friday 28 November 2008 00:27:05 Mark McLoughlin wrote:
> > Hi Rusty,
> >
> > On Thu, 2008-11-27 at 23:00 +1030, Rusty Russell wrote:
> > > On Thursday 27 November 2008 00:28:11 Mark McLoughlin wrote:
> > > > We don't really have a max tx packet size limit, so allow configuring
> > > > the device with up to 64k tx MTU.
> > >
> > > Hi Mark,
> > >
> > > Just one comment: maybe we should be conservative and maybe limit to 1500
> > > if the host doesn't offer any of the GSO or MRG_RXBUF features?
> >
> > That was actually what I was going to do until I thought about it a bit
> > more and discussed it with Herbert.
> >
> > The virtio_net MTU only affects the transmit path, so there shouldn't be
> > any issue with a host that doesn't support those features.
> 
> Not quite what I meant.

Well, you did mention MRG_RXBUF :-)

> A minimal host can reasonably expect ethernet-fitting packets.  If it
> supports GSO of course it must handle larger ones.

I think this is orthogonal to GSO - e.g. a host may support GSO even if
it can only physically transmit 1500 byte frames.

MTU configuration is commonly a trial and error thing, so we're better
off allowing larger MTU sizes in cases where the host might not support
it rather than disallowing it in cases where the host can support it.

> Otherwise we should add YA feature bit or even a max-mtu field.

If e.g. we allowed physical device assignment via virtio, then the MTU
would be limited to the MTU supported by the physical device. In that
case it might make sense to add a max-mtu field or similar, but IMHO
it's fine to allow larger MTU sizes in the mean time.

Cheers,
Mark.

