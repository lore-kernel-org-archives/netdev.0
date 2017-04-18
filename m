From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] 10GbE Intel Wired LAN Driver Updates 2017-04-18
Date: Tue, 18 Apr 2017 16:01:50 -0700
Message-ID: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:61886 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752280AbdDRXCK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Apr 2017 19:02:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to mainly ixgbe with only one ixgbevf change.

Usha adds a check to ensure the creation of number of VF's is valid based
on the traffic classes configured, all to avoid transmit hangs.

Joe Perches reduces the use of pr_cont since the output can be interleaved
by other processes.

Tony cleans up the code overwriting the KX4 config, which is configured by
the NVM.  Adds a check for MMNGC.MNG_VETO, to resolve an issue where we
were getting a link loss for the BMC when loading the driver.

Don fixes up SGMII x553 config details which were missed in earlier
implementations.  Added support for x552 XFI backplane interface support.
Cleaned up an unused define, which was causing confusion on supported
devices.

Emil fixes a link issue on KR parts by making sure the default setting is
set.  Refactors the code so that the code for allocating memory for the
list of MAC addresses that the VFs can use into its own function.  Made
some code cleans to help readability and ensure notification of SRIOV
being enabled is done upon completion.  Fixed an issue where if we failed
to allocate vfinfo in __ixgbe_enable_sriov() the driver would crash with
a NULL pointer dereference.

Philippe Reynes updates ixgbevf to use the new API for
{get|set}_link_ksettings.

Alex increases the headroom allocation when using build_skb() on a
system with 4K pages.  Fixed an issue in ixgbe_dump() where we were no
longer clearing the status bit.

The following are changes since commit 4116c97689b9b1732ac5b68afd922406f9fc842e:
  Merge branch 'ftgmac100-batch5-features'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 10GbE

Alexander Duyck (2):
  ixgbe: Add support for maximum headroom when using build_skb
  ixgbe: Fix output from ixgbe_dump

Don Skidmore (4):
  ixgbe: Complete support for X553 sgmii
  ixgbe: Add X552 XFI backplane support
  ixgbe: list X553 backplane speeds correctly
  ixgbe: Remove unused define

Emil Tantilov (4):
  ixgbe: add default setup_link for x550em_a MAC type
  ixgbe: move num_vfs_macvlans allocation into separate function
  ixgbe: return early instead of wrap block in if statement
  ixgbe: do not use adapter->num_vfs when setting VFs via module
    parameter

Joe Perches (1):
  ixgbe: Remove pr_cont uses

Philippe Reynes (1):
  ixgbevf: use new api ethtool_{get|set}_link_ksettings

Tony Nguyen (2):
  ixgbe: Remove driver config for KX4 PHY
  ixgbe: add check for VETO bit when configuring link for KR

Usha Ketineni (1):
  ixgbe: Avoid Tx hang by not allowing more than the number of VFs
    supported.

 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |  55 +++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 101 +++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c     |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c   | 169 +++++++++++++----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h   |   5 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |  22 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c    | 102 ++++++++------
 drivers/net/ethernet/intel/ixgbevf/ethtool.c     |  22 +--
 9 files changed, 287 insertions(+), 193 deletions(-)

-- 
2.12.2
