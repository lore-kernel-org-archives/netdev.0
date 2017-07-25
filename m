From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v4 0/5][pull request] 10GbE Intel Wired LAN Driver Updates 2017-07-25
Date: Tue, 25 Jul 2017 16:41:33 -0700
Message-ID: <20170725234138.42283-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:19869 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751427AbdGYXlp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Jul 2017 19:41:45 -0400
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
v4: updated patch 1 of the series with the comments from Joe Perches which
    were:
      - switched logic to return on error
      - return 0 on success
      - declare retval as an integer

The following are changes since commit 34c8c10a766c8daf42293664f5c9ca5516fa3f41:
  Merge branch 'bnxt_en-Fix-kbuild-errors-and-rename-phys_port_name'
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
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c  |   9 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h   |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c   | 102 +++++++++++++++---------
 5 files changed, 96 insertions(+), 51 deletions(-)

-- 
2.13.3
