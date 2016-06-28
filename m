From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] of_mdio: select fixed phy support unconditionally
Date: Tue, 28 Jun 2016 05:43:42 -0400 (EDT)
Message-ID: <20160628.054342.1681185612913979373.davem@davemloft.net>
References: <20160624092450.1507991-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, robh+dt@kernel.org, frowand.list@gmail.com,
	david.daney@cavium.com, andrew@lunn.ch,
	sergei.shtylyov@cogentembedded.com, ben.hutchings@codethink.co.uk,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160624092450.1507991-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 24 Jun 2016 11:24:08 +0200

> Calling the fixed-phy functions when CONFIG_FIXED_PHY=m as a previous
> change tried cannot work if the caller is in built-in code:
> 
> drivers/of/built-in.o: In function `of_phy_register_fixed_link':
> of_reserved_mem.c:(.text+0x85e0): undefined reference to `fixed_phy_register'
> 
> Making of_mdio depend on 'FIXED_PHY || !FIXED_PHY' would solve this
> dependency by enforcing that OF_MDIO itself becomes a loadable module
> when FIXED_PHY=y, but that creates a different dependency as it
> breaks any built-in ethernet driver that uses of_mdio.
> 
> Making FIXED_PHY a bool option also cannot work, since it depends on
> PHYLIB, which again is tristate.
> 
> This version now uses 'select FIXED_PHY' to ensure that the fixed-phy
> portion of of_mdio is not optional. The main downside of this is
> a small increase in code size for cases that do not need fixed phy
> support, but it should avoid all of the link-time problems.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: d1bd330a229f ("of_mdio: Enable fixed PHY support if driver is a module")

Applied to net-next, thanks Arnd.

In the future, please be explicit about what tree a patch is
targetting by specifying it in your Subject line, as:

	[PATCH net-next] ...

or similar.

Thanks.
