From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 0/6][pull request] 10GbE Intel Wired LAN Driver Updates 2017-06-27
Date: Tue, 27 Jun 2017 01:51:25 -0700
Message-ID: <20170627085131.9831-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:28455 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752603AbdF0Ivf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Jun 2017 04:51:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe only.

Tony provides majority of the changes, starting with adding a check to
ensure that adding a MAC filter was successful, before setting the
MACVLAN.  In order to receive notifications of link configurations of the
external PHY and support the configuration of the internal iXFI link on
X552 devices, Tony enables LASI interrupts.  Update the iXFI driver code
flow, since the MAC register NW_MNG_IF_SEL fields have been redefined for
X553 devices, so add MAC checks for iXFI flows.  Added additional checks
for flow control autonegotiation, since it is not support for X553 fiber
 and XFI devices.

Paul adds malicious driver detection (MDD) support for X550* devices.  MDD
is a hardware SR-IOV security feature which the driver enables by default,
and can be controlled by ethtool set-priv-flags parameter.

v2: removed unnecessary parens noticed by David Miller in patch 6 of the
    series.

The following are changes since commit 593814d1beae8ad91be6c90f95764e09fc7ca236:
  net/mlx4: fix spelling mistake: "coalesing" -> "coalescing"
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 10GbE

Paul Greenwalt (1):
  ixgbe: Add malicious driver detection support

Tony Nguyen (5):
  ixgbe: Ensure MAC filter was added before setting MACVLAN
  ixgbe: Enable LASI interrupts for X552 devices
  ixgbe: Update NW_MNG_IF_SEL support for X553
  ixgbe: Do not support flow control autonegotiation for X553
  ixgbe: Disable flow control for XFI

 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   3 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  |  30 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c  |  25 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  13 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c   |  66 ++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |  12 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c    | 240 +++++++++++++++++++----
 8 files changed, 340 insertions(+), 57 deletions(-)

-- 
2.12.2
