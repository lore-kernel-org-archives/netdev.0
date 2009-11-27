From: "Patrick Mullaney" <pmullaney@novell.com>
Subject: Re: [PATCH 1/3] netdevice: provide common routine for macvlan
	 and vlan operstate management
Date: Fri, 27 Nov 2009 10:06:37 -0700
Message-ID: <4B0FA4AD020000C70007B9AE@soto.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <bridge@lists.linux-foundation.org>,
	<alacrityvm-devel@lists.sourceforge.net>, <kaber@trash.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks. I'll post an updated patch.

On Fri, 2009-11-27 at 14:09 +0100, Arnd Bergmann wrote:
> On Friday 13 November 2009, Patrick Mullaney wrote:
> > @@ -551,7 +532,7 @@ static int macvlan_newlink(struct net_device *dev,
> >                 return err;
> >  
> >         list_add_tail(&vlan->list, &port->vlans);
> > -       macvlan_transfer_operstate(dev);
> > +       netif_stacked_transfer_operstate(dev, lowerdev);
> >         return 0;
> >  }
> >  
> > @@ -591,7 +572,8 @@ static int macvlan_device_event(struct notifier_block *unused,
> >         switch (event) {
> >         case NETDEV_CHANGE:
> >                 list_for_each_entry(vlan, &port->vlans, list)
> > -                       macvlan_transfer_operstate(vlan->dev);
> > +                       netif_stacked_transfer_operstate(vlan->dev,
> > +                                                        vlan->lowerdev);
> >                 break;
> >         case NETDEV_FEAT_CHANGE:
> >                 list_for_each_entry(vlan, &port->vlans, list) {
> 
> These have the arguments reversed, lowerdev should come first.
> 
> 	Arnd <><

