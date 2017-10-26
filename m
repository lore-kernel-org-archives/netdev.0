From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/6][pull request] Intel Wired LAN Driver Updates 2017-10-26
Date: Thu, 26 Oct 2017 09:19:49 -0700
Message-ID: <20171026161955.4407-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:17177 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932348AbdJZQUR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 12:20:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains fixes to e1000, igb, ixgbe and i40e.

Vincenzo Maffione fixes a potential race condition which would result in
the interface being up but transmits are disabled in the hardware.

Colin Ian King fixes a possible NULL pointer dereference in e1000, which
was found by Coverity.

Jean-Philippe Brucker fixes a possible kernel panic when a driver cannot
map a transmit buffer, which is caused by an erroneous test.

Alex provides a fix for ixgbe, which is a partial revert of the commit
ffed21bcee7a ("ixgbe: Don't bother clearing buffer memory for descriptor rings")
because the previous commit messed up the exception handling path by
adding the count back in when we did not need to.  Also fixed a typo,
where the transmit ITR setting was being used to determine if we were
using adaptive receive interrupt moderation or not.  Lastly, fixed a
memory leak by including programming descriptors in the cleaned count.

The following are changes since commit 78e0ea6791d7baafb8a0ca82b1bd0c7b3453c919:
  tap: double-free in error path in tap_open()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue 40GbE

Alexander Duyck (3):
  ixgbe: Fix Tx map failure path
  i40e: Fix incorrect use of tx_itr_setting when checking for Rx ITR
    setup
  i40e: Add programming descriptors to cleaned_count

Colin Ian King (1):
  e1000: avoid null pointer dereference on invalid stat type

Jean-Philippe Brucker (1):
  igb: Fix TX map failure path

Vincenzo Maffione (1):
  e1000: fix race condition between e1000_down() and e1000_watchdog

 drivers/net/ethernet/intel/e1000/e1000_ethtool.c |  9 ++++-----
 drivers/net/ethernet/intel/e1000/e1000_main.c    | 11 +++++++++--
 drivers/net/ethernet/intel/i40e/i40e_txrx.c      |  3 ++-
 drivers/net/ethernet/intel/igb/igb_main.c        |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 18 ++++++------------
 5 files changed, 22 insertions(+), 21 deletions(-)

-- 
2.14.2
