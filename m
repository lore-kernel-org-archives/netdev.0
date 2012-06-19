From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] micrel KSZ8041 disable auto negotiation with fiber
Date: Tue, 19 Jun 2012 19:45:00 +0100
Message-ID: <1340131500.2692.34.camel@bwh-desktop.uk.solarflarecom.com>
References: <4FE090A7.801@efacec.com>
	 <1340125709.2692.23.camel@bwh-desktop.uk.solarflarecom.com>
	 <4FE0BC99.2030101@efacec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?An=EDbal?= Almeida Pinto <anibal.pinto@efacec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:44883 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751003Ab2FSSpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 14:45:03 -0400
In-Reply-To: <4FE0BC99.2030101@efacec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-19 at 18:53 +0100, An=C3=ADbal Almeida Pinto wrote:
> Em Ter 19 Jun 2012 18:08:29 WEST, Ben Hutchings escreveu:
> > On Tue, 2012-06-19 at 15:45 +0100, An=C3=ADbal Almeida Pinto wrote:
> >> Hi,
> >>
> >> I am working on a custom board based on a OMAP L138 with a KSZ8041=
TL-FTL
> >> phy that have fibber and copper support.
[...]
> > The net driver or PHY driver needs to disable autoneg by default wh=
en
> > connected to fibre, and reject attempts to turn it on.
> >
> > As for *how* the driver is supposed to know whether that's the case=
, I
> > have no idea...
>=20
> On this chip you have a pin where you can specify if is fibber or=20
> copper, at power up it cleat/set the bit of auto negotiation.
>=20
> The driver can save the bit state after phy power up or reset, and wi=
th=20
> that validate if is copper or fibber.
>
> In the case of fibber shouldn't allow change the auto negotiation.

So presumably the problem is where to put this logic?

It looks like you'll be using the davinci_emac net driver, which uses
phylib (i.e. separate PHY drivers) so you need to change ks8041_driver
and related functions in drivers/net/phy/micrel.c.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
