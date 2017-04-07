From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 02/20] net: stmmac: add optional setup function
Date: Fri, 7 Apr 2017 14:51:38 +0200
Message-ID: <20170407125138.GC15546@Red>
References: <20170403091444.29876-1-clabbe.montjoie@gmail.com>
 <20170403091444.29876-3-clabbe.montjoie@gmail.com>
 <262f763b-d158-dd77-3dba-1d7b90a1eef9@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
        will.deacon-5wv7dgnIgG8@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <262f763b-d158-dd77-3dba-1d7b90a1eef9-qxv4g6HH51o@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 03, 2017 at 02:32:33PM +0200, Giuseppe CAVALLARO wrote:
> Hello Corentin
> 
> On 4/3/2017 11:14 AM, Corentin Labbe wrote:
> > Instead of adding more ifthen logic for adding a new mac_device_info
> > setup function, it is easier to add a function pointer to the function
> > needed.
> >
> > Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > ---
> >   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 4 +++-
> >   include/linux/stmmac.h                            | 3 +++
> >   2 files changed, 6 insertions(+), 1 deletion(-)
> >
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> > index 43361f3..3beca41 100644
> > --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> > +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> > @@ -3508,7 +3508,9 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
> >   	struct mac_device_info *mac;
> >   
> >   	/* Identify the MAC HW device */
> > -	if (priv->plat->has_gmac) {
> > +	if (priv->plat->setup) {
> > +		mac = priv->plat->setup(priv);
> > +	} else if (priv->plat->has_gmac) {
> >   		priv->dev->priv_flags |= IFF_UNICAST_FLT;
> >   		mac = dwmac1000_setup(priv->ioaddr,
> >   				      priv->plat->multicast_filter_bins,
> > diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
> > index 3921cb9..dadd74b 100644
> > --- a/include/linux/stmmac.h
> > +++ b/include/linux/stmmac.h
> > @@ -144,6 +144,8 @@ struct stmmac_txq_cfg {
> >   	u32 prio;
> >   };
> >   
> > +struct stmmac_priv;
> > +
> >   struct plat_stmmacenet_data {
> >   	int bus_id;
> >   	int phy_addr;
> > @@ -177,6 +179,7 @@ struct plat_stmmacenet_data {
> >   	void (*fix_mac_speed)(void *priv, unsigned int speed);
> >   	int (*init)(struct platform_device *pdev, void *priv);
> >   	void (*exit)(struct platform_device *pdev, void *priv);
> > +	struct mac_device_info *(*setup)(struct stmmac_priv *priv);
> 
> In that case  I prefer to have void *priv as done for the other callbacks.
> I mean, keep the priv struct inside the driver part.
> 


Agree, I will change it

Thanks
Regards
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
