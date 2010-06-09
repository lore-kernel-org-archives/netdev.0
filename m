From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2010-06-09
Date: Wed, 9 Jun 2010 17:12:51 -0400
Message-ID: <20100609211251.GC2452@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50997 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755318Ab0FIVPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 17:15:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is the usual, frightening, monstrous post-window pull request...
Along with the usual batch of driver updates, there are also some DMA
state API conversions from FUJITA Tomonori, some cleanups from Julia
Lawall and Joe Perches, some SSB changes from Larry Finger and Rafa=C5=82
Mi=C5=82ecki, and a number of mac80211 changes from Johannes Berg.  All=
 of it
has had at least one cycle through linux-next and most of it has been
there for several days.  This also includes the same wireless-2.6 pull =
I
sent you previously so as to resolve some merge conflicts.

Please let me know if there are problems!

John

---

The following changes since commit bb69ae049fcc986fcd742eb90ca0d44a7a49=
c9f1:
  Eric Dumazet (1):
        anycast: Some RCU conversions

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git master

Abhijeet Kolekar (1):
      iwl3945: fix internal scan

Amitkumar Karwar (1):
      libertas: Added callback functions to support SDIO suspend/resume=
=2E

Bob Copeland (1):
      ath5k: retain promiscuous setting

Bruno Randolf (15):
      ath5k: initialize calibration timers
      ath5k: move noise floor calibration into tasklet
      ath5k: Stop queues only for NF calibration
      ath5k: run NF calibration only every 60 seconds
      ath5k: remove ATH_TRACE macro
      ath5k: clarify logic when to enable spur mitigation filter
      ath5k: use ath5k_softc as driver data
      ath5k: add sysfs files for ANI parameters
      ath5k: always calculate ANI listen time
      ath5k: print error message if ANI levels are out of range
      ath5k: fix NULL pointer in antenna configuration
      ath5k: update AR5K_PHY_RESTART_DIV_GC values to match masks
      ath5k: new function for setting the antenna switch table
      ath5k: no need to save/restore the default antenna
      ath5k: add debugfs file for queue debugging

Dan Carpenter (3):
      ath9k/debug: improve the snprintf() handling
      ath9k/debug: fixup the return codes
      ath9k: cleanup: remove unneeded null check

Daniel Halperin (2):
      iwlwifi: parse block ack responses correctly
      iwlwifi: fix wrapping when handling aggregated batches

Emmanuel Grumbach (1):
      iwlwifi: move sysfs_create_group to post request firmware

=46UJITA Tomonori (7):
      mwl8k: use the dma state API instead of the pci equivalents
      iwlwifi: use the DMA state API instead of the pci equivalents
      ssb: add dma_dev to ssb_device structure
      b43legacy: replace the ssb_dma API with the generic DMA API
      b43: replace the ssb_dma API with the generic DMA API
      b44: replace the ssb_dma API with the generic DMA API
      ssb: remove the ssb DMA API

=46elix Fietkau (6):
      mac80211: add the minstrel_ht rate control algorithm
      ath9k_hw: add multicast key search support
      ath9k_common: use allocated key cache entries for multi BSS crypt=
o support
      ath9k: use the key handling code from ath9k_common instead of dup=
licating it
      ath9k: fix queue stop/start based on the number of pending frames
      mac80211: reduce debugfs code size

Gertjan van Wingerde (14):
      rt2x00: Move rt2x00debug_dump_frame declaration to rt2x00.h.
      rt2x00: Push beacon TX descriptor writing to drivers.
      rt2x00: Reverse calling order of bus write_tx_desc and driver wri=
te_tx_desc.
      rt2x00: Properly reserve room for descriptors in skbs.
      rt2x00: Fix rt2800usb TX descriptor writing.
      rt2x00: Clean up USB vendor request buffer functions.
      rt2x00: Centralize rt2800 beacon writing.
      rt2x00: Remove RT2870 chipset identification.
      rt2x00: Move all register definitions for rt2800 to rt2800.h.
      rt2x00: Introduce separate interface type for PCI-express.
      rt2x00: Simplify check for external LNA in rt2800_init_rfcsr.
      rt2x00: Move PCI/USB specific register initializations to rt2800{=
pci,usb}.
      rt2x00: Sync rt2800 MCU boot signal with Ralink driver.
      rt2x00: Fix HT40 operation in rt2800.

Grazvydas Ignotas (2):
      wl1251: fix a memory leak in probe
      wl1251: fix ELP_CTRL register reads

Helmut Schaa (5):
      cfg80211: don't refuse HT20 channels on devices that don't suppor=
t HT40
      rt2x00: rt2800: disable TX STBC for 1 stream devices
      rt2x00: Update TX_SW_CFG initvals for 305x SoC
      rt2x00: fix use of mcs rates
      rt2x00: Remove suspicious register write

Holger Schurig (1):
      mac80211: fix function pointer check

Ivo van Doorn (1):
      rt2x00: Use IEEE80211_TX_CTL_STBC flag

Jason Dravet (1):
      p54usb: Add device ID for Dell WLA3310 USB

Joe Perches (1):
      drivers/net/wireless/ipw2x00/ipw2100.c: Remove unnecessary kmallo=
c casts

Johannes Berg (33):
      iwlwifi: introduce iwl_sta_id_or_broadcast
      iwlwifi: don't crash on firmware file missing info
      iwl3945: remove sequence number assignment
      iwlwifi: move iwl_free_tfds_in_queue to iwlagn
      iwlwifi: improve station debugfs
      iwlwifi: remove IWL_MULTICAST_ID
      iwlagn: use firmware event/error log information
      iwlwifi: split debug and debugfs options
      iwlwifi: use proper short slot/preamble settings
      cfg80211: make action channel type optional
      mac80211: remove bogus mod_timer() call
      mac80211: remove tx status ampdu_ack_map
      mac80211: clean up ieee80211_stop_tx_ba_session
      mac80211: move WEP weak IV check
      mac80211: remove useless work starting
      mac80211: drop control frames after processing
      mac80211: move plink state
      mac80211: simplify key locking
      mac80211: process station blockack action frames from work
      iwlwifi: remove useless node_addr assignments
      iwlwifi: remove unused wlap_bssid_addr assignment
      iwlwifi: remove mac_addr assignment
      iwlwifi: set MAC address in RXON from interface
      iwlwifi: use virtual interface address for scan
      iwlwifi: remove debug frame dumping
      iwlwifi: remove priv->mac_addr
      iwl3945: fix bugs in txq freeing
      iwlagn: fix bug in txq freeing
      iwlwifi: kzalloc txb array
      iwlwifi: reduce memory allocation
      iwlwifi: generic scan TX antenna forcing
      iwlwifi: queue user-initiated scan when doing internal scan
      wireless: fix kernel-doc

John W. Linville (8):
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlw=
ifi/iwlwifi-2.6
      ath9k_htc: fix build error when ATH9K_HTC_DEBUGFS not enabled
      Revert "iwlwifi: move _agn statistics related structure"
      mac80211: make ARP filtering depend on CONFIG_INET
      Revert "wireless: hostap, fix oops due to early probing interrupt=
"
      iwlwifi: fix-up botched revert
      mac80211: fix lock leak w/ ARP filtering and w/o CONFIG_INET
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6

Julia Lawall (11):
      drivers/net/wireless/orinoco: Use kzalloc
      drivers/net/wireless/libertas: Use kmemdup
      drivers/net/wireless/wl12xx: Use kmemdup
      drivers/net/wireless/libertas_tf: Use kmemdup
      drivers/net/wireless/iwmc3200wifi: Use kmemdup
      drivers/net/wireless/ath/ath9k: Use kmemdup
      drivers/net/wireless/b43: Use kmemdup
      drivers/net/wireless/ipw2x00: Use kmemdup
      drivers/net/wireless/p54: Use kmemdup
      drivers/net/wireless/orinoco: Use kmemdup
      drivers/net/wireless/prism54: Use memdup_user

Jussi Kivilinna (1):
      rndis_wlan: increase assocbuf size and validate association info =
offsets from driver

Juuso Oikarinen (9):
      wl1271: Update handling of the NVS file / INI parameters
      wl1271: Add support for NVS files with 5GHz band parameters
      wl1271: Prevent dropping of TX frames in joins
      wl1271: Idle handling into own function
      wl1271: Flush TX buffers to air before going to idle
      wl1271: Use proper rates for PSM entry/exit null-funcs for 5GHz
      wl1271: Fix scan parameter handling for 5GHz
      mac80211: Add support for hardware ARP query filtering
      mac80211: Add netif state checking to ieee80211_ifa_changed

Larry Finger (1):
      ssb: Handle alternate SSPROM location

Luciano Coelho (1):
      wl1271: the core wl1271 module shouldn't depend on SPI_MASTER

Luis R. Rodriguez (5):
      ath9k_hw: add support for the AR9003 2.2
      ath9k_hw: rename the ar9003_initvals.h to ar9003_2p0_initvals.h
      ath9k_hw: add support for the AR9003 baseband watchdog
      ath9k: enable the baseband watchdog events for AR9003
      ath9k_hw: Enable TX IQ calibration on AR9003

Luke-Jr (1):
      p54spi: replace internal "cx3110x" name with "p54spi"

Ming Lei (2):
      ath9k: fix dma direction for map/unmap in ath_rx_tasklet
      ath9k: fix dma sync in rx path

Ohad Ben-Cohen (1):
      wl1271: remove sdio ARM dependency

Prarit Bhargava (1):
      ath: Fix uninitialized variable warnings

Rafa=C5=82 Mi=C5=82ecki (2):
      ssb: update PMU init to match specs
      ssb: fast powerup delay calculation for PMU capable devices

Reinette Chatre (2):
      iwlwifi: fix and add missing sta_lock usage
      iwl3945: enable stuck queue detection on 3945

Sascha Silbe (1):
      libertas: Fix ethtool reporting no WOL options supported if WOL i=
s not already active

Shanyu Zhao (3):
      iwlwifi: enable remaining 6000 Gen2 devices
      iwlwifi: add new PCI IDs for 6000g2 devices
      iwlwifi: do not clear data after chain noise calib

Sujith (34):
      ath9k_htc: Add queue statistics to xmit debugfs file
      ath9k_htc: Initialize beacon/CAB queues
      ath9k_htc: Remove HW queue translation
      ath9k_htc: Increase credit size
      ath9k_htc: Initvals update for AR9271
      ath9k_htc: Cleanup rate initialization
      ath9k_htc: Update HT configuration properly
      ath9k_htc: Enable SGI in HT20 for AR9271
      ath9k_htc: Enable RX STBC for AR9271
      ath9k: Move ath9k specific RX code to driver
      ath9k: Move driver specific structures
      ath9k_hw: Cleanup eeprom_9287.c
      ath9k_hw: Optimize ath9k_hw_ar9287_set_board_values
      ath9k_hw: Cleanup TX power calculation for AR9287
      ath9k_hw: Update the PCI WAR register
      ath9k_hw: Fix async fifo for AR9287
      ath9k_htc: Revamp CONF_IDLE handling
      ath9k_htc: Add PS wrappers
      ath9k_htc: Fix bug in handling CONF_IDLE
      ath9k_htc: Remove useless cancel_work_sync
      ath9k_htc: Fix locking for ps_idle
      ath9k_htc: Handle monitor interface removal
      ath9k_htc: Handle host RX disable
      ath9k_htc: Fix fair beacon distribution
      ath9k_htc: Use proper station add/remove callbacks
      mac80211: Remove deprecated sta_notify commands
      ath9k: Determine Firmware on probe
      ath9k_hw: Configure byte swap for non AR9271 chips
      ath9k_htc: Add support for AR7010
      ath9k_common: Move count_streams to common module
      ath9k_htc: Setup HT capabilites for 2-stream devices
      ath9k_htc: Configure dual stream rates
      ath9k_htc: Setup 5GHz channels
      ath9k_htc: Configure credit size for AR7010

Tobias Doerffel (1):
      ath5k: depend on CONFIG_PM_SLEEP for suspend/resume functions

Tobias Klauser (1):
      drivers/net/wireless: Storage class should be before const qualif=
ier

Vasanthakumar Thiagarajan (8):
      ath9k: Enable Short GI in 20 Mhz for ar9287 and later chips
      ath9k: Make sure null func frame is acked before going into PS fo=
r ar9003
      ath9k: Fix power save with auto sleeping
      ath9k_hw: Enable auto sleep for ar9003
      ath9k: Clean up few function parameters in recv.c
      ath9k: Fix bug in accessing skb->data of rx frame for edma
      ath9k: Fix bug in validating received data length for edma
      ath9k: Fix bug in rate table

Walter Goldens (1):
      wireless: fix several minor description typos

Wey-Yi Guy (13):
      iwlwifi: move _agn statistics related structure
      iwlwifi: separate statistics flag function for agn & 3945
      iwlwifi: code cleanup for _agn devices
      iwlwifi: modify out-dated comments
      iwlwifi: move ucode related function to iwl-agn-ucode.c
      iwlwifi: add name to Maintainers list
      iwlwifi: remove unused parameter in iwl_priv
      iwlwifi: beacon format related helper function
      iwlwifi: support channel switch offload in driver
      iwlwifi: beacon internal time unit
      iwlwifi: remove inaccurate comment
      iwlwifi: do not use huge command buffer for channel switch
      iwlwifi: remove unused parameter

Zhu Yi (1):
      wireless: remove my name from the maintainer list

 MAINTAINERS                                        |    5 +-
 drivers/net/b44.c                                  |  144 ++--
 drivers/net/wireless/ath/ath5k/Makefile            |    1 +
 drivers/net/wireless/ath/ath5k/ani.c               |   20 +-
 drivers/net/wireless/ath/ath5k/ath5k.h             |    7 +
 drivers/net/wireless/ath/ath5k/attach.c            |    2 -
 drivers/net/wireless/ath/ath5k/base.c              |   50 +-
 drivers/net/wireless/ath/ath5k/caps.c              |    7 -
 drivers/net/wireless/ath/ath5k/debug.c             |   74 ++-
 drivers/net/wireless/ath/ath5k/debug.h             |    9 +-
 drivers/net/wireless/ath/ath5k/desc.c              |    7 -
 drivers/net/wireless/ath/ath5k/dma.c               |   13 -
 drivers/net/wireless/ath/ath5k/eeprom.c            |    3 +-
 drivers/net/wireless/ath/ath5k/gpio.c              |    7 -
 drivers/net/wireless/ath/ath5k/pcu.c               |   24 -
 drivers/net/wireless/ath/ath5k/phy.c               |   89 ++-
 drivers/net/wireless/ath/ath5k/qcu.c               |    9 -
 drivers/net/wireless/ath/ath5k/reset.c             |   64 +--
 drivers/net/wireless/ath/ath5k/sysfs.c             |  116 +++
 drivers/net/wireless/ath/ath9k/ani.c               |    1 +
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |   11 -
 drivers/net/wireless/ath/ath9k/ar9002_hw.c         |  109 ++-
 drivers/net/wireless/ath/ath9k/ar9002_initvals.h   |    6 +-
 .../{ar9003_initvals.h =3D> ar9003_2p0_initvals.h}   |    6 +-
 .../{ar9003_initvals.h =3D> ar9003_2p2_initvals.h}   |  185 +++---
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |   10 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |  163 ++++-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |    5 +
 drivers/net/wireless/ath/ath9k/ar9003_mac.h        |    1 +
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |  119 +++
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |   66 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |   68 ++-
 drivers/net/wireless/ath/ath9k/common.c            |  314 +-------
 drivers/net/wireless/ath/ath9k/common.h            |   77 +--
 drivers/net/wireless/ath/ath9k/debug.c             |   56 +-
 drivers/net/wireless/ath/ath9k/debug.h             |    2 +
 drivers/net/wireless/ath/ath9k/eeprom.c            |   29 +
 drivers/net/wireless/ath/ath9k/eeprom.h            |    2 +
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |    1 +
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       |  618 ++++++++----=
----
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |    1 +
 drivers/net/wireless/ath/ath9k/hif_usb.c           |   58 +-
 drivers/net/wireless/ath/ath9k/hif_usb.h           |    2 +
 drivers/net/wireless/ath/ath9k/htc.h               |   12 +-
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c    |   23 +
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |  127 +++-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |  397 ++++++----
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |   47 +-
 drivers/net/wireless/ath/ath9k/htc_hst.c           |    3 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   41 +-
 drivers/net/wireless/ath/ath9k/hw.h                |   14 +-
 drivers/net/wireless/ath/ath9k/init.c              |   19 +-
 drivers/net/wireless/ath/ath9k/main.c              |  255 +------
 drivers/net/wireless/ath/ath9k/rc.c                |  177 +++--
 drivers/net/wireless/ath/ath9k/recv.c              |  278 +++++++-
 drivers/net/wireless/ath/ath9k/reg.h               |   62 +-
 drivers/net/wireless/ath/ath9k/wmi.c               |    3 -
 drivers/net/wireless/ath/ath9k/xmit.c              |   60 +-
 drivers/net/wireless/b43/dma.c                     |   69 +-
 drivers/net/wireless/b43legacy/dma.c               |   49 +-
 drivers/net/wireless/hostap/hostap_hw.c            |    9 -
 drivers/net/wireless/ipw2x00/ipw2100.c             |   18 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |    3 +-
 drivers/net/wireless/iwlwifi/Kconfig               |    6 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c            |    2 +
 drivers/net/wireless/iwlwifi/iwl-3945-debugfs.c    |   28 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c            |  202 +-----
 drivers/net/wireless/iwlwifi/iwl-4965.c            |   83 ++-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   58 ++-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |  345 ++++++++-
 drivers/net/wireless/iwlwifi/iwl-agn-debugfs.c     |   27 +-
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c        |   26 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |  252 ++----
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |    3 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |   77 ++-
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c       |  123 +++
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  609 ++++++++++--=
---
 drivers/net/wireless/iwlwifi/iwl-agn.h             |   34 +
 drivers/net/wireless/iwlwifi/iwl-commands.h        |    3 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |  305 ++++----
 drivers/net/wireless/iwlwifi/iwl-core.h            |   25 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |   81 +--
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   76 +-
 drivers/net/wireless/iwlwifi/iwl-helpers.h         |   27 +
 drivers/net/wireless/iwlwifi/iwl-rx.c              |    6 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |   40 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c             |   72 +-
 drivers/net/wireless/iwlwifi/iwl-sta.h             |   29 +
 drivers/net/wireless/iwlwifi/iwl-tx.c              |   33 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |  183 ++---
 drivers/net/wireless/iwmc3200wifi/hal.c            |    2 +-
 drivers/net/wireless/iwmc3200wifi/rx.c             |    4 +-
 drivers/net/wireless/libertas/cmd.c                |   37 +-
 drivers/net/wireless/libertas/cmdresp.c            |   30 +-
 drivers/net/wireless/libertas/decl.h               |    2 +-
 drivers/net/wireless/libertas/dev.h                |    6 +
 drivers/net/wireless/libertas/ethtool.c            |   24 +-
 drivers/net/wireless/libertas/if_sdio.c            |   58 ++
 drivers/net/wireless/libertas/if_usb.c             |   12 +-
 drivers/net/wireless/libertas/main.c               |   79 ++-
 drivers/net/wireless/libertas/scan.c               |    2 +-
 drivers/net/wireless/libertas_tf/if_usb.c          |    5 +-
 drivers/net/wireless/mwl8k.c                       |   12 +-
 drivers/net/wireless/orinoco/hermes_dld.c          |    2 +-
 drivers/net/wireless/orinoco/orinoco_usb.c         |    4 +-
 drivers/net/wireless/orinoco/wext.c                |    4 +-
 drivers/net/wireless/p54/eeprom.c                  |    4 +-
 drivers/net/wireless/p54/p54spi.c                  |    5 +-
 drivers/net/wireless/p54/p54usb.c                  |    4 +-
 drivers/net/wireless/prism54/isl_ioctl.c           |   11 +-
 drivers/net/wireless/rndis_wlan.c                  |   36 +-
 drivers/net/wireless/rt2x00/rt2400pci.c            |   17 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |   17 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |   31 +-
 drivers/net/wireless/rt2x00/rt2800.h               |   49 ++-
 drivers/net/wireless/rt2x00/rt2800lib.c            |  154 ++--
 drivers/net/wireless/rt2x00/rt2800lib.h            |   13 +-
 drivers/net/wireless/rt2x00/rt2800pci.c            |  103 +--
 drivers/net/wireless/rt2x00/rt2800pci.h            |   19 -
 drivers/net/wireless/rt2x00/rt2800usb.c            |  104 ++--
 drivers/net/wireless/rt2x00/rt2800usb.h            |   37 -
 drivers/net/wireless/rt2x00/rt2x00.h               |   42 +-
 drivers/net/wireless/rt2x00/rt2x00config.c         |   12 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c          |    1 +
 drivers/net/wireless/rt2x00/rt2x00dev.c            |    7 +-
 drivers/net/wireless/rt2x00/rt2x00dump.h           |    7 +-
 drivers/net/wireless/rt2x00/rt2x00ht.c             |   47 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h            |   26 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c            |   51 ++-
 drivers/net/wireless/rt2x00/rt2x00pci.h            |    8 +
 drivers/net/wireless/rt2x00/rt2x00queue.c          |   34 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c            |   33 +-
 drivers/net/wireless/rt2x00/rt2x00usb.h            |   19 -
 drivers/net/wireless/rt2x00/rt61pci.c              |   14 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |   48 +-
 drivers/net/wireless/wl12xx/Kconfig                |    4 +-
 drivers/net/wireless/wl12xx/wl1251_main.c          |    4 +-
 drivers/net/wireless/wl12xx/wl1251_sdio.c          |   41 +-
 drivers/net/wireless/wl12xx/wl1271.h               |   31 +-
 drivers/net/wireless/wl12xx/wl1271_cmd.c           |   41 +-
 drivers/net/wireless/wl12xx/wl1271_cmd.h           |   28 +-
 drivers/net/wireless/wl12xx/wl1271_event.c         |   10 +-
 drivers/net/wireless/wl12xx/wl1271_ini.h           |  123 +++
 drivers/net/wireless/wl12xx/wl1271_main.c          |   95 ++-
 drivers/net/wireless/wl12xx/wl1271_sdio.c          |    2 +-
 drivers/net/wireless/wl12xx/wl1271_testmode.c      |   11 +-
 drivers/net/wireless/wl12xx/wl1271_tx.c            |   36 +-
 drivers/net/wireless/wl12xx/wl1271_tx.h            |    1 +
 drivers/net/wireless/zd1211rw/zd_mac.c             |    2 +-
 drivers/net/wireless/zd1211rw/zd_usb.c             |    2 +-
 drivers/ssb/driver_chipcommon.c                    |   25 +
 drivers/ssb/driver_chipcommon_pmu.c                |   17 +-
 drivers/ssb/main.c                                 |   76 +--
 drivers/ssb/pci.c                                  |   15 +-
 include/linux/nl80211.h                            |    2 +-
 include/linux/ssb/ssb.h                            |  159 +----
 include/net/cfg80211.h                             |  120 +++-
 include/net/mac80211.h                             |   35 +-
 net/mac80211/Kconfig                               |    7 +
 net/mac80211/Makefile                              |    4 +
 net/mac80211/agg-tx.c                              |    7 +-
 net/mac80211/cfg.c                                 |   22 +-
 net/mac80211/debugfs.c                             |  154 ++---
 net/mac80211/debugfs_sta.c                         |   48 +-
 net/mac80211/driver-ops.h                          |   25 +-
 net/mac80211/driver-trace.h                        |   35 +-
 net/mac80211/ibss.c                                |   14 +-
 net/mac80211/ieee80211_i.h                         |    7 +-
 net/mac80211/iface.c                               |   14 +-
 net/mac80211/key.c                                 |  288 ++------
 net/mac80211/key.h                                 |   22 +-
 net/mac80211/main.c                                |   81 ++-
 net/mac80211/mlme.c                                |   75 ++-
 net/mac80211/rate.h                                |   13 +
 net/mac80211/rc80211_minstrel_ht.c                 |  824 ++++++++++++=
++++++++
 net/mac80211/rc80211_minstrel_ht.h                 |  128 +++
 net/mac80211/rc80211_minstrel_ht_debugfs.c         |  120 +++
 net/mac80211/rx.c                                  |   41 +-
 net/mac80211/sta_info.c                            |    8 -
 net/mac80211/sta_info.h                            |   44 +-
 net/mac80211/status.c                              |    2 +-
 net/mac80211/work.c                                |    2 +-
 net/wireless/chan.c                                |    5 +-
 net/wireless/core.h                                |    1 +
 net/wireless/mlme.c                                |    3 +-
 net/wireless/nl80211.c                             |    3 +
 186 files changed, 6755 insertions(+), 4340 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath5k/sysfs.c
 copy drivers/net/wireless/ath/ath9k/{ar9003_initvals.h =3D> ar9003_2p0=
_initvals.h} (99%)
 rename drivers/net/wireless/ath/ath9k/{ar9003_initvals.h =3D> ar9003_2=
p2_initvals.h} (91%)
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_ini.h
 create mode 100644 net/mac80211/rc80211_minstrel_ht.c
 create mode 100644 net/mac80211/rc80211_minstrel_ht.h
 create mode 100644 net/mac80211/rc80211_minstrel_ht_debugfs.c

Omnibus patch is available here:

http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.=
6-2010-06-09.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
