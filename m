From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates 2013.02.05
Date: Tue,  5 Feb 2013 02:02:13 -0800
Message-ID: <1360058548-18158-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19489 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751542Ab3BEKCr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2013 05:02:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000e and ixgbe.  Majority of the patc=
hes
are against e1000e, where Bruce makes several cosmetic #define moves in=
to
header files.  In addition, Bruce does a cleanup of braces to resolve
checkpatch warnings (when using the strict option).

Ixgbe patches contain several fixes as well as updating the copyright. =
 The
fixes from Josh Hay, resolved a possible NULL pointer dereference and
resolved Smatch warnings by fixing return values and memcpy parameters.
Alex provides 2 fixes, the first is to replace rmb() with
read_barrier_depends() in the Tx cleanup.  The second fixes an MTU
warning when using SR-IOV which corrects the fact that we were using 15=
22
to test for the max frame size in ixgbe_change_mtu and 1518 in
ixgbe_set_vf_lpe.  The difference was the addition of VLAN_HLEN, which =
we
only need to add in the case of computing a buffer size, but not a filt=
er
size.  Lastly, a patch from Emil which is based on a community patch fr=
om
Aur=C3=A9lien Guillaume which adds functions needed for reading SFF-847=
2
diagnostic data from SFP modules.

The following are changes since commit 27000929ef0f137b34ba219eb04b05e7=
72eff2b1:
  ipcomp: Mark as netns_ok.
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next maste=
r

Alexander Duyck (2):
  ixgbe: Replace rmb in Tx cleanup with read_barrier_depends
  ixgbe: Fix SR-IOV MTU warning

Bruce Allan (9):
  e1000e: cosmetic move of #defines and prototypes to the new 82571.h
  e1000e: cosmetic move of #defines to the new 80003es2lan.h
  e1000e: cosmetic move of #defines and prototypes to the new ich8lan.h
  e1000e: cosmetic move of function prototypes to the new mac.h
  e1000e: cosmetic move of #defines and function prototypes to the new
    phy.h
  e1000e: cosmetic move of #defines and function prototypes to the new
    nvm.h
  e1000e: cosmetic move of #defines and prototypes to the new manage.h
  e1000e: convert enums of register offsets and move #defines to regs.h
  e1000e: cleanup checkpatch braces checks

Don Skidmore (1):
  ixgbe: update date to 2013

Emil Tantilov (1):
  ixgbe: allow reading of SFF-8472 data over i2c

Josh Hay (2):
  ixgbe: fix potential null dereference
  ixgbe: fix return values and memcpy parameters to eliminate Smatch
    warnings

 drivers/net/ethernet/intel/e1000e/80003es2lan.c    |  63 ----
 drivers/net/ethernet/intel/e1000e/80003es2lan.h    |  95 ++++++
 drivers/net/ethernet/intel/e1000e/82571.c          |  16 -
 drivers/net/ethernet/intel/e1000e/82571.h          |  58 ++++
 drivers/net/ethernet/intel/e1000e/defines.h        |  38 ---
 drivers/net/ethernet/intel/e1000e/e1000.h          | 207 ------------
 drivers/net/ethernet/intel/e1000e/ethtool.c        |   6 +-
 drivers/net/ethernet/intel/e1000e/hw.h             | 347 +------------=
--------
 drivers/net/ethernet/intel/e1000e/ich8lan.c        | 127 --------
 drivers/net/ethernet/intel/e1000e/ich8lan.h        | 268 +++++++++++++=
+++
 drivers/net/ethernet/intel/e1000e/mac.h            |  74 +++++
 drivers/net/ethernet/intel/e1000e/manage.c         |  13 -
 drivers/net/ethernet/intel/e1000e/manage.h         |  72 +++++
 drivers/net/ethernet/intel/e1000e/netdev.c         |  15 -
 drivers/net/ethernet/intel/e1000e/nvm.h            |  47 +++
 drivers/net/ethernet/intel/e1000e/phy.c            |  43 ---
 drivers/net/ethernet/intel/e1000e/phy.h            | 242 +++++++++++++=
+
 drivers/net/ethernet/intel/e1000e/regs.h           | 252 +++++++++++++=
++
 drivers/net/ethernet/intel/ixgbe/Makefile          |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h           |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c     |  47 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c     |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c    |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h    |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c       |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.h       |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.h |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c    |   9 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c   |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   |  11 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c      |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.h      |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c       |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c       |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h       |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c       |  18 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h       |  11 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c       |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h     |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c     |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h      |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c      |   3 +-
 47 files changed, 1228 insertions(+), 910 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/e1000e/80003es2lan.h
 create mode 100644 drivers/net/ethernet/intel/e1000e/82571.h
 create mode 100644 drivers/net/ethernet/intel/e1000e/ich8lan.h
 create mode 100644 drivers/net/ethernet/intel/e1000e/mac.h
 create mode 100644 drivers/net/ethernet/intel/e1000e/manage.h
 create mode 100644 drivers/net/ethernet/intel/e1000e/nvm.h
 create mode 100644 drivers/net/ethernet/intel/e1000e/phy.h
 create mode 100644 drivers/net/ethernet/intel/e1000e/regs.h

--=20
1.7.11.7
