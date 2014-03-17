From: Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Subject: Re: [PATCH net-next v6 0/3] The huawei_cdc_ncm driver / E3276
 problem
Date: Mon, 17 Mar 2014 13:59:19 +0200
Message-ID: <20140317115919.GK3200@reaktio.net>
References: <20140314075548.GX3200@reaktio.net>
 <87wqfxnppc.fsf@nemi.mork.no>
 <20140314084159.GA3200@reaktio.net>
 <87siqlnol8.fsf@nemi.mork.no>
 <20140314090525.GB3200@reaktio.net>
 <87ob19nndo.fsf@nemi.mork.no>
 <20140314125934.GC3200@reaktio.net>
 <87vbvgnbv3.fsf@nemi.mork.no>
 <20140314142559.GD3200@reaktio.net>
 <87k3btm57a.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Enrico Mioso <mrkiko.rs@gmail.com>,
	Oliver Neukum <oliver@neukum.org>
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emh03.mail.saunalahti.fi ([62.142.5.109]:59534 "EHLO
	emh03.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932866AbaCQL7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 07:59:22 -0400
Content-Disposition: inline
In-Reply-To: <87k3btm57a.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 17, 2014 at 12:31:53PM +0100, Bj=F8rn Mork wrote:
> Pasi K=E4rkk=E4inen <pasik@iki.fi> writes:
>=20
> > http://pasik.reaktio.net/huawei-e3276-usbmon3.pcapng
> >
> > (I did move the dongle to a different usb bus nr 3 to make it the o=
nly device on that bus before capturing..)=20
>=20
> Thanks.  That helps.
>=20
> > So what I did:
> >
> > - Start wireshark capture on USB bus nr 3.
> > - Plug in the Huawei E3276 dongle.
> > - Wait for usb_modeswitch to happen.
> > - Use minicom to talk to /dev/cdc-wdm0 and send AT commands to conn=
ect to Internet:
> > 	- ATQ0 V1 E1 S0=3D0
> > 	- AT^NDISDUP=3D1,1,"internet"
> >
> > - After the dongle has connected query for DHCP status:
> > 	- AT^DHCP?
> >
> > - Launch dhcp client (dhclient) on wwp0s20u1i1 interface.
> > - Wait for a while and see RX error counters increasing on ifconfig=
 output.
> > - Cancel (ctrl+c) the dhclient.
> > - Stop wireshark capture.=20
> >
> >
> > Does that capture file show anything interesting to you?=20
>=20
> I see two devices (excluding the root hub), both with a single
> configuration:=20
>  12d1:14fe (addr: 4)
>  12d1:1506 (addr: 5)
>=20
> The 12d1:14fe device is before mode switching, so I'll just ignore th=
at
> and concentrate on the two modem interfaces of the 12d1:1506 device:
> 0 (serial, AT command) and 1 (NCM combined).
>=20

Correct.=20


> Possibly unrelated, but a bit unexpected:  I see a request for string
> descriptor 0xee, which is the "magic Microsoft descriptor".  I don't
> know of any Linux software requesting this by default.  Anyone else?
> The request results in a stall, so it's obviously unsupported by this
> devices and cannot possibly matter.  But I still wonder who sends it.=
=2E.
>=20

Hmm.. no idea about that :) This is a pretty standard Fedora 20 box,
with no thirdparty software..=20


>=20
> Anyway, I believe I can see the problem. Or some part of it.  I'm sti=
ll
> not quite sure what the cause is.
>=20
> If you look at the data sent by the driver to endpoint 0x02 (which is
> the endpoint used for NCM data from host to device), you'll see
> something like this:
>=20
> 0040  4e 43 4d 48 0c 00 01 00 00 80 0c 00 4e 43 4d 30   NCMH........N=
CM0
> 0050  10 00 00 00 b8 00 56 01 00 00 00 00 00 00 00 00   ......V......=
=2E..
> 0060  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
> 0070  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
> 0080  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
> 0090  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
> 00a0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
> 00b0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
> 00c0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
> 00d0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
> 00e0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
> 00f0  00 00 00 00 00 00 00 00 ff ff ff ff ff ff 0c 5b   .............=
=2E.[
> 0100  8f 27 9a 64 08 00 45 10 01 48 00 00 00 00 80 11   .'.d..E..H...=
=2E..
> 0110  39 96 00 00 00 00 ff ff ff ff 00 44 00 43 01 34   9..........D.=
C.4
> 0120  3a dd 01 01 06 00 ef 52 11 28 00 00 00 00 00 00   :......R.(...=
=2E..
> 0130  00 00 00 00 00 00 00 00 00 00 00 00 00 00 0c 5b   .............=
=2E.[
> 0140  8f 27 9a 64 00 00 00 00 00 00 00 00 00 00 00 00   .'.d.........=
=2E..
> 0150  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
> 0160  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
> 0170  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
> 0180  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
> 0190  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
> 01a0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
> 01b0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
> 01c0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
> 01d0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
> 01e0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
> 01f0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
> 0200  00 00 00 00 00 00 00 00 00 00 00 00 00 00 63 82   .............=
=2Ec.
> 0210  53 63 35 01 01 37 0d 01 1c 02 79 0f 06 0c 28 29   Sc5..7....y..=
=2E()
> 0220  2a 1a 77 03 3d 07 01 0c 5b 8f 27 9a 64 ff 00 00   *.w.=3D...[.'=
=2Ed...
> 0230  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
> 0240  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
> 0250  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   .............=
=2E..
>=20
> followed by lots of zero bytes because we pad to the max size.
>=20
> Looking at the data receided from the device on endpoint 0x83 (which =
is
> used for data from device to host):
>=20
> 0040  6e 63 6d 68 10 00 00 00 6e 00 00 00 10 00 00 00   ncmh....n....=
=2E..
> 0050  6e 63 6d 30 20 00 00 00 00 00 00 00 00 00 00 00   ncm0 ........=
=2E..
> 0060  32 00 00 00 3c 00 00 00 00 00 00 00 00 00 00 00   2...<........=
=2E..
> 0070  00 00 ff ff ff ff ff ff 4c 54 99 45 e5 d5 08 06   ........LT.E.=
=2E..
> 0080  00 01 08 00 06 04 00 01 4c 54 99 45 e5 d5 0a 3d   ........LT.E.=
=2E.=3D
> 0090  8a 41 00 00 00 00 00 00 0a 3d 8a 48 00 00 00 00   .A.......=3D.=
H....
> 00a0  00 00 00 00 00 00 00 00 00 00 00 00 00 00         .............=
=2E
>=20
>=20
> The padding differences making the latter much more compact can be
> ignored.  But do notice the 'ncmh' !=3D 'NCMH' and 'ncm0' !=3D 'NCM0'=
=2E
> These are all standard NCM header and datagram signatures, but the lo=
wer
> and upper case versions have different meanings.  The lower case vers=
ion
> means that the device use 32 bit length and index fields, while the
> driver use the variants with 16 bit fields.
>=20
> This explains why the driver drops received frames.  It only supports
> the 16 bit variants.  They are mandatory according to the spec and th=
e
> driver will never accept buffer sizes big enough for the 32 bit varia=
nts
> make a difference.  So adding support for the 32 bit versions has so =
far
> seemed pointless.
>=20
> But here we have a device which does not comform to spec (that's OK,
> Huawei doesn't claim it does - this is a vendor specific function aft=
er
> all), and which seems to be locked to 32 bit mode?  Either it require=
s
> the 32 bit variant, or we are doing something "wrong" during setup to
> make the device go into this mode.
>=20

Makes sense.. this seems like a good progress getting the "mystery" of =
this dongle solved.


> Adding 32 bit NCM support should be fairly easy after the changes we
> made to support MBIM.  But we need to know when to enable it, or whet=
her
> we do something wrong during setup.  So it would be useful to see if =
the
> cdc_ncm_setup function logs any interesting debug messages.
>=20
> Since you have dynamic debugging, could you do:
>=20
>   mount -t debugfs none /sys/kernel/debug
>   echo "file cdc_ncm.c +fp" >/sys/kernel/debug/dynamic_debug/control
>=20
> and then reconnect the device while capturing debug output?
>=20

I just did:

# mount -t debugfs none /sys/kernel/debug
(well it was already mounted by fedora)

# cat /proc/sys/kernel/printk
4       4       1       7

# echo 8 > /proc/sys/kernel/printk
# cat /proc/sys/kernel/printk
8       4       1       7

# echo "file cdc_ncm.c +fp" >/sys/kernel/debug/dynamic_debug/control


And then I connected the dongle.. nothing in dmesg. I also tried changi=
ng the filename=20
to huawei_cdc_ncm.c but that didn't produce any output either.=20

I wonder if i'm missing some commands to get debug output to dmesg..=20

>=20
>=20
> Bj=F8rn

Thanks,

-- Pasi
