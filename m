From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Tue, 29 Dec 2009 20:29:10 -0800 (PST)
Message-ID: <20091229.202910.226758352.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751670AbZL3E3K@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


A lot of little things, but as usual it's predominantly driver stuff.

1) dev->dev_addr was changed from an array to a pointer, however
   a few drivers still accidently referenced it as an array.

   Fix from Daniel Drake.

2) Several wireless fixes via John Linville.

3) via-rhine tries to sleep in atomic context, fix by moving reset
   task into a work queue.  Fix from Jarek Poplawski.

4) SFC driver fixes from Steve Hodgson, Ben Hutchings, and co.

5) IGB bug fixes from Alexander Duyck.

6) Make IGBVF error message more informative, from Mitch Williams

7) be2net driver bug fixes from Sarveshwar Bandi.

8) pktgen handles ->ndo_start_xmit return values wrongly, breaking
   usage with VLANs.  Fix from John Fastabend.

9) BNX2X fix for chip reset handling from Michael Chan.

10) Fix 2.6.32 regression in transparent proxy, from Jamal Hadi Salim.

11) ucc_geth fixes from Anton Vorontsov.

12) gianfar erroneously overrides ->select_queue(), fix from Sandeep
    Gopalpet

13) Fix possible NULL deref in bond_3ad.c, from Dan Carpenter.

Please pull, thanks a lot!

The following changes since commit 6b7b284958d47b77d06745b36bc7f36dab769d9b:
  Linus Torvalds (1):
        Linux 2.6.33-rc2

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexander Duyck (4):
      igb: do not force pcs link when in KX mode
      igb: do not force retry count to 1 on 82580 phy
      igb: correctly offset 82575 flow control watermarks by 16 bytes
      igb: check both function bits in status register in wol exception

Andrey Borzenkov (1):
      orinoco: fix GFP_KERNEL in orinoco_set_key with interrupts disabled

Anton Vorontsov (3):
      ucc_geth: Fix empty TX queue processing
      ucc_geth: Fix netdev watchdog triggering on link changes
      ucc_geth: Don't needlessly change MAC settings in adjust_link()

Ben Hutchings (3):
      sfc: Include XGXS in XMAC link status check except in XGMII loopback
      sfc: QT2025C: Add error message for suspected bad SFP+ cables
      sfc: Disable TX descriptor prefetch watchdog

Benjamin Herrenschmidt (1):
      ps3_gelic_wireless: Fix build failure due to missing WEXT_PRIV

Benoit Papillault (1):
      ath9k: Last fix for TX software padding.

Bob Copeland (1):
      ath5k: fix SWI calibration interrupt storm

Dan Carpenter (2):
      bond_3ad.c avoid possible null deref
      wl1271_cmd.c: cleanup char => u8

Daniel Drake (1):
      Fix MAC address access in 3c507, ibmlana, pcnet32 and libertas

Daniel Mack (1):
      Libertas: fix buffer overflow in lbs_get_essid()

David S. Miller (2):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

Denis Kirjanov (1):
      vxge: use DMA_BIT_MASK instead of plain values.

Don Skidmore (1):
      ixgbe: fix Need to call pci_save_state after pci_restore_state

Felix Fietkau (2):
      mac80211: fix ibss join with fixed-bssid
      ath9k: fix missed error codes in the tx status check

Gertjan van Wingerde (5):
      rt2x00: Fix rt2800usb detection in rt2800lib.
      mac80211: Add define for TX headroom reserved by mac80211 itself.
      rt2x00: Disable powersaving for rt61pci and rt2800pci.
      rt2x00: Fix calculation of rt2800 iveiv entry offset.
      rt2x00: Add USB ID for Linksys WUSB 600N rev 2.

Jamal Hadi Salim (1):
      net: restore ip source validation

Jarek Poplawski (1):
      net/via-rhine: Fix scheduling while atomic bugs

Johannes Berg (7):
      iwlwifi: fix EEPROM/OTP reading endian annotations and a bug
      iwlwifi: fix more eeprom endian bugs
      mac80211: fix peer HT capabilities
      mac80211: fix WMM AP settings application
      wireless: remove remaining qual code
      cfg80211: fix race between deauth and assoc response
      cfg80211: fix error path in cfg80211_wext_siwscan

John Fastabend (1):
      pktgen: ndo_start_xmit can return NET_XMIT_xxx values

John W. Linville (1):
      Revert "b43: Enforce DMA descriptor memory constraints"

Julia Lawall (1):
      drivers/net/wireless: Correct code taking the size of a pointer

Luis R. Rodriguez (4):
      ath9k: wake hardware for interface IBSS/AP/Mesh removal
      ath9k: wake hardware during AMPDU TX actions
      mac80211: fix race with suspend and dynamic_ps_disable_work
      mac80211: fix propagation of failed hardware reconfigurations

Matthew Slattery (3):
      sfc: QT2025C: Work around PHY bug
      sfc: QT2025C: Switch into self-configure mode when not in loopback
      sfc: QT2025C: Work around PHY firmware initialisation bug

Michael Chan (1):
      bnx2x: Initialize cnic status block during chip reset

Neil Turton (1):
      sfc: Fix DMA mapping cleanup in case of an error in TSO

Ralf Baechle (1):
      NET: XFRM: Fix spelling of neighbour.

Reinette Chatre (4):
      iwlwifi: power up all devices for EEPROM read
      iwl3945: disable power save
      iwlwifi: initialize spinlock before use
      iwlwifi: fix 40MHz operation setting on cards that do not allow it

Roel Kluin (2):
      iwmc3200wifi: Fix test of unsigned in iwm_ntf_stop_resume_tx()
      wl1251: timeout one too soon in wl1251_boot_run_firmware()

Samuel Ortiz (1):
      libertas: Remove carrier signaling from the scan code

Sandeep Gopalpet (1):
      gianfar: Fix gianfar select_queue bogosity

Sarveshwar Bandi (3):
      be2net: Bug fix to avoid soft lockup in loopback test.
      be2net: Bug fix to config NIC appropriately before loopback test
      be2net: Bug fix to return correct values in ethtool get_settings.

Steve Hodgson (1):
      sfc: Move PHY software state initialisation from init() into probe()

Sujith (4):
      ath9k: Fix bug in assigning sequence number
      ath9k: Fix TX queue draining
      ath9k: Stop ANI when doing a reset
      ath9k: fix suspend by waking device prior to stop

Tobias Klauser (2):
      ath9k: Storage class should be before const qualifier
      iwlwifi: Storage class should be before const qualifier

Vitaliy Gusev (1):
      tun: use tun_sk instead container_of

Wey-Yi Guy (1):
      iwlwifi: fix syslog message for event log dump size

Williams, Mitch A (1):
      igbvf: Make igbvf error message more informative

Zhu Yi (3):
      iwlwifi: allocated rx page accounting cleanup
      iwl3945: fix panic in iwl3945 driver
      iwmc3200wifi: fix array out-of-boundary access

akpm@linux-foundation.org (1):
      drivers/net/wireless/iwlwifi/iwl-tx.c: fix gcc-3.4.5 warning

 drivers/net/3c507.c                         |    4 +-
 drivers/net/Kconfig                         |    2 +
 drivers/net/benet/be.h                      |    1 +
 drivers/net/benet/be_cmds.c                 |   36 ++++
 drivers/net/benet/be_cmds.h                 |   16 ++
 drivers/net/benet/be_ethtool.c              |   77 ++++++---
 drivers/net/bnx2x_main.c                    |    2 +
 drivers/net/bonding/bond_3ad.c              |    2 +-
 drivers/net/gianfar.c                       |   13 +-
 drivers/net/ibmlana.c                       |    3 +-
 drivers/net/igb/e1000_82575.c               |    4 +-
 drivers/net/igb/e1000_phy.c                 |    9 -
 drivers/net/igb/igb_ethtool.c               |    2 +-
 drivers/net/igb/igb_main.c                  |    9 +-
 drivers/net/igbvf/netdev.c                  |    3 +-
 drivers/net/ixgbe/ixgbe_main.c              |    5 +
 drivers/net/pcnet32.c                       |    3 +-
 drivers/net/sfc/efx.c                       |    6 +-
 drivers/net/sfc/falcon.c                    |    1 +
 drivers/net/sfc/falcon_xmac.c               |   38 +++--
 drivers/net/sfc/mcdi_phy.c                  |   93 ++++-------
 drivers/net/sfc/net_driver.h                |    1 +
 drivers/net/sfc/nic.c                       |    2 +
 drivers/net/sfc/qt202x_phy.c                |  238 +++++++++++++++++++++++++--
 drivers/net/sfc/siena.c                     |    1 +
 drivers/net/sfc/tenxpress.c                 |  138 +++++++++-------
 drivers/net/sfc/tx.c                        |    4 +-
 drivers/net/tun.c                           |    6 +-
 drivers/net/ucc_geth.c                      |   42 +++--
 drivers/net/via-rhine.c                     |   41 +++--
 drivers/net/vxge/vxge-main.c                |    6 +-
 drivers/net/wireless/ath/ath5k/base.c       |   18 +--
 drivers/net/wireless/ath/ath9k/mac.c        |    2 +-
 drivers/net/wireless/ath/ath9k/mac.h        |    3 +
 drivers/net/wireless/ath/ath9k/main.c       |   20 +++
 drivers/net/wireless/ath/ath9k/pci.c        |    2 +-
 drivers/net/wireless/ath/ath9k/xmit.c       |   42 ++---
 drivers/net/wireless/b43/dma.c              |  197 +++++-----------------
 drivers/net/wireless/b43/dma.h              |    7 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c     |   15 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h     |    1 -
 drivers/net/wireless/iwlwifi/iwl-4965.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-5000-hw.h  |   14 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c     |    7 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c      |    6 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h      |    8 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h      |   13 ++-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c   |   37 ++---
 drivers/net/wireless/iwlwifi/iwl-eeprom.h   |    4 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c       |   56 +------
 drivers/net/wireless/iwlwifi/iwl-scan.c     |    3 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c      |    8 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c       |    3 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   68 ++------
 drivers/net/wireless/iwmc3200wifi/iwm.h     |    4 +-
 drivers/net/wireless/iwmc3200wifi/netdev.c  |    2 +-
 drivers/net/wireless/iwmc3200wifi/rx.c      |    2 +-
 drivers/net/wireless/libertas/mesh.c        |    4 +-
 drivers/net/wireless/libertas/scan.c        |   22 +--
 drivers/net/wireless/libertas/wext.c        |    2 -
 drivers/net/wireless/libertas_tf/main.c     |    1 -
 drivers/net/wireless/orinoco/wext.c         |    6 +-
 drivers/net/wireless/rt2x00/rt2800.h        |    2 +-
 drivers/net/wireless/rt2x00/rt2800lib.c     |   17 ++-
 drivers/net/wireless/rt2x00/rt2800usb.c     |    1 +
 drivers/net/wireless/rt2x00/rt61pci.c       |    5 +
 drivers/net/wireless/rtl818x/rtl8180_dev.c  |    1 -
 drivers/net/wireless/wl12xx/wl1251_boot.c   |    2 +-
 drivers/net/wireless/wl12xx/wl1271_cmd.c    |    4 +-
 drivers/net/wireless/zd1211rw/zd_chip.c     |  140 ----------------
 drivers/net/wireless/zd1211rw/zd_chip.h     |    3 -
 drivers/net/wireless/zd1211rw/zd_mac.c      |    3 -
 include/linux/ieee80211.h                   |    2 +-
 include/linux/inetdevice.h                  |    1 +
 include/linux/sysctl.h                      |    1 +
 include/net/mac80211.h                      |    8 +-
 net/core/pktgen.c                           |    9 +-
 net/ipv4/devinet.c                          |    1 +
 net/ipv4/fib_frontend.c                     |    2 +
 net/mac80211/ht.c                           |   25 +++-
 net/mac80211/ibss.c                         |    4 +
 net/mac80211/main.c                         |    2 +
 net/mac80211/mlme.c                         |    8 +
 net/mac80211/tx.c                           |    4 +
 net/mac80211/util.c                         |   12 ++
 net/wireless/mlme.c                         |   13 ++-
 net/wireless/scan.c                         |   13 +-
 net/xfrm/xfrm_policy.c                      |    2 +-
 90 files changed, 863 insertions(+), 813 deletions(-)
