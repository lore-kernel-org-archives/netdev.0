From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Driver SFC: Possible bug in LM87 temperature XFP detection code
Date: Wed, 29 Apr 2009 13:47:40 +0100
Message-ID: <1241009260.3246.11.camel@achroite>
References: <1240911369.10689.20.camel@localhost.localdomain>
	 <1240925799.3200.16.camel@achroite> <1240938258.3200.28.camel@achroite>
	 <Pine.LNX.4.64.0904291028060.20858@tyr.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@comx.dk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:59797 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752492AbZD2Mrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 08:47:45 -0400
In-Reply-To: <Pine.LNX.4.64.0904291028060.20858@tyr.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-04-29 at 10:52 +0200, Jesper Dangaard Brouer wrote:
[...]
> > The "internal" temperature sensor (temp1_input) is in the LM87, which is
> > placed at the corner of the board away from the bracket and the edge
> > connector.
> >
> > The "external" temperature sensor (temp2_input) is in the SFC4000.
> 
> I though this was read from the XFP.

No.

> I was hoping the NIC supported 
> reading i2c stuff from the XFP.  Does it support that? (Robert Olsson 
> wanted to play with this stuff)

That's connected to the PHY and not the controller.  According to the
datasheet for the QT2022, you can read out the EEPROM from MDIO
registers 1.32775-1.33030 (ignoring bits 8-15).  Use the MII ioctl
interface and set phy_id to 0x441 (the formula is 0x400 | (prtad << 5) |
devad).

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

