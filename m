From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH] pci: Limit VPD reads for all Intel
 Ethernet devices
Date: Tue, 19 May 2015 22:43:39 +0000
Message-ID: <46CDD500-2A1B-4457-BE17-961AFC50769E@intel.com>
References: <20150519000042.56109.69779.stgit@mdrustad-wks.jf.intel.com>
 <555B5CBF.1090902@redhat.com>
 <4AD84211-965C-4F0B-A7F4-3E6CCE6567E3@intel.com>
 <555B77E5.5060006@redhat.com>
 <99014381-25AB-416D-8E09-C431B5CD5A6C@intel.com>
 <555B9F74.3040004@redhat.com>
 <DA06AAB6-CE9B-4A27-B60D-8F55BB52A063@intel.com> <555BA850.1090901@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_EBDC4AEE-1FD3-4877-9518-6729D4EF91F0";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	"bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <555BA850.1090901@gmail.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Apple-Mail=_EBDC4AEE-1FD3-4877-9518-6729D4EF91F0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252

> On May 19, 2015, at 2:17 PM, Alexander Duyck =
<alexander.duyck@gmail.com> wrote:
>=20
> Any chance you could point me toward the software in question?  Just =
wondering because it seems like what you are fixing with this is an =
implementation issue in the application since you really shouldn't be =
accessing areas outside the scope of the VPD data structure, and doing =
so is undefined in terms of what happens if you do.

I don't have it, but if you dump VPD via sysfs you will see it comes out =
as 32k in size. The kernel just blindly provides access to the full 32K =
space provided by the spec. I'm sure that we agree that the kernel =
should not go parse it and find the actual size. If it is read via =
stdio, say fread, the read access would be whatever buffer size it =
chooses to use.

If you looked at the quirks, you might have noticed that Broadcom =
limited the VPD access for some devices for functional reasons. That is =
what gave me the idea for limiting access to what was possibly there. =
With the existing Intel Ethernet quirk, it seemed like a simple thing to =
do.

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_EBDC4AEE-1FD3-4877-9518-6729D4EF91F0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJVW7yaAAoJEDwO/+eO4+5uc/8QAITb0mh4u5YVVfHMyOLMh5yw
JA8BFJmBfP0ufBxMS7vsMJw68gqiHKnoKcPG0cOT4HiKCxgRSwdZLXY99G/VGwE1
VkwfIHe/hhPUROHJngO3V9NQveZ7OGhv/iJBqzl1v/DfDa56xYuhzuVto24ZVixK
RziXaQnR1ISztjK4gJM79Jr4mXyFltTiO1PdjCSiKw0DIlGVCcnvdsEk4yknBLeq
hgQEK8mH0nFBF/3Snj3ttuMZSKTN4McHptF8BNyrkZ+E2IjivQziBK6XOOK5MQ4k
25FtyqRnDhG9czQEFRitVuIISUnLROIaKuGk6qv3sPM7280cUEXnUok9IA8u1NN7
+iq40BPRp3JaGR8VR2XLqTRwlCeaiCEiz3JXkBNzi6wdn40F6lx/WgpXxjxfHhLu
mrG+QyOwy/YhlNotfXLFtIUFVM/Lu2x4RU08qmSoWeyZ/M+ABJdZSG+EVan8BQ1J
qnYy6OcLAg1X4Gup/Tjj2VNZAcy2KD8MxZnt5ZUEgMkgPtY3nqDiAiIWobTYB5Y2
6U0L750gRnoLtLMPdJUGYjTwSRCdhL+UjAsfLzgK8doghfJj2J2kWluAeUGM7K6m
8/TdczdLztl6loFzrwmNr+F69u3bDr9F+GvEnFguZlAll3j7j2hUnOBPX0ecE4am
jozxT1N0+FA0+1f7QOO4
=1eme
-----END PGP SIGNATURE-----

--Apple-Mail=_EBDC4AEE-1FD3-4877-9518-6729D4EF91F0--
