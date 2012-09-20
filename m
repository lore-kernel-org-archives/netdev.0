From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2] USB: remove dbg() usage in USB networking drivers
Date: Thu, 20 Sep 2012 11:30:23 +0100
Message-ID: <20120920103023.GA2012@kroah.com>
References: <20120919171316.GA12248@kroah.com>
 <1348077212.22122.13.camel@joe2Laptop>
 <20120919193536.GA13933@kroah.com>
 <20120919194614.GA17585@kroah.com>
 <1348135633.5604.5.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1348135633.5604.5.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 20, 2012 at 03:07:13AM -0700, Joe Perches wrote:
> On Wed, 2012-09-19 at 20:46 +0100, Greg Kroah-Hartman wrote:
> > The dbg() USB macro is so old, it predates me.  The USB networking drivers are
> > the last hold-out using this macro, and we want to get rid of it, so replace
> > the usage of it with the proper netdev_dbg() or dev_dbg() (depending on the
> > context) calls.
> 
> OK, one more bit of trivia
> 
> > diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
> []
> > @@ -422,8 +419,9 @@ static int net1080_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
> >  	if (!(skb->len & 0x01)) {
> >  #ifdef DEBUG
> >  		struct net_device	*net = dev->net;
> > -		dbg("rx framesize %d range %d..%d mtu %d", skb->len,
> > -			net->hard_header_len, dev->hard_mtu, net->mtu);
> > +		netdev_dbg(dev->net, "rx framesize %d range %d..%d mtu %d\n",
> > +			   skb->len, net->hard_header_len, dev->hard_mtu,
> > +			   net->mtu);
> >  #endif
> 
> maybe
> 		netdev_dbg(net, ...
> 
> or remove the odd #ifdef DEBUG surround used to guard
> the otherwise unused net variable and use:
> 
> 		netdev_dbg(dev->net, "rx framesize %d range %d..%d mtu %d\n",
> 			   skb->len, dev->net->hard_header_len, dev->hard_mtu,
> 			   dev->net->mtu);
> 

Yeah, that would be better.

Even better would be just to delete all of this debug crud from these
drivers.  Almost all of the messages are there from when the developer
originally wrote the driver, trying to figure out what was going on.
>From what I have seen, in doing all of these cleanups, is that the need
for maybe a few debug lines that can be used if users have issues, but
the majority are just useless.

But, as I'm not the author or maintainer of these drivers, I'll be nice
and just leave them in, all I want to do is get rid of the old, foolish,
macros for debugging and use the proper dynamic debug code that works so
much better.

So I'll leave this change alone, and if someone wants to do the cleanup
better, the 3 liner above is fine with me to add later.

thanks,

greg k-h
