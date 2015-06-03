From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH V2 1/2] pci: Add dev_flags bit to
 access VPD through function 0
Date: Wed, 3 Jun 2015 16:16:43 +0000
Message-ID: <4033DF50-0126-4F69-88FA-C6AABC0CADCE@intel.com>
References: <20150603000645.71269.26134.stgit@mdrustad-wks.jf.intel.com>
 <20150603001011.71269.79857.stgit@mdrustad-wks.jf.intel.com>
 <556E6667.1020000@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_B443E2EF-BF6E-486A-A6C8-5F41C784D5D3";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <556E6667.1020000@gmail.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Apple-Mail=_B443E2EF-BF6E-486A-A6C8-5F41C784D5D3
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252

> On Jun 2, 2015, at 7:28 PM, Alexander Duyck =
<alexander.duyck@gmail.com> wrote:
>=20
> You can probably combine the dev->multifunction check with the =
dev_flags check.  After all you don't need this workaround if the device =
is not multifunction.  It might even make more sense to move the =
multifunction check to the quirk in patch 2/2.

Yes. I also realized that I really should check that tdev->vpd is not =
NULL. There is no point in referencing it if, for whatever reason, it =
has no VPD.

> I also believe this leaks a reference to the device.

Yes, and I was thinking that when I wrote the line, but forgot to do =
anything about it. Good catch!

> You should be calling pci_dev_put(tdev) if tdev is not NULL.  As such =
you probably need to split up the !tdev and the rest of the checks.

Yup. I will have a V3 coming. I still don't have anything to handle PFs =
assigned to guests, but I think that would be best in a separate patch =
set if there is need to fix that. It looks to me like that would involve =
trapping on all config space accesses to such devices and then emulating =
the behavior of the VPD Address/F and Data registers. It may be worth =
seeing if anyone cares before doing anything about it. I haven't seen =
any reports related to such a setup.

Again, thank you for your comments.

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_B443E2EF-BF6E-486A-A6C8-5F41C784D5D3
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJVbyhsAAoJEDwO/+eO4+5uKZYP/RTdMtrlhEh6X3JqPAMXfUQ7
v+idF6gb2R9xmoJ+zvmoSiG+ggM7YvPi91fCee7g4YbmPJKs+yJ0lFfZgHGtV97U
WwHehHjrYjWU1gr4vXeI/igeJj2WdCX5uiqImFss9cV0bgHG8YjkNx2JpXjGs6P2
4SSoXg3Y/Dy2u8i89V0qg59n/ub4b6fNQLhVQrQZWe4KSh6gzgAOSKQpfPwmlBpY
wWgvtSMmlbUVDQ4sxNxtYwTCBSUhuGOgKsND3epOUtRvZjAKNG2ji1p29D1pJ5bi
Jc1KIQ874LO+pfPO66G/p0HOOTbJm9XRREJogHam7WMW6xbPVgO5fas55jAfjOuv
qjQE9qwtqs62IGOtjkaKV1cc8Ryphr3sp6l/dXO/Hrq3t8bWyZ1eVuuXPEn68WDQ
QFOcufx+qIp3WzQggn8n89Ip02DsR5IK0aJtlEoUz9vOH8lwJnHt6SxyDQgWLfXH
cVyUg5syiL+0zKzF71E0c9w/aTdmyiK3yP2Y47+G5dWtb7CHL+ii6zejdAJRJvL4
t9IXRXW6+sXYkVPMWYoG4QPkhZrMt1Gf89G8/anuBkJIZmOS0j9+xedfZbr8GUmH
b2Z5bDCQi1GMRveKMvcf9khdw7xcSAngfB4fdISwAYmZPT+vGTlFytG1XJfRUF77
DiEoFPL6MIoZ4CAM3k12
=5hJu
-----END PGP SIGNATURE-----

--Apple-Mail=_B443E2EF-BF6E-486A-A6C8-5F41C784D5D3--
