From: Vojtech Pavlik <vojtech@suse.cz>
Subject: Re: [PATCH 22/77] usbnet: convert catc device to net_device_ops
Date: Sat, 21 Mar 2009 14:02:33 +0100
Message-ID: <20090321130233.GA14353@suse.cz>
References: <20090321053527.316395697@vyatta.com> <20090321053714.207963951@vyatta.com> <200903210201.15098.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:51594 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752454AbZCUNCn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 09:02:43 -0400
Content-Disposition: inline
In-Reply-To: <200903210201.15098.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 21, 2009 at 02:01:14AM -0700, David Brownell wrote:
> On Friday 20 March 2009, Stephen Hemminger wrote:
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> OK by me, but I cc'd Vojtech who was the last maintainer of this code.

OK by me, too.

> 
> 
> > --- a/drivers/net/usb/catc.c	2009-03-20 12:10:10.851651580 -0700
> > +++ b/drivers/net/usb/catc.c	2009-03-20 12:10:23.060839265 -0700
> > @@ -743,6 +743,18 @@ static int catc_stop(struct net_device *
> >  	return 0;
> >  }
> >  
> > +static const struct net_device_ops catc_netdev_ops = {
> > +	.ndo_open		= catc_open,
> > +	.ndo_stop		= catc_stop,
> > +	.ndo_start_xmit		= catc_start_xmit,
> > +
> > +	.ndo_tx_timeout		= catc_tx_timeout,
> > +	.ndo_set_multicast_list = catc_set_multicast_list,
> > +	.ndo_change_mtu		= eth_change_mtu,
> > +	.ndo_set_mac_address 	= eth_mac_addr,
> > +	.ndo_validate_addr	= eth_validate_addr,
> > +};
> > +
> >  /*
> >   * USB probe, disconnect.
> >   */
> > @@ -767,12 +779,8 @@ static int catc_probe(struct usb_interfa
> >  
> >  	catc = netdev_priv(netdev);
> >  
> > -	netdev->open = catc_open;
> > -	netdev->hard_start_xmit = catc_hard_start_xmit;
> > -	netdev->stop = catc_stop;
> > -	netdev->tx_timeout = catc_tx_timeout;
> > +	netdev->netdev_ops = &catc_netdev_ops;
> >  	netdev->watchdog_timeo = TX_TIMEOUT;
> > -	netdev->set_multicast_list = catc_set_multicast_list;
> >  	SET_ETHTOOL_OPS(netdev, &ops);
> >  
> >  	catc->usbdev = usbdev;
> > 
> > -- 
> > 
> > 
> 
> 

-- 
Vojtech Pavlik
Director SuSE Labs
