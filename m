From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH] net: fec: Add support for multiple phys on mdiobus
Date: Mon, 21 Jan 2013 11:07:01 +0100
Message-ID: <20130121100701.GX1906@pengutronix.de>
References: <1358757475-21035-1-git-send-email-s.hauer@pengutronix.de>
 <50FD02B8.8080401@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	shawn.guo@linaro.org, davem@davemloft.net
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:55226 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751509Ab3AUKHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 05:07:03 -0500
Content-Disposition: inline
In-Reply-To: <50FD02B8.8080401@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 21, 2013 at 09:56:24AM +0100, Wolfgang Grandegger wrote:
> On 01/21/2013 09:37 AM, Sascha Hauer wrote:
> > There may be multiple phys on an mdio bus. This series adds support
> > for this to the fec driver. I recently had a board which has a switch
> > connected to the fec's mdio bus, so I had to pick the correct phy.
> 
> Pick one PHY from a switch port? Well, does a PHY-less (or fixed-link)
> configuration for a switch not make more sense?

Yes, you're probably right.

> Various ARM Ethernet
> contoller drivers do not support it. I recently needed a hack for an
> AT91 board.

I wonder how we want to proceed. Should there be a devicetree property
'fixed-link' like done for fs_enet (and not recommended for new code,
stated in the comment above of_phy_connect_fixed_link)?

Currently I have a property 'phy' in the fec binding which has a phandle
to a phy provided by the fec's mdio bus, but this could equally well
point to a fixed dummy phy:

	phy = &fixed-phy;

Currently there seems to be no common convention for the devicetree how
to handle such situations, or am I missing something?

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
