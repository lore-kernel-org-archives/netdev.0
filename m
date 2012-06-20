From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH -v1 3/3] usbnet: handle remote wakeup asap
Date: Wed, 20 Jun 2012 13:24:00 +0200
Message-ID: <201206201324.00338.oneukum@suse.de>
References: <1340176553-32225-1-git-send-email-ming.lei@canonical.com> <1340176553-32225-4-git-send-email-ming.lei@canonical.com> <4FE1ADB4.4060302@mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Greg Kroah-Hartman" <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sergei Shtylyov <sshtylyov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4FE1ADB4.4060302-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 20. Juni 2012, 13:02:12 schrieb Sergei Shtylyov:
> > Without the patch, usbnet can't recieve any packets from peer
> > in runtime suspend state if runtime PM is enabled and
> > autosuspend_delay is set as zero.
> 
> > Signed-off-by: Ming Lei<ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> > ---
> >   drivers/net/usb/usbnet.c |   42 ++++++++++++++++++++++++++----------------
> >   1 file changed, 26 insertions(+), 16 deletions(-)
> 
> > diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> > index 9bfa775..a89d6c5 100644
> > --- a/drivers/net/usb/usbnet.c
> > +++ b/drivers/net/usb/usbnet.c
> > @@ -1201,6 +1201,21 @@ deferred:
> >   }
> >   EXPORT_SYMBOL_GPL(usbnet_start_xmit);
> >
> > +static void rx_alloc_submit(struct usbnet *dev, gfp_t flags)
> > +{
> > +     struct urb      *urb;
> > +     int             i;
> > +
> > +     /* don't refill the queue all at once */
> > +     for (i = 0; i<  10&&  dev->rxq.qlen<  RX_QLEN(dev); i++) {
> > +             urb = usb_alloc_urb(0, flags);
> > +             if (urb != NULL) {
> > +                     if (rx_submit(dev, urb, flags) == -ENOLINK)
> 
>     The above 2 if statements can be collapsed into single one.
> 

That would not improve readability.

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
