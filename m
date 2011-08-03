From: Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Subject: RE: [PATCH ] cdc_ncm: fixes for big-endian architecture / MIPS
Date: Wed, 3 Aug 2011 13:13:08 +0200
Message-ID: <2AC7D4AD8BA1C640B4C60C61C8E520153E3DEF6B0D@EXDCVYMBSTM006.EQ1STM.local>
References: <1312302026-7077-1-git-send-email-alexey.orishko@stericsson.com>
 <20110803.034253.417905916118311130.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org" <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"gregkh-l3A5Bk7waGM@public.gmane.org" <gregkh-l3A5Bk7waGM@public.gmane.org>,
	"alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110803.034253.417905916118311130.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Miller [mailto:davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org]
> Sent: Wednesday, August 03, 2011 12:43 PM
> To: alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org; linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> gregkh-l3A5Bk7waGM@public.gmane.org; Alexey ORISHKO
> Subject: Re: [PATCH ] cdc_ncm: fixes for big-endian architecture / MIPS
> 
> From: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Tue,  2 Aug 2011 18:20:26 +0200
> 
> > @@ -203,8 +203,8 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
> >  	req.bmRequestType = USB_TYPE_CLASS | USB_DIR_IN | USB_RECIP_INTERFACE;
> >  	req.bNotificationType = USB_CDC_GET_NTB_PARAMETERS;
> >  	req.wValue = 0;
> > -	req.wIndex = cpu_to_le16(iface_no);
> > -	req.wLength = cpu_to_le16(sizeof(ctx->ncm_parm));
> > +	req.wIndex = iface_no;
> > +	req.wLength = sizeof(ctx->ncm_parm);
> >
> >  	err = cdc_ncm_do_request(ctx, &req, &ctx->ncm_parm, 0, NULL, 1000);
> >  	if (err) {
> 
> This can't be correct.
> 
> "iface_no" is a u8 we read out of desc->bInterfaceNumber
> 
> we still have to extend it to a u16 and convert it to a little endian
> 16-bit value for the req.wIndex field.
> 
> If the types for the cdc notification struct are wrong, that's another
> story entirely.  But currently they are marked as __le16 so you must
> resolve this first.

Ok. I see where confusion started...
cdc_ncm is incorrectly using struct usb_cdc_notification (__le16) as input
to usb_control_msg() function, which is expecting u16 data type arguments.

I will post an updated patch shortly.

alexey
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
