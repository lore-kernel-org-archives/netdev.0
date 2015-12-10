From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH] net/macb: add support for resetting PHY using GPIO
Date: Thu, 10 Dec 2015 08:37:56 +0100
Message-ID: <20151210073756.GA11966@pengutronix.de>
References: <1449683383-5022-1-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:34343 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751498AbbLJHiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 02:38:05 -0500
Content-Disposition: inline
In-Reply-To: <1449683383-5022-1-git-send-email-gregory.clement@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Gregory,

On Wed, Dec 09, 2015 at 06:49:43PM +0100, Gregory CLEMENT wrote:
> With device tree it is no more possible to reset the PHY at board
> level. Furthermore, doing in the driver allow to power down the PHY when
> the network interface is no more used.
> 
> The patch introduces a new optional property "phy-reset-gpio" inspired
> from the one use for the FEC.

I don't think it's a good idea to further extend the usage of this
binding. The driver should use the phy-handle property and
of_phy_connect() which gives you a proper device node for the phy. Then
the phy device node should get the reset gpio. I know it's more work,
but doing it like this gives you additional goodies like proper handling
of the max-speed property, a fixed-link if necessary and picking the
correct phy if there are muliple phys on the bus.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
