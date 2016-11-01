From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/4] net: ethernet: ti: cpsw: fix device and
 of_node leaks
Date: Tue, 01 Nov 2016 12:48:48 -0400 (EDT)
Message-ID: <20161101.124848.1812844488411463169.davem@davemloft.net>
References: <1477998217-30143-3-git-send-email-johan@kernel.org>
        <20161101.122711.1685573538225505004.davem@davemloft.net>
        <20161101164225.GC2664@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, mugunthanvnm@ti.com, yisen.zhuang@huawei.com,
        salil.mehta@huawei.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: johan@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161101164225.GC2664@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johan Hovold <johan@kernel.org>
Date: Tue, 1 Nov 2016 17:42:25 +0100

> On Tue, Nov 01, 2016 at 12:27:11PM -0400, David Miller wrote:
>> From: Johan Hovold <johan@kernel.org>
>> Date: Tue,  1 Nov 2016 12:03:35 +0100
>> 
>> > diff --git a/drivers/net/ethernet/ti/cpsw-phy-sel.c b/drivers/net/ethernet/ti/cpsw-phy-sel.c
>> > index 054a8dd23dae..589beb843f56 100644
>> > --- a/drivers/net/ethernet/ti/cpsw-phy-sel.c
>> > +++ b/drivers/net/ethernet/ti/cpsw-phy-sel.c
>> > @@ -176,8 +176,11 @@ void cpsw_phy_sel(struct device *dev, phy_interface_t phy_mode, int slave)
>> >  	}
>> >  
>> >  	dev = bus_find_device(&platform_bus_type, NULL, node, match);
>> > +	of_node_put(node);
>> >  	priv = dev_get_drvdata(dev);
>> >  
>> > +	put_device(dev);
>> > +
>> >  	priv->cpsw_phy_sel(priv, phy_mode, slave);
>> >  }
>> >  EXPORT_SYMBOL_GPL(cpsw_phy_sel);
>> 
>> The only reference you have to 'dev' is the one obtained from the
>> bus_find_device() call, therefore you must at least hold onto
>> 'dev' until after the priv->cpsw_phy_sel(priv, phy_mode, slave); call.
> 
> As I mentioned in the commit message "...there is no guarantee that the
> devres-managed struct cpsw_phy_sel_priv will continue to be valid until
> this function returns regardless of this change".
> 
> Specifically, holding a reference to dev does not prevent the
> cpsw_phy_sel driver from being unbound and priv from being freed.

But you should at least hold onto the object while you call a function
pointer embedded in a data structure referred by it.
