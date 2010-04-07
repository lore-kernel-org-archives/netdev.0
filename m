From: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
Subject: RE: [PATCH 1/1] NET: usb: Adding URB_ZERO_PACKET flag to usbnet.c
Date: Wed, 7 Apr 2010 14:13:52 -0700
Message-ID: <1270674832.6401.3.camel@Linuxdev4-laptop>
References: <1270599787.8900.8.camel@Linuxdev4-laptop>
	 <002801cad615$a352f2a0$808918ac@apr.dhcp.ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org" <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Rory Filer <rfiler-usJ8hg9QsBLWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Maulik <x0082077-l0cyMroinI0@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <002801cad615$a352f2a0$808918ac-wD+IZp/g4/2mHdYHvhjUOg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-04-06 at 22:46 -0700, Maulik wrote:
> 
> > -----Original Message-----
> > From: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org [mailto:linux-usb-
> > owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org] On Behalf Of Elina Pasheva
> > Sent: Wednesday, April 07, 2010 5:53 AM
> > To: dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
> > Cc: epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org; rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org;
> > netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > Subject: [PATCH 1/1] NET: usb: Adding URB_ZERO_PACKET flag to usbnet.c
> > 
> > Subject: [PATCH 1/1] NET: usb: Adding URB_ZERO_PACKET flag to usbnet.c
> > From: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
> > This patch adds setting of the urb transfer flag URB_ZERO_PACKET  before
> > submitting an urb for drivers that have requested it (by advertising flag
> > FLAG_SEND_ZLP).
> > The modification is in usbnet.c function usbnet_start_xmit().
> > This patch only adds the zero length flag.
> > A subsequent patch will address the buggy code we found when devices do
> > not
> > advertise FLAG_SEND_ZLP in which case there is a possibility of
> > transferring
> > packets with non-deterministic length.
> > 
> > This patch has been tested on kernel-2.6.34-rc3.
> > This patch has been checked against net-2.6 tree.
> > Signed-off-by: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
> > Signed-off-by: Rory Filer <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
> > ---
> > 
> >  drivers/net/usb/usbnet.c |   15 +++++++++------
> >  1 file changed, 9 insertions(+), 6 deletions(-)
> > 
> > --- a/drivers/net/usb/usbnet.c	2010-04-06 10:52:54.000000000 -0700
> > +++ b/drivers/net/usb/usbnet.c	2010-04-06 16:54:44.000000000 -0700
> > @@ -1068,12 +1068,15 @@ netdev_tx_t usbnet_start_xmit (struct sk
> >  	 * NOTE:  strictly conforming cdc-ether devices should expect
> >  	 * the ZLP here, but ignore the one-byte packet.
> >  	 */
> > -	if (!(info->flags & FLAG_SEND_ZLP) && (length % dev->maxpacket) ==
> > 0) {
> > -		urb->transfer_buffer_length++;
> > -		if (skb_tailroom(skb)) {
> > -			skb->data[skb->len] = 0;
> > -			__skb_put(skb, 1);
> > -		}
> > +	if (length % dev->maxpacket == 0) {
> > +		if (!(info->flags & FLAG_SEND_ZLP)) {
> > +			urb->transfer_buffer_length++;
> > +			if (skb_tailroom(skb)) {
> > +				skb->data[skb->len] = 0;
> > +				__skb_put(skb, 1);
> > +			}
> > +		} else
> > +			urb->transfer_flags |= URB_ZERO_PACKET;
> 
> You should place braces for the else case as well. See
> Documentation/CodingStyle.
> 
> It states to use braces in both the branches since the if() case 
> contains multiple statements. 
> 
> Maulik

Thanks for your review.
The patch has been applied. 
We'll look at it next time.

Elina

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
