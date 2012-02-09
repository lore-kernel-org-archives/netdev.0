From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net v2 0/8][pull request] Intel Wired LAN Driver Updates
Date: Thu,  9 Feb 2012 01:34:13 -0800
Message-ID: <1328780061-25000-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:23892 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754759Ab2BIJeY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Feb 2012 04:34:24 -0500
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

v2- fix the formatting in the "ixgbe: fix vf lookup" patch.

The following are changes since commit 64db880e7488a6d31363ad17c4c0590f27fd48e5:
  Merge branch 'for-davem' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless
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
