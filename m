From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/5][pull request] Intel Wired LAN Driver Updates
Date: Tue, 17 Dec 2013 23:19:41 -0800
Message-ID: <1387351186-23389-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:58137 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750956Ab3LRHTs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 02:19:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to net, ixgbe and e1000e.

David provides compiler fixes for e1000e.

Don provides a fix for ixgbe to resolve a compile warning.

John provides a fix to net where it is useful to be able to walk all
upper devices when bringing a device online where the RTNL lock is held.
In this case, it is safe to walk the all_adj_list because the RTNL lock is
used to protect the write side as well.  This patch adds a check to see
if the RTNL lock is held before throwing a warning in
netdev_all_upper_get_next_dev_rcu().

The following are changes since commit 781069279f049508274db63bfb352e8583e5c977:
  Merge branch 'fixes-for-3.13' of git://gitorious.org/linux-can/linux-can
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

David Ertman (3):
  e1000e: fix compiler warnings
  e1000e: fix compiler warning (maybe-unitialized variable)
  e1000e: Fix a compile flag mis-match for suspend/resume

Don Skidmore (1):
  ixgbe: fix for unused variable warning with certain config

John Fastabend (1):
  net: allow netdev_all_upper_get_next_dev_rcu with rtnl lock held

 drivers/net/ethernet/intel/e1000e/80003es2lan.c |  7 +++++--
 drivers/net/ethernet/intel/e1000e/netdev.c      |  4 ++--
 drivers/net/ethernet/intel/e1000e/phy.c         | 10 +++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c  |  2 ++
 include/linux/rtnetlink.h                       |  5 +++++
 net/core/dev.c                                  |  2 +-
 6 files changed, 22 insertions(+), 8 deletions(-)

-- 
1.8.3.1
