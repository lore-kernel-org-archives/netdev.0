From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] Intel Wired LAN Driver Updates 2015-07-17
Date: Fri, 17 Jul 2015 07:25:09 -0700
Message-ID: <1437143123-5031-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:19520 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757773AbbGQOZd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2015 10:25:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb, ixgbe, ixgbevf, i40e, bnx2x,
freescale, siena and dp83640.

Jacob provides several patches to clarify the intended way to implement
both SIOCSHWTSTAMP and ethtool's get_ts_info().  It is okay to support
the specific filters in SIOCSHWTSTAMP by upscaling them to the generic
filters.

Alex Duyck provides a igb patch to pull the time stamp from the fragment
before it gets added to the skb, to avoid a possible issue in which the
fragment can possibly be less than IGB_RX_HDR_LEN due to the time stamp
being pulled after the copybreak check.  Also provides a ixgbevf patch to
fold the ixgbevf_pull_tail() call into ixgbevf_add_rx_frag(), which gives
the advantage that the fragment does not have to be modified after it is
added to the skb.

Fan provides patches for ixgbe/ixgbevf to set the receive hash type
based on receive descriptor RSS type.

Todd provides a fix for igb where on check for link on any media other
than copper was not being detected since it was looking on the incorrect
PHY page (due to the page being used gets switched before the function
to check link gets executed).

The following are changes since commit c15df306fc79c672573f1cc2ebdfcb32d7e68780:
  ipv6: Remove unused arguments for __ipv6_dev_get_saddr().
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Alexander Duyck (2):
  igb: Pull timestamp from fragment before adding it to skb
  ixgbevf: fold ixgbevf_pull_tail into ixgbevf_add_rx_frag

Fan Du (3):
  ixgbe: Specify Rx hash type WRT Rx desc RSS type
  ixgbevf: Set Rx hash type for ingress packets
  ixgbe: Don't report flow director filter's status

Jacob Keller (8):
  clarify implementation of ethtool's get_ts_info op
  freescale: remove incorrect copied comment
  bnx2x: only report most generic filters in get_ts_info
  i40e: only report generic filters in get_ts_info
  igb: only report generic filters in get_ts_info
  ixgbe: only report generic filters in get_ts_info
  siena: only report generic filters in get_ts_info
  dp83640: only report generic filters in ts_info

Todd Fujinaka (1):
  igb: Fix i354 88E1112 PHY on RCC boards using AutoMediaDetect

 Documentation/networking/timestamping.txt          |  7 ++
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    | 11 +--
 drivers/net/ethernet/freescale/fec_ptp.c           |  6 --
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 13 +--
 drivers/net/ethernet/intel/igb/e1000_82575.c       | 18 +++--
 drivers/net/ethernet/intel/igb/igb_ethtool.c       |  4 -
 drivers/net/ethernet/intel/igb/igb_main.c          | 94 ++++++----------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c     |  2 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   |  8 --
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      | 25 +++++-
 drivers/net/ethernet/intel/ixgbevf/defines.h       | 12 +++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  | 93 +++++++++++----------
 drivers/net/ethernet/sfc/siena.c                   |  6 +-
 drivers/net/phy/dp83640.c                          | 10 +--
 include/uapi/linux/ethtool.h                       |  5 ++
 15 files changed, 134 insertions(+), 180 deletions(-)

-- 
2.4.3
