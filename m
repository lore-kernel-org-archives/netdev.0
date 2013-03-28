From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/12][pull request] Intel Wired LAN Driver Updates
Date: Thu, 28 Mar 2013 02:00:03 -0700
Message-ID: <1364461215-7793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61712 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751074Ab3C1JAU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Mar 2013 05:00:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000e, ixgbe and ixgbevf.

Majority of the changes are against e1000e (from Bruce Allan).
Bruce adds additional error handling on PHY register access, as
well as improve slow performance on 82579 when connected to a
10Mbit hub.  In addition, fixes LED blink logic for cathode
LED design.  Most notable is added EEE support which is enabled
by default and the added support for LTR on I217/I218.

The ixgbe and ixgbevf from Greg Rose changes the VM so that if a user
does not assign a MAC address, the MAC address is set to all zeros
instead of a random MAC address.  This ensures that we always know when
we have a random address and udev won't get upset about it.

The following are changes since commit 8b49a4c75965ed157e21450d23dcadd6b27c1aa3:
  bnx2x: fix compilation without CONFIG_BNX2X_SRIOV
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Bruce Allan (10):
  e1000e: additional error handling on PHY register accesses
  e1000e: slow performance between two 82579 connected via 10Mbit hub
  e1000e: fix LED blink logic for designs with LEDs driven by cathode
  e1000e: long access timeouts when I217/I218 MAC and PHY are out of
    sync
  e1000e: EEE capability advertisement not set/disabled as required
  e1000e: enable EEE by default
  e1000e: add support for LTR on I217/I218
  e1000e: cleanup unused defines
  e1000e: increase driver version number
  e1000e: fix scheduling while atomic bugs

Greg Rose (2):
  ixgbe: Don't give VFs random MAC addresses
  ixgbevf: Adjust to handle unassigned MAC address from PF

 drivers/net/ethernet/intel/e1000e/defines.h       |   2 +
 drivers/net/ethernet/intel/e1000e/e1000.h         |   3 +
 drivers/net/ethernet/intel/e1000e/ethtool.c       |  63 ++-----
 drivers/net/ethernet/intel/e1000e/ich8lan.c       | 213 ++++++++++++++++++----
 drivers/net/ethernet/intel/e1000e/ich8lan.h       |  11 +-
 drivers/net/ethernet/intel/e1000e/mac.c           |  27 ++-
 drivers/net/ethernet/intel/e1000e/netdev.c        |  38 +++-
 drivers/net/ethernet/intel/e1000e/phy.c           |  20 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |  23 ++-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  21 ++-
 drivers/net/ethernet/intel/ixgbevf/vf.c           |   7 +-
 11 files changed, 315 insertions(+), 113 deletions(-)

-- 
1.7.11.7
