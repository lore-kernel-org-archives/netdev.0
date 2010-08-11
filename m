From: Greg KH <greg@kroah.com>
Subject: Re: arp_notify: allow drivers to explicitly request a notification
 event.
Date: Wed, 11 Aug 2010 12:39:59 -0700
Message-ID: <20100811193959.GA9470@kroah.com>
References: <20100811193925.GA9452@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:55350 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756387Ab0HKTkG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Aug 2010 15:40:06 -0400
Content-Disposition: inline
In-Reply-To: <20100811193925.GA9452@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 11, 2010 at 12:39:25PM -0700, Greg KH wrote:
> Wait, Ian, are you sure this patch is correct?  Look below in
> notifier.h:
> 
> On Wed, May 26, 2010 at 12:09:42AM +0000, Ian Campbell wrote:
> > From: Ian Campbell <Ian.Campbell@citrix.com>
> > 
> > commit 06c4648d46d1b757d6b9591a86810be79818b60c upstream.
> > 
> > Currently such notifications are only generated when the device comes up or the
> > address changes. However one use case for these notifications is to enable
> > faster network recovery after a virtual machine migration (by causing switches
> > to relearn their MAC tables). A migration appears to the network stack as a
> > temporary loss of carrier and therefore does not trigger either of the current
> > conditions. Rather than adding carrier up as a trigger (which can cause issues
> > when interfaces a flapping) simply add an interface which the driver can use
> > to explicitly trigger the notification.
> > 
> > Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> > Cc: Stephen Hemminger <shemminger@linux-foundation.org>
> > Cc: Jeremy Fitzhardinge <jeremy@goop.org>
> > Cc: David S. Miller <davem@davemloft.net>
> > Cc: netdev@vger.kernel.org
> > Signed-off-by: David S. Miller <davem@davemloft.net>
> > Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
> > 
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -1772,6 +1772,8 @@ extern void netif_carrier_on(struct net_device *dev);
> >  
> >  extern void netif_carrier_off(struct net_device *dev);
> >  
> > +extern void netif_notify_peers(struct net_device *dev);
> > +
> >  /**
> >   *	netif_dormant_on - mark device as dormant.
> >   *	@dev: network device
> > diff --git a/include/linux/notifier.h b/include/linux/notifier.h
> > index 540703b..22c2abb 100644
> > --- a/include/linux/notifier.h
> > +++ b/include/linux/notifier.h
> > @@ -210,6 +210,7 @@ static inline int notifier_to_errno(int ret)
> >  #define NETDEV_POST_INIT	0x0010
> >  #define NETDEV_UNREGISTER_BATCH 0x0011
> >  #define NETDEV_BONDING_DESLAVE  0x0012
> > +#define NETDEV_NOTIFY_PEERS	0x0012
> 
> Are you sure that you can duplicate this value?

Oh nevermind, David already fixed this up with commit
38117d1495e587fbb10d6e55733139a27893cef5

I'll go queue that up for -stable as well :)

thanks,

greg k-h
