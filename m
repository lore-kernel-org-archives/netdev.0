From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3] phy: fix crash in fixed_phy_add()
Date: Fri, 20 May 2016 10:50:32 -0700 (PDT)
Message-ID: <20160520.105032.1917286986199018607.davem@davemloft.net>
References: <1463568451-9385-1-git-send-email-rabin.vincent@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
	rabinv@axis.com
To: rabin.vincent@axis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51432 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263AbcETRud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 13:50:33 -0400
In-Reply-To: <1463568451-9385-1-git-send-email-rabin.vincent@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rabin Vincent <rabin.vincent@axis.com>
Date: Wed, 18 May 2016 12:47:31 +0200

> From: Rabin Vincent <rabinv@axis.com>
> 
> Since e7f4dc3536a ("mdio: Move allocation of interrupts into core"),
> platforms which call fixed_phy_add() before fixed_mdio_bus_init() is
> called (for example, because the platform code and the fixed_phy driver
> use the same initcall level) crash in fixed_phy_add() since the
> ->mii_bus is not allocated.
> 
> Also since e7f4dc3536a, these interrupts are initalized to polling by
> default.  The few (old) platforms which directly use fixed_phy_add()
> from their platform code all pass PHY_POLL for the irq argument, so we
> can keep these platforms not crashing by simply not attempting to set
> the irq if PHY_POLL is passed.
> 
> Also, even if problems have not been reported on more modern platforms
> which used fixed_phy_register() from drivers' probe functions, we return
> -EPROBE_DEFER if the MDIO bus is not yet registered so that the probe is
> retried later.
> 
> Fixes: e7f4dc3536a400 ("mdio: Move allocation of interrupts into core")
> Signed-off-by: Rabin Vincent <rabinv@axis.com>
> ---
> v3: One more suggestion from Andrew: check mii bus state

Applied, thanks.
