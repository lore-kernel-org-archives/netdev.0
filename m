From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v6 05/11] dt-bindings: net: dwmac-sun8i:
 update documentation about integrated PHY
Date: Wed, 4 Oct 2017 21:00:28 +0200
Message-ID: <20171004190028.GA9208@Red>
References: <20170927073414.17361-1-clabbe.montjoie@gmail.com>
 <20170927073414.17361-6-clabbe.montjoie@gmail.com>
 <20170927140210.GE13516@lunn.ch>
 <20170928073708.GB32676@Red>
Reply-To: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: mark.rutland-5wv7dgnIgG8@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
	will.deacon-5wv7dgnIgG8@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
	alexandre.torgue-qxv4g6HH51o@public.gmane.org, frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	wens-jdAy2FN1RRM@public.gmane.org
Return-path: <linux-sunxi+bncBD7YLCN32UNBBVG72THAKGQEDXR3MRI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <20170928073708.GB32676@Red>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On Thu, Sep 28, 2017 at 09:37:08AM +0200, Corentin Labbe wrote:
> On Wed, Sep 27, 2017 at 04:02:10PM +0200, Andrew Lunn wrote:
> > Hi Corentin
> > 
> > > +Required properties for the mdio-mux node:
> > > +  - compatible = "mdio-mux"
> > 
> > This is too generic. Please add a more specific compatible for this
> > particular mux. You can keep "mdio-mux", since that is what the MDIO
> > subsystem will look for.
> > 
> 
> I will add allwinner,sun8i-h3-mdio-mux
> 
> > > +Required properties of the integrated phy node:
> > >  - clocks: a phandle to the reference clock for the EPHY
> > >  - resets: a phandle to the reset control for the EPHY
> > > +- phy-is-integrated
> > 
> > So the last thing you said is that the mux is not the problem
> > here. Something else is locking up. Did you discover what?
> > 
> > I really would like phy-is-integrated to go away.
> > 
> 
> I have found the problem: by enabling ephy clk/reset the timeout does not occur anymore.
> So we could remove phy-is-integrated by:
> Moving internal phy clk/reset handling in mdio_mux_syscon_switch_fn()
> But this means:
> - getting internalphy node always by manually get internal_mdio/internal_phy (and not by the given phyhandle)
> - doing some unnecessary tasks (enable/scan/disable) when external_phy is needed
> 

Hello

I have get rid of phy-is-integrated, but mdio_mux_syscon_switch_fn need to enable/disable ephy clk/reset.
And so access to internal PHY node.
But current DT made this ugly: (need to find mdio-mux then internalmdio then internal PHY)

Since MAC cannot reset/choose internal MDIO without ephy clk/rst, could we interpret this as thoses clk/rst must be set in emac node.
This will simplify a lot the code.

Regards
