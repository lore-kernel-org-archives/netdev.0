From: Beniamino Galvani <b.galvani@gmail.com>
Subject: Re: [PATCH v5 1/4] ethernet: arc: Add support for Rockchip SoC layer
 device tree bindings
Date: Wed, 3 Sep 2014 23:12:20 +0200
Message-ID: <20140903211220.GA16962@gmail.com>
References: <1409763165-16461-1-git-send-email-romain.perier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: heiko@sntech.de, linux-rockchip@lists.infradead.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, arnd@arndb.de
To: Romain Perier <romain.perier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:54636 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752823AbaICVNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 17:13:10 -0400
Content-Disposition: inline
In-Reply-To: <1409763165-16461-1-git-send-email-romain.perier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 03, 2014 at 04:52:42PM +0000, Romain Perier wrote:
> This patch defines a platform glue layer for Rockchip SoCs which
> support arc-emac driver. It ensures that regulator for the rmii is on
> before trying to connect to the ethernet controller. It applies right
> speed and mode changes to the grf when ethernet settings change.

Hi Romain,

on a Radxa Rock when I try to remove the emac_rockchip module the
board locks up when calling clk_disable_unprepare(priv->refclk). The
tree is a net-next + your series, I don't know if I need some other
patches.

There is also the following build warning due to the emac dependency
on REGULATOR which in principle seems correct, but looking at other
drivers I wonder why they use the regulator APIs but don't have the
same dependency.

drivers/regulator/Kconfig:1:error: recursive dependency detected!
drivers/regulator/Kconfig:1:       symbol REGULATOR is selected by MDIO_SUN4I
drivers/net/phy/Kconfig:159:       symbol MDIO_SUN4I depends on PHYLIB
drivers/net/phy/Kconfig:5:         symbol PHYLIB is selected by ARC_EMAC_CORE
drivers/net/ethernet/arc/Kconfig:20:      symbol ARC_EMAC_CORE is selected by EMAC_ROCKCHIP
drivers/net/ethernet/arc/Kconfig:35:      symbol EMAC_ROCKCHIP depends on REGULATOR

Regards,
Beniamino
