From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] net: qmi_wwan: Add USB IDs for MDM6600 modem on Motorola Droid 4
Date: Sun, 19 Mar 2017 17:31:12 +0100
Message-ID: <87lgs15iun.fsf@miraculix.mork.no>
References: <20170319161957.6625-1-tony@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-omap@vger.kernel.org
To: Tony Lindgren <tony@atomide.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:60221 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751490AbdCSRDz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 19 Mar 2017 13:03:55 -0400
In-Reply-To: <20170319161957.6625-1-tony@atomide.com> (Tony Lindgren's message
        of "Sun, 19 Mar 2017 09:19:57 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tony Lindgren <tony@atomide.com> writes:

> This gets qmicli working with the MDM6600 modem.
>
> Cc: Bj=C3=B8rn Mork <bjorn@mork.no>
> Reviewed-by: Sebastian Reichel <sre@kernel.org>
> Tested-by: Sebastian Reichel <sre@kernel.org>
> Signed-off-by: Tony Lindgren <tony@atomide.com>
> ---
>  drivers/net/usb/qmi_wwan.c | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
> --- a/drivers/net/usb/qmi_wwan.c
> +++ b/drivers/net/usb/qmi_wwan.c
> @@ -580,6 +580,10 @@ static const struct usb_device_id products[] =3D {
>  		USB_VENDOR_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, USB_CLASS_VENDOR_SPEC,=
 0x01, 0x69),
>  		.driver_info        =3D (unsigned long)&qmi_wwan_info,
>  	},
> +	{	/* Motorola Mapphone devices with MDM6600 */
> +		USB_VENDOR_AND_INTERFACE_INFO(0x22b8, USB_CLASS_VENDOR_SPEC, 0xfb, 0xf=
f),


This is a bit unusual, so I'd like to verify that it is correct.  Do you
happen to have a "lsusb -v" or /sys/kernel/debug/usb/devices dump for
this device?  Is this usage of vendor + class consistent with the
Windows driver *.inf data?  Are you sure that the ff/fb/ff class is only
used for QMI functions by this vendor ID?=20

The reason I ask is that I'd hate to have reports of other Motorola
devices where ff/fb/ff was used for some other USB function.  Yes, that
would be stupid.  But still... Experience shows that we cannot rule out
stupid when we consider USB descriptors.


Bj=C3=B8rn
