From: Johan Hovold <johan@kernel.org>
Subject: Re: [PATCH net 2/4] net: ethernet: ti: cpsw: fix device and of_node
 leaks
Date: Tue, 1 Nov 2016 17:42:25 +0100
Message-ID: <20161101164225.GC2664@localhost>
References: <1477998217-30143-1-git-send-email-johan@kernel.org>
 <1477998217-30143-3-git-send-email-johan@kernel.org>
 <20161101.122711.1685573538225505004.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johan@kernel.org, f.fainelli@gmail.com, mugunthanvnm@ti.com,
        yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161101.122711.1685573538225505004.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 01, 2016 at 12:27:11PM -0400, David Miller wrote:
> From: Johan Hovold <johan@kernel.org>
> Date: Tue,  1 Nov 2016 12:03:35 +0100
> 
> > diff --git a/drivers/net/ethernet/ti/cpsw-phy-sel.c b/drivers/net/ethernet/ti/cpsw-phy-sel.c
> > index 054a8dd23dae..589beb843f56 100644
> > --- a/drivers/net/ethernet/ti/cpsw-phy-sel.c
> > +++ b/drivers/net/ethernet/ti/cpsw-phy-sel.c
> > @@ -176,8 +176,11 @@ void cpsw_phy_sel(struct device *dev, phy_interface_t phy_mode, int slave)
> >  	}
> >  
> >  	dev = bus_find_device(&platform_bus_type, NULL, node, match);
> > +	of_node_put(node);
> >  	priv = dev_get_drvdata(dev);
> >  
> > +	put_device(dev);
> > +
> >  	priv->cpsw_phy_sel(priv, phy_mode, slave);
> >  }
> >  EXPORT_SYMBOL_GPL(cpsw_phy_sel);
> 
> The only reference you have to 'dev' is the one obtained from the
> bus_find_device() call, therefore you must at least hold onto
> 'dev' until after the priv->cpsw_phy_sel(priv, phy_mode, slave); call.

As I mentioned in the commit message "...there is no guarantee that the
devres-managed struct cpsw_phy_sel_priv will continue to be valid until
this function returns regardless of this change".

Specifically, holding a reference to dev does not prevent the
cpsw_phy_sel driver from being unbound and priv from being freed.

Thanks,
Johan
