From: Florian Fainelli <florian@openwrt.org>
Subject: Re: stmmac: fix phy naming inconsistency
Date: Tue, 24 Jan 2012 12:06:30 +0100
Message-ID: <4F1E90B6.6090106@openwrt.org>
References: <20120124092648.GA26380@mail.gnudd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	giancarlo.asnaghi@st.com, peppe.cavallaro@st.com
To: Alessandro Rubini <rubini@gnudd.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120124092648.GA26380@mail.gnudd.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Alessandro,

On 01/24/12 10:26, Alessandro Rubini wrote:
> After commit "db8857b stmmac: use an unique MDIO bus name" my
> device stopped being probed because two different names were being
> used in different places. This fixes the inconsistency.
>
> Signed-off-by: Alessandro Rubini<rubini@gnudd.com>
> Acked-by: Giancarlo Asnaghi<giancarlo.asnaghi@st.com>
> Cc: Giuseppe Cavallaro<peppe.cavallaro@st.com>
> Cc: Florian Fainelli<florian@openwrt.org>

Acked-by: Florian Fainelli <florian@openwrt.org>

> ---
>
> Before the commit, the phy was identified like this and stuff worked:
>
>       PHY ID 20005c90 at 1 IRQ 0 (506:01) active
>
> After that commit, I get
>
>       PHY ID 20005c90 at 1 IRQ 0 (STMMAC MII Bus-1:01) active
>       PHY stmmac-1:01 not found
>
> In one place, "stmmac" is a static string, on the other the commit
> used the name field of the bus that was "STMMAC MII Bus", so I changed
> this older string to be nicer -- without spaces.
>
> Maybe the name is available where "stmmac" is spelled out, but I
> didn't check.
>
> Now it works for me:
>
>      eth1: PHY ID 20005c90 at 1 IRQ 0 (stmmac-1:01) active
>      PHY: stmmac-1:01 - Link is Up - 100/Full
>
>
>   drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> index 6e712c5..819606e 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> @@ -154,7 +154,7 @@ int stmmac_mdio_register(struct net_device *ndev)
>   	else
>   		irqlist = priv->mii_irq;
>
> -	new_bus->name = "STMMAC MII Bus";
> +	new_bus->name = "stmmac";
>   	new_bus->read =&stmmac_mdio_read;
>   	new_bus->write =&stmmac_mdio_write;
>   	new_bus->reset =&stmmac_mdio_reset;
