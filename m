From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH 5/5] mv643xx_eth: convert to use the Marvell Orion MDIO
 driver
Date: Tue, 29 Jan 2013 17:01:31 +0100
Message-ID: <20130129170131.7964a110@skate>
References: <1359473048-26551-1-git-send-email-florian@openwrt.org>
	<1359473048-26551-6-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	Rob Landley <rob@landley.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King <linux@arm.linux.org.uk>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1359473048-26551-6-git-send-email-florian@openwrt.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Florian Fainelli,

On Tue, 29 Jan 2013 16:24:08 +0100, Florian Fainelli wrote:
> This patch converts the Marvell MV643XX ethernet driver to use the
> Marvell Orion MDIO driver. As a result, PowerPC and ARM platforms
> registering the Marvell MV643XX ethernet driver are also updated to
> register a Marvell Orion MDIO driver. This driver voluntarily overlaps
> with the Marvell Ethernet shared registers because it will use a subset
> of this shared register (shared_base + 0x4 - shared_base + 0x84). The
> Ethernet driver is also updated to look up for a PHY device using the
> Orion MDIO bus driver.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>
> ---
>  arch/arm/plat-orion/common.c               |   84 +++++++++++--

In this file, there was one "MV643XX_ETH_SHARED_NAME" platform_device
registered for each network interface. Why? If the driver is shared,
isn't the whole idea to register it only once?

In any case, one of the idea of separating the mvmdio driver from the
mvneta driver in the first place is that there should be only one
instance of the mvmdio device, even if there are multiple network
interfaces. The reason is that from a HW point of the view, the MDIO
unit is shared between the network interfaces. If you look at
armada-370-xp.dtsi, there is only one mvmdio device registered, and two
network interfaces (using the mvneta driver) that are registered (and
actually up to four network interfaces can exist, they are added by
some other .dtsi files depending on the specific SoC).

So I don't think there should be one instance of the mvmdio per network
interface.

Also, I am wondering what's left in this MV643XX_ETH_SHARED_NAME driver
once the MDIO stuff has been pulled out in a separate driver? I think
the whole point of this work should be to get rid of this
MV643XX_ETH_SHARED_NAME driver, no?

Thanks,

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
