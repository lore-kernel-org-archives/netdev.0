From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/8][pull request] Intel Wired LAN Driver Updates
Date: Wed,  8 Feb 2012 01:36:30 -0800
Message-ID: <1328693798-27323-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:45540 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751074Ab2BHJgn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Feb 2012 04:36:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains fixes to e1000, igb and ixgbe.
The e1000 fix comes from Red Hat, where a previous commit removed
code which broke WoL and this patch rectifies that. The igb patch
fixes an issue with VF lookup.  The remaining patches in the series
are against ixgbe and fix the following:
 - VF lookup and Tx hang with 32 VFs
 - broken dependency on MAX_SKB_FRAGS
 - ethtool buffer overrun in stats
 - DCB fix for up2tc mapping being lost on disable/enable

The following are changes since commit a1728800bed3b93b231d99e97c756f622b9991c2:
  net: enable TC35815 for MIPS again
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Alexander Duyck (1):
  ixgbe: Fix broken dependency on MAX_SKB_FRAGS being related to page
    size

Dean Nelson (1):
  e1000: add dropped DMA receive enable back in for WoL

Greg Rose (3):
  igb: fix vf lookup
  ixgbe: fix vf lookup
  ixgbe: Fix case of Tx Hang in PF with 32 VFs

John Fastabend (2):
  ixgbe: dcb: up2tc mapping lost on disable/enable CEE DCB state
  ixgbe: ethtool: stats user buffer overrun

Yi Zou (1):
  ixgbe: do not update real num queues when netdev is going away

 drivers/net/ethernet/intel/e1000/e1000_main.c    |   10 ++-
 drivers/net/ethernet/intel/igb/igb_main.c        |    3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c  |   11 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   88 +++++++++++++---------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   18 +++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c   |    3 +-
 6 files changed, 81 insertions(+), 52 deletions(-)

-- 
1.7.7.6
