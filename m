From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [linux-nics] [PATCH 0/4] move pci_assivned_vfs() check (while
 disabling VFs) to pci sub-system
Date: Thu, 20 Nov 2014 14:42:03 -0800
Message-ID: <1416523323.2280.10.camel@jtkirshe-mobl>
References: <1415620410-4937-1-git-send-email-sathya.perla@emulex.com>
	 <20141120222127.GB7987@google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-LM2zDDCz+zrlHt6u3p2n"
Cc: Sathya Perla <sathya.perla@emulex.com>, linux.nics@intel.com,
	shahed.shaikh@qlogic.com, linux-pci@vger.kernel.org,
	ddutile@redhat.com, ariel.elior@qlogic.com, netdev@vger.kernel.org
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20141120222127.GB7987@google.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-LM2zDDCz+zrlHt6u3p2n
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-11-20 at 15:21 -0700, Bjorn Helgaas wrote:
> [+cc Jeff]
>=20
> On Mon, Nov 10, 2014 at 05:23:26PM +0530, Sathya Perla wrote:
> > A user must not be allowed to disable VFs while they are already assign=
ed to
> > a guest. This check is being made in each individual driver that implem=
ents
> > the sriov_configure PCI method.
> > This patch-set fixes this code duplication by moving this check from
> > drivers to the sriov_nuvfs_store() routine just before invoking
> > sriov_configure() when num_vfs is equal to 0.
> >=20
> > Vasundhara Volam (4):
> >   pci: move pci_assivned_vfs() check while disabling VFs to pci
> >     sub-system
> >   bnx2x: remove pci_assigned_vfs() check while disabling VFs
> >   i40e: remove pci_assigned_vfs() check while disabling VFs
> >   qlcnic: remove pci_assigned_vfs() check while disabling VFs
> >=20
> >  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c  |    2 +-
> >  drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |    7 +------
> >  .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |   10 ----------
> >  drivers/pci/pci-sysfs.c                            |    5 +++++
> >  4 files changed, 7 insertions(+), 17 deletions(-)
>=20
> I'm dropping these for the reasons Don & Alex outlined -- they don't fix
> the problem for VFIO, so this amounts to shuffling around code that's kno=
wn
> to be broken, which seems more confusing than worthwhile.
>=20
> Jeff, if I were you I would drop the i40e patch.  I don't think it makes
> sense to remove the check from i40e before adding it to the PCI core.
>=20

Thanks for the heads up, I will drop the i40e patch as well.

--=-LM2zDDCz+zrlHt6u3p2n
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUbm47AAoJEOVv75VaS+3OHcUP/2X24f1hN/0+7xJlUhJteuFM
j0R/dWDkR5l5jF6ZOidncfmx634d6Js410lOqrXW6Kw2nCNSWy8ZqkIUMrZUHY7v
X5xW5uQG3fOzElpi5EG/MvbzGHK+5AfWVTgHUmRFk/DOXCSAhlgPYi8iDHIlDtoo
ObHtUKi93homIuYb3pdY1Fy8tNg1DQ3onUy/uLpD3Bo6dvNErogFjvj6XQUjG9iM
jwZ4IQCZuAt/M6XWhSGMrly8BmkVfyotvF3VJJGsucnvJuW+lNHqALj8yWlWe/DL
kKAW2y91OhGSbhIwi+mbXdyFzNCqlaQ+wii+79k1hAIOs+8UGqm4CQUVtoebY8gs
7gTKbCQvk6A6DTM8HTiYzCPvIDB86M5m4r9eGxF2OfFLD+B79s/r3SZkD422zA/V
eU/Xj9Y2ZEIDgr81oLQvQYrJ1MylOpgxHLkEBvh7uzPxwjpzZBP1kCx2UWcZ2vh2
kWVro3+ZmZCY1ODGqn25wBlRonqw+LyW3YhODQ6WNHdU5xd4dcDsjjTFSxQhs5Qk
nhN7bS9AGUOuHOrYQa6C6ZeuIENIccIsaskjLQ0IOHWlxyYGMmzOG7d/AZoxt+V5
h6t4u5Fk0hesumV7dQr/0tjaiwkrTqBHPeJrPAjuoEoACHC3PvVjBmaUwfcSzC6s
1nkDIqKpmaUMtoIdhHDE
=gJNr
-----END PGP SIGNATURE-----

--=-LM2zDDCz+zrlHt6u3p2n--
