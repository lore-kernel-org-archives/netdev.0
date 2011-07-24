From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 24 Jul 2011 13:28:07 -0700 (PDT)
Message-ID: <20110724.132807.985839818961800743.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The bulk of this is a final syncup with the wireless folks, updates
to the BNA and BNX2X driver, and:

1) GRE tunnel ICMP error handler packet parser has wrong expectation
   of where the IPv4 header is at this point, fix from Dmitry Kozlov.

2) rt->rt_tos --> iph->tos is not a valid conversion unless RT_TOS()
   is applied to filter out iph->tos value, fix from Julian Anastasov.

3) Duplicate header include removals from Huang Weiyi.

4) Linkwatch del_timer_sync() fix from Stephen Hemminger.

5) Malformed STP config packets need to be ignored, from Stephen
   Hemminger.

Please pull, thanks a lot!

The following changes since commit b6844e8f64920cdee620157252169ba63afb=
0c89:

  Merge branch 'for-linus' of master.kernel.org:/home/rmk/linux-2.6-arm=
 (2011-07-24 10:20:54 -0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net.git master

Amitkumar Karwar (3):
      mwifiex: put multicast/broadcast packets to the same RA
      mwifiex: check SDIO multi-port aggregation buffer room correctly
      mwifiex: disable auto deep sleep before unloading the driver

Andy Shevchenko (3):
      wireless: rtlwifi: throw away MAC_FMT and use %pM instead
      wireless: ath9k: use %pM to print MAC
      wireless: mwifiex: print hw address via %pM

Bing Zhao (1):
      MAINTAINERS: add entry for Marvell mwifiex wireless driver

Christian Lamparter (3):
      carl9170 firmware: update firmware headers
      carl9170: move beacon_update into tx.c
      carl9170: set beacon xmit power to the max

Daniel Drake (2):
      libertas: mesh: misc cleanup
      libertas: only enable mesh when interface is active

David S. Miller (2):
      Merge branch 'for-davem' of ssh://master.kernel.org/.../linville/=
wireless-next-2.6
      iwlwifi: Fix build with CONFIG_PM disabled.

Dmitry Kravkov (1):
      bnx2x: dcb - send all unmapped priorities to same COS as L2

Eliad Peller (3):
      mac80211: reconfigure tx on device reconfiguration
      cfg80211: enter psm when working as p2p_cli
      mac80211: check sta_info_get() return value

Emmanuel Grumbach (21):
      iwlagn: move Tx datapath to transport layer
      iwlagn: move the tasklet / irq to the transport layer
      iwlagn: move sync_irq to transport layer
      iwlagn: move the Rx dispatching to the upper layer
      iwlagn: add comment to tx and get_tx_cmd in iwl_trans_ops
      iwlagn: move rx transport functions to iwl-trans-rx-pcie.c
      iwlagn: move tx transport functions to iwl-trans-tx-pcie.c
      iwlagn: move iwlagn_stop_device to transport layer
      iwlagn: move all the ICT related functions to iwl-trans-rx-pcie.c
      iwlagn: add tx start API to transport layer
      iwlagn: add kick_nic API to transport layer
      iwlagn: kill iwlagn_rx_handler_setup
      iwlagn: kill iwlagn_setup_deferred_work
      iwlagn: SCD configuration for AMPDU moves to transport layer
      iwlagn: move more functions from the start flow to the transport =
layer
      iwlagn: move iwl_prepare_card_hw to the transport layer
      iwlagn: transport layer receives struct iwl_trans*
      iwlagn: simplify the bus architecture
      iwlagn: iwl_bus holds drv_data as void * instead of iwl_priv
      iwlagn: add comment to warn about WoWLAN in resume / suspend flow=
s
      iwlagn: probe would crash with DEBUG_SHIRQ

=46elix Fietkau (2):
      ath9k: improve reliability of MIC error detection
      ath9k_hw: validate and fix broken eeprom chainmask settings

=46ry, Donald H (1):
      iwlagn: remove indirection for iwlagn_hw_valid_rtc_data_addr

Hsu, Kenny (1):
      iwlagn: set default of uCode ownership to driver

Huang Weiyi (5):
      bnad: remove duplicated #include
      can: c_can: remove duplicated #include
      igb: remove duplicated #include
      qlge: remove duplicated #include
      via-velocity: remove duplicated #include

Joe Perches (1):
      rtlwifi: Convert printks to pr_<level>

Johannes Berg (15):
      nl80211: advertise GTK rekey support, new triggers
      mac80211: allow driver access to TKIP RX P1K
      mac80211: let key iteration get keys in install order
      mac80211: be more careful in suspend/resume
      iwlagn: simplify TX flags assignments
      cfg80211: allow userspace to control supported rates in scan
      mac80211: implement scan supported rates
      mac80211: sync driver before TX
      cfg80211: fix scan crash on single-band cards
      iwlagn: remove keyinfo cache
      iwlagn: remove forgotten debugfs function
      iwlagn: rewrite HW crypto
      iwlagn: implement WoWLAN
      iwlagn: track beacon interval sent to device
      iwlagn: rename iwlagn_set_dynamic_key

John W. Linville (2):
      bcma: fix 'SSB_PCICORE_BFL_NOPCI' undeclared build breakage
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6 into for-davem

Julian Anastasov (1):
      ipv4: use RT_TOS after some rt_tos conversions

Kalle Valo (1):
      ieee80211: add few wmm tspec values

Luciano Coelho (3):
      nl80211/cfg80211: add max_sched_scan_ssids in the hw description
      nl80211/cfg80211: add max_sched_scan_ie_len in the hw description
      MAINTAINERS: change maintainer of the wl1251 driver

Pavel Roskin (11):
      orinoco: minor fixes for problems found by checkpatch.pl
      carl9170: fix formatting issues found by checkpatch
      ath: use get_unaligned_le{16,32} in ath_hw_keysetmac()
      ath9k: use get_unaligned_{b16, le16, le32} where possible
      ath9k: remove defines in reg.h that exist in ../reg.h
      ath9k: use ath_opmode_to_string()
      ath5k: merge ath5k_hw and ath5k_softc
      carl9170: fix sparse warnings enabled by CONFIG_SPARSE_RCU_POINTE=
R
      ath5k: merge ath5k_{init, deinit}_hw() with their thin wrappers
      ath5k: remove ath5k_hw_get_capability(), don't use VEOL on AR5210
      ath5k: use get_unaligned_le32() in ath5k_write_pwr_to_pdadc_table=
()

Rafa=A9=A9 Mi=A9=A9ecki (25):
      ssb: SPROM: add LED duty cycle fields
      bcma: cc: set GPIOTIMER register
      bcma: extract SPROM rev 9 the same way as rev 8
      b43: bus: drop inline from SSB functions
      b43: use agent R/W ops for BCMA_IOCTL
      b43: HT-PHY: switch to channel after enabling radio
      b43: HT-PHY: find channel entry with regs data
      b43: HT-PHY: fix typo in 0x2059 radio init
      bcma: handle alternative SPROM location
      bcma: define IO status register
      b43: bcma: define 80211 core specific IO status bits
      b43: bcma: read info about supported bands
      b43: HT-PHY: fix masks in radio ctl
      b43: correctly display longer chipsets ids
      bcma: move define of BCMA_CLKCTLST register
      bcma: trivial: add helpers for masking/setting
      bcma: allow setting FAST clockmode for a core
      bcma: allow enabling PLL
      b43: bcma: implement full core reset
      b43: disable parity check on BCMA devices
      ssb: return correct translation bit for 64-bit DMA
      bcma: inform drivers about translation bits needed for the core
      b43: bcma: get DMA translation bits
      b43: (un)initialize driver on the BCMA bus
      b43legacy: dma: cache translation (routing bits)

Rajkumar Manoharan (2):
      ath9k: Fix sparse warnings
      ath9k: Fix some smatch warnings

Rasesh Mody (10):
      bna: Print Driver Version
      bna: CheckPatch Cleanup
      bna: IOC Event Notification Enhancement
      bna: State Machine Fault Handling Cleanup
      bna: Minor IRQ Index and Definition Change
      bna: Mboxq Flush When IOC Disabled
      bna: IOC Event Name Change
      bna: Add HW Semaphore Unlock Logic
      bna: HW Error Counter Fix
      bna: Header File Consolidation

Sergei Shtylyov (2):
      r8169: use pci_dev->subsystem_{vendor|device}
      sbni: use pci_dev->subsystem_device

Shmulik Ravid (1):
      bnx2x: enable internal target-read for 57712 and up only

Vladislav Zolotarov (3):
      bnx2x: count statistic ramrods on EQ to prevent MC assert
      bnx2x: fix bnx2x_stop_on_error flow in bnx2x_sp_rtnl_task
      bnx2x: use pci_pcie_cap()

Wey-Yi Guy (13):
      iwlagn: remove un-necessary file
      iwlagn: remove dual-indirect call to simply the code
      iwlagn: another double indirect removed
      iwlagn: comments for iwl_cfg
      iwlagn: calibration bitmap
      iwlagn: set correct calibration flag
      iwlagn: remove legacy calibration command
      iwlagn: define valid init calibration mask
      iwlagn: radio sensor offset in le16 format
      iwlagn: testmode fixed rate available for testmode only
      iwlagn: remove un-necessary "_agn"
      iwlagn: write iq invert register for 105/135 device
      iwlagn: remove "disable otp refresh" W/A

Yaniv Rosner (1):
      bnx2x: fix loopback for non 10G link

Yogesh Ashok Powar (1):
      mwl8k: Fixing sta dereference when ieee80211_tx_info->control.sta=
 is NULL

stephen hemminger (6):
      bridge: send proper message_age in config BPDU
      bridge: ignore bogus STP config packets
      bridge: notifier called with the wrong device
      bridge: add notification over netlink when STP changes state
      bridge: minor cleanups
      net: allow netif_carrier to be called safely from IRQ

xeb@mail.ru (1):
      gre: fix improper error handling

 MAINTAINERS                                        |   10 +-
 drivers/bcma/core.c                                |   72 ++
 drivers/bcma/driver_chipcommon.c                   |   14 +
 drivers/bcma/driver_pci.c                          |    2 +
 drivers/bcma/sprom.c                               |   14 +-
 drivers/net/bna/bfa_cee.c                          |   65 +-
 drivers/net/bna/bfa_cee.h                          |    3 +-
 drivers/net/bna/{bfa_sm.h =3D> bfa_cs.h}             |   78 +-
 drivers/net/bna/bfa_defs.h                         |    5 +-
 drivers/net/bna/bfa_defs_mfg_comm.h                |   20 +-
 drivers/net/bna/bfa_defs_status.h                  |  134 +-
 drivers/net/bna/bfa_ioc.c                          |  157 ++-
 drivers/net/bna/bfa_ioc.h                          |   51 +-
 drivers/net/bna/bfa_wc.h                           |   69 -
 drivers/net/bna/bfi.h                              |   20 +-
 drivers/net/bna/bna.h                              |   18 +-
 drivers/net/bna/bna_ctrl.c                         |   45 +-
 drivers/net/bna/bna_hw.h                           |   92 +-
 drivers/net/bna/bna_txrx.c                         |   44 +-
 drivers/net/bna/bna_types.h                        |   58 +-
 drivers/net/bna/bnad.c                             |   65 +-
 drivers/net/bna/bnad.h                             |   27 +-
 drivers/net/bna/bnad_ethtool.c                     |    2 +-
 drivers/net/bna/cna.h                              |    2 +-
 drivers/net/bnx2x/bnx2x_dcb.c                      |   39 +-
 drivers/net/bnx2x/bnx2x_main.c                     |  134 ++-
 drivers/net/can/c_can/c_can.c                      |    1 -
 drivers/net/can/c_can/c_can_platform.c             |    1 -
 drivers/net/igb/igb_main.c                         |    1 -
 drivers/net/qlge/qlge_main.c                       |    1 -
 drivers/net/r8169.c                                |    7 +-
 drivers/net/via-velocity.c                         |    1 -
 drivers/net/wan/sbni.c                             |    5 +-
 drivers/net/wireless/ath/ath5k/ahb.c               |   44 +-
 drivers/net/wireless/ath/ath5k/ani.c               |   84 +-
 drivers/net/wireless/ath/ath5k/ath5k.h             |  272 ++++-
 drivers/net/wireless/ath/ath5k/attach.c            |   31 +-
 drivers/net/wireless/ath/ath5k/base.c              | 1138 ++++++++----=
-----
 drivers/net/wireless/ath/ath5k/base.h              |  205 +---
 drivers/net/wireless/ath/ath5k/caps.c              |   45 -
 drivers/net/wireless/ath/ath5k/debug.c             |  218 ++--
 drivers/net/wireless/ath/ath5k/debug.h             |   21 +-
 drivers/net/wireless/ath/ath5k/desc.c              |   10 +-
 drivers/net/wireless/ath/ath5k/dma.c               |   12 +-
 drivers/net/wireless/ath/ath5k/eeprom.c            |    4 +-
 drivers/net/wireless/ath/ath5k/initvals.c          |    2 +-
 drivers/net/wireless/ath/ath5k/led.c               |   68 +-
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |  257 ++--
 drivers/net/wireless/ath/ath5k/pci.c               |   38 +-
 drivers/net/wireless/ath/ath5k/pcu.c               |   24 +-
 drivers/net/wireless/ath/ath5k/phy.c               |   41 +-
 drivers/net/wireless/ath/ath5k/qcu.c               |    9 +-
 drivers/net/wireless/ath/ath5k/reset.c             |   44 +-
 drivers/net/wireless/ath/ath5k/rfkill.c            |   65 +-
 drivers/net/wireless/ath/ath5k/sysfs.c             |   32 +-
 drivers/net/wireless/ath/ath5k/trace.h             |   12 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |   12 +-
 drivers/net/wireless/ath/ath9k/btcoex.c            |    8 +-
 drivers/net/wireless/ath/ath9k/debug.c             |   22 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |   12 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       |   12 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |   12 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c           |    9 +-
 drivers/net/wireless/ath/ath9k/htc_drv_debug.c     |    7 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   22 +
 drivers/net/wireless/ath/ath9k/init.c              |   25 +-
 drivers/net/wireless/ath/ath9k/recv.c              |   53 +-
 drivers/net/wireless/ath/ath9k/reg.h               |   23 -
 drivers/net/wireless/ath/ath9k/xmit.c              |    4 +
 drivers/net/wireless/ath/carl9170/carl9170.h       |   10 +-
 drivers/net/wireless/ath/carl9170/cmd.h            |    4 +-
 drivers/net/wireless/ath/carl9170/debug.c          |    2 +-
 drivers/net/wireless/ath/carl9170/fwdesc.h         |    3 +
 drivers/net/wireless/ath/carl9170/hw.h             |   41 +-
 drivers/net/wireless/ath/carl9170/led.c            |    2 +-
 drivers/net/wireless/ath/carl9170/mac.c            |  129 --
 drivers/net/wireless/ath/carl9170/main.c           |    2 +-
 drivers/net/wireless/ath/carl9170/phy.c            |    6 +-
 drivers/net/wireless/ath/carl9170/tx.c             |  290 ++++-
 drivers/net/wireless/ath/key.c                     |    7 +-
 drivers/net/wireless/b43/b43.h                     |    7 +
 drivers/net/wireless/b43/bus.c                     |   27 +-
 drivers/net/wireless/b43/dma.c                     |   27 +-
 drivers/net/wireless/b43/dma.h                     |    4 +
 drivers/net/wireless/b43/main.c                    |  106 ++-
 drivers/net/wireless/b43/phy_ht.c                  |   21 +-
 drivers/net/wireless/b43/phy_n.c                   |    4 +-
 drivers/net/wireless/b43/radio_2059.c              |    9 +
 drivers/net/wireless/b43legacy/b43legacy.h         |    2 +
 drivers/net/wireless/b43legacy/dma.c               |    7 +-
 drivers/net/wireless/iwlwifi/Makefile              |    8 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c            |   11 +-
 drivers/net/wireless/iwlwifi/iwl-2000.c            |   46 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   22 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |   58 +-
 drivers/net/wireless/iwlwifi/iwl-agn-calib.c       |   65 +-
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c        |  210 ----
 drivers/net/wireless/iwlwifi/iwl-agn-ict.c         |  306 -----
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |  504 +-------
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |    8 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |  115 ++-
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c         |  380 +++----
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |  411 +------
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c       |  179 +---
 drivers/net/wireless/iwlwifi/iwl-agn.c             | 1240 ++++++++++--=
-------
 drivers/net/wireless/iwlwifi/iwl-agn.h             |   65 +-
 .../net/wireless/iwlwifi/{iwl-pci.h =3D> iwl-bus.h}  |   70 +
 drivers/net/wireless/iwlwifi/iwl-commands.h        |  180 +++-
 drivers/net/wireless/iwlwifi/iwl-core.c            |   28 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |   64 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h             |    1 +
 drivers/net/wireless/iwlwifi/iwl-debug.h           |   10 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |   87 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |  197 +--
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |   10 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c            |  271 ----
 drivers/net/wireless/iwlwifi/iwl-io.h              |    7 +-
 drivers/net/wireless/iwlwifi/iwl-led.c             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-pci.c             |  101 +-
 drivers/net/wireless/iwlwifi/iwl-power.c           |    8 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |   82 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c              |  212 +---
 drivers/net/wireless/iwlwifi/iwl-scan.c            |    8 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c             |    8 +-
 drivers/net/wireless/iwlwifi/iwl-sta.h             |    5 +-
 drivers/net/wireless/iwlwifi/iwl-sv-open.c         |   10 +-
 drivers/net/wireless/iwlwifi/iwl-trans-int-pcie.h  |   82 ++
 drivers/net/wireless/iwlwifi/iwl-trans-rx-pcie.c   |  979 ++++++++++++=
+++
 .../iwlwifi/{iwl-tx.c =3D> iwl-trans-tx-pcie.c}      |  484 +++++++-
 drivers/net/wireless/iwlwifi/iwl-trans.c           |  643 +++++++++-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |  154 ++-
 drivers/net/wireless/libertas/dev.h                |    2 -
 drivers/net/wireless/libertas/main.c               |    2 +-
 drivers/net/wireless/libertas/mesh.c               | 1320 +++++++++---=
--------
 drivers/net/wireless/libertas/mesh.h               |   31 -
 drivers/net/wireless/libertas/tx.c                 |    2 +-
 drivers/net/wireless/mwifiex/debugfs.c             |   33 +-
 drivers/net/wireless/mwifiex/ioctl.h               |    1 +
 drivers/net/wireless/mwifiex/main.h                |    1 +
 drivers/net/wireless/mwifiex/sdio.c                |    5 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |   14 +
 drivers/net/wireless/mwifiex/wmm.c                 |    2 +
 drivers/net/wireless/mwl8k.c                       |    6 +-
 drivers/net/wireless/orinoco/airport.c             |    9 +-
 drivers/net/wireless/orinoco/cfg.c                 |    6 +-
 drivers/net/wireless/orinoco/fw.c                  |    7 +-
 drivers/net/wireless/orinoco/fw.h                  |    2 +-
 drivers/net/wireless/orinoco/hermes.c              |   40 +-
 drivers/net/wireless/orinoco/hermes.h              |   37 +-
 drivers/net/wireless/orinoco/hermes_dld.c          |    8 +-
 drivers/net/wireless/orinoco/hermes_dld.h          |   12 +-
 drivers/net/wireless/orinoco/hw.c                  |   48 +-
 drivers/net/wireless/orinoco/hw.h                  |    2 +-
 drivers/net/wireless/orinoco/main.c                |   46 +-
 drivers/net/wireless/orinoco/mic.c                 |    8 +-
 drivers/net/wireless/orinoco/orinoco.h             |   16 +-
 drivers/net/wireless/orinoco/orinoco_cs.c          |    6 +-
 drivers/net/wireless/orinoco/orinoco_nortel.c      |    3 +-
 drivers/net/wireless/orinoco/orinoco_pci.c         |    4 +-
 drivers/net/wireless/orinoco/orinoco_plx.c         |    6 +-
 drivers/net/wireless/orinoco/orinoco_tmd.c         |    2 +-
 drivers/net/wireless/orinoco/orinoco_usb.c         |   23 +-
 drivers/net/wireless/orinoco/spectrum_cs.c         |   10 +-
 drivers/net/wireless/orinoco/wext.c                |   14 +-
 drivers/net/wireless/rtlwifi/base.c                |   20 +-
 drivers/net/wireless/rtlwifi/cam.c                 |    8 +-
 drivers/net/wireless/rtlwifi/core.c                |    6 +-
 drivers/net/wireless/rtlwifi/debug.h               |    5 -
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c  |    5 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |   69 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c       |   11 +-
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c        |    8 +-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |   12 +-
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c       |    5 +-
 drivers/net/wireless/rtlwifi/rtl8192se/rf.c        |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c        |    6 +-
 drivers/net/wireless/rtlwifi/usb.c                 |   12 +-
 drivers/ssb/main.c                                 |    5 +-
 include/linux/bcma/bcma.h                          |   21 +
 include/linux/bcma/bcma_driver_chipcommon.h        |   13 +-
 include/linux/bcma/bcma_regs.h                     |   27 +-
 include/linux/ieee80211.h                          |   37 +
 include/linux/nl80211.h                            |   33 +-
 include/linux/ssb/ssb.h                            |    2 +
 include/net/cfg80211.h                             |   33 +-
 include/net/mac80211.h                             |   60 +
 net/bridge/br_if.c                                 |    2 +-
 net/bridge/br_netlink.c                            |    2 +
 net/bridge/br_private.h                            |    1 +
 net/bridge/br_private_stp.h                        |    3 +-
 net/bridge/br_stp.c                                |   31 +-
 net/bridge/br_stp_bpdu.c                           |   15 +-
 net/bridge/br_stp_if.c                             |    3 +
 net/bridge/br_stp_timer.c                          |    1 +
 net/core/link_watch.c                              |    2 +-
 net/ipv4/gre.c                                     |   21 +-
 net/ipv4/ipmr.c                                    |    2 +-
 net/ipv4/route.c                                   |    2 +-
 net/mac80211/agg-rx.c                              |   10 +-
 net/mac80211/cfg.c                                 |    4 +
 net/mac80211/driver-ops.h                          |   31 +
 net/mac80211/driver-trace.h                        |   43 +
 net/mac80211/ieee80211_i.h                         |    7 +-
 net/mac80211/key.c                                 |    2 +-
 net/mac80211/mlme.c                                |   30 +-
 net/mac80211/pm.c                                  |    3 +
 net/mac80211/scan.c                                |    6 +-
 net/mac80211/tkip.c                                |   11 +
 net/mac80211/util.c                                |   71 +-
 net/mac80211/work.c                                |   28 +-
 net/wireless/core.c                                |    7 +-
 net/wireless/core.h                                |    4 +
 net/wireless/nl80211.c                             |  109 ++-
 net/wireless/scan.c                                |    4 +
 net/wireless/util.c                                |   38 +
 217 files changed, 8010 insertions(+), 6814 deletions(-)
 rename drivers/net/bna/{bfa_sm.h =3D> bfa_cs.h} (60%)
 delete mode 100644 drivers/net/bna/bfa_wc.h
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-ict.c
 rename drivers/net/wireless/iwlwifi/{iwl-pci.h =3D> iwl-bus.h} (61%)
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-hcmd.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-trans-int-pcie.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-trans-rx-pcie.c
 rename drivers/net/wireless/iwlwifi/{iwl-tx.c =3D> iwl-trans-tx-pcie.c=
} (53%)
