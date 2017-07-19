From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v3 0/5][pull request] 10GbE Intel Wired LAN Driver Updates 2017-07-18
Date: Tue, 18 Jul 2017 18:23:00 -0700
Message-ID: <20170719012305.76795-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:31205 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751560AbdGSBXM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Jul 2017 21:23:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe only.

Tony provides all of the changes in the series, starting with adding a
check to ensure that adding a MAC filter was successful, before setting the
MACVLAN.  In order to receive notifications of link configurations of the
external PHY and support the configuration of the internal iXFI link on
X552 devices, Tony enables LASI interrupts.  Update the iXFI driver code
flow, since the MAC register NW_MNG_IF_SEL fields have been redefined for
X553 devices, so add MAC checks for iXFI flows.  Added additional checks
for flow control autonegotiation, since it is not support for X553 fiber
 and XFI devices.

v2: removed unnecessary parens noticed by David Miller in patch 6 of the
    series.
v3: dropped patch 6 of the original series, while we work out a more
    generic solution for malicious driver detection (MDD) support.

The following are changes since commit 8c5e9fb8ac8f60253cd9589b61403d616dbdaf69:
  Merge branch 'net-attribute_group-const'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 10GbE

Tony Nguyen (5):
  ixgbe: Ensure MAC filter was added before setting MACVLAN
  ixgbe: Enable LASI interrupts for X552 devices
  ixgbe: Update NW_MNG_IF_SEL support for X553
  ixgbe: Do not support flow control autonegotiation for X553
  ixgbe: Disable flow control for XFI

 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |  30 +++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c  |  16 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h   |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c   | 102 +++++++++++++++---------
 5 files changed, 99 insertions(+), 55 deletions(-)

-- 
2.13.2
