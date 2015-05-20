From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH] pci: Use a bus-global mutex to
 protect VPD operations
Date: Wed, 20 May 2015 16:00:46 +0000
Message-ID: <C73FDF83-62F7-47F4-905A-CD7D482F0709@intel.com>
References: <20150519000037.56109.68356.stgit@mdrustad-wks.jf.intel.com>
 <555B78F7.60908@redhat.com> <20150519160158.00002cd6@unknown>
 <555BD029.7050803@redhat.com>
 <F47DC49C-CCC5-4693-8905-20ABCE6F5993@intel.com>
 <555BDD14.2080807@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_8D7C4533-375A-45A6-BB00-B7E88D683895";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <555BDD14.2080807@redhat.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Apple-Mail=_8D7C4533-375A-45A6-BB00-B7E88D683895
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252

> On May 19, 2015, at 6:02 PM, Alexander Duyck =
<alexander.h.duyck@redhat.com> wrote:
>=20
> My suspicion is that we have a number of bugs floating around out =
there like the Broadcom issue.  Specifically, one of the ones I found =
was that the r8169 seems to have a similar issue as called out in the =
email thread at http://permalink.gmane.org/gmane.linux.network/232260.  =
I'm wondering if we shouldn't add an initializer for the read/write =
functions that will go through and pull out the 3 or 4 headers from the =
VPD data needed to get the actual length.  Then it would lock down the =
VPD and save some serious time on reads since most devices don't have =
32K of VPD to read.

That is interesting. I noticed that there are functions already present =
to find VPD tags. If the VPD were invalid, would this block its being =
read at all, or would it default to allow reading/writing anything? I =
don't know if there might be people using Linux to completely write the =
VPD area. Presumably your idea would prevent rewriting the VPD area to =
something larger.

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_8D7C4533-375A-45A6-BB00-B7E88D683895
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJVXK+tAAoJEDwO/+eO4+5uCzIQALOmwWUbPkoYyC0COmg72qe/
E9MxuQD9et55vp4DS6zDdLH5eruRgqEGYu6LZxintzNgUawD+rH0P1f6l5LRZo7B
r4KNMIwsnvDc2JDAsvBWBMGnEyjaZv16YLrL/aYVwBwT9W7/hz1EQum8ijeSwkOZ
BcBBQm2VKJmkEh6q1CLSyVLhgaMSZvmI3GBNIIst3Y6xNSPSww+WZ59rkYxZYYDv
5VDnGmHs6q6tpvB+a/BSTgUhZ/7uQsMZ+O1FBecnWtLp36AXtL0dHSBVVAHZ0QhS
Il/R8RNYEhpbfpukdY+yt81TZEX4Zm8MwYB35GIJzlCIVlDn6NvQqNl/O480dyYf
0PPfoSAf/aWSg46DUOJMo0oh8zt3DEU6Fk8cR89LKzKUzlVU90cMj0tbOlxD46Il
DreV6AHIXaDeuNKU6AlS0CO69KlECF7iU0s2+8Zus5PO++6CCeuzGEpf4MEHDY79
t5fAFiqu6pVk31pAaQl7Y+P6GzhJszgZYxuyDoh861QXKwMdNWTb7grXeXc0gpJv
9WjecP1alFkTuJKzPwf2ScK/cCSv/VqydhwTEQTdHN5HLFndTuzLaVkcKs15pezl
prs5ggSYdxZGx2MTiBOutEhOsgYGYcJcAu6vYlVNrcikLkGzWy6VYdxZX6FJy9az
B1WTBfBqZyxsTSNdcsnE
=ghFr
-----END PGP SIGNATURE-----

--Apple-Mail=_8D7C4533-375A-45A6-BB00-B7E88D683895--
