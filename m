From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH V3 0/2] pci: Provide a flag to access VPD through
 function 0
Date: Wed, 17 Jun 2015 16:29:14 +0000
Message-ID: <45099CC7-DDAB-41D9-AB74-5A81E2AAF64C@intel.com>
References: <20150603184445.109080.36387.stgit@mdrustad-wks.jf.intel.com>
 <051B68B4-3E77-4EB0-B9FE-8523631884A2@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_933DBC4A-33F1-459A-87A3-C3AAF3D93F76";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:40986 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753449AbbFQQ3i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 12:29:38 -0400
In-Reply-To: <051B68B4-3E77-4EB0-B9FE-8523631884A2@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_933DBC4A-33F1-459A-87A3-C3AAF3D93F76
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

+ Alex

> On Jun 5, 2015, at 2:59 PM, Rustad, Mark D <mark.d.rustad@intel.com> =
wrote:
>=20
>> On Jun 3, 2015, at 11:46 AM, Mark D Rustad <mark.d.rustad@intel.com> =
wrote:
>>=20
>> Many multi-function devices provide shared registers in extended
>> config space for accessing VPD. The behavior of these registers
>> means that the state must be tracked and access locked correctly
>> for accesses not to hang or worse. One way to meet these needs is
>> to always perform the accesses through function 0, thereby using
>> the state tracking and mutex that already exists.
>>=20
>> To provide this behavior, add a dev_flags bit to indicate that this
>> should be done. This bit can then be set for any non-zero function
>> that needs to redirect such VPD access to function 0. Do not set
>> this bit on the zero function or there will be an infinite recursion.
>>=20
>> The second patch uses this new flag to invoke this behavior on all
>> multi-function Intel Ethernet devices.
>>=20
>> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
>>=20
>> ---
>> Changes in V2:
>> - Corrected a spelling error in a log message
>> - Added checks to see that the referenced function 0 is reasonable
>> Changes in V3:
>> - Don't leak a device reference
>> - Check that function 0 has VPD
>> - Make a helper for the function 0 checks
>> - Moved a multifunction check to the quirk patch
>=20
> So does this series look acceptable now? I think I addressed the =
issues that Alex raised. Can these also be considered for -stable?

More than a week has passed without any comment. Is this going to be =
accepted or is there still an issue?

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_933DBC4A-33F1-459A-87A3-C3AAF3D93F76
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJVgaBZAAoJEDwO/+eO4+5uGukQAKOK+W+hOnYngKpbDANNutZn
jAJIdQ9+tnf+bShEU5F+hNEtmmj4nSw6OCvHrI+34TgBlMJxcrF2hfV5TAebmIZX
rd4dbz1Xjw7tU49XJKj7CNq2vKELiezlqDJCbi9p+0q+/xDRDfwNzYNv2BsgW3zQ
bGtfV3WvYnKQ26A9FKmAK+fe9SQKt+P/AipRilsGlt9xIQljZrsXm6RUuFyqpURn
2AAlYF5cIqehVSPi8igRj8OI3RrfHqImgOtEMuJHXLhuHq8hNjC26Gw6X8r9N/U0
ooz4fSQC/fcpzFtsxMuhasNWhoxquVBbPSmFKhQf70t44WHmyy8pIxkZYVmyrYIv
u1fCQAa+Ot2BrQ5/v0FLTCMnJzurdkL0yTJC8VzLwzQGC0OCQ+K2d4VkKp5mOakN
wUkBdQsYNbMH5Bwi+0VMQxhleYo3t7se8Rin89dyZQnLZLYjBav0lQU4j0oPrfh5
xEYQ2Iy+H4B+Bka5CR5kwbeAYoTy6kW9Hqf38FpVgSV2A2D7tir2lNpVnbjz8XZg
q1hhcYqmkJTk2eIa+d670JNE1Y1O+tCMeFDOEW0xziD2e9aJdk4uTxn1RrahB0UN
6cNepkGeiqaDVyWJwrmOrqlv8g5L0WIc87lIY/x5mWV87+7/1GIu0Z29jN3kr58p
KkCsxWobnNpZCFkkDdS9
=33l1
-----END PGP SIGNATURE-----

--Apple-Mail=_933DBC4A-33F1-459A-87A3-C3AAF3D93F76--
