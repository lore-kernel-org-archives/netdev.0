From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: Fwd: [PATCH] net:usb:cdc_ncm: fix that tag Huawei devices as wwan
Date: Mon, 15 Jun 2015 10:58:07 +0200
Message-ID: <87ioapl55s.fsf@nemi.mork.no>
References: <SNT147-W99A0E937260823EBAA1FFB3B90@phx.gbl>
	<CA+55aFz3S3nR_aDMMS1vcayyEqJCBL5tgoYAfDE2WGyM3Vcrww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Ben Hutchings <ben.hutchings-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	xiaomao <xiaomao0213-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+55aFz3S3nR_aDMMS1vcayyEqJCBL5tgoYAfDE2WGyM3Vcrww-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Linus Torvalds's message of "Sun, 14 Jun 2015 13:51:46 -1000")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> writes:

> Hmm. Oliver is marked as the maintainer of the USB CDC code, but
> others have touched it more recently. So I'm just wildly adding peopl=
e
> to the cc to comment on this patch and maybe apply it.
> Oliver/David/Ben/Bj=C3=B8rn?

Adding Aleksander and Dan, too.  The 'wwanX' vs 'usbX' distinction is a
hint for userspace and nothing more. We try our best to make this hint
as precise as possible, but there has never been any guarantee that it
is 100% correct.  So userspace will have to deal with hints being wrong=
=2E
This has been discussed before:
http://lists.freedesktop.org/archives/modemmanager-devel/2014-April/001=
068.html

What makes the Huawei NCM devices special is that the same ID is reused
for both types of devices, making it impossible to achieve perfect
hinting by adding exceptions to the generic rule.  We can choose betwee=
n
wrong towards 'wwanX' or wrong towards 'usbX'.  But the hint WILL be
wrong in some cases no matter what we do.

The 12d1:1506 device ID is a perfect example.  Here's a report of a
Huawei E5776 which should be used as a plain 'usbX' NCM device:
http://lists.freedesktop.org/archives/modemmanager-devel/2014-April/001=
040.html
And here's a report of a Huawei E3276 which needs wwan management and
therefore should be hinted as a 'wwanX' NCM device:
http://www.dd-wrt.com/phpBB2/viewtopic.php?p=3D764920

So which of the two wrongs should we choose?

Huawei wanting this changed is a strong argument for the 'usbX'
direction, of course.  But this will be a user visible change which is
likely to break currently working devices until userspace adapts.  And
that will normally trump almost any other argument.  I don't think we
can change this now.  I sincerely apologise about having added the
generic rule in the first place, but I don't see how I can go back and
change that.

I believe we have to follow the path of least surprise: Keeping what we
have.

But we should definitely work with userspace to ensure that a wrongly
flagged 'wwanX' device is usable without any wwan management.
Preferably without the user really noticing anything different (except
possibly the device name).



Bj=C3=B8rn

> ---------- Forwarded message ----------
> From: xiaomao <xiaomao0213-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>
> Date: Sun, Jun 14, 2015 at 1:18 PM
> Subject: [PATCH] net:usb:cdc_ncm: fix that tag Huawei devices as wwan
>
>
> Form: Qianni Mamaqianni-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
>
> Huawei devices is the gereric CDC_NCM devices, but not is WWAN
> devices. In the patch, we deleted the code about tagging Huawei
> devices as WWAN.
> ---
>
> Signed-off-by:Qianni Mamaqianni-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
>
> --- linux-3.19/drivers/net/usb/cdc_ncm.c.orig	2015-06-15 01:29:52.354=
238079 +0800
> +++ linux-3.19/drivers/net/usb/cdc_ncm.c	2015-06-15 01:31:04.07423624=
6 +0800
> @@ -1573,12 +1573,12 @@ static const struct usb_device_id cdc_de
>  	},
> =20
>  	/* tag Huawei devices as wwan */
> -	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1,
> +	/*{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1,
>  					USB_CLASS_COMM,
>  					USB_CDC_SUBCLASS_NCM,
>  					USB_CDC_PROTO_NONE),
>  	  .driver_info =3D (unsigned long)&wwan_info,
> -	},
> +	},*/
> =20
>  	/* Infineon(now Intel) HSPA Modem platform */
>  	{ USB_DEVICE_AND_INTERFACE_INFO(0x1519, 0x0443,
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
