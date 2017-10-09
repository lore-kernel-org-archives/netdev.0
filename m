From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/5][pull request] Intel Wired LAN Driver Updates 2017-10-09
Date: Mon,  9 Oct 2017 08:12:46 -0700
Message-ID: <20171009151251.53939-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:48022 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751636AbdJIPNO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 11:13:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and arch/Kconfig.

Mark fixes a case where PHY register access is not supported and we were
returning a PHY address, when we should have been returning -EOPNOTSUPP.

Sabrina Dubroca fixes the use of a logical "and" when it should have been
the bitwise "and" operator.

Ding Tianhong reverts the commit that added the Kconfig bool option
ARCH_WANT_RELAX_ORDER, since there is now a new flag
PCI_DEV_FLAGS_NO_RELAXED_ORDERING that has been added to indicate that
Relaxed Ordering Attributes should not be used for Transaction Layer
Packets.  Then follows up with making the needed changes to ixgbe to
use the new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag.

John Fastabend fixes an issue in the ring accounting when the transmit
ring parameters are changed via ethtool when an XDP program is attached.

The following are changes since commit a9e2971b8cd3ef469de0112ba15778b5b98ad72e:
  tipc: Unclone message at secondary destination lookup
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue 10GbE

Ding Tianhong (2):
  Revert commit 1a8b6d76dc5b ("net:add one common config...")
  net: ixgbe: Use new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag

John Fastabend (1):
  ixgbe: incorrect xdp ring accounting in ethtool tx_frame param

Mark D Rustad (1):
  ixgbe: Return error when getting PHY address if PHY access is not
    supported

Sabrina Dubroca (1):
  ixgbe: fix masking of bits read from IXGBE_VXLANCTRL register

 arch/Kconfig                                     |  3 ---
 arch/sparc/Kconfig                               |  1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c   | 22 ----------------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  | 19 -------------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 16 ++++++++--------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  6 +++++-
 6 files changed, 13 insertions(+), 54 deletions(-)

-- 
2.14.2
