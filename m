From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] 100GbE Intel Wired LAN Driver Updates 2015-12-13
Date: Sun, 13 Dec 2015 16:27:32 -0800
Message-ID: <1450052867-36654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:41661 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751478AbbLNA1t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 19:27:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to fm10k only.

Jacob updates the driver to use ether_addr_copy() instead of copying
byte-by-byte in a for loop.  Fixed up CamelCase variable names and coding
style issues.  Cleaned up namespace pollution of fm10k_iov_msg_data_pf().
Cleaned up, by making it consistent, the use of VLAN and VLAN ID instead of
vlan or vid.  Lastly, update the driver to initialize XPS so that we can
take advantage of the kernel feature.

Alex Duyck fixed up the driver to free the resources associated with the
MSI-X vector table if the q_vector allocation failed.  Then fixed the driver
to check for msix_entries to be NULL and freed the IRQ if the mailbox API
returned an error on trying to connect.

Bruce cleans up whitespace and namespace pollution issues in the driver.
Also updates the driver to use the BIT() macro instead of bit-shifting coding.

The following are changes since commit f68766d8844f4340992a993f1af5f0307d740d8c:
  Merge branch '1GbE' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 100GbE

Alexander Duyck (2):
  fm10k: Cleanup MSI-X interrupts in case of failure
  fm10k: Cleanup exception handling for mailbox interrupt

Bruce Allan (5):
  fm10k: do not inline fm10k_iov_select_vid()
  fm10k: whitespace cleanups
  fm10k: use BIT() macro instead of open-coded bit-shifting
  fm10k: cleanup namespace pollution
  fm10k: cleanup overly long lines

Jacob Keller (8):
  fm10k: use ether_addr_copy to copy MAC address
  fm10k: do not use CamelCase
  fm10k: remove unnecessary else block from if statements with return
  fm10k: remove namespace pollution of fm10k_iov_msg_data_pf
  fm10k: consistently refer to VLANs and VLAN IDs
  fm10k: bump driver version
  fm10k: conditionally compile DCB and DebugFS support
  fm10k: initialize xps at driver load

 drivers/net/ethernet/intel/fm10k/Makefile        | 20 ++++--
 drivers/net/ethernet/intel/fm10k/fm10k.h         | 15 +++--
 drivers/net/ethernet/intel/fm10k/fm10k_dcbnl.c   |  4 --
 drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c |  4 --
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 16 +++--
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    | 10 +--
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c     |  3 +-
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  | 14 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     | 81 ++++++++++++++++--------
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c      | 55 +++++++---------
 drivers/net/ethernet/intel/fm10k/fm10k_pf.h      |  5 +-
 drivers/net/ethernet/intel/fm10k/fm10k_tlv.c     | 18 +++---
 drivers/net/ethernet/intel/fm10k/fm10k_tlv.h     |  7 +-
 drivers/net/ethernet/intel/fm10k/fm10k_type.h    | 16 ++---
 drivers/net/ethernet/intel/fm10k/fm10k_vf.c      |  1 +
 15 files changed, 148 insertions(+), 121 deletions(-)

-- 
2.5.0
