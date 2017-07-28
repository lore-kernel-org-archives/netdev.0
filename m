From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/3] net-next: stmmac: dwmac-sun8i: choose
 internal PHY via compatible
Date: Fri, 28 Jul 2017 11:54:27 +0200
Message-ID: <20170728095427.GA31579@Red>
References: <20170728092818.23419-1-clabbe.montjoie@gmail.com>
 <20170728092818.23419-4-clabbe.montjoie@gmail.com>
 <CAGb2v64w-KCmYExN7OqvuLj42-pHN-BN5iKpxA+KW84v+RfCDQ@mail.gmail.com>
Reply-To: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
	Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	alexandre.torgue-qxv4g6HH51o@public.gmane.org, Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
To: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Return-path: <linux-sunxi+bncBD7YLCN32UNBBYET5TFQKGQEBPCM36Y-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <CAGb2v64w-KCmYExN7OqvuLj42-pHN-BN5iKpxA+KW84v+RfCDQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2017 at 05:49:55PM +0800, Chen-Yu Tsai wrote:
> On Fri, Jul 28, 2017 at 5:28 PM, Corentin Labbe
> <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > The current way to find if the phy is internal is to compare DT phy-mode
> > and emac_variant/internal_phy.
> > But it will negate a possible future SoC where an external PHY use the
> > same phy mode than the internal one.
> >
> > This patch adds a new way to find if the PHY is internal, via its
> > compatible.
> >
> > Since the phy_mode of the internal PHY does need to be know, the
> > variant internal_phy member is converted to a boolean.
> >
> > Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > ---
> >  drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c | 16 ++++++++++------
> >  1 file changed, 10 insertions(+), 6 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
> > index fffd6d5fc907..04f7ddd802b0 100644
> > --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
> > +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
> > @@ -48,7 +48,7 @@
> >   */
> >  struct emac_variant {
> >         u32 default_syscon_value;
> > -       int internal_phy;
> > +       bool internal_phy;
> 
> Nit: please add a verb to the name, like "has_internal_phy",
> or even "soc_has_internal_phy". This makes it clear what this
> property represents.
> 
> ChenYu

I will use soc_has_internal_phy

Thanks
