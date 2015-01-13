From: "Mark A. Greer" <mgreer@animalcreek.com>
Subject: Re: [PATCH 2/6] net: davinci_emac: Fix runtime pm calls for
 davinci_emac
Date: Tue, 13 Jan 2015 16:42:36 -0700
Message-ID: <20150113234236.GA3921@animalcreek.com>
References: <1421177368-19756-1-git-send-email-tony@atomide.com>
 <1421177368-19756-3-git-send-email-tony@atomide.com>
 <20150113195141.GT16533@saruman>
 <20150113205439.GK2419@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Felipe Balbi <balbi@ti.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	Brian Hutchinson <b.hutchman@gmail.com>
To: Tony Lindgren <tony@atomide.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150113205439.GK2419@atomide.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 13, 2015 at 12:54:40PM -0800, Tony Lindgren wrote:
> * Felipe Balbi <balbi@ti.com> [150113 11:55]:
> > On Tue, Jan 13, 2015 at 11:29:24AM -0800, Tony Lindgren wrote:
> > > --- a/drivers/net/ethernet/ti/davinci_emac.c
> > > +++ b/drivers/net/ethernet/ti/davinci_emac.c
> > > @@ -1538,7 +1538,7 @@ static int emac_dev_open(struct net_device *ndev)
> > >  	int i = 0;
> > >  	struct emac_priv *priv = netdev_priv(ndev);
> > >  
> > > -	pm_runtime_get(&priv->pdev->dev);
> > > +	pm_runtime_get_sync(&priv->pdev->dev);
> > 
> > gotta check return value on all pm_runtime_get_sync() calls. IIRC,
> > there's a coccinelle script for checking and patching this.
> 
> Sure, here's an updated patch with error checking added.
> 
> Regards,
> 
> Tony
> 
> 8< ---------------------
> From: Tony Lindgren <tony@atomide.com>
> Date: Mon, 22 Dec 2014 08:19:06 -0800
> Subject: [PATCH] net: davinci_emac: Fix runtime pm calls for davinci_emac
> 
> Commit 3ba97381343b ("net: ethernet: davinci_emac: add pm_runtime support")
> added support for runtime PM, but it causes issues on omap3 related devices
> that actually gate the clocks:
> 
> Unhandled fault: external abort on non-linefetch (0x1008)
> ...
> [<c04160f0>] (emac_dev_getnetstats) from [<c04d6a3c>] (dev_get_stats+0x78/0xc8)
> [<c04d6a3c>] (dev_get_stats) from [<c04e9ccc>] (rtnl_fill_ifinfo+0x3b8/0x938)
> [<c04e9ccc>] (rtnl_fill_ifinfo) from [<c04eade4>] (rtmsg_ifinfo+0x68/0xd8)
> [<c04eade4>] (rtmsg_ifinfo) from [<c04dd35c>] (register_netdevice+0x3a0/0x4ec)
> [<c04dd35c>] (register_netdevice) from [<c04dd4bc>] (register_netdev+0x14/0x24)
> [<c04dd4bc>] (register_netdev) from [<c041755c>] (davinci_emac_probe+0x408/0x5c8)
> [<c041755c>] (davinci_emac_probe) from [<c0396d78>] (platform_drv_probe+0x48/0xa4)
> 
> Let's fix it by moving the pm_runtime_get() call earlier, and also add it to
> the emac_dev_getnetstats(). Also note that we want to use pm_runtime_get_sync()
> as we don't want to have deferred_resume happen. And let's also check the
> return value for pm_runtime_get_sync() as noted by Felipe Balbi <balbi@ti.com>.
> 
> Cc: Brian Hutchinson <b.hutchman@gmail.com>
> Cc: Felipe Balbi <balbi@ti.com>
> Cc: Mark A. Greer <mgreer@animalcreek.com>
> Signed-off-by: Tony Lindgren <tony@atomide.com>

Tony,

Sorry for the sloppy pm_runtime patch and thanks for fixing it.

Acked-by: Mark A. Greer <mgreer@animalcreek.com>
