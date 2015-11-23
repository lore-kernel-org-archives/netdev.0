From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates 2015-11-23
Date: Mon, 23 Nov 2015 11:36:01 -0800
Message-ID: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:20880 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752635AbbKWTgS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 14:36:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe, ixgbevf, fm10k, i40e and i40evf.

Jacob fixes an issue where VF could attempt to read queues it does not own,
so prevent this we check queue 0 before we continue.

Matthew fixes the MTU for jumbo frames for fm10k.

Julia Lawall cleans up a unneeded NULL test in ixgbe.

Mark cleans up a redundant header inclusion.  Adds KR mode support for
CS4227 chip.  Cleaned up diagnostic code, which is no longer needed, for
the CS4227 chip.

Jean Sacren fixes kernel documentation for ixgbe.

Alex Duyck fixes an fm10k and ixgbe issue in which the polling routine would
increase the budget for receive to at least 1 per queue if multiple queues were
present.  This would result in receive packets being processed when the budget
was 0 which is meant to indicate that no receive can be handled.  Also fixes
an ixgbevf performance issue where netperf test will starve for memory in the
time form one transmit interrupt to the next, so limit lowest interrupt rate
for adaptive interrupt moderation to 12K.  Fixed up ixgbe and ixgbevf to
use napi_schedule_irqoff() where the drivers were run from hard interrupt
context or with interrupts already disabled in netpoll.

Jesse fixes a compiler warning about an unused variable for i40evf.

John Greene fixes an issue with ixgbevf, where if the VF driver is loaded
while the corresponding PH interface is down, the driver assigns a random
MAC address, can be overwritten with the value of hw->mac.perm_addr which
is 0 at that point.  So avoid this case by initializing hw->mac.perm_addr
to the randomly generated address and do not set it unless we receive an
ACK from ixgbe.

Rasmus Villemoes cleans up some confusing code in i40e debugfs code.

The following are changes since commit 3d40e44361eab3dd6c969241d12dac7466eb7174:
  Merge branch 'dsa-gpio-reset'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Alexander Duyck (4):
  fm10k: Fix handling of NAPI budget when multiple queues are enabled
    per vector
  ixgbe: Fix handling of NAPI budget when multiple queues are enabled
    per vector
  ixgbevf: Limit lowest interrupt rate for adaptive interrupt moderation
    to 12K
  ixgbe/ixgbevf: use napi_schedule_irqoff()

Emil Tantilov (2):
  ixgbevf: use ether_addr_copy instead of memcpy
  ixgbevf: fix spoofed packets with random MAC

Jacob Keller (2):
  fm10k: do not assume VF always has 1 queue
  fm10k: Correct MTU for jumbo frames

Jean Sacren (1):
  ixgbe: fix multiple kernel-doc errors

Jesse Brandeburg (1):
  i40evf: fix compiler warning of unused variable

Julia Lawall (1):
  ixgbe: drop null test before destroy functions

Mark Rustad (3):
  ixgbe: Delete redundant include file
  ixgbe: Add KR mode support for CS4227 chip
  ixgbe: Remove CS4227 diagnostic code

Rasmus Villemoes (1):
  intel: i40e: fix confused code

 drivers/net/ethernet/intel/fm10k/fm10k.h          |   2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_main.c     |   4 +
 drivers/net/ethernet/intel/fm10k/fm10k_type.h     |   1 +
 drivers/net/ethernet/intel/fm10k/fm10k_vf.c       |   7 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c    |  24 ++--
 drivers/net/ethernet/intel/i40evf/i40evf_main.c   |   7 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c     |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  19 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c     | 165 ++++++++--------------
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |   2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   3 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  23 ++-
 drivers/net/ethernet/intel/ixgbevf/vf.c           |   4 +-
 13 files changed, 111 insertions(+), 153 deletions(-)

-- 
2.5.0
