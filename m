From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: ixgbe: Regression, unsupported SFP+ modules on 10Gbit/s X520
 NIC no longer work with allow_unsupported_sfp=1
Date: Thu, 14 Feb 2013 16:28:56 -0800
Message-ID: <1360888136.26020.4.camel@jtkirshe-mobl>
References: <D76AF9B3DDF5FF49833AC0A1396549060333A1C5@s554.babiel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-PMFf2NBKCQbc1YWK5wLw"
Cc: netdev@vger.kernel.org,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>
To: Stefan Behte <s.behte@babiel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:31452 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932639Ab3BOA27 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 19:28:59 -0500
In-Reply-To: <D76AF9B3DDF5FF49833AC0A1396549060333A1C5@s554.babiel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PMFf2NBKCQbc1YWK5wLw
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-02-15 at 01:10 +0100, Stefan Behte wrote:
> Hello,
>=20
> I was told to send a mail, even though I had already opened
> https://bugzilla.kernel.org/show_bug.cgi?id=3D53901.
>=20
> Someone patched the ixgbe driver, and now non-intel SFPs do not work
> anymore, again. The issue of intel "lock-in" was discussed before
> here:
> http://marc.info/?l=3De1000-devel&m=3D132697406314730&w=3D2
>=20
> A tested patch is attached.
>=20
> Here is what I do:
>=20
> # modinfo ixgbe | grep parm
> parm:           max_vfs:Maximum number of virtual functions to
> allocate per physical function - default is zero and maximum value is
> 63 (uint)
> parm:           allow_unsupported_sfp:Allow unsupported and untested
> SFP+ modules on 82599-based adapters (uint)
> parm:           debug:Debug level (0=3Dnone,...,16=3Dall) (int)
>=20
> # modprobe -r ixgbe
> # modprobe ixgbe allow_unsupported_sfp=3D0
> # dmesg | grep ixgbe
> [13690.355090] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver -
> version 3.9.15-k
> [13690.355092] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
> [13690.373128] ixgbe 0000:02:00.0: failed to load because an
> unsupported SFP+ module type was detected.
> [13690.373177] ixgbe 0000:02:00.0: Reload the driver after installing
> a supported module.
> [13690.390987] ixgbe 0000:02:00.1: failed to load because an
> unsupported SFP+ module type was detected.
> [13690.391036] ixgbe 0000:02:00.1: Reload the driver after installing
> a supported module.
>=20
> # modprobe -r ixgbe
> # modprobe ixgbe allow_unsupported_sfp=3D1
> # dmesg | grep ixgbe
> [13679.088849] dca service started, version 1.12.1
> [13679.091174] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver -
> version 3.9.15-k
> [13679.091177] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
> [13679.109194] ixgbe 0000:02:00.0: failed to load because an
> unsupported SFP+ module type was detected.
> [13679.109243] ixgbe 0000:02:00.0: Reload the driver after installing
> a supported module.
> [13679.127399] ixgbe 0000:02:00.1: failed to load because an
> unsupported SFP+ module type was detected.
> [13679.127450] ixgbe 0000:02:00.1: Reload the driver after installing
> a supported module.
> [13690.352712] dca service started, version 1.12.1
>=20
>=20
> With the patch:
>=20
> # modprobe -r ixgbe
> # modprobe ixgbe allow_unsupported_sfp=3D0
> # dmesg | grep ixgbe
> [13907.870087] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver -
> version 3.9.15-k
> [13907.870089] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
> [13907.888106] ixgbe 0000:02:00.0: failed to load because an
> unsupported SFP+ module type was detected.
> [13907.888155] ixgbe 0000:02:00.0: Reload the driver after installing
> a supported module.
> [13907.906187] ixgbe 0000:02:00.1: failed to load because an
> unsupported SFP+ module type was detected.
> [13907.906237] ixgbe 0000:02:00.1: Reload the driver after installing
> a supported module.
>=20
>=20
> # modprobe -r ixgbe
> # modprobe ixgbe allow_unsupported_sfp=3D1
> # dmesg | grep ixgbe
> [13914.534758] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver -
> version3.9.15-k
> [13914.534761] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
> [13914.552820] ixgbe 0000:02:00.0 (unregistered net_device): WARNING:
> Intel (R) Network Connections are quality tested using Intel (R)
> Ethernet Optics.  Using untested modules is not supported and may
> cause unstable operation or damage to
> the module or the adapter.  Intel Corporation is not responsible for
> any harm caused by using untested modules.
> [13917.741931] ixgbe 0000:02:00.0: irq 50 for MSI/MSI-X
> [13917.741938] ixgbe 0000:02:00.0: irq 51 for MSI/MSI-X
> [13917.741942] ixgbe 0000:02:00.0: irq 52 for MSI/MSI-X
> [13917.741951] ixgbe 0000:02:00.0: irq 53 for MSI/MSI-X
> [13917.741955] ixgbe 0000:02:00.0: irq 54 for MSI/MSI-X
> [13917.741960] ixgbe 0000:02:00.0: irq 55 for MSI/MSI-X
> [13917.741965] ixgbe 0000:02:00.0: irq 56 for MSI/MSI-X
> [13917.741969] ixgbe 0000:02:00.0: irq 57 for MSI/MSI-X
> [13917.741973] ixgbe 0000:02:00.0: irq 58 for MSI/MSI-X
> [13917.742002] ixgbe 0000:02:00.0: Multiqueue Enabled: Rx Queue count
> =3D 8, Tx Queue count =3D 8
> [13917.742126] ixgbe 0000:02:00.0: (PCI Express:5.0GT/s:Width x8)
> 90:e2:ba:37:3b:18
> [13917.742207] ixgbe 0000:02:00.0: MAC: 2, PHY: 14, SFP+: 65535, PBA
> No: E68793-005
> [13917.743461] ixgbe 0000:02:00.0: Intel(R) 10 Gigabit Network
> Connection
> [13917.761578] ixgbe 0000:02:00.1 (unregistered net_device): WARNING:
> Intel (R) Network Connections are quality tested using Intel (R)
> Ethernet Optics.  Using untested modules is not supported and may
> cause unstable operation or damage to the module or the adapter.
> Intel Corporation is not responsible for any harm caused by using
> untested modules.
> [13920.948726] ixgbe 0000:02:00.1: irq 59 for MSI/MSI-X
> [13920.948737] ixgbe 0000:02:00.1: irq 60 for MSI/MSI-X
> [13920.948742] ixgbe 0000:02:00.1: irq 61 for MSI/MSI-X
> [13920.948746] ixgbe 0000:02:00.1: irq 62 for MSI/MSI-X
> [13920.948751] ixgbe 0000:02:00.1: irq 63 for MSI/MSI-X
> [13920.948757] ixgbe 0000:02:00.1: irq 64 for MSI/MSI-X
> [13920.948761] ixgbe 0000:02:00.1: irq 65 for MSI/MSI-X
> [13920.948767] ixgbe 0000:02:00.1: irq 66 for MSI/MSI-X
> [13920.948774] ixgbe 0000:02:00.1: irq 67 for MSI/MSI-X
> [13920.948803] ixgbe 0000:02:00.1: Multiqueue Enabled: Rx Queue count
> =3D 8, Tx Queue count =3D 8
> [13920.948927] ixgbe 0000:02:00.1: (PCI Express:5.0GT/s:Width x8)
> 90:e2:ba:37:3b:19
> [13920.949008] ixgbe 0000:02:00.1: MAC: 2, PHY: 14, SFP+: 65535, PBA
> No: E68793-005
> [13920.950237] ixgbe 0000:02:00.1: Intel(R) 10 Gigabit Network
> Connection
>=20
> And then I get two nice Interfaces. Please apply. :)
>=20
>=20
> Best regards,
>=20
> Stefan Behte
>=20
> Babiel GmbH
> Moskauer Strasse 27
> D-40227 D=C3=BCsseldorf
>=20
> Tel:    0211-179349 0
> Fax:    0211-179349 29
> E-Mail: S.Behte@babiel.com
> Internet: http://www.babiel.com
>=20
Thanks Stefan, I will make sure that we take a look at the bugzilla.


--=-PMFf2NBKCQbc1YWK5wLw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRHYFIAAoJEOVv75VaS+3OdKoP/i6scGIups6rdMLU3NHnGQv4
B9mThmUe33Shw5qW/OsK2gM+Qo2dU3KpzcHV5TnNBNFg1uGa40Lj5rYxlz1metbO
FMEPXzuuVFYRLc3rd3niE/mXPGLL2K1QrUoKzIjBPkFOTjElEXX+cyGq0P86Scgl
kpqOwPRL2fcX5TSO+Pj1FI7FWOuo/+KWhKEDlU45VE1eLqFz1DkxMjmBz0s6bhbf
Rm18Nndudew1LwPwOZg7wAIw53A5femLV0vXfTJyvt57sE7+7vDpfkzIePUGv1O/
IvMuybNmMpzCY3xcFoxA8YZ89nKqeaCttAPq0RpPi6YebbuvNvx5wtUQcst5SIPj
GTgEt5taRvlGfItG8dqhq6hc6I5+Z870bbPwtwwN6hqxgoMeu09Tb0ZAx1tUcrkB
AJofHKR1Wds9PqN1pFBhqa8dr+Sbr6T4vULGtzQrZde4My6rYGzPVX05nJF2jmO7
51PkhzFRQBTlnje/MpN2u/urmijnG92v/qGodDUEAU83oV90hsD0nmCzV+iJvo92
l7LYoA9yBLevFFYkdFyu9DLYY3BASLXTTIhiBtVEkf/Tu359+ZfcbMcC7W0qpkJC
t6zjvmPRz7GkVzTZUBFLwDgSqPh76LwCYawG6WeiJxjLzJ8lOkFdjP0CQ6LMgrXq
E5OGZ5oUQhY7L3xlHddA
=6Br9
-----END PGP SIGNATURE-----

--=-PMFf2NBKCQbc1YWK5wLw--
