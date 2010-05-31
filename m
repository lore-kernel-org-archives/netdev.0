From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] can: mpc5xxx_can.c: Fix build failure
Date: Mon, 31 May 2010 20:27:01 +0200
Message-ID: <4C03FF75.3010208@grandegger.com>
References: <1275323499-15543-1-git-send-email-agust@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan-core@lists.berlios.de,
	"David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@secretlab.ca>
To: Anatolij Gustschin <agust@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:53899 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751581Ab0EaS1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 14:27:18 -0400
In-Reply-To: <1275323499-15543-1-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Anatolij,

On 05/31/2010 06:31 PM, Anatolij Gustschin wrote:
> Fixes build error caused by the OF device_node pointer
> being moved into struct device.
> 
> Signed-off-by: Anatolij Gustschin <agust@denx.de>
> Cc: Wolfgang Grandegger <wg@grandegger.com>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> ---
>  drivers/net/can/mscan/mpc5xxx_can.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/can/mscan/mpc5xxx_can.c b/drivers/net/can/mscan/mpc5xxx_can.c
> index 8af8442..f48deaf 100644
> --- a/drivers/net/can/mscan/mpc5xxx_can.c
> +++ b/drivers/net/can/mscan/mpc5xxx_can.c
> @@ -152,7 +152,7 @@ static u32 __devinit mpc512x_can_get_clock(struct of_device *ofdev,
>  	}
>  
>  	/* Determine the MSCAN device index from the physical address */
> -	pval = of_get_property(ofdev->node, "reg", &plen);
> +	pval = of_get_property(ofdev->dev.of_node, "reg", &plen);
>  	BUG_ON(!pval || plen < sizeof(*pval));
>  	clockidx = (*pval & 0x80) ? 1 : 0;
>  	if (*pval & 0x2000)
> @@ -168,11 +168,11 @@ static u32 __devinit mpc512x_can_get_clock(struct of_device *ofdev,
>  	 */
>  	if (clock_name && !strcmp(clock_name, "ip")) {
>  		*mscan_clksrc = MSCAN_CLKSRC_IPS;
> -		freq = mpc5xxx_get_bus_frequency(ofdev->node);
> +		freq = mpc5xxx_get_bus_frequency(ofdev->dev.of_node);
>  	} else {
>  		*mscan_clksrc = MSCAN_CLKSRC_BUS;
>  
> -		pval = of_get_property(ofdev->node,
> +		pval = of_get_property(ofdev->dev.of_node,
>  				       "fsl,mscan-clock-divider", &plen);
>  		if (pval && plen == sizeof(*pval))
>  			clockdiv = *pval;
> @@ -251,7 +251,7 @@ static int __devinit mpc5xxx_can_probe(struct of_device *ofdev,
>  				       const struct of_device_id *id)
>  {
>  	struct mpc5xxx_can_data *data = (struct mpc5xxx_can_data *)id->data;
> -	struct device_node *np = ofdev->node;
> +	struct device_node *np = ofdev->dev.of_node;
>  	struct net_device *dev;
>  	struct mscan_priv *priv;
>  	void __iomem *base;

The patch seems incomplete. I get at least one more warning (because
I'm compiling for 52xx, I guess):

  CC      drivers/net/can/mscan/mpc5xxx_can.o
drivers/net/can/mscan/mpc5xxx_can.c: In function 'mpc52xx_can_get_clock':
drivers/net/can/mscan/mpc5xxx_can.c:76: error: 'struct of_device' has no member named 'node'

Should I send v2? Thanks for fixing that. I also checked the
sja1000_of_platform driver,  which was converted correctly.

Wolfgang.
