From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/2][pull request] Intel Wired LAN Driver Updates 2017-03-02
Date: Thu,  2 Mar 2017 18:24:46 -0800
Message-ID: <20170303022448.79638-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43918 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751422AbdCCCZK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Mar 2017 21:25:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains fixes to ixgbe only.

Paolo fixes the driver so that you can actually update the RSS key value
via ethtool.

Alex fixes an issue on architectures that have a cache line size larger
than 64 Bytes, where the amount of headroom for the frame starts
shrinking.  To take this into account, Alex adds one small check so that
we compare the max_frame to the amount of actual data we can store, so
we will automatically enable 3K receive buffers as soon as the maximum
frame size we can handle drops below the standard Ethernet MTU.

The following are changes since commit 9f674e48c13dcbc31ac903433727837795b81efe:
  xen-netback: Use GFP_ATOMIC to allocate hash
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue 10GbE

Alexander Duyck (1):
  ixgbe: Limit use of 2K buffers on architectures with 256B or larger
    cache lines

Paolo Abeni (1):
  ixgbe: update the rss key on h/w, when ethtool ask for it

 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |  3 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  4 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 22 ++++++++++++++++++----
 3 files changed, 23 insertions(+), 6 deletions(-)

-- 
2.12.0
