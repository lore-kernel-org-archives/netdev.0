From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: [PATCH 01/12] usbnet: introduce usbnet 3 command helpers
Date: Fri, 12 Oct 2012 11:18:35 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1210121115080.1605-100000@iolanthe.rowland.org>
References: <CACVXFVPdOkvKBBrshnmQv5cYVdDhi8j0V_WxNwBU9VuDsCLkXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVPdOkvKBBrshnmQv5cYVdDhi8j0V_WxNwBU9VuDsCLkXA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 12 Oct 2012, Ming Lei wrote:

> > probably easiest for the runtime PM core to use tsk_set_allowd_gfp()
> > before calling any runtime_resume method.
> 
> Yes, it might be done in usb runtime resume context because all
> usb device might include a mass storage interface. But, in fact,
> we can find if there is one mass storage interface on the current
> configuration easily inside usb_runtime_resume().
> 
> Also, we can loose the constraint in runtime PM core, before calling
> runtime_resume callback for one device, the current context is marked
> as ~GFP_IOFS only if it is a block device or there is one block device
> descendant. But the approach becomes a bit complicated because
> device tree traversing is involved.

Exactly.  It's much easier just to do it always.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
