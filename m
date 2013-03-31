From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#565404: linux-image-2.6.26-2-amd64: atl1e: TSO is broken
Date: Sun, 31 Mar 2013 03:10:05 +0100
Message-ID: <1364695805.3557.41.camel@deadeye.wl.decadent.org.uk>
References: <CDAFEDABF718A54BABD0DA5476695307475CCD42@SHEXMB-01.global.atheros.com>
	 <20100125.163612.582489483209420341.anders@netinsight.net>
	 <CDAFEDABF718A54BABD0DA5476695307475CCFF8@SHEXMB-01.global.atheros.com>
	 <20100126.093439.651115405791675606.anders@netinsight.net>
	 <1364689558.3557.22.camel@deadeye.wl.decadent.org.uk>
	  <157393863283F442885425D2C45428564F202477@nasanexd02f.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-mP+FDYZkx+GjDvw+Imbo"
Cc: Anders =?ISO-8859-1?Q?Bostr=F6m?= <anders@netinsight.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"565404@bugs.debian.org" <565404@bugs.debian.org>,
	"Hannes Frederic Sowa (hannes@stressinduktion.org)"
	<hannes@stressinduktion.org>
To: "Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54771 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754962Ab3CaCKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Mar 2013 22:10:21 -0400
In-Reply-To: <157393863283F442885425D2C45428564F202477@nasanexd02f.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-mP+FDYZkx+GjDvw+Imbo
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2013-03-31 at 02:18 +0000, Huang, Xiong wrote:
> > > >
> > > > I've tested with
> > > > Debian linux-image-2.6.26-2-amd64 version 2.6.26-19lenny2, Debian
> > > > linux-image-2.6.30-bpo.2-amd64 version 2.6.30-8~bpo50+2 and
> > > > kernel.org
> > > > 2.6.30.10 amd64 with ethtool patch for setting of tso. Same result.
> > >
> > > Does booting with the kernel parameter 'pci=3Dnomsi' avoid the proble=
m?
> > >
> >=20
> > Hannes has found DMA-write (for rx-packet)  is abnormal due to msi func=
tion.
> > But TSO is for rx-packet, an opposite direction. I'm not sure :(, If so=
meone
> > has this issue,  he/she could have a try.
> >=20
>=20
> I checked windows driver, it does limit  the max packet length for TSO
> windows XP : 32*1024 bytes (include MAC header and all MAC payload). No s=
upport IP/TCP option.
> Windows 7:  15, 000 bytes, support IP/TCP option.

If TSO on these devices don't work properly with TCP options then you're
just going to have to disable it - Linux requires it to support at least
the timestamp option.  I'm not sure about IP options (this really ought
to be documented).

If there's a length limit lower than 64K, you'll need to set the limit
using netif_set_gso_max_size() before registering the net device.

Ben.

--=20
Ben Hutchings
Teamwork is essential - it allows you to blame someone else.

--=-mP+FDYZkx+GjDvw+Imbo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUVea/ee/yOyVhhEJAQo7NxAAhwtMRcil0VtFFnFH+Wc92wPGUg5+4vVB
xg5K0KQmuptFP+cWFUGOokz6oCTW55uaDBh6bDeju9rr1+SejBjrHTrKWYU1Dylj
r29ABR/PsVkrIBUpH7Ji9yy2BhUZFQXAW0UJEdMXHW3XZlki5MpA7bQo/NgEufA4
q+JUZ99DaVJ4hUIBjaYKke9Xck+Xjsp8tTYRVZkDteL3NeqNbU6ow1e2lqYuOvPK
KvXgD2dRDb4LpGga6t/zmXFyIsT0DC71y/CWj5wrKPFm/8JDT9CIP0NZSy1AxwtX
ZCcUX1Ip179OIJmwW2M5oFWGsJYMIt6g9mhlJyYKKUh7nJSn49Iyr0NB7SeRcq0l
Sc+r1pgMgCFl0bGiHLDi0+gQeZVmMsjFwTUs/kfqRIIOul9/tp4soWAMxQfsRZRV
VU0Z9Qv1sUkUL1P7tCdEF0DMwoVxNawbjLJS5GCL4Q9JU/QnkYhpZ/nuCkWKA8WX
gLN1cSZ14DMFNzfVPDzy579KqmbwkSghai4jykjz5CqN5t0fFE1H3mOnZuCY9dej
LPFTFWwo2TSvA0yPaD58J0v5ZSf6qlukgUVEC+1J9S0App2jFxVSiYdnq5zsiGMS
NTOBIiIYO0GLcQZ0t1fNUGpTFd3YPw56LjJid84cmtXyXsOnxHKt5o1YHShOnxuv
KPBXCUt1RyI=
=UghS
-----END PGP SIGNATURE-----

--=-mP+FDYZkx+GjDvw+Imbo--
