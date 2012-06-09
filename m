From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH] netdev: mv643xx_eth: Prevent build on PPC32
Date: Sat, 9 Jun 2012 12:01:05 +0800
Message-ID: <20120609040104.GI3924@opensource.wolfsonmicro.com>
References: <20120605192820.GC7683@zod.bos.redhat.com>
 <1338939005.21665.54.camel@deadeye.wl.decadent.org.uk>
 <20120606023842.GD7683@zod.bos.redhat.com>
 <20120607235115.GB21150@sirena.org.uk>
 <20120607235550.GK7683@zod.bos.redhat.com>
 <20120608003445.GC21150@sirena.org.uk>
 <20120608010403.GL7683@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3eH4Qcq5fItR5cpy"
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Andrew Lunn <andrew@lunn.ch>, Olof Johansson <olof@lixom.net>,
	netdev@vger.kernel.org
To: Josh Boyer <jwboyer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:54643 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714Ab2FIEBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2012 00:01:22 -0400
Content-Disposition: inline
In-Reply-To: <20120608010403.GL7683@zod.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--3eH4Qcq5fItR5cpy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jun 07, 2012 at 09:04:03PM -0400, Josh Boyer wrote:

> I'm not placing blame.  I'm declaring people should be cautious going
> forward.  5 arches have the clock API.  21 don't.  Whatever reasons
> there are for that, I don't care.  It should be a big warning sign.

My point here is that it's a warning sign for the API, not really for
the drivers that use it.

> It might even be beneficial to put some Kconfig dependencies on both
> CONFIG_COMMON_CLK (which is somewhat misleadingly named) and
> CONFIG_CLKDEV_LOOKUP so those are only selectable on those 5 arches.
> Something like:

>  config CLKDEV_LOOKUP
>  	bool
> +	depends on (ARM || SUPERH || MIPS || C6X || BLACKFIN)
>  	select HAVE_CLK

This is a really bad approach.  It's sending totally the wrong message
about where we want to be (we want to have the clock API available
everywhere) and more importantly it still means that drivers need to go
on carrying around ifdefery or unhelpful dependencies which is just lots
of pointless work.  A very large proportion of the drivers that use
clocks are just making sure clocks are enabled when the device is active
to integrate with system wide power optimisation and don't actually care
if there are clocks there at all, we should be making their life as easy
as possible.

A much better approach is get the stubs mentioned earlier merged
(they're already on their way) faster.  That way there are no compile
time dependencies and the problem goes away unless the driver is doing
something more active with clocks like managing the clock rate.

In the case of CLKDEV_LOOKUP the symbol should only be selected by an
architecture anyway, it's a layer on top of the architecture clock code.

> Regardless, hopefully things like this will get hit in linux-next in the
> future.  I believe the only reason that it wasn't this time is that
> none of the PPC defconfigs build in linux-next bother to build the
> driver at all.

They do generally, people do randconfig and allXconfig builds all the
time.

--3eH4Qcq5fItR5cpy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJP0sp5AAoJEBus8iNuMP3dsJgP/2rvRckRCnpumsJQKTs3w/ES
DcZPUTDBNUKXFo3PT4+ZDfOMYDP8780EktyIf94s6tp3B0eYLkICS1vl0ONR4Kex
LMX4PFrphhc5NFqzs5SSA+k41ITAG/zu0KF2XXUXhPt6FIaWuQQ7QKX4MNvmolrU
0HBNabRvByK8NQ2DWyzfVpUv5JuvmKzrWngE977dEUCFqTIoXqqByPHvAJj06VoD
wTPAnLMVvUWO9YaeqoxnYAWrprwU9ZbnVMkMGjWtooMQPULZ540s17369NDK199P
BTCooHA/O+dpwVxYMJGhJ3uIGS7u1T2vhYLEfjaCCUL8in5VWUegGdmtShrE8Glv
GO4xN2Qi0zeNFT0/lhfzM6BMv+c/6E4aUfIJBUbS1Rmw21Gszw2NFn1bX07jdndQ
3UChWBYajo+6kHHfACMSSxk0Lmexf0LkBKYxywIDXvpN5p48xAg3CW7hUOIKv54E
ZkCEDMW1yF0Weuqbrd6z5NWIgYyBj2Y6qekTV0BvO9Ru/aWiLQU8nBdcDygULK54
cSf94stS4rXRLG8fJ6pk4iwyRwoMOWNH9vLRab9RLnolZ96q2JwQQyKos5Bq6uGv
PpcA9Cddm69x2kyMyX6e5YG0PQg3TTsOn/iMF2oXBl8qstY3xDtwItRwaTe0yduy
vC7UVdkT7fKyG5x/BewT
=ZtQc
-----END PGP SIGNATURE-----

--3eH4Qcq5fItR5cpy--
