From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH V3 0/2] pci: Provide a flag to access VPD through
 function 0
Date: Fri, 5 Jun 2015 21:59:20 +0000
Message-ID: <051B68B4-3E77-4EB0-B9FE-8523631884A2@intel.com>
References: <20150603184445.109080.36387.stgit@mdrustad-wks.jf.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_926CE864-1ACB-499A-B033-66D4E3C73A01";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:63566 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751968AbbFEV7W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jun 2015 17:59:22 -0400
In-Reply-To: <20150603184445.109080.36387.stgit@mdrustad-wks.jf.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_926CE864-1ACB-499A-B033-66D4E3C73A01
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

> On Jun 3, 2015, at 11:46 AM, Mark D Rustad <mark.d.rustad@intel.com> =
wrote:
>=20
> Many multi-function devices provide shared registers in extended
> config space for accessing VPD. The behavior of these registers
> means that the state must be tracked and access locked correctly
> for accesses not to hang or worse. One way to meet these needs is
> to always perform the accesses through function 0, thereby using
> the state tracking and mutex that already exists.
>=20
> To provide this behavior, add a dev_flags bit to indicate that this
> should be done. This bit can then be set for any non-zero function
> that needs to redirect such VPD access to function 0. Do not set
> this bit on the zero function or there will be an infinite recursion.
>=20
> The second patch uses this new flag to invoke this behavior on all
> multi-function Intel Ethernet devices.
>=20
> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
>=20
> ---
> Changes in V2:
> - Corrected a spelling error in a log message
> - Added checks to see that the referenced function 0 is reasonable
> Changes in V3:
> - Don't leak a device reference
> - Check that function 0 has VPD
> - Make a helper for the function 0 checks
> - Moved a multifunction check to the quirk patch

So does this series look acceptable now? I think I addressed the issues =
that Alex raised. Can these also be considered for -stable?

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_926CE864-1ACB-499A-B033-66D4E3C73A01
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJVchu3AAoJEDwO/+eO4+5ulYAP/A1UBUn+VE9AjaORMDHs+i+X
Cs/zLjQNLGg7u9c2gKNnzNowsngZI6gxlId5Pk/OLiRWidjKWccWLAGtpxrEDXiu
a3XU4qogJ/MEK1PcStJEn2URZcH0u+prH2agEfl7Y4A4nC/FMW4HlK84D1gcGLtr
ZTnR61OtjYEwYXomDoeMaBhgHjPwDR/8yyEdTpSVASpmIw6W26G5nh3Xmvj/JTCq
DlfJ3Uqb40I8yCluCxPR+zsaPJ7Z+K2aKbGuISm1JMf6kyaGcgsy2DoW2cGaVNVj
cZ//5oHyW2lwaIqcvbHTp/JKEfuiWpfxH2PJzwk2jgXoQdwVILUJuMimdEkznsXR
qx3jJX/ZSZWQv7AccG9uIjK9HtkcrKhd8q34NVh+L3zzrpu+jVYgLHmQ7jEUKHbO
cfB5s798wO2mzNtssmUvOUT3/McZrLYpc1VHYepXgIzpXt+pMukEGYFb3hRSyH7k
DHiY/dmfjBRywbXpQBPU5aICJupHhK3OeCqZprOZxkGgEKp0oYvW0rccjrxZfRCj
P5FrM3I5HzIU9UyPyzYb2KfSHwzrbkNExzP2qWyDS68+8yhhV9x2H7GHYG+z1Q7L
Jv9hoj1ZLjHbrSasAayNRnzoxYEWQ51VfzH6MZ1AT+SEUOUGiVffzxgsxhHxaw1B
ZNogdJHKqrP3fSa6WwPT
=9LFS
-----END PGP SIGNATURE-----

--Apple-Mail=_926CE864-1ACB-499A-B033-66D4E3C73A01--
