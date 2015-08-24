From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: [PATCH] usbnet: Fix two races between usbnet_stop() and the BH
Date: Mon, 24 Aug 2015 14:06:15 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1508241403100.5935-100000@iolanthe.rowland.org>
References: <20150824.104328.554582952440857559.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eugene.shatokhin-irhHPgl+04UvJsYlp49lxw@public.gmane.org, <bjorn-yOkvZcmFvRU@public.gmane.org>, <oneukum-IBi9RG/b67k@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150824.104328.554582952440857559.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 24 Aug 2015, David Miller wrote:

> From: Eugene Shatokhin <eugene.shatokhin-irhHPgl+04UvJsYlp49lxw@public.gmane.org>
> Date: Wed, 19 Aug 2015 14:59:01 +0300
> 
> > So the following might be possible, although unlikely:
> > 
> > CPU0             CPU1
> >                  clear_bit: read dev->flags
> >                  clear_bit: clear EVENT_RX_KILL in the read value
> > 
> > dev->flags=0;
> > 
> >                  clear_bit: write updated dev->flags
> > 
> > As a result, dev->flags may become non-zero again.
> 
> Is this really possible?
> 
> Stores really are "atomic" in the sense that the do their update
> in one indivisible operation.

Provided you use ACCESS_ONCE or WRITE_ONCE or whatever people like to 
call it now.

> Atomic operations like clear_bit also will behave that way.

Are you certain about that?  I couldn't find any mention of it in
Documentation/atomic_ops.txt.

In theory, an architecture could implement atomic bit operations using 
a spinlock to insure atomicity.  I don't know if any architectures do 
this, but if they do then the scenario above could arise.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
