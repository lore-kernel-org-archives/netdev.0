From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/10][pull request] Intel Wired LAN Drivers Update
Date: Sat, 24 Sep 2011 02:17:33 -0700
Message-ID: <1316855863-6091-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:33105 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752330Ab1IXJRq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Sep 2011 05:17:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e1000, ixgbe, ixgbevf and
if_link.  The e1000 patch is a fix to an issue seen qemu-kvm. The
if_link patch adds an additional parameter for spoof checking,
and there is a subsequent ixgbe patch to implement the if_link
parameter.  The ixgbevf patch fixes an issue with trunk VLAN.

The remainder of the patches for ixgbe include:
  - add thermal sensor support
  - add ECC warning for legacy interrupts
  - cleanup/update interrupt throttle rate logic
  - cleanup/update X540 code

NOTE- After the discussion on conflating NAPI and interrupt moderation,
I have a patch in validation to remove the tie between work_limit and
interrupt moderation for ixgbe, which is not in this series.  I mention
this because the cleanup to interrupt throttle rate logic patch
still contains the code that ties NAPI and interrupt moderation.

The following are changes since commit 7777de9af54a1402c79bf7663b38ff5ba308dd45:
  qlcnic: Change CDRP function
and are available in the git repository at:
  git://github.com/Jkirsher/net-next.git

Dean Nelson (1):
  e1000: don't enable dma receives until after dma address has been
    setup

Don Skidmore (2):
  ixgbe: cleanup ixgbe_setup_gpie() for X540
  ixgbe: add ECC warning for legacy interrupts

Emil Tantilov (1):
  ixgbe: Cleanup q_vector interrupt throttle rate logic

Greg Rose (3):
  ixgbevf: Fix broken trunk vlan
  if_link: Add additional parameter to IFLA_VF_INFO for spoof checking
  ixgbe: Add new netdev op to turn spoof checking on or off per VF

Jacob Keller (1):
  ixgbe add thermal sensor support for x540 hardware

John Fastabend (1):
  ixgbe: update {P}FC thresholds to account for X540 and loopback

Vasu Dev (1):
  ixgbe: disable LLI for FCoE

 drivers/net/ethernet/intel/e1000/e1000_main.c      |    6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h           |   28 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c     |    8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c    |   12 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.h       |    1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c |    9 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c |    8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   |  153 +++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c      |    4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  299 +++++++++++++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     |   48 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h     |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h      |   64 ++++-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |    6 +-
 include/linux/if_link.h                            |    7 +
 include/linux/netdevice.h                          |    3 +
 net/core/rtnetlink.c                               |   25 ++-
 17 files changed, 442 insertions(+), 240 deletions(-)

-- 
1.7.6.2
