From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/8][pull request] 100GbE Intel Wired LAN Driver Updates 2017-01-08
Date: Sun,  8 Jan 2017 02:10:26 -0800
Message-ID: <20170108101034.119851-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:60633 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1162037AbdAHKKg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 8 Jan 2017 05:10:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to fm10k only.

Ngai-Mint changes the driver to use the MAC pointer in the fm10k_mac_info
structure for fm10k_get_host_state_generic().  Fixed a race condition
where the mailbox interrupt request bits can be cleared before being
handled causing certain mailbox messages from the PF to be untreated
and the PF will enter in some inactive state.

Jake removes the typecast of u8 to char, and the extra variable that was
created for the typecast.  Bumps the driver version.  Added back the
receive descriptor timestamp value so that applications built on top
of the IES API can function properly.  Cleaned up the debug statistics
flag, since debug statistics were removed and the flag was missed in
the removal.

Scott limits the DMA sync for CPU to the actual length of the packet,
instead of the entire buffer, since the DMA sync occurs every time a
packet is received.

The following are changes since commit 111427f6eb5a5d9ce22f8a90780ac1c18113091a:
  net: dsa: move HWMON support to its own file
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 100GbE

Jacob Keller (4):
  fm10k: remove extraneous variable definition in fm10k_ethtool.c
  fm10k: bump version number
  fm10k: report the receive timestamp in FM10K_CB(skb)->tstamp
  fm10k: remove FM10K_FLAG_DEBUG_STATS

Ngai-Mint Kwan (3):
  fm10k-shared: use mac-> instead of hw->mac.
  fm10k: request reset when mbx->state changes
  fm10k: do not clear global mailbox interrupt bits

Scott Peterson (1):
  fm10k: Limit dma sync of RX buffers to actual packet size

 drivers/net/ethernet/intel/fm10k/fm10k.h         |  4 +---
 drivers/net/ethernet/intel/fm10k/fm10k_common.c  |  6 +++---
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 21 +++++++++------------
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    | 12 ++++++++----
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c     | 10 +++++++---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     |  6 +++++-
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c      |  4 ----
 7 files changed, 33 insertions(+), 30 deletions(-)

-- 
2.9.3
