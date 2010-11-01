From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 0/4] Ethtool: cleanup strategy
Date: Mon, 01 Nov 2010 21:05:25 +0000
Message-ID: <1288645525.2231.60.camel@achroite.uk.solarflarecom.com>
References: <cover.1288496404.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	linux-driver@qlogic.com, linux-net-drivers@solarflare.com
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:24554 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753430Ab0KAVF3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 17:05:29 -0400
In-Reply-To: <cover.1288496404.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-10-31 at 04:40 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> While writing and debugging driver for StorLink's Gemini ethernet
> "card" I couldn't not notice that ethtool support had accumulated a l=
ot
> of dust and "aah, let's just copy that from another driver"-generated
> code.  There are things that are reimplemented in more-or-less same w=
ay
> in multiple network drivers, there are logic bugs or unexpected
> variations among the implementations, and there is a lot of boilerpla=
te
> code needed to be written by a person who wants to support ethtool
> in his driver.  I'm concentrating on offload feature setting here as
> that's what I needed for my driver.

I agree; I've fixed a few of these variations but I'm aware there are
many left.  Thanks for taking on some of this cleanup work.

[...]
> My proposal is to implement a offload feature setting that needs
> (almost) no code in network driver.  The idea is to add two
> ethtool-specific fields to struct net_device:
>=20
>  - hw_features
>       offloads supported by the netdev (togglable by user)
>  - features_requested
>       offloads currently requested by user; this will be superset of
>       (features & hw_features) when i.e. current MTU or other externa=
l
>       conditions disable some offloads
>=20
> ... and use them to implement changing of offloads in ethtool core.
> Since get_*() for TX offloads is just a bit test on netdev->features,
> corresponding ethtool entry points could be removed.

Right.

It also might be worth defining a standard feature flag for RX checksum
offload, since currently every driver has to maintain its own private
flag.  Though we're running short of feature flags on 32-bit machines.

[...]
> * sfc
> 	assumed: constant efx->type->offload_features
[...]

This is correct.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

