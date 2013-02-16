From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates 2013.02.16
Date: Sat, 16 Feb 2013 00:33:21 -0800
Message-ID: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:2804 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751399Ab3BPIdk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Feb 2013 03:33:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000, e1000e, igb, igbvf and ixgbe.
The e1000, e1000e, igb and igbvf are single patch changes and the
remaining 11 patches are all against ixgbe.

The e1000 patch is a comment cleanup to align e1000 with the code
commenting style for /drivers/net.  It also contains a few other white
space cleanups (i.e. fix lines over 80 char, remove unnecessary blank
lines and fix the use of tabs/spaces).

The e1000e patch from Koki (Fujitsu) adds a warning when link speed is
downgraded due to SmartSpeed.

The igb patch from Stefan (Red Hat) increases the timeout in the ethtoo=
l
offline self-test because some i350 adapters would sometimes fail the
self-test because link auto negotiation may take longer than the curren=
t
4 second timeout.

The igbvf patch from Alex is meant to address several race issues that
become possible because next_to_watch could possibly be set to a value
that shows that the descriptor is done when it is not.  In order to cor=
rect
that we instead make next_to_watch a pointer that is set to NULL during
cleanup, and set to the eop_desc after the descriptor rings have been w=
ritten.

The remaining patches for ixgbe are a mix of fixes and added support as=
 well
as some cleanup.  Most notably is the added support for displaying the
number of Tx/Rx channels via ethtool by Alex.  Also Aur=C3=A9lien adds =
the
ability for reading data from SFP+ modules over i2c for diagnostic
monitoring.

The following are changes since commit efd9450e7e36717f24dff3bd584faa80=
a85231d6:
  net: use skb_reset_mac_len() in dev_gro_receive()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next maste=
r

Alexander Duyck (8):
  igbvf: Make next_to_watch a pointer and adjust memory barriers to
    avoid races
  ixgbe: Define FCoE and Flow director limits much sooner to allow for
    changes
  ixgbe: Add function for setting XPS queue mapping
  ixgbe: Update ixgbe driver to use __netdev_pick_tx in
    ixgbe_select_queue
  ixgbe: Make ixgbe_setup_tc usable even when DCB is not enabled
  ixgbe: Add support for displaying the number of Tx/Rx channels
  ixgbe: Add support for set_channels ethtool operation
  ixgbe: Update DESC_NEEDED define to adjust for changes to
    MAX_SKB_FRAGS

Aur=C3=A9lien Guillaume (1):
  ixgbe: implement SFF diagnostic monitoring via ethtool

Emil Tantilov (3):
  ixgbe: fix possible data corruption in read_i2c_byte
  ixgbe: cleanup error checking in ixgbe_identify_sfp_module_generic()
  ixgbe: fix Tx timeouts with BQL

Jeff Kirsher (1):
  e1000: fix whitespace issues and multi-line comments

Koki Sanagi (1):
  e1000e: display a warning message when SmartSpeed works

Stefan Assmann (1):
  igb: increase timeout for ethtool offline self-test

 drivers/net/ethernet/intel/e1000/e1000.h         |  65 +--
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c | 140 +++---
 drivers/net/ethernet/intel/e1000/e1000_hw.c      | 558 +++++++++++++--=
--------
 drivers/net/ethernet/intel/e1000/e1000_main.c    | 322 +++++++------
 drivers/net/ethernet/intel/e1000/e1000_param.c   |  29 +-
 drivers/net/ethernet/intel/e1000e/netdev.c       |   7 +
 drivers/net/ethernet/intel/igb/igb_ethtool.c     |   2 +-
 drivers/net/ethernet/intel/igbvf/igbvf.h         |   2 +-
 drivers/net/ethernet/intel/igbvf/netdev.c        |  52 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |  17 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 257 ++++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c     |  21 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 125 ++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c     |  36 +-
 14 files changed, 973 insertions(+), 660 deletions(-)

--=20
1.7.11.7
