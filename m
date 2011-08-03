From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH ] cdc_ncm: fixes for big-endian architecture / MIPS
Date: Wed, 03 Aug 2011 03:42:53 -0700 (PDT)
Message-ID: <20110803.034253.417905916118311130.davem@davemloft.net>
References: <1312302026-7077-1-git-send-email-alexey.orishko@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org,
	alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org
To: alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1312302026-7077-1-git-send-email-alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Tue,  2 Aug 2011 18:20:26 +0200

> @@ -203,8 +203,8 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
>  	req.bmRequestType = USB_TYPE_CLASS | USB_DIR_IN | USB_RECIP_INTERFACE;
>  	req.bNotificationType = USB_CDC_GET_NTB_PARAMETERS;
>  	req.wValue = 0;
> -	req.wIndex = cpu_to_le16(iface_no);
> -	req.wLength = cpu_to_le16(sizeof(ctx->ncm_parm));
> +	req.wIndex = iface_no;
> +	req.wLength = sizeof(ctx->ncm_parm);
>  
>  	err = cdc_ncm_do_request(ctx, &req, &ctx->ncm_parm, 0, NULL, 1000);
>  	if (err) {

This can't be correct.

"iface_no" is a u8 we read out of desc->bInterfaceNumber

we still have to extend it to a u16 and convert it to a little endian
16-bit value for the req.wIndex field.

If the types for the cdc notification struct are wrong, that's another
story entirely.  But currently they are marked as __le16 so you must
resolve this first.

Otherwise your changes will result in several new sparse endian
warnings.

I'm not applying this, even if it is correct functionally.

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
