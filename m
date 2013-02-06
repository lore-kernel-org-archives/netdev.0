From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] qmi_wwan, cdc-ether: add ADU960S
Date: Wed, 06 Feb 2013 20:51:15 +0100
Message-ID: <874nhp6x1o.fsf@nemi.mork.no>
References: <1360173904.11742.8.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:57492 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758288Ab3BFTvX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 14:51:23 -0500
In-Reply-To: <1360173904.11742.8.camel@dcbw.foobar.com> (Dan Williams's
	message of "Wed, 06 Feb 2013 12:05:04 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Williams <dcbw@redhat.com> writes:

> It advertises a standard CDC-ETHER interface, which actually should b=
e
> driven by qmi_wwan.
>
> Signed-off-by: Dan Williams <dcbw@redhat.com>
> ---
> diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.=
c
> index 3f3d12d..cc6d0c1 100644
> --- a/drivers/net/usb/cdc_ether.c
> +++ b/drivers/net/usb/cdc_ether.c
> @@ -615,6 +615,13 @@ static const struct usb_device_id	products [] =3D=
 {
>  	.driver_info =3D 0,
>  },
> =20
> +/* AnyDATA ADU960S - handled by qmi_wwan */
> +{
> +	USB_DEVICE_AND_INTERFACE_INFO(0x16d5, 0x650a, USB_CLASS_COMM,
> +			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
> +	.driver_info =3D 0,
> +},
> +
>  /*
>   * WHITELIST!!!
>   *
> diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
> index 6a1ca50..2b5ea32 100644
> --- a/drivers/net/usb/qmi_wwan.c
> +++ b/drivers/net/usb/qmi_wwan.c
> @@ -459,6 +459,7 @@ static const struct usb_device_id products[] =3D =
{
>  	{QMI_FIXED_INTF(0x1199, 0x68a2, 19)},	/* Sierra Wireless MC7710 in =
QMI mode */
>  	{QMI_FIXED_INTF(0x1199, 0x901c, 8)},    /* Sierra Wireless EM7700 *=
/
>  	{QMI_FIXED_INTF(0x1bbb, 0x011e, 4)},	/* Telekom Speedstick LTE II (=
Alcatel One Touch L100V LTE) */
> +	{QMI_FIXED_INTF(0x16d5, 0x650a, 8)},	/* AnyDATA ADU960S */
> =20
>  	/* 4. Gobi 1000 devices */
>  	{QMI_GOBI1K_DEVICE(0x05c6, 0x9212)},	/* Acer Gobi Modem Device */


Just thinking....

Maybe we should use USB_DEVICE_AND_INTERFACE_INFO() in qmi_wwan as well
for these devices?  The only reason we match on interface number for
most devices in that driver is because those devices use ff/ff/ff for
multiple different functions.  When the function is uniquely identified
using class/subclass/protocol as here, then I believe it makes more
sense to use those values. And it creates a symmetry between the
cdc_ether and the qmi_wwan entries, making the connection between them
clearer.

Not to mention that such symmetry prevents us from ending up with no
driver supporting the device if some firmware upgrade happened to chang=
e
the interface number..


Bj=C3=B8rn
