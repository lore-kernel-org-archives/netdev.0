From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/7][pull request] 100GbE Intel Wired LAN Driver Updates 2017-04-05
Date: Thu,  6 Apr 2017 00:54:49 -0700
Message-ID: <20170406075456.27757-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27550 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756667AbdDFHzF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 03:55:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to fm10k only.

Phil Turnbull from Oracle fixes an issue where the argument provided to
FM10K_REMOVED macro was not what was expecting.

Jake modifies the driver to replace the bitwise operators and defines with
a BITMAP and enumeration values to avoid race conditions.  Also future
proof the driver so that developers do not have to remember to re-size the
bitmaps when adding new values.  Fixed the wording of a code comment to
avoid stating that we return a value for a void function.

Ngai-Mint makes sure that when configuring the receive ring, we make sure
the receive queue is disabled.  Fixed an issue where interfaces were
resetting because the transmit mailbox FIFO was becoming full since the
host was not ready, so ensure the host is ready before queueing up
mailbox messages.

The following are changes since commit faeeb317a5615076dff1ff44b51e862e6064dbd0:
  bonding: attempt to better support longer hw addresses
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 100GbE

Jacob Keller (4):
  fm10k: use a BITMAP for flags to avoid race conditions
  fm10k: future-proof state bitmaps using DECLARE_BITMAP
  fm10k: allow service task to reschedule itself
  fm10k: update function header comment for fm10k_get_stats64

Ngai-Mint Kwan (2):
  fm10k: disable receive queue when configuring ring
  fm10k: do not enqueue mailbox when host not ready

Phil Turnbull (1):
  fm10k: correctly check if interface is removed

 drivers/net/ethernet/intel/fm10k/fm10k.h         |  68 +++++++++-----
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c |  68 +++++++++-----
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    |  16 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  | 115 +++++++++++++++++------
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     | 105 ++++++++++++---------
 5 files changed, 239 insertions(+), 133 deletions(-)

-- 
2.12.2
