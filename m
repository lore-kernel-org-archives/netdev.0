From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH] pci: Use a bus-global mutex to protect VPD operations
Date: Wed, 27 May 2015 19:11:05 +0000
Message-ID: <151DE2D4-7D19-48B1-8317-9470F03B400D@intel.com>
References: <20150519000037.56109.68356.stgit@mdrustad-wks.jf.intel.com>
 <20150527172741.GX32152@google.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_2CAACB5C-A450-43BD-A92C-2F5701829C79";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:17449 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754033AbbE0TLJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2015 15:11:09 -0400
In-Reply-To: <20150527172741.GX32152@google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_2CAACB5C-A450-43BD-A92C-2F5701829C79
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

> On May 27, 2015, at 10:27 AM, Bjorn Helgaas <bhelgaas@google.com> =
wrote:
>=20
> It sounds like there are real problems here that would be fixed by =
changing
> the mutex strategy and limiting VPD read lengths, but that we don't =
quite
> have consensus on how to solve them yet.

I have a new pair of patches that I am getting internal feedback on. I
will be on vacation starting tomorrow and won't be back until Tuesday, =
so
I think it best to send them when I get back so that I will be available
to respond. I could be convinced to send them now.

> VPD is a bit of a tar pit.

It sure is.

> We've talked about limiting VPD read length
> before (see links below), which requires interpreting the VPD contents
> (just the tags & sizes) the kernel.  I think I'm OK with doing that,
> provided we should audit existing users and make sure we don't break =
them.
>=20
> =
http://lkml.kernel.org/r/c67cd7f4-8d8f-48fc-a63c-dbdafde873a2@CMEXHTCAS1.a=
d.emulex.com
> =
http://lkml.kernel.org/r/1f6d7b6c-7189-4fe3-926b-42609724cab9@CMEXHTCAS2.a=
d.emulex.com
>=20
> I'd also like to include specifics, e.g., bugzillas with complete =
dmesg and
> lspci information, for the problems we're fixing.

The issue I am addressing is for when the VPD Address/F and Data =
registers
are shared across multiple functions. My latest patch addresses this by
always performing the access through function 0. I added a dev_flags bit
to indicate when this should be done, so only devices that have a quirk
that sets that bit will get that treatment.

The patch I have still doesn't address the issue for direct-assigned
devices. I have no answer to that, but will point out that most guests
seem to use virtual machines that don't support extended config space
anyway. Only those that do support extended config space and access VPD
could be a source of trouble.

I have to say that I haven't actually reproduced the failure, but given
the design of the hardware it is clear that somehow a common mutex needs
to protect those shared registers.

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_2CAACB5C-A450-43BD-A92C-2F5701829C79
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJVZhbJAAoJEDwO/+eO4+5uf40QAKfoXP3qP/Tby1eKVA/I0mht
lyCVAZBVOni7NWU93ERbXGM6wU6Vrx7JpxxYQbaDJ6zwPp6IWW5Sk6fBnxUWFmjc
ARGXgQm+IYl8Zjrqw9SGQsQUJB+PuBWIVKbMqAQfbRFlPGmwQfFaQUxN5elZQpAg
WEzLNUNSBUoKyz735cqqDPajUYRkD6kDbeMf8UkJQ+VOghwCTPG3WzSQThI61oSE
EptUZdJa6ZKlrk+JtFV36/wX2TAX9Xw7fjlLCtEr8y8q6XFa/m0NQXKe9V0Y8Tur
3dKd1tXdVWuJzGgUtWcUAWiPlkCbDzl+WJ1HF5vGr8dKQXfLTEBGchcccxGs1mnK
l4s/0cbncPTQYwbD9eoe+hKhELersdPgXTXODOaJQkYkJkd75g2HKNptt5GJV/Sd
N6iNVHgVxKMUyK6XN2ak2tVmF4ARW+GPUcFLT3uYWoHxZm27Y6J2u7traIwS+pwr
707IUTlwuxFlNxmHo1Z198d7M7yoCZlIXTskISHw/BAnxGx9e7r+9c+dvvmq6AFC
uyZQD9DVKd1G1+2mP7MLbKHhs3RmsKJaO4D9htKMV22zGXQ8aFk8LKlpLwjHR2Yz
KS6JBEWF4uOPBomTtWEuoMNmoEc+6mCGKBonsN+qLL833R9pUoHrwivqtL2//c+m
vCuQrJ9G7znvbNVZKQAV
=iuey
-----END PGP SIGNATURE-----

--Apple-Mail=_2CAACB5C-A450-43BD-A92C-2F5701829C79--
