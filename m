From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: AW: ixgbe: Regression, unsupported SFP+ modules on 10Gbit/s
 X520 NIC no longer work with allow_unsupported_sfp=1
Date: Wed, 20 Feb 2013 05:39:56 -0800
Message-ID: <1361367596.7173.52.camel@jtkirshe-mobl>
References: <D76AF9B3DDF5FF49833AC0A1396549060314FBD8@s554.babiel.com>
	 <87618083B2453E4A8714035B62D67992337B4938@FMSMSX102.amr.corp.intel.com>
	 <D76AF9B3DDF5FF49833AC0A1396549060314FC0C@s554.babiel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-p3mjvaIfZu/XHEwqmvp9"
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Fujinaka, Todd" <todd.fujinaka@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Boom, Douglas" <douglas.boom@intel.com>
To: Stefan Behte <s.behte@babiel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:36610 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935310Ab3BTNj6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2013 08:39:58 -0500
In-Reply-To: <D76AF9B3DDF5FF49833AC0A1396549060314FC0C@s554.babiel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-p3mjvaIfZu/XHEwqmvp9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-02-18 at 04:13 -0800, Stefan Behte wrote:
> Hi,
>=20
> >I don't think this is a regression since the check you are bypassing wit=
h your patch has nothing to do with the unsupported SFP modules lock (this =
check is few lines below).
> No, that part skipped by the goto.
>=20
> >The check you are trying to bypass is actually for supported 1gig SFP mo=
dule types.
> Actually that's inaccurate: if it's not a compatible module, it's being m=
arked as unsupported. That's the whole purpose of that code.
>=20
>                 //if it's not a 10GE Module
>                 if (comp_codes_10g =3D=3D 0 &&
>=20
>                     // and if the current module is NOT compatible (hw->p=
hy.sfp_type must be 9, 10, 11 or 12, see ixgbe_type.h)
>                     !(hw->phy.sfp_type =3D=3D ixgbe_sfp_type_1g_cu_core1 =
||
>                       hw->phy.sfp_type =3D=3D ixgbe_sfp_type_1g_cu_core0 =
||
>                       hw->phy.sfp_type =3D=3D ixgbe_sfp_type_1g_sx_core0 =
||
>                       hw->phy.sfp_type =3D=3D ixgbe_sfp_type_1g_sx_core1)=
) {
>=20
>                        // then mark hardware as unsupported -> the SFP wi=
ll not be enabled
>                        // but it should be, if allow_unsupported_sfp=3D1
>                         hw->phy.type =3D ixgbe_phy_sfp_unsupported;
>                         status =3D IXGBE_ERR_SFP_NOT_SUPPORTED;
>=20
>                         // skip other stuff, e.g. the checks you mentione=
d below
>                         goto out;
>                 }
>=20
> Ok, my patch is not nice. I've attached one that completely removes the b=
lock, as IMHO its only purpose is to lock out non-intel SFPs. Of course I'v=
e verified that the code works (at least for me :)).
>=20
> >1. What is the SFP+ module you are using (make/model/type)?
> The module is a TP-Link TL-SM311LS 1000BASE-LX LC.
>=20
> >2. What is the hw->phy.sfp_type set to (you can add a printk, or if you =
plug it in after load there should be a "detected SFP+" message in dmesg).
> It's in the log I sent:
> [13920.949008] ixgbe 0000:02:00.1: MAC: 2, PHY: 14, SFP+: 65535, PBA No: =
E68793-005
> So hw->phy.sfp_type is 65535.
>=20
> >3. You said that you get the interfaces, but are they operational (link,=
 pass traffic etc)?
> I'm going to run some longterm tests for reliability. But yes, they appea=
r to be working just fine.
>=20
> >4. Because you mentioned that this is a regression - was there a previou=
s version of the driver that loads without the unsupported errors with this=
 SFP module?
> Not sure, but as a result of the discussion (http://marc.info/?l=3De1000-=
devel&m=3D132697406314730&w=3D2) there was a decision and patch that would =
allow non-intel SFPs.
> So I don't care too much what we call this - the driver does not work as =
intended: Intel is preventing use of 3rd-party SFPs.
>=20
> So can we please remove this lock-in?
>=20
> Best regards,
> Stefan Behte
>=20
> --------------------------------------------
>=20
> Stefan Behte
> Teamleiter Systemadministration
>=20
> Babiel GmbH
> Erkrather Str. 224a
> D-40233 D=C3=BCsseldorf
>=20
> Tel: 0211-179349 0
> Fax: 0211-179349 29
> E-Mail: s.behte@babiel.com
> Internet: http://www.babiel.com
>=20
> Gesch=C3=A4ftsf=C3=BChrer: Georg Babiel, Dr. Rainer Babiel, Harald Babiel=
 Amtsgericht D=C3=BCsseldorf HRB 38633
>=20
> ~~~~~~~~~~~~~~ DISCLAIMER ~~~~~~~~~~~~~~~
>=20
> The information transmitted in this electronic mail message may contain c=
onfidential and or privileged materials. Any review, retransmission, dissem=
ination or other use of or taking of any action in reliance upon, this info=
rmation by persons or entities other than the intended recipient is prohibi=
ted. If you receive such e-mails in error, please contact the sender and de=
lete the material from any computer.
>=20
>=20
> -----Urspr=C3=BCngliche Nachricht-----
> Von: Tantilov, Emil S [mailto:emil.s.tantilov@intel.com]
> Gesendet: Freitag, 15. Februar 2013 21:14
> An: Stefan Behte; netdev@vger.kernel.org
> Cc: Skidmore, Donald C; Kirsher, Jeffrey T; Fujinaka, Todd; Ronciak, John
> Betreff: RE: ixgbe: Regression, unsupported SFP+ modules on 10Gbit/s X520=
 NIC no longer work with allow_unsupported_sfp=3D1
>=20
> Stefan,
>=20
> I don't think this is a regression since the check you are bypassing with=
 your patch has nothing to do with the unsupported SFP modules lock (this c=
heck is few lines below). The check you are trying to bypass is actually fo=
r supported 1gig SFP module types. Could you provide some additional inform=
ation about your setup?
>=20
> 1. What is the SFP+ module you are using (make/model/type)?
> 2. What is the hw->phy.sfp_type set to (you can add a printk, or if you p=
lug it in after load there should be a "detected SFP+" message in dmesg).
> 3. You said that you get the interfaces, but are they operational (link, =
pass traffic etc)?
> 4. Because you mentioned that this is a regression - was there a previous=
 version of the driver that loads without the unsupported errors with this =
SFP module?
>=20
> Thanks,
> Emil
>=20
> >-----Original Message-----
> >From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]=
 On
> >Behalf Of Stefan Behte
> >Sent: Thursday, February 14, 2013 4:58 PM
> >To: netdev@vger.kernel.org
> >Subject: ixgbe: Regression, unsupported SFP+ modules on 10Gbit/s X520 NI=
C
> >no longer work with allow_unsupported_sfp=3D1
> >
> >Hello,
> >
> >I was told to send a mail, even though I had already opened
> >https://bugzilla.kernel.org/show_bug.cgi?id=3D53901.
> >
> >Someone patched the ixgbe driver, and now non-intel SFPs do not work
> >anymore, again. The issue of intel "lock-in" was discussed before here:
> >http://marc.info/?l=3De1000-devel&m=3D132697406314730&w=3D2
> >
> >A tested patch is attached.
> >
> >Here is what I do:
> >
> ># modinfo ixgbe | grep parm
> >parm:           max_vfs:Maximum number of virtual functions to allocate =
per
> >physical function - default is zero and maximum value is 63 (uint)
> >parm:           allow_unsupported_sfp:Allow unsupported and untested SFP=
+
> >modules on 82599-based adapters (uint)
> >parm:           debug:Debug level (0=3Dnone,...,16=3Dall) (int)
> >
> ># modprobe -r ixgbe
> ># modprobe ixgbe allow_unsupported_sfp=3D0
> ># dmesg | grep ixgbe
> >[13690.355090] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver -
> >version 3.9.15-k
> >[13690.355092] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
> >[13690.373128] ixgbe 0000:02:00.0: failed to load because an unsupported
> >SFP+ module type was detected.
> >[13690.373177] ixgbe 0000:02:00.0: Reload the driver after installing a
> >supported module.
> >[13690.390987] ixgbe 0000:02:00.1: failed to load because an unsupported
> >SFP+ module type was detected.
> >[13690.391036] ixgbe 0000:02:00.1: Reload the driver after installing a
> >supported module.
> >
> ># modprobe -r ixgbe
> ># modprobe ixgbe allow_unsupported_sfp=3D1
> ># dmesg | grep ixgbe
> >[13679.088849] dca service started, version 1.12.1
> >[13679.091174] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver -
> >version 3.9.15-k
> >[13679.091177] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
> >[13679.109194] ixgbe 0000:02:00.0: failed to load because an unsupported
> >SFP+ module type was detected.
> >[13679.109243] ixgbe 0000:02:00.0: Reload the driver after installing a
> >supported module.
> >[13679.127399] ixgbe 0000:02:00.1: failed to load because an unsupported
> >SFP+ module type was detected.
> >[13679.127450] ixgbe 0000:02:00.1: Reload the driver after installing a
> >supported module.
> >[13690.352712] dca service started, version 1.12.1
> >
> >
> >With the patch:
> >
> ># modprobe -r ixgbe
> ># modprobe ixgbe allow_unsupported_sfp=3D0
> ># dmesg | grep ixgbe
> >[13907.870087] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver -
> >version 3.9.15-k
> >[13907.870089] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
> >[13907.888106] ixgbe 0000:02:00.0: failed to load because an unsupported
> >SFP+ module type was detected.
> >[13907.888155] ixgbe 0000:02:00.0: Reload the driver after installing a
> >supported module.
> >[13907.906187] ixgbe 0000:02:00.1: failed to load because an unsupported
> >SFP+ module type was detected.
> >[13907.906237] ixgbe 0000:02:00.1: Reload the driver after installing a
> >supported module.
> >
> >
> ># modprobe -r ixgbe
> ># modprobe ixgbe allow_unsupported_sfp=3D1
> ># dmesg | grep ixgbe
> >[13914.534758] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver -
> >version3.9.15-k
> >[13914.534761] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
> >[13914.552820] ixgbe 0000:02:00.0 (unregistered net_device): WARNING: In=
tel
> >(R) Network Connections are quality tested using Intel (R) Ethernet Opti=
cs.
> >Using untested modules is not supported and may cause unstable operation=
 or
> >damage to
> >the module or the adapter.  Intel Corporation is not responsible for any
> >harm caused by using untested modules.
> >[13917.741931] ixgbe 0000:02:00.0: irq 50 for MSI/MSI-X
> >[13917.741938] ixgbe 0000:02:00.0: irq 51 for MSI/MSI-X
> >[13917.741942] ixgbe 0000:02:00.0: irq 52 for MSI/MSI-X
> >[13917.741951] ixgbe 0000:02:00.0: irq 53 for MSI/MSI-X
> >[13917.741955] ixgbe 0000:02:00.0: irq 54 for MSI/MSI-X
> >[13917.741960] ixgbe 0000:02:00.0: irq 55 for MSI/MSI-X
> >[13917.741965] ixgbe 0000:02:00.0: irq 56 for MSI/MSI-X
> >[13917.741969] ixgbe 0000:02:00.0: irq 57 for MSI/MSI-X
> >[13917.741973] ixgbe 0000:02:00.0: irq 58 for MSI/MSI-X
> >[13917.742002] ixgbe 0000:02:00.0: Multiqueue Enabled: Rx Queue count =
=3D 8,
> >Tx Queue count =3D 8
> >[13917.742126] ixgbe 0000:02:00.0: (PCI Express:5.0GT/s:Width x8)
> >90:e2:ba:37:3b:18
> >[13917.742207] ixgbe 0000:02:00.0: MAC: 2, PHY: 14, SFP+: 65535, PBA No:
> >E68793-005
> >[13917.743461] ixgbe 0000:02:00.0: Intel(R) 10 Gigabit Network Connectio=
n
> >[13917.761578] ixgbe 0000:02:00.1 (unregistered net_device): WARNING: In=
tel
> >(R) Network Connections are quality tested using Intel (R) Ethernet Opti=
cs.
> >Using untested modules is not supported and may cause unstable operation=
 or
> >damage to the module or the adapter.  Intel Corporation is not responsib=
le
> >for any harm caused by using untested modules.
> >[13920.948726] ixgbe 0000:02:00.1: irq 59 for MSI/MSI-X
> >[13920.948737] ixgbe 0000:02:00.1: irq 60 for MSI/MSI-X
> >[13920.948742] ixgbe 0000:02:00.1: irq 61 for MSI/MSI-X
> >[13920.948746] ixgbe 0000:02:00.1: irq 62 for MSI/MSI-X
> >[13920.948751] ixgbe 0000:02:00.1: irq 63 for MSI/MSI-X
> >[13920.948757] ixgbe 0000:02:00.1: irq 64 for MSI/MSI-X
> >[13920.948761] ixgbe 0000:02:00.1: irq 65 for MSI/MSI-X
> >[13920.948767] ixgbe 0000:02:00.1: irq 66 for MSI/MSI-X
> >[13920.948774] ixgbe 0000:02:00.1: irq 67 for MSI/MSI-X
> >[13920.948803] ixgbe 0000:02:00.1: Multiqueue Enabled: Rx Queue count =
=3D 8,
> >Tx Queue count =3D 8
> >[13920.948927] ixgbe 0000:02:00.1: (PCI Express:5.0GT/s:Width x8)
> >90:e2:ba:37:3b:19
> >[13920.949008] ixgbe 0000:02:00.1: MAC: 2, PHY: 14, SFP+: 65535, PBA No:
> >E68793-005
> >[13920.950237] ixgbe 0000:02:00.1: Intel(R) 10 Gigabit Network Connectio=
n
> >
> >And then I get two nice Interfaces. Please apply. :)
> >
> >
> >Best regards,
> >
> >Stefan Behte
> >

Stefan,

We are currently working on the resolution to your issue.  I have also
added your patch to my queue of ixgbe patches.

Cheers,
Jeff

--=-p3mjvaIfZu/XHEwqmvp9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRJNIsAAoJEOVv75VaS+3OLbAP/1gzHliYlRPVmFLjsHP2X9dN
9afGlotRe+BAtu3rz/dfzkajpOBR+2qJadtiBwKKsLMhWgspNKKyQtt0PAFYTdMq
KyTCRghT2Qy4nHvta4KGb7XAGJd8KJ/n/DmUgJFe4X7+KfPz2+Gm6O7dZSWqiINc
MnQV4QPZR90nP5y/HdnXKVtSwALfQr+/hxn/ZhQS3hXv9owmNug5yawwOp5v2D/f
Psj6zZkj5ayyF4051zf6kxQaZjzu4xhNjes2/40cl4qs+LZYcSqi8KPCbMPVrLLk
YZzjFVkIyICWGERgDwlBrEbmeSuZatw800zO5if1EhJoh1vEugWm+S8vD32kxf31
Tl+KYTauCylwnjp8jq4PN6xiYZBQBotkCSkWKCXusLeTL3vEbNSIxF5vN0GznBMw
BkzTp68dUoGGvNIv0gampppc4gjn4+Owjmr56FQcrmVNqQYkDBQy/p5j98aabbtS
HUjDNtYwGyU8yjjmzc4Ho7lA6U9i5LuTrO1Zf9AePUMcyrIICi90wOMLF7f4NEpA
Nad+RVfcaS05GCi5xUXHyflrZzWjlsoLc4rhyfrgJUnRX7FMCzG3BKCSiAbk7DPN
U1w2VHqRHf5u4ghqDWv9iZmkUH2tPanyUi8O5G0+6FjJyFsni4/n5MT8oIEsBzMK
WNeipltVJh2c/bZgD6nl
=xTy0
-----END PGP SIGNATURE-----

--=-p3mjvaIfZu/XHEwqmvp9--
