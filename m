From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2016-09-15
Date: Thu, 15 Sep 2016 18:09:21 +0300
Message-ID: <87zin99p3y.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here's the first pull request for 4.9. The ones I want to point out are
the FIELD_PREP() and FIELD_GET() macros added to bitfield.h, which are
reviewed by Linus, and make it possible to remove util.h from mt7601u.

Also we have new HW support to various drivers and other smaller
features, the signed tag below contains more information. And I pulled
my ath-current (uses older net tree as the baseline) branch to fix a
conflict in ath10k.

Once again the diffstat from git request-pull was wrong. I fixed it by
manually copying the diffstat from a test pull against net-next, so
everything should be ok. But please let me know if there are any
problems.

Kalle

The following changes since commit e34f2ff40e0339f6a379e1ecf49e8f2759056453:

  ath9k: bring back direction setting in ath9k_{start_stop} (2016-09-07 16:21:04 +0300)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git tags/wireless-drivers-next-for-davem-2016-09-15

for you to fetch changes up to b7450e248d71067e0c1a09614cf3d7571f7e10fa:

  mwifiex: firmware name correction for usb8997 chipset (2016-09-14 20:02:14 +0300)

----------------------------------------------------------------
wireless-drivers-next patches for 4.9

Major changes:

iwlwifi

* preparation for new a000 HW continues
* some DQA improvements
* add support for GMAC
* add support for 9460, 9270 and 9170 series

mwifiex

* support random MAC address for scanning
* add HT aggregation support for adhoc mode
* add custom regulatory domain support
* add manufacturing mode support via nl80211 testmode interface

bcma

* support BCM53573 series of wireless SoCs

bitfield.h

* add FIELD_PREP() and FIELD_GET() macros

mt7601u

* convert to use the new bitfield.h macros

brcmfmac

* add support for bcm4339 chip with modalias sdio:c00v02D0d4339

ath10k

* add nl80211 testmode support for 10.4 firmware
* hide kernel addresses from logs using %pK format specifier
* implement NAPI support
* enable peer stats by default

ath9k

* use ieee80211_tx_status_noskb where possible

wil6210

* extract firmware capabilities from the firmware file

ath6kl

* enable firmware crash dumps on the AR6004

ath-current is also merged to fix a conflict in ath10k.

----------------------------------------------------------------
Amitkumar Karwar (8):
      mwifiex: fix failed to reconnect after interface disabled/enabled
      mwifiex: remove misleading disconnect message
      mwifiex: add CHAN_REGION_CFG command
      mwifiex: add custom regulatory domain support
      mwifiex: add PCIe function level reset support
      mwifiex: PCIe8997 chip specific handling
      mwifiex: handle error if IRQ request fails in mwifiex_sdio_of()
      mwifiex: correction in Rx STBC field of htcapinfo

Arend Van Spriel (2):
      brcmfmac: add support for bcm4339 chip with modalias sdio:c00v02D0d4339
      brcmfmac: sdio: shorten retry loop in brcmf_sdio_kso_control()

Arnd Bergmann (1):
      bcma: use of_dma_configure() to set initial dma mask

Ashok Raj Nagarajan (2):
      ath10k: fix sending frame in management path in push txq logic
      ath10k: fix reporting channel survey data

Ayala Beker (1):
      iwlwifi: mvm: support GMAC protocol

Baoyou Xie (2):
      ath9k: mark ath_fill_led_pin() static
      brcmfmac: add missing header dependencies

Ben Greear (1):
      ath10k: improve logging message

Bob Copeland (2):
      ath9k: fix misleading indent
      ath9k: remove repetitions of mask array size

Chaehyun Lim (1):
      ath10k: remove unused variable ar_pci

Christian Engelmayer (2):
      rtlwifi: rtl8192de: Fix leak in _rtl92de_read_adapter_info()
      rtlwifi: rtl8723ae: Fix leak in _rtl8723e_read_adapter_info()

Christophe Jaillet (4):
      mwifiex: fix the length parameter of a memset
      mwifiex: simplify length computation for some memset
      rt2x00usb: Fix error return code
      mwifiex: scan: Simplify code

Colin Ian King (5):
      ath10k: fix spelling mistake "montior" -> "monitor"
      mwifiex: fix missing break on IEEE80211_STYPE_ACTION case
      zd1211rw: fix spelling mistake "firmeware" -> "firmware"
      ath10k: fix memory leak on caldata on error exit path
      rtl8xxxu: fix spelling mistake "firmare" -> "firmware"

Dan Kephart (1):
      ath6kl: enable firmware crash dumps on the AR6004

Daniel Wagner (2):
      ath10k: use complete() instead complete_all()
      carl9170: Fix wrong completion usage

Eduardo Abinader (1):
      ath9k: consider return code on

Eric Bentley (1):
      ath6kl: Allow the radio to report 0 dbm txpower without timing out

Felix Fietkau (2):
      ath9k: use ieee80211_tx_status_noskb where possible
      ath9k: improve powersave filter handling

Ganapathi Bhat (4):
      mwifiex: support random MAC address for scanning
      mwifiex: fix radar detection issue
      mwifiex: Command 7 handling for USB chipsets
      mwifiex: firmware name correction for usb8997 chipset

Guy Mishol (1):
      wl18xx: add time sync configuration api

Hans de Goede (1):
      rtl8xxxu: Make rtl8xxxu_ampdu_action less chatty

Heinrich Schuchardt (3):
      mwifiex: remove superfluous condition
      mwifiex: key_material_v2 remove superfluous condition
      rtlwifi: remove superfluous condition

Ismael Luceno (1):
      brcmfmac: Add USB ID for Cisco Linksys AE1200

Jakub Kicinski (4):
      add basic register-field manipulation macros
      mt7601u: remove redefinition of GENMASK
      mt7601u: remove unnecessary include
      mt7601u: use linux/bitfield.h

Jes Sorensen (19):
      rtl8xxxu: Mark 0x20f4:0x648b as tested
      rtl8xxxu: Mark 0x2001:0x3308 as tested
      rtl8xxxu: Fix error handling if rtl8xxxu_init_device() fails
      rtl8xxxu: Add TP-Link TL-WN823N v2 to list of supported devices
      rtl8xxxu: Add TX page defines for 8723b
      rtl8xxxu: Switch 8723a to use new rtl8xxxu_init_queue_reserved_page() routine
      rtl8xxxu: Switch 8192cu/8188cu devices to use rtl8xxxu_init_queue_reserved_page()
      rtl8xxxu: Remove now obsolete rtl8xxxu_old_init_queue_reserved_page()
      rtl8xxxu: Simplify code setting TX buffer boundary
      rtl8xxxu: Add bit definitions for REG_FPGA0_TX_INFO
      rtl8xxxu: Add interrupt bit definitions for gen2 parts
      rtl8xxxu: Use flag to indicate whether device has TX report timer support
      rtl8xxxu: Convert flags in rtl8xxxu_fileops to bitflags
      rtl8xxxu: Introduce fops bitflag indicating type of thermal meter
      rtl8xxxu: Simplify calculating of hw value used for setting TX rate
      rtl8xxxu: Determine the need for SGI before handling specific TX desc formats
      rtl8xxxu: Determine need for shore preamble before updating TX descriptors
      rtl8xxxu: Split filling of TX descriptors into separate functions
      rtl8xxxu: Reset device on module unload if still attached

Julia Lawall (3):
      ath: constify local structures
      iwlegacy: constify local structures
      rtlwifi: rtl818x: constify local structures

Kalle Valo (3):
      Merge tag 'iwlwifi-next-for-kalle-2016-08-30-2' of git://git.kernel.org/.../iwlwifi/iwlwifi-next
      Merge branch 'ath-current' into ath-next
      Merge ath-next from git://git.kernel.org/.../kvalo/ath.git

Karthik D A (2):
      mwifiex: Fixed endianness problem for big endian platform
      mwifiex: add region code information in debugfs

Larry Finger (1):
      rtlwifi: Fix missing country code for Great Britain

Lazar Alexei (1):
      wil6210: Fix driver down flow

Liad Kaufman (5):
      iwlwifi: mvm: re-aggregate shared queue after unsharing
      iwlwifi: mvm: keep track of tid associated with each queue
      iwlwifi: mvm: re-assign old queues after hw restart in dqa mode
      iwlwifi: mvm: use defines for SCD_CONFIG_CMD enablement
      iwlwifi: mvm: support txq tid owner change

Lior David (6):
      wil6210: change HALP logging category to IRQ
      wil6210: fix wiphy registration sequence
      wil6210: fix protection of wil->scan_request
      wil6210: align to latest auto generated wmi.h
      wil6210: extract firmware capabilities from FW file
      wil6210: extract firmware version from file header

Maharaja Kennadyrajan (2):
      ath10k: hide kernel addresses from logs using %pK format specifier
      ath10k: Added support for extended dbglog module id for 10.4

Masahiro Yamada (1):
      ath10k: replace config_enabled() with IS_REACHABLE()

Maxim Altshul (1):
      wlcore: Remove wl pointer from wl_sta structure

Maya Erez (5):
      wil6210: align to latest auto generated wmi.h
      wil6210: fix HALP handling in case of HALP vote time-out
      wil6210: support rx key setting for all TIDs
      wil6210: fix stop p2p device handling
      wil6210: prevent usage of incorrect TX hwtail

Michal Kazior (4):
      ath10k: implement wmi echo command
      ath10k: implement wmi echo event
      ath10k: add wmi command barrier utility
      ath10k: fix spurious tx/rx during boot

Mohammed Shafi Shajakhan (3):
      ath10k: suppress warnings when getting wmi WDS peer event id
      ath10k: Fix broken NULL func data frame status for 10.4
      ath10k: remove unnecessary error code assignment

Nicolas Iooss (1):
      brcmfmac: fix pmksa->bssid usage

Oleg Drokin (1):
      rtlwifi/rtl8192de: Fix print format string

Oren Givon (5):
      iwlwifi: rename and reorder 9000 series configuration structs
      iwlwifi: add a new series 9460 with new PCI ID
      iwlwifi: add new 9460 series PCI IDs
      iwlwifi: add the new 9270 series
      iwlwifi: add the new 9170 series

Pavel Andrianov (1):
      wl3501_cs: Add spinlock to wl3501_reset

Rafał Miłecki (1):
      bcma: support BCM53573 series of wireless SoCs

Rajan Vaja (1):
      hostap: Use memdup_user() to reuse code

Rajkumar Manoharan (4):
      ath10k: fix group privacy action frame decryption for qca4019
      ath10k: improve wake_tx_queue ops performance
      ath10k: implement NAPI support
      ath10k: fix throughput regression in multi client mode

Sara Sharon (5):
      iwlwifi: mvm: allow same PN for de-aggregated AMSDU
      iwlwifi: mvm: support new paging command format
      iwlwifi: pcie: refrain from SCD accesses
      iwlwifi: pcie: fix ucode load flow for a000 devices
      iwlwifi: pcie: remove dead code

Sergey Ryazanov (1):
      ath5k: fix EEPROM dumping via debugfs

Stanislaw Gruszka (3):
      mwifiex: make "PCI-E is not the winner" print more informative
      mwifiex: print status of FW ready event
      mwifiex: do not print dot when downloading FW

Tamizh chelvam (4):
      ath10k: move firmware_swap_code_seg_info to ath10k_fw_file
      ath10k: handle testmode events for 10.2 and 10.4 based firmware
      ath10k: add testmode support for 10.4 firmware
      ath10k: Add WMI_SERVICE_PERIODIC_CHAN_STAT_SUPPORT wmi service

Thomas Pedersen (1):
      ath10k: enable peer stats by default

Vasanthakumar Thiagarajan (4):
      ath10k: move ath10k_hw_params definition to hw.h
      ath10k: add provision for Rx descriptor abstraction
      ath10k: properly remove padding from the start of rx payload
      ath10k: remove 4-addr padding related hw_param configuration

Wei Yongjun (2):
      wlcore: spi: fix non static symbol warning
      rtl8xxxu: gen1: Fix non static symbol warning

Xinming Hu (5):
      mwifiex: process rxba_sync event
      mwifiex: add HT aggregation support for adhoc mode
      mwifiex: correct aid value during tdls setup
      mwifiex: add manufacturing mode support
      mwifiex: add cfg80211 testmode support

>From git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next
 * tag                         wireless-drivers-next-for-davem-2016-09-15 -> FETCH_HEAD
Removing drivers/net/wireless/mediatek/mt7601u/util.h
Auto-merging drivers/net/wireless/intel/iwlwifi/mvm/mvm.h
Auto-merging drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c
Auto-merging drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
Merge made by the 'recursive' strategy.
 drivers/bcma/driver_chipcommon.c                   |   32 +-
 drivers/bcma/main.c                                |    6 +-
 drivers/net/wireless/ath/ath10k/ahb.c              |   12 +-
 drivers/net/wireless/ath/ath10k/bmi.c              |    4 +-
 drivers/net/wireless/ath/ath10k/ce.c               |    4 +-
 drivers/net/wireless/ath/ath10k/core.c             |  125 ++-
 drivers/net/wireless/ath/ath10k/core.h             |   79 +-
 drivers/net/wireless/ath/ath10k/debug.c            |   11 +-
 drivers/net/wireless/ath/ath10k/htc.c              |    6 +-
 drivers/net/wireless/ath/ath10k/htt.h              |    2 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |  194 ++--
 drivers/net/wireless/ath/ath10k/htt_tx.c           |    2 -
 drivers/net/wireless/ath/ath10k/hw.c               |   13 +
 drivers/net/wireless/ath/ath10k/hw.h               |   76 +-
 drivers/net/wireless/ath/ath10k/mac.c              |   70 +-
 drivers/net/wireless/ath/ath10k/pci.c              |   77 +-
 drivers/net/wireless/ath/ath10k/pci.h              |    6 +-
 drivers/net/wireless/ath/ath10k/swap.c             |   26 +-
 drivers/net/wireless/ath/ath10k/swap.h             |   11 +-
 drivers/net/wireless/ath/ath10k/testmode.c         |   27 +-
 drivers/net/wireless/ath/ath10k/thermal.c          |    2 +-
 drivers/net/wireless/ath/ath10k/txrx.c             |    4 +-
 drivers/net/wireless/ath/ath10k/wmi-ops.h          |   33 +-
 drivers/net/wireless/ath/ath10k/wmi-tlv.c          |   59 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |  186 +++-
 drivers/net/wireless/ath/ath10k/wmi.h              |   24 +
 drivers/net/wireless/ath/ath5k/debug.c             |    6 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |    4 +-
 drivers/net/wireless/ath/ath6kl/hif.c              |   11 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |    9 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |    6 +-
 drivers/net/wireless/ath/ath9k/gpio.c              |    2 +-
 drivers/net/wireless/ath/ath9k/main.c              |    2 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |  104 ++-
 drivers/net/wireless/ath/carl9170/usb.c            |    6 +-
 drivers/net/wireless/ath/dfs_pattern_detector.c    |    2 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |  151 ++--
 drivers/net/wireless/ath/wil6210/debugfs.c         |   53 +-
 drivers/net/wireless/ath/wil6210/fw.h              |   14 +-
 drivers/net/wireless/ath/wil6210/fw_inc.c          |   92 +-
 drivers/net/wireless/ath/wil6210/interrupt.c       |   15 +-
 drivers/net/wireless/ath/wil6210/main.c            |   63 +-
 drivers/net/wireless/ath/wil6210/netdev.c          |   34 +-
 drivers/net/wireless/ath/wil6210/p2p.c             |   46 +
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |    9 +-
 drivers/net/wireless/ath/wil6210/txrx.c            |    9 +-
 drivers/net/wireless/ath/wil6210/wil6210.h         |   11 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |   12 +-
 drivers/net/wireless/ath/wil6210/wmi.h             |  932 ++++++++++++++++++--
 .../wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c  |    1 +
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |    4 +-
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.c    |   14 +-
 .../broadcom/brcm80211/brcmfmac/tracepoint.c       |    1 +
 .../net/wireless/broadcom/brcm80211/brcmfmac/usb.c |    4 +
 .../broadcom/brcm80211/include/brcm_hw_ids.h       |    2 +
 drivers/net/wireless/intel/iwlegacy/3945.c         |    4 +-
 drivers/net/wireless/intel/iwlwifi/iwl-9000.c      |   83 +-
 drivers/net/wireless/intel/iwlwifi/iwl-config.h    |    6 +-
 drivers/net/wireless/intel/iwlwifi/iwl-fh.h        |   15 +-
 drivers/net/wireless/intel/iwlwifi/iwl-prph.h      |   19 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-sta.h    |   31 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-tx.h |   12 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api.h    |    8 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c        |   28 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |   18 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |   26 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c      |    6 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c       |  342 ++++++-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.h       |    4 +
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c        |   38 +-
 drivers/net/wireless/intel/iwlwifi/mvm/utils.c     |   24 +-
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c      |   41 +-
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c    |   45 +-
 drivers/net/wireless/intel/iwlwifi/pcie/tx.c       |   13 +-
 .../net/wireless/intersil/hostap/hostap_ioctl.c    |   20 +-
 drivers/net/wireless/marvell/mwifiex/11h.c         |   27 +-
 drivers/net/wireless/marvell/mwifiex/11n.h         |    7 +-
 .../net/wireless/marvell/mwifiex/11n_rxreorder.c   |   78 +-
 .../net/wireless/marvell/mwifiex/11n_rxreorder.h   |    3 +-
 drivers/net/wireless/marvell/mwifiex/cfg80211.c    |  143 ++-
 drivers/net/wireless/marvell/mwifiex/cmdevt.c      |   26 +-
 drivers/net/wireless/marvell/mwifiex/debugfs.c     |    2 +
 drivers/net/wireless/marvell/mwifiex/fw.h          |   73 +-
 drivers/net/wireless/marvell/mwifiex/init.c        |   22 +-
 drivers/net/wireless/marvell/mwifiex/join.c        |    3 +-
 drivers/net/wireless/marvell/mwifiex/main.c        |  270 +++++-
 drivers/net/wireless/marvell/mwifiex/main.h        |    7 +
 drivers/net/wireless/marvell/mwifiex/pcie.c        |  182 +++-
 drivers/net/wireless/marvell/mwifiex/pcie.h        |   13 +-
 drivers/net/wireless/marvell/mwifiex/scan.c        |   28 +-
 drivers/net/wireless/marvell/mwifiex/sdio.c        |    6 +-
 drivers/net/wireless/marvell/mwifiex/sta_cmd.c     |   61 +-
 drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c |  134 ++-
 drivers/net/wireless/marvell/mwifiex/sta_event.c   |  144 ++-
 drivers/net/wireless/marvell/mwifiex/sta_ioctl.c   |    6 +-
 drivers/net/wireless/marvell/mwifiex/uap_event.c   |    7 +-
 drivers/net/wireless/marvell/mwifiex/usb.c         |    6 +-
 drivers/net/wireless/marvell/mwifiex/usb.h         |    3 +-
 drivers/net/wireless/marvell/mwifiex/util.c        |    1 +
 drivers/net/wireless/mediatek/mt7601u/dma.c        |    2 +-
 drivers/net/wireless/mediatek/mt7601u/dma.h        |   10 +-
 drivers/net/wireless/mediatek/mt7601u/eeprom.c     |   12 +-
 drivers/net/wireless/mediatek/mt7601u/init.c       |   10 +-
 drivers/net/wireless/mediatek/mt7601u/mac.c        |   38 +-
 drivers/net/wireless/mediatek/mt7601u/main.c       |    1 -
 drivers/net/wireless/mediatek/mt7601u/mcu.c        |   20 +-
 drivers/net/wireless/mediatek/mt7601u/mt7601u.h    |    4 +-
 drivers/net/wireless/mediatek/mt7601u/phy.c        |   44 +-
 drivers/net/wireless/mediatek/mt7601u/regs.h       |    4 -
 drivers/net/wireless/mediatek/mt7601u/tx.c         |   19 +-
 drivers/net/wireless/mediatek/mt7601u/util.h       |   77 --
 drivers/net/wireless/ralink/rt2x00/rt2x00usb.c     |    4 +-
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.h   |   22 +-
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192c.c |    5 +
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c |    2 +
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_8723a.c |    5 +
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_8723b.c |    7 +
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c  |  328 +++----
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_regs.h  |   60 ++
 drivers/net/wireless/realtek/rtlwifi/core.c        |    2 +-
 drivers/net/wireless/realtek/rtlwifi/regd.c        |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/sw.c    |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ce/sw.c    |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/hw.c    |    3 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/phy.c   |    6 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/sw.c    |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/sw.c    |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192se/sw.c    |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/hw.c    |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/sw.c    |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/sw.c    |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/sw.c    |    2 +-
 drivers/net/wireless/ti/wl18xx/acx.c               |   29 +
 drivers/net/wireless/ti/wl18xx/acx.h               |   13 +
 drivers/net/wireless/ti/wl18xx/event.c             |    1 +
 drivers/net/wireless/ti/wlcore/main.c              |    1 -
 drivers/net/wireless/ti/wlcore/spi.c               |    2 +-
 drivers/net/wireless/ti/wlcore/wlcore.h            |    3 +
 drivers/net/wireless/ti/wlcore/wlcore_i.h          |    1 -
 drivers/net/wireless/wl3501_cs.c                   |    7 +-
 drivers/net/wireless/zydas/zd1211rw/zd_usb.c       |    2 +-
 include/linux/bitfield.h                           |   93 ++
 include/linux/bug.h                                |    3 +
 include/linux/mmc/sdio_ids.h                       |    1 +
 144 files changed, 4390 insertions(+), 1218 deletions(-)
 delete mode 100644 drivers/net/wireless/mediatek/mt7601u/util.h
 create mode 100644 include/linux/bitfield.h

-- 
Kalle Valo
