From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/7][pull request] Intel Wired LAN Driver Updates
Date: Fri, 10 Feb 2012 16:08:17 -0800
Message-ID: <1328918904-11511-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:22454 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754862Ab2BKAI1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Feb 2012 19:08:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to ixgbe and skbuff.
The skbuff patch helps reduce the overall size of sk_buff and the
remaining patches are against ixgbe.  They do the following:
 - refactor RSC and address that RSC was not setting GSO size
 - combine post-DMA processing of sk_buff fields into 1 function
 - drop _ADV since all descriptors are advanced
 - improvements in the use of clear and status bits on Rx

The following are changes since commit d9dd966d7fc088a6bed991c2b1e2fba4485e0a31:
  igb: fix warning about unused function
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (7):
  ixgbe: Minor refactor of RSC
  ixgbe: Address fact that RSC was not setting GSO size for incoming
    frames
  ixgbe: Let the Rx buffer allocation clear status bits instead of
    cleanup
  ixgbe: Add function for testing status bits in Rx descriptor
  ixgbe: Drop the _ADV of descriptor macros since all ixgbe descriptors
    are ADV
  ixgbe: Combine post-DMA processing of sk_buff fields into single
    function
  skbuff: Move rxhash and vlan_tci to consolidate holes in sk_buff

 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   29 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c    |   59 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  686 ++++++++++++++--------
 include/linux/skbuff.h                           |    9 +-
 5 files changed, 505 insertions(+), 282 deletions(-)

-- 
1.7.7.6
