From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 5/7] net:mdio-mux: Add MDIO mux driver for iProc SoCs
Date: Fri, 3 Jun 2016 18:27:15 +0200
Message-ID: <20160603162715.GG22120@lunn.ch>
References: <1464967568-27562-1-git-send-email-pramod.kumar@broadcom.com>
 <1464967568-27562-6-git-send-email-pramod.kumar@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	bcm-kernel-feedback-list@broadcom.com,
	linux-arm-kernel@lists.infradead.org
To: Pramod Kumar <pramod.kumar@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1464967568-27562-6-git-send-email-pramod.kumar@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 03, 2016 at 08:56:06PM +0530, Pramod Kumar wrote:
> iProc based SoCs supports the integrated mdio multiplexer which
> has the bus selection as well as mdio transaction generation logic
> inside.
> 
> This mutiplexer has child buses for PCIe, SATA, USB and ETH. These

multiplexer 

> buses could be internal or external to SOC where PHYs are attached.
> These buses could use C-45 or C-22 mdio transaction.
> 
> Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>
> ---
>  drivers/net/phy/Kconfig              |  11 ++
>  drivers/net/phy/Makefile             |   1 +
>  drivers/net/phy/mdio-mux-bcm-iproc.c | 246 +++++++++++++++++++++++++++++++++++
>  3 files changed, 258 insertions(+)
>  create mode 100644 drivers/net/phy/mdio-mux-bcm-iproc.c
> 
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index 6dad9a9..38faecf 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -254,6 +254,17 @@ config MDIO_BUS_MUX_MMIOREG
>  
>  	  Currently, only 8-bit registers are supported.
>  
> +config MDIO_BUS_MUX_BCM_IPROC
> +	tristate "Support for iProc based MDIO bus multiplexers"
> +	depends on OF && OF_MDIO && (ARCH_BCM_IPROC || COMPILE_TEST)
> +	select MDIO_BUS_MUX
> +	default ARCH_BCM_IPROC
> +	help
> +	  This module provides a driver for MDIO bus multiplexers found in
> +	  iProc based Broadcom SoCs. This mulitplexer connects one of several

multiplexer


> +	  child MDIO bus to a parent bus. Buses could be interal as well as

internal

Maybe you should turn on the spelling checker in your text editor?

> +static int start_miim_ops(void __iomem *base,
> +			  u16 phyid, u32 reg, u16 val, u32 op)
> +{
> +	u32 param;
> +	int ret;
> +
> +	writel(0, base + MDIO_CTRL_OFFSET);
> +	ret = iproc_mdio_wait_for_idle(base, 0);
> +	if (ret)
> +		goto err;
> +
> +	param = readl(base + MDIO_PARAM_OFFSET);
> +	param |= phyid << MDIO_PARAM_PHY_ID;
> +	param |= val << MDIO_PARAM_PHY_DATA;
> +	if (reg & MII_ADDR_C45)
> +		param |= (1 << MDIO_PARAM_C45_SEL);

You could use BIT(MDIO_PARAM_C45_SEL) here

> +static int mdio_mux_iproc_remove(struct platform_device *pdev)
> +{
> +	struct iproc_mdiomux_desc *md = dev_get_platdata(&pdev->dev);
> +
> +	mdio_mux_uninit(md->mux_handle);
> +
> +	return 0;

You should unregister and free the parent MDIO device.

    Andrew
