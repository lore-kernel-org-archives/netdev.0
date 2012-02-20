From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: [PATCH] net/usbnet: avoid recursive locking in usbnet_stop()
Date: Mon, 20 Feb 2012 16:40:49 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1202201638330.13111-100000@netrider.rowland.org>
References: <4F42B4E4.5090100@linutronix.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Sebastian Andrzej Siewior <bigeasy-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F42B4E4.5090100-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Feb 2012, Sebastian Andrzej Siewior wrote:

> > What's the issue here?
> >
> > If a driver calls usb_unlink_urb() while holding a lock, and the
> > completion routine tries to acquire the same lock, then deadlock is
> > possible.  The fact that usb_unlink_urb() is asynchronous is not a
> > guarantee of anything; the HCD is allowed to call the completion
> > handler from within usb_unlink_urb().
> >
> > It's true that the kerneldoc for usb_unlink_urb() says "This request is
> > always asynchronous".  It might be a good idea to remove the word
> > "always", because it seems to give people the wrong idea.
> 
> I see. So you approve that patch and suggest to remove the "always"
> wording plus adding something like "the hcd might call complete routine
> during unlink" ?

Well, I haven't read the patch and don't really understand what issue 
it tries to solve.  But if that issue is the one I talked about above 
then yes, it makes sense.  And changing the documentation as you 
suggest would be a good thing to do in any case.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
