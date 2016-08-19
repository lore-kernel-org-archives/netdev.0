From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/4][pull request] 10GbE Intel Wired LAN Driver Updates 2016-08-18
Date: Thu, 18 Aug 2016 23:03:32 -0700
Message-ID: <1471586616-64728-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:23047 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754484AbcHSGDx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 Aug 2016 02:03:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and ixgbevf.

Emil cleans up confusing amongst the users by making an error message
into a debug message, since the TXDCTL.ENABLE (and comparable
VFTXDCTL.ENABLE for ixgbevf) bit is set only when the
transmit queue is actually enabled, which may not happen during the
configure phase eve if we waited for it.  Converts to using netdev_dbg()
macro instead of our home brewed macro for ixgbevf.  Converted the
service task to use atomic bitwise operations when setting and checking
reset requests to reduce the possibility of race conditions.

The following are changes since commit e951f145d1724769546efe2e04f6cb2b7037d7ea:
  Merge branch 'tipc-next'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 10GbE

Emil Tantilov (4):
  ixgbe: only check Tx queue enablement when debugging
  ixgbevf: change hw_dbg to use netdev_dbg
  ixgbevf: only check Tx queue enablement when debugging
  ixgbe: use atomic bitwise operations when handling reset requests

 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 18 ++++++++----------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      | 11 ++++-------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  3 ++-
 4 files changed, 15 insertions(+), 19 deletions(-)

-- 
2.7.4
