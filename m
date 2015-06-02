From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH 1/2] pci: Add dev_flags bit to access
 VPD through function 0
Date: Tue, 2 Jun 2015 18:15:14 +0000
Message-ID: <CCF4C06B-1029-4341-B5AE-846C834DD747@intel.com>
References: <20150602165706.6252.76253.stgit@mdrustad-wks.jf.intel.com>
 <20150602170414.6252.48036.stgit@mdrustad-wks.jf.intel.com>
 <556DEC80.70206@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_E85B156B-4084-42DB-AC89-B61AD227E479";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:62066 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759664AbbFBSPQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2015 14:15:16 -0400
In-Reply-To: <556DEC80.70206@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_E85B156B-4084-42DB-AC89-B61AD227E479
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252

> On Jun 2, 2015, at 10:48 AM, Alexander Duyck =
<alexander.h.duyck@redhat.com> wrote:
>=20
> I'm pretty sure these could cause some serious errors if you direct =
assign the device into a VM since you then end up with multiple devices =
sharing a bus.  Also it would likely have side-effects on a LOM (Lan On =
Motherboard) as it also shares the bus with multiple non-Ethernet =
devices.
>=20
> I believe you still need to add something like a check for =
!pci_is_root_bus(dev->bus) before you attempt to grab function 0.  It =
probably also wouldn't hurt to check the dev->multifunction bit before =
running this code since it wouldn't make sense to go chasing down the =
VPD on another function if the device doesn't have one.  You could =
probably do that either as a part of this code, or perhaps put it in the =
quirk.

I'll look into those. I think you are right about more checks being =
needed. Thanks for the comments.

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_E85B156B-4084-42DB-AC89-B61AD227E479
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJVbfKyAAoJEDwO/+eO4+5uS1EP/0iz43K4T06SNaevlhCtbIJE
Hs15bymg8LzlrmiB7fPnNG0UCEBm7ZRxYPHQk3XHlhDa9NzbmDSd/9AkFWQfJD7v
o5ldapmrw0mMPrNwSiAGQe786JwVaY7OWholffaYPCoH0tvHEE1u6i+Y0XgijiZO
uCngOplCqcVOF/ZQSZZFgL0J2tjYVtgjozN/N1gY9kb5qhGqGBrq2Y8KHQnGgWQo
Gv1In08cOyqVc92PuVgRR8Yt/WiUZy319LuTpJLCaCHszYr6OB5PRrrtKwBHiHbE
34CPrw9wyezz9D8Q96OYSKazEm8TiavsQxMs/TchwEl9oRStAELvEDXVzWbVLV1e
n3mc2g7G0qcJVFsd9tRe++5C8pZslqGW2tMrmM7ZdYErK9iW63qWyleJ+YsHnSFd
HVKidcMytR5K+FWosYO478J1VvTDKmpFAH2XQduByqskYZIJrWaGBWfPO3ort4F5
T38w8+ZPPOvOTtVOpwfBnlKMhlrF3U/PVKmJDl9WwHyDqD1NZuX9IbHmy071vb9T
t8KJ976ADLUCuQSouSTmZRCc3HErDYaJ8qCi4c1Edh6dWiMH9j77WwypNk/QvChy
Mr+/uYifPsI5IX+K8421bWueC4U7SawVXZC++PeRJ38jK7PDy+peljN9vNKxT5j7
d5t53styxL54g7GsKmMg
=h75D
-----END PGP SIGNATURE-----

--Apple-Mail=_E85B156B-4084-42DB-AC89-B61AD227E479--
