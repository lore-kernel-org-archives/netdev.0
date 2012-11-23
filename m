From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 1/3] net: stmmac: change GMAC control register for SGMII
Date: Fri, 23 Nov 2012 10:31:21 +0100
Message-ID: <50AF4269.1070404@st.com>
References: <004b01cdc959$80af8030$820e8090$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, kgene.kim@samsung.com,
	linux-kernel@vger.kernel.org
To: Byungho An <bh74.an@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <004b01cdc959$80af8030$820e8090$%an@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello An

On 11/23/2012 10:04 AM, Byungho An wrote:
>
> This patch changes GMAC control register (TC(Transmit
> Configuration) and PS(Port Selection) bit for SGMII.
> In case of SGMII, TC bit is '1' and PS bit is 0.

I was looking at this too. In particular, I was working on the rgmii 
interrupt so I guess we could improve this part together.

First my note is that I would like to have this kind of code never 
placed in the stmmac_main. It should stay in the core part.
Also I 'd like to avoid the Kconfig option where possible.

At any rate, I'll come back with further details soon.

BR,
Peppe

>
> Signed-off-by: Byungho An <bh74.an@samsung.com>
> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   10 ++++++++++
>   1 file changed, 10 insertions(+)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index c6cdbc4..a719c87 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1037,6 +1037,7 @@ static int stmmac_open(struct net_device *dev)
>   {
>   	struct stmmac_priv *priv = netdev_priv(dev);
>   	int ret;
> +	u32 value;
>
>   #ifdef CONFIG_STMMAC_TIMER
>   	priv->tm = kzalloc(sizeof(struct stmmac_timer *), GFP_KERNEL);
> @@ -1088,6 +1089,15 @@ static int stmmac_open(struct net_device *dev)
>   	/* Initialize the MAC Core */
>   	priv->hw->mac->core_init(priv->ioaddr);
>
> +	if (priv->phydev->interface == PHY_INTERFACE_MODE_SGMII) {
> +		value = readl(priv->ioaddr);
> +		/* GMAC_CONTROL_TC : transmit config in RGMII/SGMII */
> +		value |= 0x1000000;
> +		/* GMAC_CONTROL_PS : Port Selection for GMII */
> +		value &= ~(0x8000);
> +		writel(value, priv->ioaddr);
> +	}
> +
>   	/* Request the IRQ lines */
>   	ret = request_irq(dev->irq, stmmac_interrupt,
>   			 IRQF_SHARED, dev->name, dev);
>
