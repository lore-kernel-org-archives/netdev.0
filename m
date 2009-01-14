From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] Expanding ethtool PHY information
Date: Wed, 14 Jan 2009 11:55:19 -0500
Message-ID: <496E18F7.10908@pobox.com>
References: <1231879514.3005.31.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55805 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764149AbZANQz0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:55:26 -0500
In-Reply-To: <1231879514.3005.31.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> The set of port types reported through the ethtool API is looking a b=
it
> limited:
>=20
> /* Which connector port. */
> #define PORT_TP			0x00
> #define PORT_AUI		0x01
> #define PORT_MII		0x02
> #define PORT_FIBRE		0x03
> #define PORT_BNC		0x04
>=20
> There are of course many different types of fibre and several differe=
nt
> types of slot for fibre transceivers.  Also there are other copper-wi=
re
> types not included - at least CX4 and KX4.  This is even before we
> consider non-Ethernet devices which are starting to support some of t=
he
> ethtool API.
>=20
> This probably doesn't matter for *setting* port type at the moment, a=
s
> few devices other than 10 megabit Ethernet NICs allow software to sel=
ect
> between different port types.  However it does mean that other port
> types cannot be reported correctly.  At the least, I think we could d=
o
> with a PORT_OTHER.  Similarly for the supported port type flags.
>=20
> Other PHY information that seems worth adding:
> =EF=BB=BF- link partner abilities (ethtool_cmd)
> - MDIO support: none, clause 22, clause 45 (ethtool_drvinfo)
> - PHY firmware version (ethtool_drvinfo?)
>=20
> What do you think of these?  Obviously it's easy to add these to the
> interface but the structures are filling up and extending them with n=
ew
> ethtool operations has a cost.

It's an interesting question.  The port types are really a legacy detai=
l=20
left over from the ancient days.

I do agree that other PHY information is worth adding, but my initial=20
reaction is to make current drivers PORT_OTHER, and then provide a=20
separate avenue for better defining what 'other' means for that specifi=
c=20
driver/hardware.

	Jeff




