From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH V4 1/2] pci: Add dev_flags bit to access VPD through
 function 0
Date: Tue, 15 Sep 2015 18:39:35 +0000
Message-ID: <F17F8A11-FB09-4131-A404-DE106F3944BB@intel.com>
References: <20150713183821.19985.52157.stgit@mdrustad-wks.jf.intel.com>
 <20150713184001.19985.64867.stgit@mdrustad-wks.jf.intel.com>
 <1442341152.23936.122.camel@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_66A0996E-F82D-416F-878C-5B64F9B52B95";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Myron Stowe <myron.stowe@redhat.com>
To: Alex Williamson <alex.williamson@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:15565 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751576AbbIOSjk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 14:39:40 -0400
In-Reply-To: <1442341152.23936.122.camel@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_66A0996E-F82D-416F-878C-5B64F9B52B95
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

> On Sep 15, 2015, at 11:19 AM, Alex Williamson =
<alex.williamson@redhat.com> wrote:
>=20
> In addition to the (PCI_SLOT() !=3D devfn) issue, I'm concerned about
> topologies like we see on Skylake.  IIRC, the integrated NIC appears =
at
> something like 00:1f.6.  I don't know if that specific NIC has VPD, =
nor
> am I sure it really matter because another example or some future
> version might.  So we'll set the PCI_DEV_FLAGS_VPD_REF_F0 because we =
do
> so for all (PCI_FUNC() !=3D 0) Intel NICs, we'll call
> pci_vpd_f0_dev_check(), which will error because function 0 has a
> different class code and device ID, so we return error and if VPD =
exists
> on the device, it's now inaccessible.

Yes, that is exactly what would happen.

> I thought there was talk about whitelisting anything on the root bus =
to
> avoid strange root complex integrated devices (and perhaps avoid the
> general case for assigned devices within a VM), but I don't see =
anything
> like that here.

I hadn't heard that talk, but I'm not on the PCI list and I guess I =
wasn't copied.

> Perhaps instead of failing and hiding VPD we should fail, clear the
> flag, and allow normal access.  Thanks,

Because the purpose of VPD is to hold information about the device, I =
would suggest that VPD should never be provided for an embedded network =
device, but rather for the device as a whole. So while there may well be =
VPD for an SOC, that VPD should not be associated with one of its =
embedded devices, but rather something more appropriate for the device =
as a whole. And attaching VPD to a whole bunch of internal devices would =
just be madness.

So I understand the concern, but I don't think that it should really =
happen in real systems. I did think about this case when I was working =
on the patches. A networking device should really only have VPD when it =
is its own physical device, such as a NIC.

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_66A0996E-F82D-416F-878C-5B64F9B52B95
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJV+GXmAAoJEDwO/+eO4+5uuYEQAIHwv1Er0PsY5aZ0uKgq0MAO
Mys+olp+93YO+PpukFYIkBEuge4yBDH0w5dL2w1C/WsGaHRVyhz1aXDTaqIVAZSr
/JufCvnQCoUnnr8Pq8+Gx3860bShQs5aQWr68sfiNVEmYwL/1y3yABGCTEOkrVZO
2F7VI5rIbXuw8L8M48qyE69i08Ef+gjG0TzWOxXC1F+ekpJv7LIBOZnEPNBgayC/
GJLqbhK+J/BFq5YuWaNm+En33oi15xHowxR34vIcXJdEmuvehVVHzNEPzlU4/uE2
UgT9SfvrlsALyv0WNTypCQQaBwUQrb42jERkuC1g18W1WybDIH1UpFNEf/bJnN4e
Nxmkv++0kxBu9ZjFAWC3m0+QIPtwYG6v7ITvXvruigb+hCwkQQGS/P9bCmDOYwo3
L4Sm35dFlr+o2fMZj70hW2KG94bZT0E1B1V1QIAhFveO6bzr+FpJb1lHQC6sUAv7
12tH7NEJLas+7tbrmy0CkYOczgW+MtAeRjH4Nwcg7CYkkwTfbN4t8ii1eryY+PE3
zPMGvzVSnUI3QUgZggH7Uaj4YT2AP+WraZVrfRu02gp/yxBcRbUJ3ccIkMZVYXYL
90CcxSkpSw8db+HK3JxDrkQ1/XloeATnhjlFheqw5XTPssVEcHkuJIGJZ3yaOn/u
TQuRPaMnVE4OC3SNqmos
=YdLe
-----END PGP SIGNATURE-----

--Apple-Mail=_66A0996E-F82D-416F-878C-5B64F9B52B95--
