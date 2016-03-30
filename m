From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 00/11][pull request] Intel Wired LAN Driver Updates 2016-03-29
Date: Wed, 30 Mar 2016 16:00:44 -0700
Message-ID: <1459378855-139837-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55746 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755190AbcC3XBR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Mar 2016 19:01:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains fixes to ixgbe and ixgbevf.

Tushar fixes an issue which was introduced with an earlier commit, where
hardware register RAR0 default MAC address does not get set properly.

Alex fixes two issues, first being the VXLAN port number should be stored
in network order instead of in host order.  The second fix corrects the ATR
code to handle IPv6 extension headers.  The issue was ATR code was assuming
that it would be able to use tcp_hdr for every TCP frame that came through,
but that is not the case, which resulted in bad filters being setup.

Mark fixes a use of usleep_range() to udelay() in the case where a lock
is being held.

Stefan fixes the offline self tests where ndo_stop() should be used instead
of ndo_close(), which causes IFF_UP to be cleared and interface routes get
removed.

Emil fixes the error case where we need to return an error when a MAC
address change is rejected by the PF.  This helps prevent the user from
modifying the MAC address when the operation is not permitted.

Sridhar provides three fixes for ixgbe, all dealing with traffic class
offload handling.

The following are changes since commit e84810c7b85a2d7897797b3ad3e879168a8e032a:
  qmi_wwan: add "D-Link DWM-221 B1" device id
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue 10GbE

Alexander Duyck (2):
  ixgbe: Store VXLAN port number in network order
  ixgbe: Fix ATR so that it correctly handles IPv6 extension headers

Emil Tantilov (2):
  ixgbevf: fix error code path when setting MAC address
  ixgbe: make __ixgbe_setup_tc static

Mark Rustad (1):
  ixgbe: Use udelay to avoid sleeping while atomic

Sridhar Samudrala (3):
  ixgbe: fix error handling in TC cls_u32 offload routines
  ixgbe: Fix cls_u32 offload support for fields with masks
  ixgbe: Fix cls_u32 offload support for L4 ports

Stefan Assmann (2):
  ixgbe: call ndo_stop() instead of dev_close() when running offline
    selftest
  ixgbevf: call ndo_stop() instead of dev_close() when running offline
    selftest

Tushar Dave (1):
  ixgbe: Fix for RAR0 not being set to default MAC addr

 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |  10 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c  |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 165 ++++++++++------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_model.h    |  21 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c     |   2 +-
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |   4 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   2 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  16 ++-
 drivers/net/ethernet/intel/ixgbevf/vf.c           |   4 +-
 9 files changed, 107 insertions(+), 121 deletions(-)

-- 
2.5.5
