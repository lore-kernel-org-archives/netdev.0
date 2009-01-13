From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC] Expanding ethtool PHY information
Date: Tue, 13 Jan 2009 20:45:14 +0000
Message-ID: <1231879514.3005.31.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Jeff Garzik <jgarzik@pobox.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:52731 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753443AbZAMUpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 15:45:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The set of port types reported through the ethtool API is looking a bit
limited:

/* Which connector port. */
#define PORT_TP			0x00
#define PORT_AUI		0x01
#define PORT_MII		0x02
#define PORT_FIBRE		0x03
#define PORT_BNC		0x04

There are of course many different types of fibre and several different
types of slot for fibre transceivers.  Also there are other copper-wire
types not included - at least CX4 and KX4.  This is even before we
consider non-Ethernet devices which are starting to support some of the
ethtool API.

This probably doesn't matter for *setting* port type at the moment, as
few devices other than 10 megabit Ethernet NICs allow software to selec=
t
between different port types.  However it does mean that other port
types cannot be reported correctly.  At the least, I think we could do
with a PORT_OTHER.  Similarly for the supported port type flags.

Other PHY information that seems worth adding:
=EF=BB=BF- link partner abilities (ethtool_cmd)
- MDIO support: none, clause 22, clause 45 (ethtool_drvinfo)
- PHY firmware version (ethtool_drvinfo?)

What do you think of these?  Obviously it's easy to add these to the
interface but the structures are filling up and extending them with new
ethtool operations has a cost.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

