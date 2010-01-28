From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] [PATCH] net: Add support for ndo_select_queue()
	functions to cache the queue mapping
Date: Thu, 28 Jan 2010 18:34:34 +0000
Message-ID: <1264703676.2783.44.camel@achroite.uk.solarflarecom.com>
References: <1264700317.2783.15.camel@achroite.uk.solarflarecom.com>
	 <20100128100011.2b624a9e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:51868 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754152Ab0A1Sej convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 13:34:39 -0500
In-Reply-To: <20100128100011.2b624a9e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-01-28 at 10:00 -0800, Stephen Hemminger wrote:
> On Thu, 28 Jan 2010 17:38:37 +0000
> Ben Hutchings <bhutchings@solarflare.com> wrote:
>=20
> > =EF=BB=BFWe think it's worth matching up RX and TX queue selection =
for a socket
> > when the queues share an interrupt.  Currently the default TX queue
> > selection is unlikely to match RX queue selection.  TX queue select=
ionc
> > can be overridden by the driver to match RX queue selection, but at=
 the
> > expense of caching.  We found that without caching the cost of
> > recalculating the the hash in software for each packet outweighed t=
he
> > benefit of good queue selection.
>=20
> Will this work with RPS and device driver hashing?

=EF=BB=BFIf the device only has a single TX queue this can't possibly h=
elp it.

In the case where a device has multiple RX and TX queues, I think it is
preferable that contention for TX queues is likely to be among cores
that are close together, not spread over the whole system.  I assume
that RPS will normally be configured to spread traffic from each
hardware RX queue to a group of cores that are close together (same NUM=
A
mode, maybe sharing some caches).  In that case it would also be
desirable to limit contention for a TX queue to within these same group=
s
of cores, so TX queue selection ought to match hardware RX queue
selection.  So I don't think this should conflict with RPS.

> I am thinking of the problem where the hardware hash function is
> Toeplitz (per NDIS spec), and the software hash function is Jhash
> (what kernel uses because it is cheaper).
>=20
> Therefore the transmit hash and receiver hash will be different.

The intent here is to make it worthwhile to calculate that expensive
hash on the TX side.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

