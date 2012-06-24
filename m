From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Sun, 24 Jun 2012 11:34:19 +0200
Message-ID: <877guxhx44.fsf@nemi.mork.no>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no>
	<CACVXFVOZUvyNDzEoWT5o7JQRKjuw1pUgkipxV7dxT1w2Dd0H+A@mail.gmail.com>
	<87hau2hwna.fsf@nemi.mork.no> <201206232255.08319.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Marius =?utf-8?Q?Bj=C3=B8rnstad?= Kotsbak
	<marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201206232255.08319.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org> (Oliver Neukum's message
	of "Sat, 23 Jun 2012 22:55:08 +0200")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org> writes:
> Am Samstag, 23. Juni 2012, 17:32:09 schrieb Bj=C3=B8rn Mork:
>> Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>> > On Sat, Jun 23, 2012 at 4:45 PM, Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> w=
rote:
>
>> > Suppose there will be another usbnet driver which has its own subd=
river
>> > too, the same trick of checking need to be added again if not taki=
ng the
>> > general way of simply removing 'usb_set_intfdata(intf, NULL);' in
>> > usbnet_disconnect.
>>=20
>> Yes, I guess so.
>>=20
>> I am just worrying (maybe too much) about the unknown consequences o=
f
>> removing that code in usbnet, not fully understanding why it was the=
re
>> in the first place.  And I do not want to take the blame and cleanup
>> work if anything goes wrong :-) Fixing it in qmi_wwan feels much saf=
er.
>
> void usbnet_cdc_unbind(struct usbnet *dev, struct usb_interface *intf=
)
> {
>         struct cdc_state                *info =3D (void *) &dev->data=
;
>         struct usb_driver               *driver =3D driver_of(intf);
>
>         /* disconnect master --> disconnect slave */
>         if (intf =3D=3D info->control && info->data) {
>                 /* ensure immediate exit from usbnet_disconnect */
>                 usb_set_intfdata(info->data, NULL);
>                 usb_driver_release_interface(driver, info->data);
>                 info->data =3D NULL;
>
> 1. We mirror the minidrivers closely, which reduces errors
> 2. unbind() is called with the data anyway and after disconnect()
>     the intfdata is not valid anyway, because the interface may have =
been
>     reprobed.

Sorry, I did not understand what you meant we should do here.  The extr=
a
usb_set_intfdata(, NULL) in usbnet_disconnect() won't make any
difference for that piece of code, will it?

And the USB core ensures that intfdata is set to NULL before any
reprobing, so that will never be a problem.  That's the reason why it
seems redundant setting it in usbnet_disconnect().



Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
