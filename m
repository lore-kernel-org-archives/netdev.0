From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH net-next v6 0/3] The huawei_cdc_ncm driver / E3276
 problem
Date: Thu, 13 Mar 2014 16:41:47 -0500
Message-ID: <1394746907.15946.8.camel@dcbw.local>
References: <1383555049-24834-1-git-send-email-bjorn@mork.no>
	 <20140313202557.GV3200@reaktio.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	Oliver Neukum <oliver@neukum.org>
To: Pasi =?ISO-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38327 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753290AbaCMVkR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Mar 2014 17:40:17 -0400
In-Reply-To: <20140313202557.GV3200@reaktio.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-03-13 at 22:25 +0200, Pasi K=C3=A4rkk=C3=A4inen wrote:
> On Mon, Nov 04, 2013 at 09:50:46AM +0100, Bj=C3=B8rn Mork wrote:
> >=20
> > [quote Enrico Mioso]
> >=20
> > So this is a new, revised, edition of the huawei_cdc_ncm.c driver, =
which=20
> > supports devices resembling the NCM standard, but using it also as =
a mean=20
> > to encapsulate other protocols, as is the case for the Huawei E3131=
 and
> > E3251 modem devices.
> >
>=20
> Hello,
>=20
> I'm trying to use Huawei E3276 4G/LTE USB dongle with Linux 3.13.6 ke=
rnel,
> and thus i'm using the new huawei_cdc_ncm driver.
>=20
> I'm using the /dev/cdc-wdm0 device to send AT commands to it, and tha=
t seems to work,
> so the dongle seems like it's connected (also the LED on the dongle s=
uggests it's connected).
>=20
> .. the problem is the wwan0 interface (well, udev renames it to wwp0s=
26u1u5i1) doesn't work.
> Launching a dhcp client on the wwp0s26u1u5i1 doesn't get any IP addre=
ss.
>=20
> Any tips how to troubleshoot this?=20

Which AT commands are you using to start the data connection?

I believe Huawei says that DHCP on the network port is only supported i=
f
network port's USB interface has Class 0x2 + SubClass [0x6 | 0xd] +
Protocol 0x0.

Lastly, I think the E3276 has a couple of different "modes" that it can
switch into with usb_modeswitch too, and only some modes expose the
right network interface.  What modeswitch command is getting sent to th=
e
device?

Dan

> I'm seeing "RX errors" listed for the interface in "ifconfig -a" outp=
ut.. is that normal?=20
>=20
> The device in question is (ATI command output):
>=20
> Manufacturer: huawei
> Model: E3276
> Revision: 21.263.03.00.07
> IMEI: 863XYZXYZXYZXYZ
> +GCAP: +CGSM,+DS,+ES
>=20
> Thanks!
>=20
> -- Pasi
>=20
>=20
> > Some precisations are needed however - and I encourage discussion o=
n this: and=20
> > that's why I'm sending this message with a broader CC.
> > Merging those patches might change:
> > - the way Modem Manager interacts with those devices
> > - some regressions might be possible if there are some unknown firm=
ware=20
> >   variants around (Franko?)
> >=20
> > First of all: I observed the behaviours of two devices.
> > Huawei E3131: this device doesn't accept NDIS setup requests unless=
 they're=20
> > sent via the embedded AT channel exposed by this driver.
> > So actually we gain funcionality in this case!
> >=20
> > The second case, is the Huawei E3251: which works with standard NCM=
 driver,=20
> > still exposing an AT embedded channel. Whith this patch set applied=
, you gain=20
> > some funcionality, loosing the ability to catch standard NCM events=
 for now.
> > The device will work in both ways with no problems, but this has to=
 be=20
> > acknowledged and discussed. Might be we can develop this driver fur=
ther to=20
> > change this, when more devices are tested.
> >=20
> > We where thinking Huawei changed their interfaces on new devices - =
but probably=20
> > this driver only works around a nice firmware bug present in E3131,=
 which=20
> > prevented the modem from being used in NDIS mode.
> >=20
> > I think committing this is definitely wortth-while, since it will a=
llow for=20
> > more Huawei devices to be used without serial connection. Some devi=
ces like the=20
> > E3251 also, reports some status information only via the embedded A=
T channel,=20
> > at least in my case.
> > Note: I'm not subscribed to any list except the Modem Manager's one=
, so please=20
> > CC me, thanks!!
> >=20
> > [/quote]
> >=20
> > Enrico Mioso (3):
> >   net: cdc_ncm: Export cdc_ncm_{tx,rx}_fixup functions for re-use
> >   net: huawei_cdc_ncm: Introduce the huawei_cdc_ncm driver
> >   net: cdc_ncm: remove non-standard NCM device IDs
> >=20
> >  drivers/net/usb/Kconfig          |   15 +++
> >  drivers/net/usb/Makefile         |    1 +
> >  drivers/net/usb/cdc_ncm.c        |   17 +--
> >  drivers/net/usb/huawei_cdc_ncm.c |  230 ++++++++++++++++++++++++++=
++++++++++++
> >  include/linux/usb/cdc_ncm.h      |    3 +
> >  5 files changed, 253 insertions(+), 13 deletions(-)
> >  create mode 100644 drivers/net/usb/huawei_cdc_ncm.c
> >=20
> > --=20
> > 1.7.10.4
> >=20
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-usb" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
