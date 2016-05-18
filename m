From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCHv3] phy: fix crash in fixed_phy_add()
Date: Wed, 18 May 2016 15:38:43 +0200
Message-ID: <20160518133843.GB25448@lunn.ch>
References: <1463568451-9385-1-git-send-email-rabin.vincent@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, f.fainelli@gmail.com,
	netdev@vger.kernel.org, Rabin Vincent <rabinv@axis.com>
To: Rabin Vincent <rabin.vincent@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41120 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752805AbcERNis (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2016 09:38:48 -0400
Content-Disposition: inline
In-Reply-To: <1463568451-9385-1-git-send-email-rabin.vincent@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 18, 2016 at 12:47:31PM +0200, Rabin Vincent wrote:
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

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Thanks
	Andrew
