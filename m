From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/6][pull request] 10GbE Intel Wired LAN Driver Updates 2016-08-20
Date: Sat, 20 Aug 2016 20:22:16 -0700
Message-ID: <1471749742-7080-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:24499 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751764AbcHUDWY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 20 Aug 2016 23:22:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and ixgbevf.

Veola fixes how the backplane reports the media in ethtool, as KR, KX or
KX4 based on the backplane interface present.

Emil fixes ixgbevf since an incorrect size parameter for
ixgbevf_write_msg_read_ack() ended up only giving the PF the first 4
bytes of the MAC address, so correct the size by calculating it on the
fly for all instances where we call ixgbevf_write_msg_read_ack().  Added
geneve receive offload support for x550em_a.

Don fixes the LED interface for x557 since it uses a different interface.
Added support for the new x557 copper device.

The following are changes since commit 8238ac0ce27b9537a4c161e0382abfc613ee577b:
  Merge branch 'tun-cleanups'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 10GbE

Don Skidmore (3):
  ixgbe: Fix led interface for X557 devices
  ixgbe: add device to MDIO speed setting
  ixgbe: Add support for new X557 device

Emil Tantilov (2):
  ixgbevf: fix incorrect MAC address on load
  ixgbe: add support for geneve Rx offload

Veola Nazareth (1):
  ixgbe: report correct media type for KR, KX and KX4 interfaces

 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 175 ++++++++++++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |  11 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c    |  62 +++++++-
 drivers/net/ethernet/intel/ixgbevf/vf.c          |  21 ++-
 7 files changed, 217 insertions(+), 61 deletions(-)

-- 
2.7.4
