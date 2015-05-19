From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH] pci: Limit VPD reads for all Intel
 Ethernet devices
Date: Tue, 19 May 2015 18:38:18 +0000
Message-ID: <99014381-25AB-416D-8E09-C431B5CD5A6C@intel.com>
References: <20150519000042.56109.69779.stgit@mdrustad-wks.jf.intel.com>
 <555B5CBF.1090902@redhat.com>
 <4AD84211-965C-4F0B-A7F4-3E6CCE6567E3@intel.com>
 <555B77E5.5060006@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_7C641D78-AD3B-49FD-B59E-18DE695267FD";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <555B77E5.5060006@redhat.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Apple-Mail=_7C641D78-AD3B-49FD-B59E-18DE695267FD
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252

> On May 19, 2015, at 10:50 AM, Alexander Duyck =
<alexander.h.duyck@redhat.com> wrote:
>=20
> These two patches are very much related.

They are only related because I saw an opportunity to do this while =
working on the other issue. That is the only relationship.

<snip material on the other patch>

>>> Artificially limiting the size of the VPD does nothing but cut off =
possibly useful data, you would be better of providing all of the data =
on only the first function than providing only partial data on all =
functions and adding extra lock overhead.
>> This limit only limits the maximum that the OS will read to what is =
architecturally possible in these devices. Yes, PCIe architecturally =
provides for the possibility of more, but these devices do not. More =
repeating data can be read, however slowly, but there is no possibility =
of useful content beyond the first 1K. If this limit were set to 0x100, =
which is more in line what the actual usage is, it would be an =
artificial limit, but at 1K it is not. Oh and it does include devices =
made by others that incorporate Intel Ethernet silicon, not just =
Intel-built devices.
>=20
> As per section 3.4.4 of the X540 datasheet the upper addressable range =
for the VPD section is 0xFFF which means the upper limit for the =
hardware is 0x1000, not 0x400.

Ok. I have no problem changing it to that. I had been looking at other =
specs, but 0x1000 really is a hard limit.

<snip more material mostly relating to the other patch>

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_7C641D78-AD3B-49FD-B59E-18DE695267FD
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJVW4MYAAoJEDwO/+eO4+5uY6UP/0cZrd9ddW1gjettVusyKlU7
UiXD/fW5ABN/7kyYv3ttPcUumGBmgMC/Z2Gb7h35oVrAOpe8URk8ouTuLaztvYMh
DpaSqmgss5VT4rxXArbIDGYPt4nHzHdR4q7+nbfSx1EM84we6KgiISIP1MARFSlh
pnVVdu/DNZ9Bn4cbIpecXVu55mM1B2FxKo/RPTmx9MwLpveVyBS6cIErpqbghOAe
uXu0NhPAdeHKPtQJo+gnbYvegmFoYZRO1Nemzhph47pIwJeu8uTyYMUcAOphN/uv
T+Q0rGGP3+INZLQ0oIMdey+ulzJxyR1nNOw6ynNsSz5A7DcfeUfe40OPWm3Qo9KU
PXPDIPtWDMaUPbA7b7B/cLCMjSKYiAwE9wlmKPvyf0Q4Vga9ZQVBlJ9cTym82nQ2
Ctmx8LvF0ntBhWR01kKmNZpkCWIX8iFRJ7luNOtvTYP5NX+vTDDfSbhCok0Sq16c
Ru0RkQpF6wA0kV2vdqvlUA8RFmYZDc1Qzx557TTo55rck9dN7PYFAXZK9Srcm2h3
0qeTGhXX5fbYyElTh0mVsikt7rzZbqi2O+MdGh3OquFWUUTkTdYvLV8KT5HM2Dax
fTjD4NNM1Lj0mMLtAiRdecpBPnEBvk609biwKYezDwBBhvFyhUm1xz6ZojR+mJjk
Zl5zJRGjNyBxYhRetDG3
=mha2
-----END PGP SIGNATURE-----

--Apple-Mail=_7C641D78-AD3B-49FD-B59E-18DE695267FD--
