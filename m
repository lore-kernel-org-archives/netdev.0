From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: ixgbe: Regression, unsupported SFP+ modules on 10Gbit/s X520
 NIC no longer work with allow_unsupported_sfp=1
Date: Fri, 15 Feb 2013 20:14:19 +0000
Message-ID: <87618083B2453E4A8714035B62D67992337B4938@FMSMSX102.amr.corp.intel.com>
References: <D76AF9B3DDF5FF49833AC0A1396549060314FBD8@s554.babiel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Fujinaka, Todd" <todd.fujinaka@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Stefan Behte <s.behte@babiel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42376 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751022Ab3BOUOV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 15:14:21 -0500
In-Reply-To: <D76AF9B3DDF5FF49833AC0A1396549060314FBD8@s554.babiel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefan,

I don't think this is a regression since the check you are bypassing wi=
th your patch has nothing to do with the unsupported SFP modules lock (=
this check is few lines below). The check you are trying to bypass is a=
ctually for supported 1gig SFP module types. Could you provide some add=
itional information about your setup?=20

1. What is the SFP+ module you are using (make/model/type)?=20
2. What is the hw->phy.sfp_type set to (you can add a printk, or if you=
 plug it in after load there should be a "detected SFP+" message in dme=
sg).
3. You said that you get the interfaces, but are they operational (link=
, pass traffic etc)?
4. Because you mentioned that this is a regression - was there a previo=
us version of the driver that loads without the unsupported errors with=
 this SFP module?

Thanks,
Emil

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.or=
g] On
>Behalf Of Stefan Behte
>Sent: Thursday, February 14, 2013 4:58 PM
>To: netdev@vger.kernel.org
>Subject: ixgbe: Regression, unsupported SFP+ modules on 10Gbit/s X520 =
NIC
>no longer work with allow_unsupported_sfp=3D1
>
>Hello,
>
>I was told to send a mail, even though I had already opened
>https://bugzilla.kernel.org/show_bug.cgi?id=3D53901.
>
>Someone patched the ixgbe driver, and now non-intel SFPs do not work
>anymore, again. The issue of intel "lock-in" was discussed before here=
:
>http://marc.info/?l=3De1000-devel&m=3D132697406314730&w=3D2
>
>A tested patch is attached.
>
>Here is what I do:
>
># modinfo ixgbe | grep parm
>parm:           max_vfs:Maximum number of virtual functions to allocat=
e per
>physical function - default is zero and maximum value is 63 (uint)
>parm:           allow_unsupported_sfp:Allow unsupported and untested S=
=46P+
>modules on 82599-based adapters (uint)
>parm:           debug:Debug level (0=3Dnone,...,16=3Dall) (int)
>
># modprobe -r ixgbe
># modprobe ixgbe allow_unsupported_sfp=3D0
># dmesg | grep ixgbe
>[13690.355090] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver -
>version 3.9.15-k
>[13690.355092] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
>[13690.373128] ixgbe 0000:02:00.0: failed to load because an unsupport=
ed
>SFP+ module type was detected.
>[13690.373177] ixgbe 0000:02:00.0: Reload the driver after installing =
a
>supported module.
>[13690.390987] ixgbe 0000:02:00.1: failed to load because an unsupport=
ed
>SFP+ module type was detected.
>[13690.391036] ixgbe 0000:02:00.1: Reload the driver after installing =
a
>supported module.
>
># modprobe -r ixgbe
># modprobe ixgbe allow_unsupported_sfp=3D1
># dmesg | grep ixgbe
>[13679.088849] dca service started, version 1.12.1
>[13679.091174] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver -
>version 3.9.15-k
>[13679.091177] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
>[13679.109194] ixgbe 0000:02:00.0: failed to load because an unsupport=
ed
>SFP+ module type was detected.
>[13679.109243] ixgbe 0000:02:00.0: Reload the driver after installing =
a
>supported module.
>[13679.127399] ixgbe 0000:02:00.1: failed to load because an unsupport=
ed
>SFP+ module type was detected.
>[13679.127450] ixgbe 0000:02:00.1: Reload the driver after installing =
a
>supported module.
>[13690.352712] dca service started, version 1.12.1
>
>
>With the patch:
>
># modprobe -r ixgbe
># modprobe ixgbe allow_unsupported_sfp=3D0
># dmesg | grep ixgbe
>[13907.870087] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver -
>version 3.9.15-k
>[13907.870089] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
>[13907.888106] ixgbe 0000:02:00.0: failed to load because an unsupport=
ed
>SFP+ module type was detected.
>[13907.888155] ixgbe 0000:02:00.0: Reload the driver after installing =
a
>supported module.
>[13907.906187] ixgbe 0000:02:00.1: failed to load because an unsupport=
ed
>SFP+ module type was detected.
>[13907.906237] ixgbe 0000:02:00.1: Reload the driver after installing =
a
>supported module.
>
>
># modprobe -r ixgbe
># modprobe ixgbe allow_unsupported_sfp=3D1
># dmesg | grep ixgbe
>[13914.534758] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver -
>version3.9.15-k
>[13914.534761] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
>[13914.552820] ixgbe 0000:02:00.0 (unregistered net_device): WARNING: =
Intel
>(R) Network Connections are quality tested using Intel (R) Ethernet Op=
tics.
>Using untested modules is not supported and may cause unstable operati=
on or
>damage to
>the module or the adapter.  Intel Corporation is not responsible for a=
ny
>harm caused by using untested modules.
>[13917.741931] ixgbe 0000:02:00.0: irq 50 for MSI/MSI-X
>[13917.741938] ixgbe 0000:02:00.0: irq 51 for MSI/MSI-X
>[13917.741942] ixgbe 0000:02:00.0: irq 52 for MSI/MSI-X
>[13917.741951] ixgbe 0000:02:00.0: irq 53 for MSI/MSI-X
>[13917.741955] ixgbe 0000:02:00.0: irq 54 for MSI/MSI-X
>[13917.741960] ixgbe 0000:02:00.0: irq 55 for MSI/MSI-X
>[13917.741965] ixgbe 0000:02:00.0: irq 56 for MSI/MSI-X
>[13917.741969] ixgbe 0000:02:00.0: irq 57 for MSI/MSI-X
>[13917.741973] ixgbe 0000:02:00.0: irq 58 for MSI/MSI-X
>[13917.742002] ixgbe 0000:02:00.0: Multiqueue Enabled: Rx Queue count =
=3D 8,
>Tx Queue count =3D 8
>[13917.742126] ixgbe 0000:02:00.0: (PCI Express:5.0GT/s:Width x8)
>90:e2:ba:37:3b:18
>[13917.742207] ixgbe 0000:02:00.0: MAC: 2, PHY: 14, SFP+: 65535, PBA N=
o:
>E68793-005
>[13917.743461] ixgbe 0000:02:00.0: Intel(R) 10 Gigabit Network Connect=
ion
>[13917.761578] ixgbe 0000:02:00.1 (unregistered net_device): WARNING: =
Intel
>(R) Network Connections are quality tested using Intel (R) Ethernet Op=
tics.
>Using untested modules is not supported and may cause unstable operati=
on or
>damage to the module or the adapter.  Intel Corporation is not respons=
ible
>for any harm caused by using untested modules.
>[13920.948726] ixgbe 0000:02:00.1: irq 59 for MSI/MSI-X
>[13920.948737] ixgbe 0000:02:00.1: irq 60 for MSI/MSI-X
>[13920.948742] ixgbe 0000:02:00.1: irq 61 for MSI/MSI-X
>[13920.948746] ixgbe 0000:02:00.1: irq 62 for MSI/MSI-X
>[13920.948751] ixgbe 0000:02:00.1: irq 63 for MSI/MSI-X
>[13920.948757] ixgbe 0000:02:00.1: irq 64 for MSI/MSI-X
>[13920.948761] ixgbe 0000:02:00.1: irq 65 for MSI/MSI-X
>[13920.948767] ixgbe 0000:02:00.1: irq 66 for MSI/MSI-X
>[13920.948774] ixgbe 0000:02:00.1: irq 67 for MSI/MSI-X
>[13920.948803] ixgbe 0000:02:00.1: Multiqueue Enabled: Rx Queue count =
=3D 8,
>Tx Queue count =3D 8
>[13920.948927] ixgbe 0000:02:00.1: (PCI Express:5.0GT/s:Width x8)
>90:e2:ba:37:3b:19
>[13920.949008] ixgbe 0000:02:00.1: MAC: 2, PHY: 14, SFP+: 65535, PBA N=
o:
>E68793-005
>[13920.950237] ixgbe 0000:02:00.1: Intel(R) 10 Gigabit Network Connect=
ion
>
>And then I get two nice Interfaces. Please apply. :)
>
>
>Best regards,
>
>Stefan Behte
>
>Babiel GmbH
>Moskauer Strasse 27
>D-40227 D=FCsseldorf
>
>Tel:    0211-179349 0
>Fax:    0211-179349 29
>E-Mail: S.Behte@babiel.com
>Internet: http://www.babiel.com
>
>Gesch=E4ftsf=FChrer: Georg Babiel, Dr. Rainer Babiel, Harald Babiel
>Amtsgericht D=FCsseldorf HRB 38633
>
>~~~~~~~~~~~~~~ DISCLAIMER ~~~~~~~~~~~~~~~
>
>The information transmitted in this electronic mail message may contai=
n
>confidential and or privileged materials. Any review, retransmission,
>dissemination or other use of or taking of any action in reliance upon=
,
>this information by persons or entities other than the intended recipi=
ent
>is prohibited. If you receive such e-mails in error, please contact th=
e
>sender and delete the material from any computer.
