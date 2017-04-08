From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/12][pull request] 40GbE Intel Wired LAN Driver Updates 2017-04-08
Date: Sat,  8 Apr 2017 02:55:41 -0700
Message-ID: <20170408095553.78307-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:26215 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751243AbdDHJz5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 8 Apr 2017 05:55:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Mitch fixes an issue where the client driver (i40iw) was attempting to
load on x710 devices (which do not support iWARP), so only register with
the client if iWARP is supported.

Jake fixes up error messages to better clarify to the user when adding a
invalid flow type.  Updates the driver to look up the MAC address from
eth_get_platform_mac_address() first before checking what the firmware
provides.  Cleans up code so we are not repeating a duplicate loop, by
checking both transmit and receive queues in a single loop.  Also cleans
up flags never used, so remove the definitions.

Alex does cleanup so that we are always updating pf->flags when a change
is made to the private flags.  Adds support for 3K buffers to the receive
path so that we can provide the additional padding needed in the event
of NET_IP_ALIGN being non-zero or a cache line being greater than 64.
Adds support for build_skb() to i40e/i40evf.

Maciej adjusts the scope of the rtnl lock held during reset because it
was stopping other PFs from running their reset procedures.

Alan reduces code complexity in i40e_detect_recover_hung_queue().

The following are changes since commit 3a9024f52c2e92a143195db43d2abbd5d0792c06:
  net: thunderx: Enable TSO and checksum offloads for ipv6
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alan Brady (1):
  i40e: Simplify i40e_detect_recover_hung_queue logic

Alexander Duyck (4):
  i40e: Swap use of pf->flags and pf->hw_disabled_flags for ATR Eviction
  i40e/i40evf: Add support for using order 1 pages with a 3K buffer
  i40e/i40evf: Add support for padding start of frames
  i40e/i40evf: Use build_skb to build frames

Alice Michael (1):
  i40e: remove I40E_FLAG_NEED_LINK_UPDATE

Jacob Keller (4):
  i40e: update error message when trying to add invalid filters
  i40e: allow look-up of MAC address from Open Firmware or IDPROM
  i40e: remove extraneous loop in i40e_vsi_wait_queues_disabled
  i40e: clean up historic deprecated flag definitions

Maciej Sosin (1):
  i40e: Decrease the scope of rtnl lock

Mitch Williams (1):
  i40e: only register client on iWarp-capable devices

 drivers/net/ethernet/intel/i40e/i40e.h          |  10 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c  |   7 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 268 +++++++++++++-----------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c     | 116 +++++++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.h     |  85 +++++++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c   |  89 ++++++--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h   |  82 +++++++-
 drivers/net/ethernet/intel/i40evf/i40evf.h      |   1 -
 drivers/net/ethernet/intel/i40evf/i40evf_main.c |  14 +-
 9 files changed, 486 insertions(+), 186 deletions(-)

-- 
2.12.2
