From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 07 Nov 2011 13:45:53 -0500 (EST)
Message-ID: <20111107.134553.430562180571864277.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) The IXGBE build fix wrt. CONFIG_PCI_IOV from Gregory Rose.

2) Fixes for module unload races and statistic problems in forcedeth from
   david decotigny, Mike Ditto, and Mandeep Baines.

3) Kill stray BKL references from wanrouter code, from Richard Weinberger.

4) usbnet oopses due to unguarded skb_tx_timestamp() check, fix from
   Konstantin Khlebnikov.

5) tg3 driver bug fixes from Matt Carlson.

6) Fix bogus compare of u8 with -1 in bonding, from Dan Carpenter.

7) Netlink message validation fix from Johannes Berg.

8) Fix sky2 driver regression on Yukon Optima chips, from Stephen Hemminger.

Please pull, thanks a lot!

The following changes since commit 83dbb15e9cd78a3619e3db36777e2f81d09b2914:

  Merge branch 'drm-fixes' of git://people.freedesktop.org/~airlied/linux (2011-11-07 10:01:56 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

Andres Salomon (1):
      libertas: ensure we clean up a scan request properly

Christian Lamparter (1):
      carl9170: fix AMPDU TX_CTL_REQ_TX_STATUS handling

Dan Carpenter (1):
      bonding: comparing a u8 with -1 is always false

David Herrmann (4):
      Bluetooth: ath3k: Use GFP_KERNEL instead of GFP_ATOMIC
      Bluetooth: bcm203x: Fix race condition on disconnect
      Bluetooth: bcm203x: Use GFP_KERNEL in workqueue
      Bluetooth: bfusb: Fix error path on firmware load

David S. Miller (1):
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wireless

Eliad Peller (2):
      mac80211: fix remain_off_channel regression
      mac80211: config hw when going back on-channel

Emmanuel Grumbach (1):
      iwlagn: fix the race in the unmapping of the HCMD

Jeff Kirsher (2):
      i825xx:xscale:8390:freescale: Fix Kconfig dependancies
      etherh: Add MAINTAINERS entry for etherh

Johan Hedberg (1):
      Bluetooth: Set HCI_MGMT flag only in read_controller_info

Johannes Berg (4):
      mac80211: disable powersave for broken APs
      mac80211: warn only once about not finding a rate
      netlink: validate NLA_MSECS length
      netlink: clarify attribute length check documentation

John W. Linville (2):
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Jouni Malinen (1):
      mac80211: Fix TDLS support validation in add_station handler

Konstantin Khlebnikov (1):
      usbnet: fix oops in usbnet_start_xmit

Larry Finger (1):
      b43: Remove unneeded message

Mandeep Baines (1):
      forcedeth: Improve stats counters

Matt Carlson (8):
      tg3: Fix APE mutex init and use
      tg3: Fix 4k tx bd segmentation code
      tg3: Fix 4k skb error recovery path
      tg3: Fix irq alloc error cleanup path
      tg3: Obtain PCI function number from device
      tg3: Schedule at most one tg3_reset_task run
      tg3: Eliminate timer race with reset_task
      tg3: Update version to 3.121

Mike Ditto (1):
      forcedeth: Acknowledge only interrupts that are being processed

Or Gerlitz (1):
      MAINTAINERS/rds: update maintainer

Rajkumar Manoharan (5):
      ath9k_hw: Fix regression of register offset for AR9003 chips
      ath9k_hw: Fix radio retention for AR9462
      ath9k_hw: Fix regression of register offset of AR9330/AR9340
      ath9k_hw: Update AR9485 initvals to fix system hang issue
      ath9k_hw: Fix noise floor calibration timeout on fast channel change

Richard Weinberger (1):
      wanrouter: Remove kernel_lock annotations

Rose, Gregory V (1):
      ixgbe: Fix compile for kernel without CONFIG_PCI_IOV defined

Szymon Janc (2):
      Bluetooth: rfcomm: Fix sleep in invalid context in rfcomm_security_cfm
      Bluetooth: Increase HCI reset timeout in hci_dev_do_close

Wey-Yi Guy (2):
      iwlwifi: allow pci_enable_msi fail
      iwlwifi: don't perform "echo test" when cmd queue stuck

david decotigny (3):
      forcedeth: fix race when unloading module
      forcedeth: remove unneeded stats updates
      forcedeth: fix a few sparse warnings (variable shadowing)

stephen hemminger (2):
      macvlan: receive multicast with local address
      sky2: fix regression on Yukon Optima

 MAINTAINERS                                      |    3 +-
 drivers/bluetooth/ath3k.c                        |    4 +-
 drivers/bluetooth/bcm203x.c                      |   12 ++-
 drivers/bluetooth/bfusb.c                        |   13 +-
 drivers/net/bonding/bond_main.c                  |    4 +-
 drivers/net/bonding/bond_procfs.c                |    4 +-
 drivers/net/ethernet/broadcom/tg3.c              |  195 ++++++++++++----------
 drivers/net/ethernet/broadcom/tg3.h              |   21 ++-
 drivers/net/ethernet/freescale/Kconfig           |    3 +-
 drivers/net/ethernet/intel/Kconfig               |    6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c   |    2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h   |    4 +-
 drivers/net/ethernet/marvell/sky2.c              |   11 --
 drivers/net/ethernet/natsemi/Kconfig             |    5 +-
 drivers/net/ethernet/nvidia/forcedeth.c          |   88 ++++-------
 drivers/net/macvlan.c                            |    7 +
 drivers/net/usb/usbnet.c                         |    3 +-
 drivers/net/wireless/ath/ath9k/ar9002_calib.c    |    4 -
 drivers/net/wireless/ath/ath9k/ar9003_calib.c    |   11 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h      |   34 ++--
 drivers/net/wireless/ath/ath9k/ar9485_initvals.h |   10 +-
 drivers/net/wireless/ath/ath9k/hw.c              |    3 +
 drivers/net/wireless/ath/carl9170/tx.c           |   11 +-
 drivers/net/wireless/b43/xmit.c                  |    1 -
 drivers/net/wireless/iwlwifi/iwl-core.c          |   10 -
 drivers/net/wireless/iwlwifi/iwl-pci.c           |    8 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c    |   12 +-
 drivers/net/wireless/libertas/cfg.c              |   25 ++-
 drivers/net/wireless/libertas/cfg.h              |    1 +
 drivers/net/wireless/libertas/main.c             |    6 +-
 include/linux/ethtool.h                          |    2 +
 include/net/bluetooth/rfcomm.h                   |    1 +
 include/net/mac80211.h                           |    3 +-
 include/net/netlink.h                            |   11 +-
 lib/nlattr.c                                     |    1 +
 net/bluetooth/hci_core.c                         |    2 +-
 net/bluetooth/mgmt.c                             |    2 -
 net/bluetooth/rfcomm/core.c                      |    9 +-
 net/mac80211/cfg.c                               |   12 +-
 net/mac80211/ieee80211_i.h                       |    1 +
 net/mac80211/mlme.c                              |   18 ++-
 net/mac80211/work.c                              |    7 +-
 net/wanrouter/wanproc.c                          |    2 -
 43 files changed, 325 insertions(+), 267 deletions(-)
