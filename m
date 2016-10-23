From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH v4 01/10] ethernet: add sun8i-emac driver
Date: Sun, 23 Oct 2016 10:55:39 +0200
Message-ID: <20161023085539.GB9001@Red>
References: <1475828757-926-1-git-send-email-clabbe.montjoie@gmail.com>
 <1475828757-926-2-git-send-email-clabbe.montjoie@gmail.com>
 <1475852559.1945.2.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, davem@davemloft.net, f.fainelli@gmail.com,
        andrew@lunn.ch, netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1475852559.1945.2.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 07, 2016 at 08:02:39AM -0700, Joe Perches wrote:
> On Fri, 2016-10-07 at 10:25 +0200, Corentin Labbe wrote:
> > This patch add support for sun8i-emac ethernet MAC hardware.
> > It could be found in Allwinner H3/A83T/A64 SoCs.
> 
> trivial notes:
> 
> > diff --git a/drivers/net/ethernet/allwinner/sun8i-emac.c b/drivers/net/ethernet/allwinner/sun8i-emac.c
> []
> > +static const char const estats_str[][ETH_GSTRING_LEN] = {
> 
> one too many const
> 
> > +/* MAGIC value for knowing if a descriptor is available or not */
> > +#define DCLEAN cpu_to_le32(BIT(16) | BIT(14) | BIT(12) | BIT(10) | BIT(9))
> 
> Aren't there #defines for these bits?
> 
> > +static void sun8i_emac_flow_ctrl(struct sun8i_emac_priv *priv, int duplex,
> > +				 int fc)
> > +{
> > +	u32 flow = 0;
> > +
> > +	flow = readl(priv->base + EMAC_RX_CTL0);
> > +	if (fc & EMAC_FLOW_RX)
> > +		flow |= BIT(16);
> > +	else
> > +		flow &= ~BIT(16);
> > +	writel(flow, priv->base + EMAC_RX_CTL0);
> > +
> > +	flow = readl(priv->base + EMAC_TX_FLOW_CTL);
> > +	if (fc & EMAC_FLOW_TX)
> > +		flow |= BIT(0);
> > +	else
> > +		flow &= ~BIT(0);
> 
> more magic bits that could be #defines
> 
> > +static int sun8i_emac_rx_from_ddesc(struct net_device *ndev, int i)
> > +{
> > []
> > +	/* the checksum or length of received frame's payload is wrong*/
> > +	if (dstatus & BIT(0)) {
> []
> > +	if (dstatus & BIT(1)) {
> []
> > +	if ((dstatus & BIT(3))) {
> 
> etc...

Thanks for the review, I will fix all thoses issue.

Regards
Corentin Labbe
