From: Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Subject: Re: [PATCH net-next v6 0/3] The huawei_cdc_ncm driver / E3276
 problem
Date: Fri, 14 Mar 2014 09:55:48 +0200
Message-ID: <20140314075548.GX3200@reaktio.net>
References: <1383555049-24834-1-git-send-email-bjorn@mork.no>
 <20140313202557.GV3200@reaktio.net>
 <1394746907.15946.8.camel@dcbw.local>
 <20140313220812.GW3200@reaktio.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	Oliver Neukum <oliver@neukum.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emh02.mail.saunalahti.fi ([62.142.5.108]:41608 "EHLO
	emh02.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755594AbaCNHzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 03:55:51 -0400
Content-Disposition: inline
In-Reply-To: <20140313220812.GW3200@reaktio.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 14, 2014 at 12:08:12AM +0200, Pasi K=E4rkk=E4inen wrote:
> On Thu, Mar 13, 2014 at 04:41:47PM -0500, Dan Williams wrote:
> > On Thu, 2014-03-13 at 22:25 +0200, Pasi K=E4rkk=E4inen wrote:
> > > On Mon, Nov 04, 2013 at 09:50:46AM +0100, Bj=F8rn Mork wrote:
> > > >=20
> > > > [quote Enrico Mioso]
> > > >=20
> > > > So this is a new, revised, edition of the huawei_cdc_ncm.c driv=
er, which=20
> > > > supports devices resembling the NCM standard, but using it also=
 as a mean=20
> > > > to encapsulate other protocols, as is the case for the Huawei E=
3131 and
> > > > E3251 modem devices.
> > > >
> > >=20
> > > Hello,
> > >=20
> > > I'm trying to use Huawei E3276 4G/LTE USB dongle with Linux 3.13.=
6 kernel,
> > > and thus i'm using the new huawei_cdc_ncm driver.
> > >=20
> > > I'm using the /dev/cdc-wdm0 device to send AT commands to it, and=
 that seems to work,
> > > so the dongle seems like it's connected (also the LED on the dong=
le suggests it's connected).
> > >=20
> > > .. the problem is the wwan0 interface (well, udev renames it to w=
wp0s26u1u5i1) doesn't work.
> > > Launching a dhcp client on the wwp0s26u1u5i1 doesn't get any IP a=
ddress.
> > >=20
> > > Any tips how to troubleshoot this?=20
> >=20
>=20
> Hi,
>=20
> > Which AT commands are you using to start the data connection?
> >=20
>=20
> I've been using:
>=20
> ATQ0 V1 E1 S0=3D0
> AT^NDISDUP=3D1,1,"internet"
> AT^DHCP?
>

Oh, I forgot to mention.. after I send AT^NDISDUP=3D1,1,"internet" I ge=
t this:

^NDISSTAT:1,,,"IPV4"

=2E. which to my understanding means it's connected (1=3D=3Dconnected).
Also sending AT^NDISSTATQRY? results in:

^NDISSTATQRY: 1,,,"IPV4"


But I can't get an IP with dhcp client on the wwan0 interface..


-- Pasi

=20
>=20
> > I believe Huawei says that DHCP on the network port is only support=
ed if
> > network port's USB interface has Class 0x2 + SubClass [0x6 | 0xd] +
> > Protocol 0x0.
> >=20
>=20
> # lsusb | grep -i huawei
> Bus 001 Device 010: ID 12d1:1506 Huawei Technologies Co., Ltd. Modem/=
Networkcard
>=20
> # lsusb -t
> ..
>         |__ Port 5: Dev 10, If 0, Class=3DVendor Specific Class, Driv=
er=3Doption, 480M
>         |__ Port 5: Dev 10, If 1, Class=3DVendor Specific Class, Driv=
er=3Dhuawei_cdc_ncm, 480M
>         |__ Port 5: Dev 10, If 2, Class=3DMass Storage, Driver=3Dusb-=
storage, 480M
>         |__ Port 5: Dev 10, If 3, Class=3DMass Storage, Driver=3Dusb-=
storage, 480M
>=20
> Bus 001 Device 010: ID 12d1:1506 Huawei Technologies Co., Ltd. Modem/=
Networkcard
> Device Descriptor:
>   bLength                18
>   bDescriptorType         1
>   bcdUSB               2.00
>   bDeviceClass            0 (Defined at Interface level)
>   bDeviceSubClass         0
>   bDeviceProtocol         0
>   bMaxPacketSize0        64
>   idVendor           0x12d1 Huawei Technologies Co., Ltd.
>   idProduct          0x1506 Modem/Networkcard
>   bcdDevice            1.02
>   iManufacturer           2 HUAWEI Technology
>   iProduct                1 HUAWEI Mobile
>   iSerial                 0
>   bNumConfigurations      1
>   Configuration Descriptor:
>     bLength                 9
>     bDescriptorType         2
>     wTotalLength          173
>     bNumInterfaces          4
>     bConfigurationValue     1
>     iConfiguration          3 Huawei Configuration
>     bmAttributes         0x80
>       (Bus Powered)
>     MaxPower              500mA
>     Interface Descriptor:
>       bLength                 9
>       bDescriptorType         4
>       bInterfaceNumber        0
>       bAlternateSetting       0
>       bNumEndpoints           2
>       bInterfaceClass       255 Vendor Specific Class
>       bInterfaceSubClass      2
>       bInterfaceProtocol     18
>       iInterface              0
>       ** UNRECOGNIZED:  05 24 00 10 01
>       ** UNRECOGNIZED:  04 24 02 02
>       ** UNRECOGNIZED:  05 24 01 00 00
>       ** UNRECOGNIZED:  06 24 06 00 00 00
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x81  EP 1 IN
>         bmAttributes            2
>           Transfer Type            Bulk
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0200  1x 512 bytes
>         bInterval              32
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x01  EP 1 OUT
>         bmAttributes            2
>           Transfer Type            Bulk
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0200  1x 512 bytes
>         bInterval              32
>     Interface Descriptor:
>       bLength                 9
>       bDescriptorType         4
>       bInterfaceNumber        1
>       bAlternateSetting       0
>       bNumEndpoints           1
>       bInterfaceClass       255 Vendor Specific Class
>       bInterfaceSubClass      2
>       bInterfaceProtocol     22
>       iInterface              0
>       ** UNRECOGNIZED:  05 24 00 10 01
>       ** UNRECOGNIZED:  06 24 1a 00 01 1f
>       ** UNRECOGNIZED:  0d 24 0f 04 0f 00 00 00 ea 05 03 00 01
>       ** UNRECOGNIZED:  05 24 06 01 01
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x82  EP 2 IN
>         bmAttributes            3
>           Transfer Type            Interrupt
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0040  1x 64 bytes
>         bInterval               5
>     Interface Descriptor:
>       bLength                 9
>       bDescriptorType         4
>       bInterfaceNumber        1
>       bAlternateSetting       1
>       bNumEndpoints           3
>       bInterfaceClass       255 Vendor Specific Class
>       bInterfaceSubClass      2
>       bInterfaceProtocol     22
>       iInterface              0
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x82  EP 2 IN
>         bmAttributes            3
>           Transfer Type            Interrupt
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0040  1x 64 bytes
>         bInterval               5
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x83  EP 3 IN
>         bmAttributes            2
>           Transfer Type            Bulk
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0200  1x 512 bytes
>         bInterval              32
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x02  EP 2 OUT
>         bmAttributes            2
>           Transfer Type            Bulk
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0200  1x 512 bytes
>         bInterval              32
>     Interface Descriptor:
>       bLength                 9
>       bDescriptorType         4
>       bInterfaceNumber        2
>       bAlternateSetting       0
>       bNumEndpoints           2
>       bInterfaceClass         8 Mass Storage
>       bInterfaceSubClass      6 SCSI
>       bInterfaceProtocol     80 Bulk-Only
>       iInterface              0
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x03  EP 3 OUT
>         bmAttributes            2
>           Transfer Type            Bulk
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0200  1x 512 bytes
>         bInterval               0
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x84  EP 4 IN
>         bmAttributes            2
>           Transfer Type            Bulk
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0200  1x 512 bytes
>         bInterval               0
>     Interface Descriptor:
>       bLength                 9
>       bDescriptorType         4
>       bInterfaceNumber        3
>       bAlternateSetting       0
>       bNumEndpoints           2
>       bInterfaceClass         8 Mass Storage
>       bInterfaceSubClass      6 SCSI
>       bInterfaceProtocol     80 Bulk-Only
>       iInterface              0
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x04  EP 4 OUT
>         bmAttributes            2
>           Transfer Type            Bulk
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0200  1x 512 bytes
>         bInterval               0
>       Endpoint Descriptor:
>         bLength                 7
>         bDescriptorType         5
>         bEndpointAddress     0x85  EP 5 IN
>         bmAttributes            2
>           Transfer Type            Bulk
>           Synch Type               None
>           Usage Type               Data
>         wMaxPacketSize     0x0200  1x 512 bytes
>         bInterval               0
> Device Qualifier (for other device speed):
>   bLength                10
>   bDescriptorType         6
>   bcdUSB               2.00
>   bDeviceClass            0 (Defined at Interface level)
>   bDeviceSubClass         0
>   bDeviceProtocol         0
>   bMaxPacketSize0        64
>   bNumConfigurations      1
> Device Status:     0x0000
>   (Bus Powered)
>=20
>=20
> > Lastly, I think the E3276 has a couple of different "modes" that it=
 can
> > switch into with usb_modeswitch too, and only some modes expose the
> > right network interface.  What modeswitch command is getting sent t=
o the
> > device?
> >=20
>=20
> This is on Fedora 20.=20
>=20
> Mar 13 23:56:36 localhost logger: usb_modeswitch: using overriding co=
nfig file /etc/usb_modeswitch.d/12d1:14fe; make sure this is intended
> Mar 13 23:56:36 localhost logger: usb_modeswitch: please report any n=
ew or corrected settings; otherwise, check for outdated files
> Mar 13 23:56:36 localhost usb_modeswitch: switching device 12d1:14fe =
on 001/009
> Mar 13 23:56:37 localhost logger: usb_modeswitch: switched to 12d1:15=
06 on 001/010
>=20
> # cat /etc/usb_modeswitch.d/12d1:14fe
>=20
> # T-Mobile NL (Huawei E352)
>=20
> TargetVendor=3D  0x12d1
> TargetProductList=3D"1506,150f,151d"
>=20
> MessageContent=3D"555342431234567800000000000000110620000001000000000=
00000000000"
>=20
>=20
> # grep -i e3276 /etc/usb_modeswitch.d/*
> /etc/usb_modeswitch.d/12d1:156a:# Huawei E3276s-151 and E3251
>=20
>=20
> # cat /etc/usb_modeswitch.d/12d1:156a
>=20
> # Huawei E3276s-151 and E3251
>=20
> TargetVendor=3D  0x12d1
> TargetProductList=3D"156b,156c"
>=20
> MessageContent=3D"555342431234567800000000000000110620000001000000000=
00000000000"
>=20
>=20
>=20
> Hopefully that was enough information..=20
>=20
> Thanks!
>=20
> -- Pasi
>=20
>=20
> > Dan
> >=20
> > > I'm seeing "RX errors" listed for the interface in "ifconfig -a" =
output.. is that normal?=20
> > >=20
> > > The device in question is (ATI command output):
> > >=20
> > > Manufacturer: huawei
> > > Model: E3276
> > > Revision: 21.263.03.00.07
> > > IMEI: 863XYZXYZXYZXYZ
> > > +GCAP: +CGSM,+DS,+ES
> > >=20
> > > Thanks!
> > >=20
> > > -- Pasi
> > >=20
> > >=20
> > > > Some precisations are needed however - and I encourage discussi=
on on this: and=20
> > > > that's why I'm sending this message with a broader CC.
> > > > Merging those patches might change:
> > > > - the way Modem Manager interacts with those devices
> > > > - some regressions might be possible if there are some unknown =
firmware=20
> > > >   variants around (Franko?)
> > > >=20
> > > > First of all: I observed the behaviours of two devices.
> > > > Huawei E3131: this device doesn't accept NDIS setup requests un=
less they're=20
> > > > sent via the embedded AT channel exposed by this driver.
> > > > So actually we gain funcionality in this case!
> > > >=20
> > > > The second case, is the Huawei E3251: which works with standard=
 NCM driver,=20
> > > > still exposing an AT embedded channel. Whith this patch set app=
lied, you gain=20
> > > > some funcionality, loosing the ability to catch standard NCM ev=
ents for now.
> > > > The device will work in both ways with no problems, but this ha=
s to be=20
> > > > acknowledged and discussed. Might be we can develop this driver=
 further to=20
> > > > change this, when more devices are tested.
> > > >=20
> > > > We where thinking Huawei changed their interfaces on new device=
s - but probably=20
> > > > this driver only works around a nice firmware bug present in E3=
131, which=20
> > > > prevented the modem from being used in NDIS mode.
> > > >=20
> > > > I think committing this is definitely wortth-while, since it wi=
ll allow for=20
> > > > more Huawei devices to be used without serial connection. Some =
devices like the=20
> > > > E3251 also, reports some status information only via the embedd=
ed AT channel,=20
> > > > at least in my case.
> > > > Note: I'm not subscribed to any list except the Modem Manager's=
 one, so please=20
> > > > CC me, thanks!!
> > > >=20
> > > > [/quote]
> > > >=20
> > > > Enrico Mioso (3):
> > > >   net: cdc_ncm: Export cdc_ncm_{tx,rx}_fixup functions for re-u=
se
> > > >   net: huawei_cdc_ncm: Introduce the huawei_cdc_ncm driver
> > > >   net: cdc_ncm: remove non-standard NCM device IDs
> > > >=20
> > > >  drivers/net/usb/Kconfig          |   15 +++
> > > >  drivers/net/usb/Makefile         |    1 +
> > > >  drivers/net/usb/cdc_ncm.c        |   17 +--
> > > >  drivers/net/usb/huawei_cdc_ncm.c |  230 ++++++++++++++++++++++=
++++++++++++++++
> > > >  include/linux/usb/cdc_ncm.h      |    3 +
> > > >  5 files changed, 253 insertions(+), 13 deletions(-)
> > > >  create mode 100644 drivers/net/usb/huawei_cdc_ncm.c
> > > >=20
> > > > --=20
> > > > 1.7.10.4
> > > >=20
> > > > --
> > > > To unsubscribe from this list: send the line "unsubscribe netde=
v" in
> > > > the body of a message to majordomo@vger.kernel.org
> > > > More majordomo info at  http://vger.kernel.org/majordomo-info.h=
tml
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-u=
sb" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.htm=
l
> >=20
> >=20
