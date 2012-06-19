From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] micrel KSZ8041 disable auto negotiation with fiber
Date: Tue, 19 Jun 2012 18:08:29 +0100
Message-ID: <1340125709.2692.23.camel@bwh-desktop.uk.solarflarecom.com>
References: <4FE090A7.801@efacec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?An=EDbal?= Almeida Pinto <anibal.pinto@efacec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8296 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751958Ab2FSRId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 13:08:33 -0400
In-Reply-To: <4FE090A7.801@efacec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-19 at 15:45 +0100, An=C3=ADbal Almeida Pinto wrote:
> Hi,
>=20
> I am working on a custom board based on a OMAP L138 with a KSZ8041TL-=
=46TL=20
> phy that have fibber and copper support.
>=20
> When using with fibber the board can't connect to a switch, only afte=
r=20
> exec :
>=20
> 	ethtool -s eth1 speed 100 duplex full autoneg off
>=20
> the phy get link and start working.
>=20
> On some switches it appears that autoneg don't work well with fibber,=
=20
> ethtool reports that its at 10MB/s after exec
>=20
> 	ethtool -s eth1 autoneg on

I'm not aware of any specification for autoneg over fibre, so I imagine
the PHY is being programmed with an invalid configuration and sending
weird signals.

> The auto negotiation bit on phy register is disable on start when usi=
ng=20
> the fibber but Linux don't appear to look at it.
>=20
> Found a thread [1] that solve the problem but don't appear to be full=
y=20
> accepted.
>=20
> The problem is modifying the phy code without interfere with ethtool =
use.
>=20
> Any official/accepted solution to this problem ?

The net driver or PHY driver needs to disable autoneg by default when
connected to fibre, and reject attempts to turn it on.

As for *how* the driver is supposed to know whether that's the case, I
have no idea...

> [1] - http://marc.info/?l=3Dlinuxppc-embedded&m=3D131107263711714

=2E..which seems to be where the previous discussion ended.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
