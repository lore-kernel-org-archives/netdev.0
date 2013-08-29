From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: Re: [net-next v2 1/2] vxlan: Notify drivers for listening UDP port
 changes
Date: Thu, 29 Aug 2013 12:55:59 -0700 (PDT)
Message-ID: <alpine.LFD.2.03.1308291254290.25550@intel.com>
References: <1377780878-32384-1-git-send-email-jeffrey.t.kirsher@intel.com> <1377801778.5372.8.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30030 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755556Ab3H2TlG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 15:41:06 -0400
In-Reply-To: <1377801778.5372.8.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 29 Aug 2013, Ben Hutchings wrote:

> On Thu, 2013-08-29 at 05:54 -0700, Jeff Kirsher wrote:
> > From: Joseph Gasparakis <joseph.gasparakis@intel.com>
> > 
> > This patch adds two more ndo ops: ndo_add_rx_vxlan_port() and
> > ndo_del_rx_vxlan_port().
> [...]
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -948,6 +948,18 @@ struct netdev_phys_port_id {
> >   *	Called to get ID of physical port of this device. If driver does
> >   *	not implement this, it is assumed that the hw is not able to have
> >   *	multiple net devices on single physical port.
> > + *
> > + * int (*ndo_add_vxlan_port)(struct  net_device *dev,
> > + *			      __u16 port);
> > + *	Called by vxlan to notiy a driver about the UDP port that vxlan
> > + *	is listnening to. It is called only when a new port starts listening.
> > + *	The operation is protected by the vxlan_net->sock_lock.
> > + *
> > + * int (*ndo_del_vxlan_port)(struct  net_device *dev,
> > + *			    __u16 port);
> > + *	Called by vxlan to notify the driver about a UDP port of vxlan
> > + *	that is not listening anymore. The operation is protected by
> > + *	the vxlan_net->sock_lock.
> >   */
> >  struct net_device_ops {
> >  	int			(*ndo_init)(struct net_device *dev);
> > @@ -1078,6 +1090,10 @@ struct net_device_ops {
> >  						      bool new_carrier);
> >  	int			(*ndo_get_phys_port_id)(struct net_device *dev,
> >  							struct netdev_phys_port_id *ppid);
> > +	int			(*ndo_add_vxlan_port)(struct  net_device *dev,
> > +						      __u16 port);
> > +	int			(*ndo_del_vxlan_port)(struct  net_device *dev,
> > +						      __u16 port);
> >  };
> [...]
> 
> I notice these are defined to return int, but the callers don't check
> the return value.  Should they return void or do the callers need some
> error handling?
> 
> Ben.
> 
> 
You are right Ben, these should be defined to return void. Will fix that 
asap.

Joseph
