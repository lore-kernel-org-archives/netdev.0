From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 0/6] Intel Wired LAN Driver Updates
Date: Thu, 27 Feb 2014 20:32:39 -0800
Message-ID: <1393561965-3688-1-git-send-email-aaron.f.brown@intel.com>
Cc: Aaron Brown <aaron.f.brown@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:53821 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750907AbaB1EgJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 23:36:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and ixgbevf.

Don provides an update to change a hard coded timeout interval to
a system-wide timeout one, collects AUTOC register functions into
one place and fixes some firmware bit handling.

Emil resolves a tx handling error introduced in a recent commit and
adds check for CHECKSUM_PARTIAL to avoid an skb_is_gso check

Don Skidmore (4):
  ixgbe: fix to use correct timeout interval for memory read completion
  ixgbe: collect all 82599 AUTOC code in one function
  ixgbe: fix bit toggled for 82599 reset fix.
  ixgbe: Add check for FW veto bit

Emil Tantilov (2):
  ixgbevf: fix handling of tx checksumming
  ixgbevf: add check for CHECKSUM_PARTIAL when doing TSO

 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |   1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c    |   2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c    | 189 ++++++++++++----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c   | 172 +++++++++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h   |   5 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c      |  44 ++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h      |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h     |  21 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c     |   2 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   5 +-
 10 files changed, 294 insertions(+), 150 deletions(-)

-- 
1.8.5.GIT
