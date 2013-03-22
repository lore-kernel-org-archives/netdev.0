From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH 0/4 v3] mv643xx_eth: use mvmdio MDIO bus driver
Date: Fri, 22 Mar 2013 10:14:23 -0400
Message-ID: <20130322141423.GJ13280@titan.lakedaemon.net>
References: <1363284515-9865-1-git-send-email-florian@openwrt.org>
 <1363959568-16976-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	Rob Landley <rob@landley.net>, Andrew Lunn <andrew@lunn.ch>,
	Russell King <linux@arm.linux.org.uk>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1363959568-16976-1-git-send-email-florian@openwrt.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 22, 2013 at 02:39:24PM +0100, Florian Fainelli wrote:
> Hi all,
> 
> This patch converts the mv643xx_eth driver to use the mvmdio MDIO bus driver
> instead of rolling its own implementation. As a result, all users of this
> mv643xx_eth driver are converted to register an "orion-mdio" platform_device.
> The mvmdio driver is also updated to support an interrupt line which reports
> SMI error/completion, and to allow traditionnal platform device registration
> instead of just device tree.
> 
> David, I think it makes sense for you to merge all of this, since we do
> not want the architecture files to be desynchronized from the mv643xx_eth to
> avoid runtime breakage. The potential for merge conflicts should be very small.
> 
> Florian Fainelli (4):
>   net: mvmdio: allow platform device style registration
>   net: mvmdio: rename base register cookie from smireg to regs
>   net: mvmdio: enhance driver to support SMI error/done interrupts
>   mv643xx_eth: convert to use the Marvell Orion MDIO driver
> 
>  .../devicetree/bindings/net/marvell-orion-mdio.txt |    3 +
>  arch/arm/plat-orion/common.c                       |   54 +++---
>  arch/powerpc/platforms/chrp/pegasos_eth.c          |   20 ++
>  arch/powerpc/sysdev/mv64x60_dev.c                  |   16 +-
>  drivers/net/ethernet/marvell/Kconfig               |    5 +-
>  drivers/net/ethernet/marvell/Makefile              |    2 +-
>  drivers/net/ethernet/marvell/mv643xx_eth.c         |  195 ++------------------
>  drivers/net/ethernet/marvell/mvmdio.c              |  130 ++++++++++---
>  include/linux/mv643xx_eth.h                        |    1 -
>  9 files changed, 187 insertions(+), 239 deletions(-)

Whole series applied on top of v3.9-rc3 and tested on dreamplug
(kirkwood DT boot with legacy mv643xx_eth init)

Tested-by: Jason Cooper <jason@lakedaemon.net>

also, for the bits changing plat-orion:

Acked-by: Jason Cooper <jason@lakedaemon.net>

thx,

Jason.
