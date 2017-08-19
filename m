From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH v3 3/4] net: stmmac: register parent MDIO node for
 sun8i-h3-emac
Date: Sat, 19 Aug 2017 20:50:25 +0200
Message-ID: <20170819185025.GB13266@Red>
References: <20170818122118.4925-1-clabbe.montjoie@gmail.com>
 <20170818122118.4925-4-clabbe.montjoie@gmail.com>
 <CAGb2v66KcZkiDDHryMmVzm4WroXePPy3V44SLpVdoO3ZEjgC=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Maxime Ripard <maxime.ripard@free-electrons.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        devicetree <devicetree@vger.kernel.org>,
        linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Chen-Yu Tsai <wens@csie.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAGb2v66KcZkiDDHryMmVzm4WroXePPy3V44SLpVdoO3ZEjgC=g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 19, 2017 at 01:05:21AM +0800, Chen-Yu Tsai wrote:
> On Fri, Aug 18, 2017 at 8:21 PM, Corentin Labbe
> <clabbe.montjoie@gmail.com> wrote:
> > In case of a MDIO switch, the registered MDIO node should be
> > the parent of the PHY. Otherwise of_phy_connect will fail.
> >
> > Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> > ---
> >  drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 12 ++++++++++--
> >  1 file changed, 10 insertions(+), 2 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> > index a366b3747eeb..ca3cc99d8960 100644
> > --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> > +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> > @@ -312,10 +312,12 @@ static int stmmac_dt_phy(struct plat_stmmacenet_data *plat,
> >         static const struct of_device_id need_mdio_ids[] = {
> >                 { .compatible = "snps,dwc-qos-ethernet-4.10" },
> >                 { .compatible = "allwinner,sun8i-a83t-emac" },
> > -               { .compatible = "allwinner,sun8i-h3-emac" },
> >                 { .compatible = "allwinner,sun8i-v3s-emac" },
> >                 { .compatible = "allwinner,sun50i-a64-emac" },
> >         };
> > +       static const struct of_device_id need_mdio_mux_ids[] = {
> > +               { .compatible = "allwinner,sun8i-h3-emac" },
> > +       };
> >
> >         /* If phy-handle property is passed from DT, use it as the PHY */
> >         plat->phy_node = of_parse_phandle(np, "phy-handle", 0);
> > @@ -332,7 +334,13 @@ static int stmmac_dt_phy(struct plat_stmmacenet_data *plat,
> >                 mdio = false;
> >         }
> >
> > -       if (of_match_node(need_mdio_ids, np)) {
> > +       /*
> > +        * In case of a MDIO switch/mux, the registered MDIO node should be
> > +        * the parent of the PHY. Otherwise of_phy_connect will fail.
> > +        */
> > +       if (of_match_node(need_mdio_mux_ids, np)) {
> > +                plat->mdio_node =  of_get_parent(plat->phy_node);
> 
> Extra space before of_get_parent.
> 
> Also this is going to fail horribly if a fixed link is used.
> 

Hello

I will add an extra patch for handling fixed-link for both need_mdio_mux_ids/need_mdio_ids cases.

Thanks
Regards
