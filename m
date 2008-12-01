From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio_net: large tx MTU support
Date: Mon, 1 Dec 2008 14:32:10 +1030
Message-ID: <200812011432.10486.rusty@rustcorp.com.au>
References: <1227707891.9579.44.camel@blaa> <200811281052.33474.rusty@rustcorp.com.au> <1227864595.3643.13.camel@blaa>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	virtualization <virtualization@lists.linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:40073 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751450AbYLAECN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Nov 2008 23:02:13 -0500
In-Reply-To: <1227864595.3643.13.camel@blaa>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 28 November 2008 19:59:55 Mark McLoughlin wrote:
> On Fri, 2008-11-28 at 10:52 +1030, Rusty Russell wrote:
> > On Friday 28 November 2008 00:27:05 Mark McLoughlin wrote:
> > > Hi Rusty,
> > >
> > > On Thu, 2008-11-27 at 23:00 +1030, Rusty Russell wrote:
> > > > On Thursday 27 November 2008 00:28:11 Mark McLoughlin wrote:
> > > > > We don't really have a max tx packet size limit, so allow
> > > > > configuring the device with up to 64k tx MTU.
> > > >
> > > > Hi Mark,
> > > >
> > > > Just one comment: maybe we should be conservative and maybe limit to
> > > > 1500 if the host doesn't offer any of the GSO or MRG_RXBUF features?
> > >
> > > That was actually what I was going to do until I thought about it a bit
> > > more and discussed it with Herbert.
> > >
> > > The virtio_net MTU only affects the transmit path, so there shouldn't
> > > be any issue with a host that doesn't support those features.
> >
> > Not quite what I meant.
>
> Well, you did mention MRG_RXBUF :-)

Yeah, but you should know by now not to listen to me!

> > A minimal host can reasonably expect ethernet-fitting packets.  If it
> > supports GSO of course it must handle larger ones.
>
> I think this is orthogonal to GSO - e.g. a host may support GSO even if
> it can only physically transmit 1500 byte frames.

Sure, but we know at least it can take large packets in some respect.

> MTU configuration is commonly a trial and error thing, so we're better
> off allowing larger MTU sizes in cases where the host might not support
> it rather than disallowing it in cases where the host can support it.

We're changing the driver behaviour; we *should* add a feature bit.  The only 
counter-argument to this is that all the existing hosts we know of allow the 
behaviour we're specifying.

(Grovelling through an old qemu here it seems to be true, and old tun/tap 
would take anything).

> If e.g. we allowed physical device assignment via virtio, then the MTU
> would be limited to the MTU supported by the physical device. In that
> case it might make sense to add a max-mtu field or similar, but IMHO
> it's fine to allow larger MTU sizes in the mean time.

OK, I'm swayed.  Only because the user has to make a conscious decision to up 
the MTU; and if they choose wrong, networking won't work.

I've applied your original patch.

Thanks!
Rusty.

