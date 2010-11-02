From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH 0/4] Ethtool: cleanup strategy
Date: Tue, 2 Nov 2010 02:02:53 +0100
Message-ID: <20101102010253.GC15848@rere.qmqm.pl>
References: <cover.1288496404.git.mirq-linux@rere.qmqm.pl> <1288645525.2231.60.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	linux-driver@qlogic.com, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:42014 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750999Ab0KBBCy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Nov 2010 21:02:54 -0400
Content-Disposition: inline
In-Reply-To: <1288645525.2231.60.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 01, 2010 at 09:05:25PM +0000, Ben Hutchings wrote:
> [...]
> > My proposal is to implement a offload feature setting that needs
> > (almost) no code in network driver.  The idea is to add two
> > ethtool-specific fields to struct net_device:
> >=20
> >  - hw_features
> >       offloads supported by the netdev (togglable by user)
> >  - features_requested
> >       offloads currently requested by user; this will be superset o=
f
> >       (features & hw_features) when i.e. current MTU or other exter=
nal
> >       conditions disable some offloads
> >=20
> > ... and use them to implement changing of offloads in ethtool core.
> > Since get_*() for TX offloads is just a bit test on netdev->feature=
s,
> > corresponding ethtool entry points could be removed.
>=20
> Right.
>=20
> It also might be worth defining a standard feature flag for RX checks=
um
> offload, since currently every driver has to maintain its own private
> flag.  Though we're running short of feature flags on 32-bit machines=
=2E

RX offloads are different in that most devices allow readback of
configured bits, so actually no specific flags are needed. I've postpon=
ed
thinking about this until after I cleaning up TX part.

> [...]
> > * sfc
> > 	assumed: constant efx->type->offload_features
> [...]
>=20
> This is correct.

Thanks,
Micha=B3 Miros=B3aw

