From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_net: runtime pm wrap mdio read and write
Date: Wed, 26 Feb 2014 22:21:32 +0300
Message-ID: <530E3EBC.5060408@cogentembedded.com>
References: <1393433319-22685-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	magnus.damn@opensource.se, horms@verge.net.au
To: Ben Dooks <ben.dooks@codethink.co.uk>, netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1393433319-22685-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/26/2014 07:48 PM, Ben Dooks wrote:

> On the R8A7790, if the device has been suspended by pm_runtime
> and the MII code tries to access the bus then there is a possiblity

    s/possiblity/possibility/.

> that it will fail to read any data from the MII bus.

> Change the MDIO read and write calls to be wrappered by calls to

    s/wrappered/wrapped/.

> pm_runtime_{get,put}_sync so that the device will be enabled during
> these calls. It is put here to avoid having to enable and disable
> the clock for every bit that is sent by the MII bit-banging code.

> This has been exposed by the change to using OF and a fix to enable
> the pm_runtime clock management which seems to have been broken for
> some time for the device-tree booted Renesas kernels.

    What fix to enable run-time PM are you talking about?

> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
> ---
>   drivers/net/ethernet/renesas/sh_eth.c | 39 +++++++++++++++++++++++++++++++++++
>   1 file changed, 39 insertions(+)

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index b92034c..8d1b84e 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -983,6 +983,8 @@ static unsigned long sh_eth_get_edtrr_trns(struct sh_eth_private *mdp)
>
>   struct bb_info {
>   	void (*set_gate)(void *addr);
> +        int (*mdio_read)(struct mii_bus *bus, int phy_id, int regnum);
> +        int (*mdio_write)(struct mii_bus *bus, int phy_id, int regnum, u16 val);

    Please indent with tabs.

> @@ -1071,6 +1073,38 @@ static struct mdiobb_ops bb_ops = {
>   	.get_mdio_data = sh_get_mdio,
>   };
>
> +/* Wrapper to ensure bitbang ops have device runtime-pm enabled */
> +
> +static inline struct bb_info *mii_to_bitbang(struct mii_bus *bus)
> +{
> +	struct mdiobb_ctrl *ctrl = bus->priv;

    Empty line between declaration and the other code needed.

> +	return container_of(ctrl, struct bb_info, ctrl);
> +}
[...]

WBR, Sergei

