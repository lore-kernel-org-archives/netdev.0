From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 00/15][pull request] Intel Wired LAN Driver Updates
Date: Wed, 19 Mar 2014 01:17:24 -0700
Message-ID: <1395217044.2050.23.camel@jtkirshe-mobl>
References: <1395200533-16908-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-aBTRdR+QTtudSscu2hDj"
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:10524 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751627AbaCSIRd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Mar 2014 04:17:33 -0400
In-Reply-To: <1395200533-16908-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-aBTRdR+QTtudSscu2hDj
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-03-18 at 20:41 -0700, Jeff Kirsher wrote:
> This series contains updates to i40e, i40evf, e1000e, ixgbe and ixgbevf.
>=20
> Mitch adds support for the VF link state ndo which allows the PF driver
> to control the virtual link state of the VF devices.  Added
> support for viewing and modifying RSS hash options and RSS hash look-up
> table programming through ethtool for i40evf.  Fixed complaint about
> the use of min() where min_t() should be used in i40evf.
>=20
> Anjali adds support for ethtool -k option for NTUPLE control for i40e.
>=20
> Elizabeth cleans up and refactors i40e_open() to separate out the VSI
> code into its own i40e_vsi_open().
>=20
> Jesse enables the hardware feature head write back to avoid updating the
> descriptor ring by marking each descriptor with a DD bit and instead
> writes a memory location with an update to where the driver should clean
> up to in i40e and i40evf.  Reduces context descriptors for i40e/i40evf
> since we do not need context descriptors for every packet, only for
> TSO or timesync.
>=20
> Dan Carpenter fixes a potential array underflow in i40e_vc_process_vf_msg=
().
>=20
> Dave fixes an e1000e hardware unit hang where the check for pending Tx wo=
rk
> when link is lost was mistakenly moved to be done only when link is first
> detected to be lost.  Fixed a problem with poor network performance on
> certain silicon in e1000e when configured for 100M HDX performance.
>=20
> Carolyn adds register defines needed for time sync functions and the code
> to call the updated defines.
>=20
> Jacob adds the ixgbe function for writing PCI config word and checks
> whether the adapter has been removed first.
>=20
> Mark adds the bit __IXGBEVF_REMOVING to indicate that the module is being
> removed because the __IXGBEVF_DOWN bit had been overloaded for this
> purpose, but leads to trouble.  ixgbevf_down function can now prevent
> multiple executions by doing test_and_set_bit on __IXGBEVF_DOWN.
>=20
> v2:
> - dropped patch Mitch's patch "i40evf: correctly program RSS HLUT table"
>   based on feedback from Ben Hutchings so that Mitch can re-work the
>   patch solution

Or noticed I referenced the wrong patch name.  v2 dropped the previous
patch 3 in the series which was "i40evf: Support RSS option in ethtool"
patch from Mitch.

>=20
> The following are changes since commit 8cfad496c4257441710735ccef622f3829=
870164:
>   ieee802154: properly unshare skbs in ieee802154 *_rcv functions
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master
>=20
> Anjali Singhai Jain (1):
>   i40e: Patch to enable Ethtool/netdev feature flag for NTUPLE control
>=20
> Carolyn Wyborny (1):
>   igb: Add register defines needed for time sync functions
>=20
> Catherine Sullivan (1):
>   i40e/i40evf: Bump build versions
>=20
> Dan Carpenter (1):
>   i40e: potential array underflow in i40e_vc_process_vf_msg()
>=20
> David Ertman (2):
>   e1000e: Fix Hardware Unit Hang
>   e1000e: Fix Explicitly set Transmit Control Register
>=20
> Elizabeth Kappler (1):
>   i40e: Refactor and cleanup i40e_open(), adding i40e_vsi_open()
>=20
> Jacob Keller (1):
>   ixgbe: add ixgbe_write_pci_cfg_word with ixgbe_removed check
>=20
> Jesse Brandeburg (2):
>   i40e/i40evf: enable hardware feature head write back
>   i40e/i40evf: reduce context descriptors
>=20
> Mark Rustad (2):
>   ixgbevf: Indicate removal state explicitly
>   ixgbevf: Protect ixgbevf_down with __IXGBEVF_DOWN bit
>=20
> Mitch Williams (3):
>   i40e: support VF link state ndo
>   i40evf: correctly program RSS HLUT table
>   i40evf: use min_t
>=20
>  drivers/net/ethernet/intel/e1000e/netdev.c         | 42 +++++++---
>  drivers/net/ethernet/intel/i40e/i40e.h             |  4 +-
>  drivers/net/ethernet/intel/i40e/i40e_main.c        | 89 ++++++++++++++++=
++---
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 48 ++++++++++--
>  drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 91 ++++++++++++++++=
++++--
>  drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  4 +
>  drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 48 ++++++++++--
>  drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 23 +++---
>  drivers/net/ethernet/intel/igb/e1000_defines.h     | 70 ++++++++++++++++=
-
>  drivers/net/ethernet/intel/igb/e1000_regs.h        |  9 +++
>  drivers/net/ethernet/intel/igb/igb_ptp.c           |  4 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c     |  6 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_common.h    |  1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  9 +++
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf.h       |  5 +-
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  | 18 +++--
>  16 files changed, 400 insertions(+), 71 deletions(-)
>=20



--=-aBTRdR+QTtudSscu2hDj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTKVKUAAoJEOVv75VaS+3O0doP/A7V5J8MFUv91AHBpX1yXmcn
HL5kw9ip4rE3ZSKOrUcrDDZPrYI7nj8iOcXwR5ck7nqHYgBaEpolY8BL9aKgwPEl
p9FlfyjUmow2MLa7S0gmCj51RVJ2OMTIw9bOJclKRRNKP4UAvflpfgfnekz6Uikt
z4z8PlKYSk2PDlIfAEtA8gI3wlDN9MjW0P7OTFKRJGqq9PsV8YfPIx/IywQvqG1I
0G/3Dax7MuBxlZASa5jIVb6TtiOFkkc7ETGONuyybZo3mBVXX7Bx2R1EbXXNn3D7
y1WSYMBrEgkzmzpsyKqF9YrvXTvyanRoWw8f3kd6VDReODdM7mICgAjRx96hO+bJ
ZhIneBxyPJWWJ7I6KMN/Cxpp7SPWzC+VmyXim7Bw4APcvmOkLVenls9UFqJCSiGI
axsNWSfvjT6i/KpOuKxTvtO+mP0Iq7Ej694a44o60HQaDRANjc7b4I5itqpVO3qd
4+93Hx0FiIBB36fOdhOwBpGiOxT4Ll8Wt6lJoDyB4yn5DhfsMsd+NJel9RzSCDit
yftgaI0iAbpaHhQG8Cckj1nphTNGtoFOIy4BGY+2tO2v1YrWaaMP3IEgPy/CgdF3
2plnfWA3vm++/ZWud5xBhrALPJpuaZM2QbIzljSS4ep31oAJ6OhByvTRtBH2/HjO
9QyYhJs5zhVV49LUQbgR
=9KZi
-----END PGP SIGNATURE-----

--=-aBTRdR+QTtudSscu2hDj--
