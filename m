From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 02/11] ixgb: Fix the use of dprintk rather than printk
Date: Mon, 24 Apr 2006 10:24:16 -0700
Message-ID: <20060424102416.27b20559@localhost.localdomain>
References: <20060422010016.24255.50772.stgit@jk-desktop.jf.intel.com>
	<20060422010034.24255.21136.stgit@jk-desktop.jf.intel.com>
	<20060422090301.GB26666@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	John Rociak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:726 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750991AbWDXRZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2006 13:25:03 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060422090301.GB26666@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 22 Apr 2006 11:03:01 +0200
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Jeff Kirsher <jeffrey.t.kirsher@intel.com> :
> [...]
> > diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
> > index c83271b..a696c33 100644
> > --- a/drivers/net/ixgb/ixgb.h
> > +++ b/drivers/net/ixgb/ixgb.h
> [...]
> > @@ -192,6 +197,7 @@ struct ixgb_adapter {
> >  
> >  	/* structs defined in ixgb_hw.h */
> >  	struct ixgb_hw hw;
> > +	u16 msg_enable;
> >  	struct ixgb_hw_stats stats;
> >  #ifdef CONFIG_PCI_MSI
> >  	boolean_t have_msi;
> > diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
> > index d38ade5..e8d83de 100644
> > --- a/drivers/net/ixgb/ixgb_ethtool.c
> > +++ b/drivers/net/ixgb/ixgb_ethtool.c
> > @@ -251,6 +251,20 @@ ixgb_set_tso(struct net_device *netdev, 
> >  } 
> >  #endif /* NETIF_F_TSO */
> >  
> > +static uint32_t
> > +ixgb_get_msglevel(struct net_device *netdev)
> > +{
> > +	struct ixgb_adapter *adapter = netdev->priv;
> > +	return adapter->msg_enable;
> > +}
> > +
> > +static void
> > +ixgb_set_msglevel(struct net_device *netdev, uint32_t data)
> > +{
> > +	struct ixgb_adapter *adapter = netdev->priv;
> > +	adapter->msg_enable = data;
> > +}
> > +
> 
> Minor nits:
> - you may consider removing the u{8/16/32} in drivers/net/ixgb
>   for consistency sake in a different patch (there is a strong
>   majority of uint_something in the driver).


All the uint32_t should be removed.  Kernel style is u32.
