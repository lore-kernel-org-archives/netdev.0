From: Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Subject: Re: [PATCH net-next v6 0/3] The huawei_cdc_ncm driver / E3276
 problem
Date: Thu, 13 Mar 2014 22:25:57 +0200
Message-ID: <20140313202557.GV3200@reaktio.net>
References: <1383555049-24834-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	Oliver Neukum <oliver@neukum.org>
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emh06.mail.saunalahti.fi ([62.142.5.116]:51703 "EHLO
	emh06.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752248AbaCMUfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 16:35:03 -0400
Content-Disposition: inline
In-Reply-To: <1383555049-24834-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 04, 2013 at 09:50:46AM +0100, Bj=F8rn Mork wrote:
>=20
> [quote Enrico Mioso]
>=20
> So this is a new, revised, edition of the huawei_cdc_ncm.c driver, wh=
ich=20
> supports devices resembling the NCM standard, but using it also as a =
mean=20
> to encapsulate other protocols, as is the case for the Huawei E3131 a=
nd
> E3251 modem devices.
>

Hello,

I'm trying to use Huawei E3276 4G/LTE USB dongle with Linux 3.13.6 kern=
el,
and thus i'm using the new huawei_cdc_ncm driver.

I'm using the /dev/cdc-wdm0 device to send AT commands to it, and that =
seems to work,
so the dongle seems like it's connected (also the LED on the dongle sug=
gests it's connected).

=2E. the problem is the wwan0 interface (well, udev renames it to wwp0s=
26u1u5i1) doesn't work.
Launching a dhcp client on the wwp0s26u1u5i1 doesn't get any IP address=
=2E

Any tips how to troubleshoot this?=20

I'm seeing "RX errors" listed for the interface in "ifconfig -a" output=
=2E. is that normal?=20

The device in question is (ATI command output):

Manufacturer: huawei
Model: E3276
Revision: 21.263.03.00.07
IMEI: 863XYZXYZXYZXYZ
+GCAP: +CGSM,+DS,+ES

Thanks!

-- Pasi


> Some precisations are needed however - and I encourage discussion on =
this: and=20
> that's why I'm sending this message with a broader CC.
> Merging those patches might change:
> - the way Modem Manager interacts with those devices
> - some regressions might be possible if there are some unknown firmwa=
re=20
>   variants around (Franko?)
>=20
> First of all: I observed the behaviours of two devices.
> Huawei E3131: this device doesn't accept NDIS setup requests unless t=
hey're=20
> sent via the embedded AT channel exposed by this driver.
> So actually we gain funcionality in this case!
>=20
> The second case, is the Huawei E3251: which works with standard NCM d=
river,=20
> still exposing an AT embedded channel. Whith this patch set applied, =
you gain=20
> some funcionality, loosing the ability to catch standard NCM events f=
or now.
> The device will work in both ways with no problems, but this has to b=
e=20
> acknowledged and discussed. Might be we can develop this driver furth=
er to=20
> change this, when more devices are tested.
>=20
> We where thinking Huawei changed their interfaces on new devices - bu=
t probably=20
> this driver only works around a nice firmware bug present in E3131, w=
hich=20
> prevented the modem from being used in NDIS mode.
>=20
> I think committing this is definitely wortth-while, since it will all=
ow for=20
> more Huawei devices to be used without serial connection. Some device=
s like the=20
> E3251 also, reports some status information only via the embedded AT =
channel,=20
> at least in my case.
> Note: I'm not subscribed to any list except the Modem Manager's one, =
so please=20
> CC me, thanks!!
>=20
> [/quote]
>=20
> Enrico Mioso (3):
>   net: cdc_ncm: Export cdc_ncm_{tx,rx}_fixup functions for re-use
>   net: huawei_cdc_ncm: Introduce the huawei_cdc_ncm driver
>   net: cdc_ncm: remove non-standard NCM device IDs
>=20
>  drivers/net/usb/Kconfig          |   15 +++
>  drivers/net/usb/Makefile         |    1 +
>  drivers/net/usb/cdc_ncm.c        |   17 +--
>  drivers/net/usb/huawei_cdc_ncm.c |  230 ++++++++++++++++++++++++++++=
++++++++++
>  include/linux/usb/cdc_ncm.h      |    3 +
>  5 files changed, 253 insertions(+), 13 deletions(-)
>  create mode 100644 drivers/net/usb/huawei_cdc_ncm.c
>=20
> --=20
> 1.7.10.4
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
