From: Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Subject: RE: [PATCH ] cdc_ncm: fixes for big-endian architecture / MIPS
Date: Wed, 3 Aug 2011 16:07:18 +0200
Message-ID: <2AC7D4AD8BA1C640B4C60C61C8E520153E3DEF6C26@EXDCVYMBSTM006.EQ1STM.local>
References: <87hb5yock6.fsf@gnu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org" <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"gregkh-l3A5Bk7waGM@public.gmane.org" <gregkh-l3A5Bk7waGM@public.gmane.org>,
	"alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Giuseppe Scrivano <giuseppe-A9uVI2HLR7kOP4wsBPIw7w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87hb5yock6.fsf-mXXj517/zsQ@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> From 8bd65735b4f0db5b6213f59a443c21d0d55dba8e Mon Sep 17 00:00:00 2001
> From: Giuseppe Scrivano <giuseppe-A9uVI2HLR7kOP4wsBPIw7w@public.gmane.org>
> Date: Fri, 15 Jul 2011 15:34:14 +0200
> Subject: [PATCH] cdc_ncm: fix endianess problem.
> 
> Signed-off-by: Giuseppe Scrivano <giuseppe-A9uVI2HLR7kOP4wsBPIw7w@public.gmane.org>
> ---
>  drivers/net/usb/cdc_ncm.c |   65 +++++++++++++++++++++++++-------------------
> -

> +struct cdc_ncm_request {
> +	u8	bRequest;
> +	u8	bmRequestType;
> +	u16	wValue;
> +	u16	wIndex;
> +	u16	wLength;
> +} __packed;

Since it was incorrect to use struct usb_cdc_notification I would rather
remove cdc_ncm_do_request() function and provide u16 parameters directly to 
usb_control_msg without creating yet additional structure for usb control request.

alexey
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
