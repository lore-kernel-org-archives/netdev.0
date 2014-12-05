From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] Intel Wired LAN Driver Updates 2014-12-05
Date: Fri,  5 Dec 2014 09:52:39 -0800
Message-ID: <1417801973-28793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:7122 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751539AbaLERxp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Dec 2014 12:53:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and ixgbevf.

Alex provides a couple of patches to cleanup ixgbe.  First cleans up the
page reuse code getting it into a state where all the workarounds needed
are in place as well as cleaning up a few minor oversights such as using
__free_pages instead of put_page to drop a locally allocated page.  Then
cleans up the tail writes for the ixgbe descriptor queues.

Mark Peterson adds support to lookup MAC addresses in Open Firmware or
IDPROM.

Emil provides patches for ixgbe and ixgbevf to fix an issue on rmmod and
to add support for X550 in the VF driver.  First removes the read/write
operations to the CIAA/D registers since it can block access to the PCI
config space and make use of standard kernel functions for accessing the
PCI config space.  Then fixes an issue where the driver has logic to free
up used data in case any of the checks in ixgbe_probe() fail, however
there is a similar set of cleanups that can occur on driver unload in
ixgbe_remove() which can cause the rmmod command to crash.

Don provides the remaining patches in the series to complete the addition
of X550 support into the ixgbe driver.

The following are changes since commit d8febb77b52ebddb9bd03ccaa5b61005e3a45a85:
  tun: Fix GSO meta-data handling in tun_get_user
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (2):
  ixgbe: Clean-up page reuse code
  ixgbe: Remove tail write abstraction and add missing barrier

Don Skidmore (7):
  ixgbe: add support for X550 extended RSS support
  ixgbe: Add timeout parameter to ixgbe_host_interface_command
  ixgbe: Add x550 SW/FW semaphore support
  ixgbe: add methods for combined read and write operations
  ixgbe: cleanup checksum to allow error results
  ixgbe: Add X550 support function pointers
  ixgbe: bump version number

Emil Tantilov (4):
  ixgbe: remove CIAA/D register reads from bad VF check
  ixgbe: fix crash on rmmod after probe fail
  ixgbevf: add support for X550 VFs
  ixgbevf: fix possible crashes in probe and remove

Martin K Petersen (1):
  ixgbe: Look up MAC address in Open Firmware or IDPROM

 drivers/net/ethernet/intel/ixgbe/Makefile         |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |   45 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c   |  133 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h   |    8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c  |    9 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  403 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c      |  214 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h      |   10 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |    3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h     |  284 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c     |   85 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.h     |   39 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c     | 1432 +++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbevf/defines.h      |    2 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |    4 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   42 +-
 drivers/net/ethernet/intel/ixgbevf/vf.c           |   10 +
 drivers/net/ethernet/intel/ixgbevf/vf.h           |    2 +
 18 files changed, 2404 insertions(+), 323 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.h
 create mode 100644 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c

-- 
1.9.3
