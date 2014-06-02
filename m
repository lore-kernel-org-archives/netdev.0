From: Ben Hutchings <ben@decadent.org.uk>
Subject: Pull request: Fixes for new ethtool RSS commands
Date: Mon, 02 Jun 2014 01:57:39 +0100
Message-ID: <1401670659.14007.94.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-KIWD7KaguMVNJkdRMAKO"
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46310 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752472AbaFBA5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 20:57:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-KIWD7KaguMVNJkdRMAKO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The following changes since commit eb02a272c97b6e25d8e5fcf1ea93923e6f155595=
:

  driver/net/ethernet/ec_bhf.c: fix sparse warnings (2014-05-14 16:09:33 -0=
400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/net-next.git ethtool-rs=
sh-fixes

for you to fetch changes up to dfe805c14a2018c5a58cfa3921f1897032740501:

  ethtool: Check that reserved fields of struct ethtool_rxfh are 0 (2014-05=
-19 01:30:30 +0100)

This addresses several problems I previously identified with the new
ETHTOOL_{G,S}RSSH commands:

1. Missing validation of reserved parameters
2. Vague documentation
3. Use of unnamed magic number
4. No consolidation with existing driver operations

I don't currently have access to suitable network hardware, but have
tested these changes with a dummy driver that can support various
combinations of operations and sizes, together with (a) Debian's ethtool
3.13 (b) ethtool 3.14 with the submitted patch to use ETHTOOL_{G,S}RSSH
and minor adjustment for fixes 1 and 3.

Ben.

----------------------------------------------------------------
Ben Hutchings (8):
      ethtool: Return immediately on error in ethtool_copy_validate_indir()
      ethtool: Name the 'no change' value for setting RSS hash key but not =
indir table
      ethtool: Improve explanation of the two arrays following struct ethto=
ol_rxfh
      ethtool: Expand documentation of ethtool_ops::{get,set}_rxfh()
      ethtool: Disallow ETHTOOL_SRSSH with both indir table and hash key un=
changed
      ethtool, be2net: constify array pointer parameters to ethtool_ops::se=
t_rxfh
      ethtool: Replace ethtool_ops::{get,set}_rxfh_indir() with {get,set}_r=
xfh()
      ethtool: Check that reserved fields of struct ethtool_rxfh are 0

 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |  15 +--
 drivers/net/ethernet/broadcom/tg3.c                |   8 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   8 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c        |   2 +-
 drivers/net/ethernet/emulex/benet/be_cmds.h        |   2 +-
 drivers/net/ethernet/emulex/benet/be_ethtool.c     |   3 +-
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c |  15 +--
 drivers/net/ethernet/intel/igb/igb_ethtool.c       |   9 +-
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c    |  10 +-
 drivers/net/ethernet/sfc/ethtool.c                 |  10 +-
 include/linux/ethtool.h                            |  24 ++---
 include/uapi/linux/ethtool.h                       |  25 ++---
 net/core/ethtool.c                                 | 110 +++++++++--------=
----
 13 files changed, 116 insertions(+), 125 deletions(-)

--=20
Ben Hutchings
Any smoothly functioning technology is indistinguishable from a rigged demo=
.

--=-KIWD7KaguMVNJkdRMAKO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU4vMC+e/yOyVhhEJAQpoYhAAlXSg+nvC2p0gIYTSen+dsmM9XfBqNnh0
DyeUd187elysKztsS41Uop7kjfah8KMt6T6ZXZBJH608C7xUSo6lIr8Fv+V/aM/F
zmwTKqrrEJM6G5ipd9HIa76hzkvR4fO+5+F3Rq/93qsGLvDGkLaBETv4I0KLuN0+
rqXkn87KTVY/bTkqfTzgXQOAmnmhFqdhJQvEO2/Xi4TyIK1d0QK9dgT1bMDAF+2I
0D9MUs0LzASflGeFEeU2IoAgmxegnzNNUYiQ+NEEiau8pFwA7mij/cHXC3zwv4nL
YRnZiHkMlD+Rp3wug1vos6FtOF8Jv5UsyjDCB+/AHkkcI33PhWWyxvPwfVyWpxtM
bgSm0TUdjjDfw+tQcL4BuJmow5goBp7xEpFlX6tIGS86WPk34D+sxvyQuTQgZ4wY
nKuI/fcN0A0f0+Bre1fmfiU9fLJhYM9xzqruDWWVS9ov6UPcFSDgSwmXVan1AMdv
bYb01rsKLUV7lSej8KSiD99dPakUf15q1+sea7jzXtCVAtgjG3u6uKl4S/3XgPXn
TyjLyPeYTGJEyS7OWqbXBs3G50p8vW4DCKjlmRv27fIsSSroVcJO4oGsjC9D+q3h
bkgE4VVbmbdTcNEQe3xnB61PU3ys1/soU+bki4rEZ/cLo0nTIVmiufMnCrGU3qFL
CACpY+Z2V2g=
=Ab/+
-----END PGP SIGNATURE-----

--=-KIWD7KaguMVNJkdRMAKO--
