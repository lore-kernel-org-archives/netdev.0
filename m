From: Beniamino Galvani <b.galvani@gmail.com>
Subject: Re: [PATCH v5 1/4] ethernet: arc: Add support for Rockchip SoC layer
 device tree bindings
Date: Thu, 4 Sep 2014 23:38:21 +0200
Message-ID: <20140904213821.GA13511@gmail.com>
References: <1409763165-16461-1-git-send-email-romain.perier@gmail.com>
 <20140903211220.GA16962@gmail.com>
 <3809311.80Auz8fbHu@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Romain Perier <romain.perier@gmail.com>, heiko@sntech.de,
	linux-rockchip@lists.infradead.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:40509 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755990AbaIDVjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 17:39:09 -0400
Content-Disposition: inline
In-Reply-To: <3809311.80Auz8fbHu@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 04, 2014 at 11:33:38AM +0200, Arnd Bergmann wrote:
> This is a recurring problem: 
> 
> driver a depends on x and selects y
> driver b depends on y and selects x
> 
> Maybe we should teach Kconfig to not worry about it when x and y are
> both user-selectable as well.
> 
> However, a nicer solution would be if we could agree for each symbol
> on who is supposed to 'select' or 'depends on' it. In particular,
> we are inconsistent about CONFIG_REGULATOR:
> 
> MDIO_SUN4I probably should not 'select' it but instead 'depends on'
> this symbol if anything. It would be nice if someone could submit
> a patch to that effect. EMAC_ROCKCHIP could also drop the dependency
> on REGULATOR: you can still build the driver without that subsystem
> being enabled, but then all the regulators have to be set up by
> the boot loader.

Thanks, things are clearer now. 

If I understand correctly the dependency of MDIO_SUN4I on REGULATOR
can be dropped as well for the same reason; I will send a patch for
that.

Beniamino

> 
> There isn't much we can do about the PHYLIB dependency, unless we
> turn it into a silent symbol that gets selected by all phy drivers,
> or we change all network drivers that currently 'select' it to
> 'depends on'. I don't really want to get involved in that discussion ;-)
> 
> 	Arnd
