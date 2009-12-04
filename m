From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] virtio_net: add more ethtool information
Date: Thu, 3 Dec 2009 16:33:10 -0800
Message-ID: <20091203163310.1553689e@nehalam>
References: <20091203063225.926337440@vyatta.com>
	<20091203063311.902077645@vyatta.com>
	<200912041032.23865.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alex Williamson <alex.williamson@hp.com>,
	netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46494 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752187AbZLDAdP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2009 19:33:15 -0500
In-Reply-To: <200912041032.23865.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 4 Dec 2009 10:32:23 +1030
Rusty Russell <rusty@rustcorp.com.au> wrote:

> On Thu, 3 Dec 2009 05:02:26 pm Stephen Hemminger wrote:
> > It is useful for some tools (as well as bonding, and bridging)
> > for virtio network interface provide more ethtool information.
> 
> Hi Stephen,
> 
>     Can't see any harm.  Some minor questions below:
> 
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > --- a/drivers/net/virtio_net.c	2009-12-01 14:24:14.766450584 -0800
> > +++ b/drivers/net/virtio_net.c	2009-12-01 16:49:18.295535415 -0800
> > @@ -763,7 +763,36 @@ static void virtnet_vlan_rx_kill_vid(str
> >  		dev_warn(&dev->dev, "Failed to kill VLAN ID %d.\n", vid);
> >  }
> >  
> > +static void virtnet_get_drvinfo(struct net_device *dev,
> > +				struct ethtool_drvinfo *info)
> > +{
> > +	struct virtnet_info *vi = netdev_priv(dev);
> > +
> > +	strcpy(info->driver, "virtnet");
> > +	strcpy(info->version, "0.1");
> > +	strcpy(info->fw_version, "N/A");
> > +	strcpy(info->bus_info, dev_driver_string(&vi->vdev->dev));
> 
> 0.1 as a version is weird.  If we need a number, "0" seems best.
> 
> > +	cmd->speed = SPEED_1000;
> 
> Why 1000?  Because it's commong?  How about a SPEED_UNLIMITED?
> 

Well until the performance is improved, that is about what I see!
