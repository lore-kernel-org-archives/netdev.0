From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 1/2] net: phy: dp83867: Port mirroring support in the
 DP83867 TI's PHY driver
Date: Sat, 4 Feb 2017 18:32:56 +0100
Message-ID: <20170204173256.GB8364@lunn.ch>
References: <1486224132-15420-1-git-send-email-lukma@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Karicheri Muralidharan <m-karicheri2@ti.com>,
        linux-kernel@vger.kernel.org, Eric Engestrom <eric@engestrom.ch>,
        netdev@vger.kernel.org, Kishon Vijay Abraham I <kishon@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: Lukasz Majewski <lukma@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55662 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751209AbdBDRdR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 4 Feb 2017 12:33:17 -0500
Content-Disposition: inline
In-Reply-To: <1486224132-15420-1-git-send-email-lukma@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 04, 2017 at 05:02:11PM +0100, Lukasz Majewski wrote:
> This patch adds support for enabling or disabling the port mirroring 
> (at CFG4 register) feature of the DP83867 TI's PHY device.

As we discussed before, "port mirroring" is bad naming. Yes, we should
use it, because that is what the datasheet calls this feature. But the
commit message should also contain a description of what this means,
and reference that the linux name for this concept is lane swapping.

> +enum {

Maybe give the 0 value a name. DP83867_PORT_MIRROING_KEEP?

> +	DP83867_PORT_MIRROING_EN = 1,
> +	DP83867_PORT_MIRROING_DIS,
> +};
> +

That extra enum value can then make this more obvious:
  
        if (dp83867->port_mirroring != DP83867_PORT_MIRROING_KEEP)
		dp83867_config_port_mirroring(phydev);

On the first reading of the patch, i though you were setting mirroring
on/off under all conditions, but in fact you don't. This makes it
clearer.

	Thanks
		Andrew
