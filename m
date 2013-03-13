From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net,stable-3.8] net: qmi_wwan: set correct altsetting
 for Gobi 1K devices
Date: Wed, 13 Mar 2013 11:34:30 -0400 (EDT)
Message-ID: <20130313.113430.1432101723516184304.davem@davemloft.net>
References: <1363177517-23524-1-git-send-email-bjorn@mork.no>
	<1363182216.1415.5.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bjorn-yOkvZcmFvRU@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1363182216.1415.5.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Wed, 13 Mar 2013 08:43:36 -0500

> On Wed, 2013-03-13 at 13:25 +0100, Bj=F8rn Mork wrote:
>> commit bd877e4 ("net: qmi_wwan: use a single bind function for
>> all device types") made Gobi 1K devices fail probing.
>>=20
>> Using the number of endpoints in the default altsetting to decide
>> whether the function use one or two interfaces is wrong.  Other
>> altsettings may provide more endpoints.
>>=20
>> With Gobi 1K devices, USB interface #3's altsetting is 0 by default,=
 but
>> altsetting 0 only provides one interrupt endpoint and is not suffice=
nt
>> for QMI.  Altsetting 1 provides all 3 endpoints required for qmi_wwa=
n
>> and works with QMI. Gobi 1K layout for intf#3 is:
>>=20
>>     Interface Descriptor:  255/255/255
>>       bInterfaceNumber        3
>>       bAlternateSetting       0
>>       Endpoint Descriptor:  Interrupt IN
>>     Interface Descriptor:  255/255/255
>>       bInterfaceNumber        3
>>       bAlternateSetting       1
>>       Endpoint Descriptor:  Interrupt IN
>>       Endpoint Descriptor:  Bulk IN
>>       Endpoint Descriptor:  Bulk OUT
>>=20
>> Prior to commit bd877e4, we would call usbnet_get_endpoints
>> before giving up finding enough endpoints. Removing the early
>> endpoint number test and the strict functional descriptor
>> requirement allow qmi_wwan_bind to continue until
>> usbnet_get_endpoints has made the final attempt to collect
>> endpoints.  This restores the behaviour from before commit
>> bd877e4 without losing the added benefit of using a single bind
>> function.
>>=20
>> The driver has always required a CDC Union functional descriptor
>> for two-interface functions. Using the existence of this
>> descriptor to detect two-interface functions is the logically
>> correct method.
>>=20
>> Reported-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>> Signed-off-by: Bj=F8rn Mork
>=20
> Works on my UML290, Gobi3K, Gobi1K, Gobi2K, and E362.
>=20
> Tested-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Applied and queued up for -stable.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
