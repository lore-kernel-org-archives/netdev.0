From: Ben Hutchings <ben@decadent.org.uk>
Subject: Pull request: Fixes for new ethtool RSS commands
Date: Tue, 03 Jun 2014 02:49:21 +0100
Message-ID: <1401760161.14007.179.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-lWGBsiLZww98338Xj/V7"
Cc: netdev <netdev@vger.kernel.org>,
	Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49625 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751200AbaFCBtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 21:49:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-lWGBsiLZww98338Xj/V7
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The following changes since commit eb02a272c97b6e25d8e5fcf1ea93923e6f155595=
:

  driver/net/ethernet/ec_bhf.c: fix sparse warnings (2014-05-14 16:09:33 -0=
400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/net-next.git ethtool-rs=
sh-fixes

for you to fetch changes up to f062a3844845d267e3716cbc188ad502a15898b7:

  ethtool: Check that reserved fields of struct ethtool_rxfh are 0 (2014-06=
-03 02:43:16 +0100)

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

v2: Update RSS operations in vmxnet3 too

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
 drivers/net/vmxnet3/vmxnet3_ethtool.c              |   8 +-
 include/linux/ethtool.h                            |  24 ++---
 include/uapi/linux/ethtool.h                       |  25 ++---
 net/core/ethtool.c                                 | 110 +++++++++--------=
----
 14 files changed, 120 insertions(+), 129 deletions(-)

--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-lWGBsiLZww98338Xj/V7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU40ps+e/yOyVhhEJAQpRxw//SuhRB4oLGcsAfS+mlsnCMTI1pJ3WuC5o
H/2heUehW2/Rt3NPmu8IMLXLcRbrG+WFkHH3S081NmwDq3iefRd6aGCQ7MuIlJpP
GXv+qQxMn07S2bDqyva76KPLbrHifMjFV59a9iC27DjaEhzVkJ35Lyci0Ng+opj7
L8sdKZoTLUfaZ8qE0QnehYJFy2MQhG5DSljx3lrPI8iJ42PBz2ht0ihhGdkAqgaE
c1ggqJbcaLrySUC7lWgSUtJD3l5iUwiu9ZXWt7WkqiDF0cA//uLEgC8Rc2wCxKL0
DT1QK/j87wmLQHs/eMEtlwqQavYLZSBx8sbtvXZ6Vuf8GHpbmDPCg9i/rTqgsgcI
BnO+6uVHkOq3TCtyVkCBhjQ9G47vftPoGi8/ZbP6tBavs1Uj2BmgmDGo0wziby65
HYQcXQIeS7GlSxnPnC13ZzVXnAlu8nAvzo4H5WnYjrghmNRL0Rzsw+hRSbfSoCW+
wwAbrnt3aKAftd5741ND1I+3m7F92L+8kKoIOHWhXCq56mxzxrs3W5CTJvCstttF
DgV/qyUW42LQ1B8Hvu3eKgWv83Tax7CaV8d9rbMr9dc8sSZnnO18GYebVWIgaMZm
CqLRwkoSJPT1sdT2zMjllbmyKiCq/sNYMwfCCSgJvIWCmO12d9obAIKNVtE7yTpT
Q3ZZBXZtPk8=
=SwGl
-----END PGP SIGNATURE-----

--=-lWGBsiLZww98338Xj/V7--
