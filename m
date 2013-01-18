From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net] net: cdc_ncm: workaround for missing CDC Union
Date: Fri, 18 Jan 2013 22:17:03 +0100
Message-ID: <871udiur74.fsf@nemi.mork.no>
References: <1358519147-10073-1-git-send-email-bjorn@mork.no>
	<22276933.xSGyXJfOvq@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>,
	Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <22276933.xSGyXJfOvq-7ztolUikljGernLeA6q8OA@public.gmane.org> (Oliver Neukum's message of
	"Fri, 18 Jan 2013 20:11:25 +0100")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org> writes:
> On Friday 18 January 2013 15:25:47 Bj=C3=B8rn Mork wrote:
>> Adding support for the MBIM mode in some Sierra Wireless devices.
>>=20
>> Some Sierra Wireless firmwares support CDC MBIM but have no CDC
>> Union funtional descriptor. This violates the MBIM specification,
>> but we can easily work around the bug by looking at the Interface
>> Association Descriptor instead.  This is most likely what
>> Windows uses too, which explains how the firmware bug has gone
>> unnoticed until now.
>
> Should we do this for everything CDC?

I don't know.  There are workarounds for missing CDC Union descriptors
on RNDIS devices in cdc_ether.c, but I have no idea if those devices in
provide an IAD instead.  I don't think this bug is a very common.

MBIM devices are likely to have IADs because Microsoft let you skip som=
e
of the more hairy vendor specific control message parts if you provide
one:
http://msdn.microsoft.com/en-us/library/windows/hardware/mbim-based-mob=
ile-broadband-requirements-for-windows.aspx

But they should of course provide the CDC Union functional descriptor a=
s
well, even if that is "just" a USB-IF requirement and not a Windows
requirement ;-)


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
