From: "Stefan Behte" <s.behte@babiel.com>
Subject: ixgbe: Regression, unsupported SFP+ modules on 10Gbit/s X520 NIC no longer work with allow_unsupported_sfp=1
Date: Fri, 15 Feb 2013 01:58:10 +0100
Message-ID: <D76AF9B3DDF5FF49833AC0A1396549060314FBD8@s554.babiel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----_=_NextPart_001_01CE0B17.869A4003"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.babiel.com ([217.79.215.109]:55551 "EHLO mail.babiel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759774Ab3BOA6N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 19:58:13 -0500
Received: from localhost (unknown [127.0.0.1])
	by mail.babiel.com (Postfix) with ESMTP id 00CDC4CE09A
	for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 00:58:12 +0000 (UTC)
Received: from mail.babiel.com ([127.0.0.1])
	by localhost (mail.babiel.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id cSfwfnaRlZiJ for <netdev@vger.kernel.org>;
	Fri, 15 Feb 2013 01:58:11 +0100 (CET)
Received: from s554.babiel.com (business-178-015-110-066.static.arcor-ip.net [178.15.110.66])
	by mail.babiel.com (Postfix) with ESMTP id CAC864CE01C
	for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 01:58:11 +0100 (CET)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

------_=_NextPart_001_01CE0B17.869A4003
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hello,

I was told to send a mail, even though I had already opened =
https://bugzilla.kernel.org/show_bug.cgi?id=3D53901.

Someone patched the ixgbe driver, and now non-intel SFPs do not work =
anymore, again. The issue of intel "lock-in" was discussed before here:
http://marc.info/?l=3De1000-devel&m=3D132697406314730&w=3D2

A tested patch is attached.

Here is what I do:

# modinfo ixgbe | grep parm
parm:           max_vfs:Maximum number of virtual functions to allocate =
per physical function - default is zero and maximum value is 63 (uint)
parm:           allow_unsupported_sfp:Allow unsupported and untested =
SFP+ modules on 82599-based adapters (uint)
parm:           debug:Debug level (0=3Dnone,...,16=3Dall) (int)

# modprobe -r ixgbe
# modprobe ixgbe allow_unsupported_sfp=3D0
# dmesg | grep ixgbe
[13690.355090] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - =
version 3.9.15-k
[13690.355092] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
[13690.373128] ixgbe 0000:02:00.0: failed to load because an unsupported =
SFP+ module type was detected.
[13690.373177] ixgbe 0000:02:00.0: Reload the driver after installing a =
supported module.
[13690.390987] ixgbe 0000:02:00.1: failed to load because an unsupported =
SFP+ module type was detected.
[13690.391036] ixgbe 0000:02:00.1: Reload the driver after installing a =
supported module.

# modprobe -r ixgbe
# modprobe ixgbe allow_unsupported_sfp=3D1
# dmesg | grep ixgbe
[13679.088849] dca service started, version 1.12.1
[13679.091174] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - =
version 3.9.15-k
[13679.091177] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
[13679.109194] ixgbe 0000:02:00.0: failed to load because an unsupported =
SFP+ module type was detected.
[13679.109243] ixgbe 0000:02:00.0: Reload the driver after installing a =
supported module.
[13679.127399] ixgbe 0000:02:00.1: failed to load because an unsupported =
SFP+ module type was detected.
[13679.127450] ixgbe 0000:02:00.1: Reload the driver after installing a =
supported module.
[13690.352712] dca service started, version 1.12.1


With the patch:

# modprobe -r ixgbe
# modprobe ixgbe allow_unsupported_sfp=3D0
# dmesg | grep ixgbe
[13907.870087] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - =
version 3.9.15-k
[13907.870089] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
[13907.888106] ixgbe 0000:02:00.0: failed to load because an unsupported =
SFP+ module type was detected.
[13907.888155] ixgbe 0000:02:00.0: Reload the driver after installing a =
supported module.
[13907.906187] ixgbe 0000:02:00.1: failed to load because an unsupported =
SFP+ module type was detected.
[13907.906237] ixgbe 0000:02:00.1: Reload the driver after installing a =
supported module.


# modprobe -r ixgbe
# modprobe ixgbe allow_unsupported_sfp=3D1
# dmesg | grep ixgbe
[13914.534758] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - =
version3.9.15-k
[13914.534761] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
[13914.552820] ixgbe 0000:02:00.0 (unregistered net_device): WARNING: =
Intel (R) Network Connections are quality tested using Intel (R) =
Ethernet Optics.  Using untested modules is not supported and may cause =
unstable operation or damage to
the module or the adapter.  Intel Corporation is not responsible for any =
harm caused by using untested modules.
[13917.741931] ixgbe 0000:02:00.0: irq 50 for MSI/MSI-X
[13917.741938] ixgbe 0000:02:00.0: irq 51 for MSI/MSI-X
[13917.741942] ixgbe 0000:02:00.0: irq 52 for MSI/MSI-X
[13917.741951] ixgbe 0000:02:00.0: irq 53 for MSI/MSI-X
[13917.741955] ixgbe 0000:02:00.0: irq 54 for MSI/MSI-X
[13917.741960] ixgbe 0000:02:00.0: irq 55 for MSI/MSI-X
[13917.741965] ixgbe 0000:02:00.0: irq 56 for MSI/MSI-X
[13917.741969] ixgbe 0000:02:00.0: irq 57 for MSI/MSI-X
[13917.741973] ixgbe 0000:02:00.0: irq 58 for MSI/MSI-X
[13917.742002] ixgbe 0000:02:00.0: Multiqueue Enabled: Rx Queue count =
=3D 8, Tx Queue count =3D 8
[13917.742126] ixgbe 0000:02:00.0: (PCI Express:5.0GT/s:Width x8) =
90:e2:ba:37:3b:18
[13917.742207] ixgbe 0000:02:00.0: MAC: 2, PHY: 14, SFP+: 65535, PBA No: =
E68793-005
[13917.743461] ixgbe 0000:02:00.0: Intel(R) 10 Gigabit Network =
Connection
[13917.761578] ixgbe 0000:02:00.1 (unregistered net_device): WARNING: =
Intel (R) Network Connections are quality tested using Intel (R) =
Ethernet Optics.  Using untested modules is not supported and may cause =
unstable operation or damage to the module or the adapter.  Intel =
Corporation is not responsible for any harm caused by using untested =
modules.
[13920.948726] ixgbe 0000:02:00.1: irq 59 for MSI/MSI-X
[13920.948737] ixgbe 0000:02:00.1: irq 60 for MSI/MSI-X
[13920.948742] ixgbe 0000:02:00.1: irq 61 for MSI/MSI-X
[13920.948746] ixgbe 0000:02:00.1: irq 62 for MSI/MSI-X
[13920.948751] ixgbe 0000:02:00.1: irq 63 for MSI/MSI-X
[13920.948757] ixgbe 0000:02:00.1: irq 64 for MSI/MSI-X
[13920.948761] ixgbe 0000:02:00.1: irq 65 for MSI/MSI-X
[13920.948767] ixgbe 0000:02:00.1: irq 66 for MSI/MSI-X
[13920.948774] ixgbe 0000:02:00.1: irq 67 for MSI/MSI-X
[13920.948803] ixgbe 0000:02:00.1: Multiqueue Enabled: Rx Queue count =
=3D 8, Tx Queue count =3D 8
[13920.948927] ixgbe 0000:02:00.1: (PCI Express:5.0GT/s:Width x8) =
90:e2:ba:37:3b:19
[13920.949008] ixgbe 0000:02:00.1: MAC: 2, PHY: 14, SFP+: 65535, PBA No: =
E68793-005
[13920.950237] ixgbe 0000:02:00.1: Intel(R) 10 Gigabit Network =
Connection

And then I get two nice Interfaces. Please apply. :)


Best regards,

Stefan Behte

Babiel GmbH
Moskauer Strasse 27
D-40227 D=FCsseldorf

Tel:    0211-179349 0
Fax:    0211-179349 29
E-Mail: S.Behte@babiel.com
Internet: http://www.babiel.com

Gesch=E4ftsf=FChrer: Georg Babiel, Dr. Rainer Babiel, Harald Babiel
Amtsgericht D=FCsseldorf HRB 38633

~~~~~~~~~~~~~~ DISCLAIMER ~~~~~~~~~~~~~~~

The information transmitted in this electronic mail message may contain =
confidential and or privileged materials. Any review, retransmission, =
dissemination or other use of or taking of any action in reliance upon, =
this information by persons or entities other than the intended =
recipient is prohibited. If you receive such e-mails in error, please =
contact the sender and delete the material from any computer.

------_=_NextPart_001_01CE0B17.869A4003
Content-Type: application/octet-stream;
	name="ixgbe-allow-non-intel-sfp-again.patch"
Content-Transfer-Encoding: base64
Content-Description: ixgbe-allow-non-intel-sfp-again.patch
Content-Disposition: attachment;
	filename="ixgbe-allow-non-intel-sfp-again.patch"

ZGlmZiAtdXIgL3Vzci9zcmMvbGludXgtMy43Ljcub3JpL2RyaXZlcnMvbmV0L2V0aGVybmV0L2lu
dGVsL2l4Z2JlLy9peGdiZV9waHkuYyAuL2l4Z2JlX3BoeS5jCi0tLSAvdXNyL3NyYy9saW51eC0z
LjcuNy5vcmkvZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvaXhnYmUvL2l4Z2JlX3BoeS5jCTIw
MTMtMDItMTEgMTg6MDU6MDkuMDAwMDAwMDAwICswMTAwCisrKyAuL2l4Z2JlX3BoeS5jCTIwMTMt
MDItMTQgMTk6MDE6MzMuMDAwMDAwMDAwICswMTAwCkBAIC0xMDYxLDkgKzEwNjEsMTEgQEAKIAkJ
ICAgICAgaHctPnBoeS5zZnBfdHlwZSA9PSBpeGdiZV9zZnBfdHlwZV8xZ19jdV9jb3JlMCB8fAog
CQkgICAgICBody0+cGh5LnNmcF90eXBlID09IGl4Z2JlX3NmcF90eXBlXzFnX3N4X2NvcmUwIHx8
CiAJCSAgICAgIGh3LT5waHkuc2ZwX3R5cGUgPT0gaXhnYmVfc2ZwX3R5cGVfMWdfc3hfY29yZTEp
KSB7CisJCSAgICAgIGlmICghaHctPmFsbG93X3Vuc3VwcG9ydGVkX3NmcCkgewogCQkJaHctPnBo
eS50eXBlID0gaXhnYmVfcGh5X3NmcF91bnN1cHBvcnRlZDsKIAkJCXN0YXR1cyA9IElYR0JFX0VS
Ul9TRlBfTk9UX1NVUFBPUlRFRDsKIAkJCWdvdG8gb3V0OworCQkgICAgICB9CiAJCX0KIAogCQkv
KiBBbnl0aGluZyBlbHNlIDgyNTk4LWJhc2VkIGlzIHN1cHBvcnRlZCAqLwo=

------_=_NextPart_001_01CE0B17.869A4003--
