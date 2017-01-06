From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/10][pull request] 1GbE Intel Wired LAN Driver Updates 2017-01-06
Date: Fri,  6 Jan 2017 02:48:42 -0800
Message-ID: <20170106104852.10363-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:26908 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S938325AbdAFKtS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 05:49:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates/fixes to igb and e1000e.

Joe fixes indentation and improper line wrapping in igb.

David Singleton fixes an issue in e1000e where in systemd, where things
are done in parallel and can create a condition where e1000_shutdown is
called after e1000_close, hitting BUG_ON assert in free_msi_irqs.

Cao Jin fixes a code comment on the wakeup status register.  Also fixes
a possible NULL pointer dereference by using igb_adapter->io_addr
instead of e1000_hw->hw_addr in igb_configure_tx_ring().

Chris Arges works around a firmware issue, which can cause probe of i210
NIC to fail, so zero the page select register during igb_get_phy_id() to
workaround the issue.  Aaron Sierra adds also a check for this issue
during the initialization of PHY parameters to ensure that this same
issue happens after probe.

Todd fixes a possible race condition in close/suspend by extending
the rtnl_lock() to protect the call to netif_device_detach() and
igb_clear_interrupt_scheme().  Also adds i211 to a known i210/i211
workaround.

Hannu Lounento fixes inverted logic on a debug statement.

The following are changes since commit c1878f7a89efbbe1ac0082d09b2928782a6ceba1:
  tools: psock_tpacket: block Rx until socket filter has been added and socket has been bound to loopback.
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 1GbE

Aaron Sierra (1):
  igb: reset the PHY before reading the PHY ID

Cao jin (2):
  igb: correct register comments
  igb: use igb_adapter->io_addr instead of e1000_hw->hw_addr

Chris J Arges (1):
  igb: Workaround for igb i210 firmware issue

Guilherme G Piccoli (1):
  igb: re-assign hw address pointer on reset after PCI error

Hannu Lounento (1):
  igb: Fix hw_dbg logging in igb_update_flash_i210

Joe Perches (1):
  igb: Realign bad indentation

Todd Fujinaka (2):
  igb: close/suspend race in netif_device_detach
  igb: add i211 to i210 PHY workaround

khalidm (1):
  e1000e: driver trying to free already-free irq

 drivers/net/ethernet/intel/e1000e/netdev.c   |  2 +-
 drivers/net/ethernet/intel/igb/e1000_82575.c | 11 ++++++++++
 drivers/net/ethernet/intel/igb/e1000_i210.c  |  4 ++--
 drivers/net/ethernet/intel/igb/e1000_mac.c   | 15 ++++++--------
 drivers/net/ethernet/intel/igb/e1000_phy.c   |  4 ++++
 drivers/net/ethernet/intel/igb/e1000_regs.h  |  2 +-
 drivers/net/ethernet/intel/igb/igb_main.c    | 30 ++++++++++++++++++----------
 7 files changed, 44 insertions(+), 24 deletions(-)

-- 
2.9.3
