From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH v2 2/3] net: usb: cdc_enc: New driver exposing USB CDC encapsulated protocols
Date: Sun, 15 Jan 2012 15:22:02 +0100
Message-ID: <87lip9dp11.fsf@nemi.mork.no>
References: <cover.1326607234.git.bjorn@mork.no>
	<d11888532ee381806b35974e71af4c0122255c05.1326607234.git.bjorn@mork.no>
	<201201151436.29794.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Thomas =?utf-8?Q?Sch=C3=A4fer?= <tschaefer-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201201151436.29794.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org> (Oliver Neukum's message
	of "Sun, 15 Jan 2012 14:36:29 +0100")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org> writes:
> Am Sonntag, 15. Januar 2012, 07:40:36 schrieb Bj=C3=B8rn Mork:
>> USB CDC Ethernet devices may encapsulate vendor specific protocols i=
nside
>> USB_CDC_SEND_ENCAPSULATED_COMMAND +USB_CDC_GET_ENCAPSULATED_RESPONSE
>> control messages. Devices based on Qualcomm MSM
>> chipsets are known to use this for exporting the Qualcomm
>> MSM Interface (QMI) protocol. Examples of such devices are
>> the Huawei E392 and E398 LTE modems.
>
> The problem is that this is another version of the code already
> in cdc-wdm, which is tested well.

Huh?  I thought that was something entirely different.  Isn't it?

Anyway, I see that I should look thoroughly at it as it does these
things in a much nicer way.  Thanks for the pointer.

> I'd really like to unify this stuff.

That makes sense. =20

[snipped a number of detailed issues which I obviously need to fix]

>> +
>> +/* per CDC_ENC interface state */
>> +struct cdc_enc_state {
>> +	struct usb_interface *intf;
>> +	struct urb *urb;		/* receive urb */
>> +	struct urb *interrupt;		/* interrupt urb */
>> +	unsigned char rcvbuf[CDC_ENC_BUFLEN];     /* receive buffer */
>
> This is a violation of the DMA requirements. You must use kmalloc.

This probably only demonstrates my lack of understanding these
requirements.  I thought this was OK as long as I kmalloc'ed the whole
struct, but I see now that that isn't necessarily true.

>
> I had a not very detailed look at this driver, but I would really pre=
fer
> if you could have a look at making unified code for this, cdc-wdm and=
 cdc-acm.

Will do.  Thanks a lot for the fast review.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
