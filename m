From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: usbnet: fix oops in usbnet_start_xmit
Date: Thu, 06 Sep 2012 15:10:51 +0200
Message-ID: <25431888.4WZyYrK8zN@linux-lqwf.site>
References: <20111109073459.GA14409@elgon.mountain> <20120906125230.GI19410@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: khlebnikov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120906125230.GI19410@mwanda>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 06 September 2012 05:52:30 Dan Carpenter wrote:
> I sent this email a year ago when the patch was committed but I
> never received a response.

I probably should have checked then.

> regards,
> dan carpenter
> 
> On Wed, Nov 09, 2011 at 10:34:59AM +0300, Dan Carpenter wrote:
> > Hello Konstantin Khlebnikov,
> > 
> > This is a semi-automatic email about new static checker warnings.
> > 
> > The patch 23ba07991dad: "usbnet: fix oops in usbnet_start_xmit" from 
> > Nov 7, 2011, leads to the following Smatch complaint:
> > 
> > drivers/net/usb/usbnet.c +1077 usbnet_start_xmit()
> >        error: we previously assumed 'skb' could be null (see line 1060)
> > 
> > drivers/net/usb/usbnet.c
> >   1059        
> >   1060                if (skb)
> >                     ^^^
> > check introduced here.
> > 
> >   1061                        skb_tx_timestamp(skb);
> >   1062        
> >   1063                // some devices want funky USB-level framing, for
> >   1064                // win32 driver (usually) and/or hardware quirks
> >   1065                if (info->tx_fixup) {
> >   1066                        skb = info->tx_fixup (dev, skb, GFP_ATOMIC);

It turns out that skb == NULL implies info->tx_fixup != NULL
and skb will be reassigned.
This is very dirty.

	Regards
		Oliver


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
