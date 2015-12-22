From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/10][pull request] 100GbE Intel Wired LAN Driver Updates 2015-12-22
Date: Tue, 22 Dec 2015 06:02:02 -0800
Message-ID: <1450792932-96015-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:29757 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753506AbbLVODP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Dec 2015 09:03:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to fm10k only.

Bruce cleans up the initialization of fm10k_workqueue at the global level,
which fixes a checkpatch.pl error.  Made several other cleanups of the
driver, like making structures that do not change constant, remove unused
code, cleanup code comments and use boolean states true/false instead of
an integer since a bool is all that is needed.

Jacob fixed the TLV format for little endian structures which are 4 byte
aligned copy, so add an additional __aligned(4) and __packed to ensure
that these structures are actually 4 byte aligned and packed correctly.
Updated the driver to use ether_addr_equal() instead of memcmp() to
compare MAC addresses.

Alex Duyck cleans up the exception handling so all of the paths result in
a similar state if we fail.  Specifically the driver will now unload the
mailbox interrupt, free the queue vectors and MSI-X, and then detach the
interface.

The following are changes since commit 076ef440708bc28d821cebb2dbca64e3c917ac73:
  ibmveth: consolidate kmalloc of array, memset 0 to kcalloc
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 100GbE

Alexander Duyck (1):
  fm10k: Cleanup exception handling for changing queues

Bruce Allan (7):
  fm10k: don't initialize fm10k_workqueue at global level
  fm10k: address operator not needed when declaring function pointers
  fm10k: constify fm10k_mac_ops, fm10k_iov_ops and fm10k_info structures
  fm10k: remove unused struct element
  fm10k: use true/false for boolean get_host_state
  fm10k: cleanup mailbox code comments etc
  fm10k: IS_ENABLED() is not appropriate for boolean kconfig option

Jacob Keller (2):
  fm10k: correctly pack TLV structures and explain reasoning
  fm10k: use ether_addr_equal instead of memcmp

 drivers/net/ethernet/intel/fm10k/fm10k_main.c   |  6 +--
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c    | 50 +++++++++++--------
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.h    |  4 +-
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 28 ++++++++---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c    | 61 +++++++++++++++++------
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c     | 66 ++++++++++++-------------
 drivers/net/ethernet/intel/fm10k/fm10k_pf.h     | 15 ++++--
 drivers/net/ethernet/intel/fm10k/fm10k_tlv.c    |  2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_tlv.h    |  4 +-
 drivers/net/ethernet/intel/fm10k/fm10k_type.h   |  9 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_vf.c     | 44 ++++++++---------
 drivers/net/ethernet/intel/fm10k/fm10k_vf.h     |  2 +-
 12 files changed, 173 insertions(+), 118 deletions(-)

-- 
2.5.0
