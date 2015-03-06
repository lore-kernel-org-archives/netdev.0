From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2015-03-06
Date: Fri, 06 Mar 2015 19:08:10 +0200
Message-ID: <874mpy2gw5.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:46233 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403AbbCFRIS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 12:08:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here's a pull request for net-next. Lots of smaller fixes and cleanup,
major changes are documented in the signed tag and available below

Do note that I wasn't able compile net-next (commit 23375a0fd549) with
my config:

wireless-drivers-next/include/net/switchdev.h:133: multiple definition =
of `netdev_switch_fib_ipv4_abort'
net/bridge/br.o:wireless-drivers-next/include/net/switchdev.h:133: firs=
t defined here
net/bridge/br_netlink.o: In function `netdev_switch_fib_ipv4_abort':
wireless-drivers-next/include/net/switchdev.h:133: multiple definition =
of `netdev_switch_fib_ipv4_abort'
net/bridge/br.o:wireless-drivers-next/include/net/switchdev.h:133: firs=
t defined here

But this pull request should still merge to net-next without conflicts.
Please let me know if you have any problems.

Kalle

The following changes since commit 009f33ed6f9d9da0141c2d18b1c7912d2d9b=
e7c1:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/jkirsher/net-next (2015-02-25 18:13:07 -0500)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-=
next.git tags/wireless-drivers-next-for-davem-2015-03-06

for you to fetch changes up to 1ca2760fb2c13959fcba794695cd5b306cbfa6a4=
:

  bcma: prepare Kconfig symbol for PCI driver (2015-03-05 14:11:45 +020=
0)

----------------------------------------------------------------
Major changes:

brcmfmac:

* sdio improvements
* add a debugfs file so users can provide us all the revinfo we could
  ask for

iwlwifi:

* add triggers for firmware dump collection
* remove support for -9.ucode
* new statitics API
* rate control improvements

ath9k:

* add per-vif TX power capability
* BT coexistance fixes

ath10k:

* qca6174: enable STA transmit beamforming (TxBF) support
* disable multi-vif power save by default

bcma:

* enable support for PCIe Gen 2 host devices

----------------------------------------------------------------
Arend van Spriel (3):
      brcmfmac: use helper function for changing SDIO state
      brcmfmac: add debugfs file containing revision info
      brcmfmac: make sdio suspend wait for threads to freeze

Arik Nemtsov (1):
      iwlwifi: mvm: consider TDLS queues as used during drain

Avinash Patil (6):
      mwifiex: use alloc_workqueue's format strings capabilities for WQ=
 names
      mwifiex: do not process mgmt rx on uninitialized interface
      mwifiex: change datatype to bool for device capability flags
      mwifiex: modify TX buff size for SD8887
      mwifiex: DMA alignment for RX packets
      mwifiex: do not initialize ext_scan in mwifiex_init_adapter

Bas Peters (1):
      libertas: remove unnecessary check before calling debugfs_remove

Ben Greear (4):
      ath10k: scan should handle scan-start-failed event properly
      ath10k: fix spelling mistakes and add details to mac logging
      ath10k: fix spelling in htt code comment
      ath10k: fix CE_DESC_FLAGS_META_DATA_LSB definition

Boris Sorochkin (1):
      wil6210: Fix division by zero in wil_vring_debugfs_show

Chen Gang (1):
      bcma: Kconfig: Let it depend on PCI

Colin Ian King (1):
      wil6210: increase cmd buffer size to avoid sscanf buffer overflow

Dan Carpenter (1):
      rtlwifi: rtl8188ee: missing curly braces in handle_branch1()

David Spinadel (2):
      iwlwifi: mvm: use only 40 ms for fragmented scan
      iwlwifi: mvm: don't override passive dwell in case of fragmented =
scan

Emmanuel Grumbach (12):
      iwlwifi: pcie: apply destination before releasing reset
      iwlwifi: mvm: new Alive / error table API
      iwlwifi: add new TLV capability flag for BT PLCR
      iwlwifi: mvm: allow to force the Rx chains from debugfs
      iwlwifi: mvm: add framework for triggers for fw dump
      iwlwifi: mvm: add the cause of the firmware dump in the dump
      iwlwifi: mvm: add trigger for firmware dump upon missed beacons
      iwlwifi: mvm: add trigger for firmware dump upon channel switch
      iwlwifi: mvm: add trigger for firmware dump upon command response
      iwlwifi: mvm: restart firmware recording when no configuration is=
 set
      iwlwifi: mvm: add trigger for firmware dump upon statistics
      iwlwifi: mvm: add trigger for firmware dump upon low RSSI

Eran Harary (2):
      iwlwifi: mvm: increase the number of PAPD channel groups to 9
      iwlwifi: mvm: don't write to DBGC_OUT_CTRL when stopping the reco=
rding

Eyal Shapira (8):
      iwlwifi: mvm: rs: better match tx response rate to the LQ table
      iwlwifi: mvm: rs: fix BT Coex check to look at the correct ant
      iwlwifi: mvm: rs: adapt rate matching to new STBC/BFER
      iwlwifi: mvm: rs: disable MIMO for low latency P2P
      iwlwifi: mvm: rs: avoid ss_force from being reset after tx idle
      iwlwifi: mvm: rs: print single stream params via debugfs
      iwlwifi: mvm: fix BT coex shared antenna activity check
      iwlwifi: mvm: remove unused function in BT coex

Geert Uytterhoeven (1):
      iwlegacy: 4965-rs: Remove bogus colon after newline from debug me=
ssage

Hante Meuleman (3):
      brcmfmac: Remove error print for invalid key index.
      brcmfmac: Dont sleep when ctrl frames to transmit.
      brcmfmac: Fix escan timer causing oops.

Jes Sorensen (1):
      rtlwifi: Clear ACM_CTRL AC3_VO bit correctly

Johannes Berg (3):
      iwlwifi: mvm: add statistics API version 10
      iwlwifi: mvm: support radio statistics as global survey
      iwlwifi: mvm: support beacon statistics for BSS client

Kalle Valo (2):
      Merge tag 'iwlwifi-next-for-kalle-2015-03-01' of https://git.kern=
el.org/.../iwlwifi/iwlwifi-next
      Merge ath-next from ath.git

Larry Finger (1):
      ssb: Silence warning for unknown backplane revision

Leon Nardella (1):
      ath9k_htc: Add new USB ID

Lorenzo Bianconi (2):
      ath9k: add per-vif TX power capability
      ath9k: add per-vif TX power capability to TX path

Luciano Coelho (3):
      iwlwifi: deprecate -9.ucode for 3160 / 7260 / 7265
      iwlwifi: mvm: remove deprecated scan API code
      iwlwifi: mvm: don't iterate interfaces to disconnect in net-detec=
t

Marek Puzyniak (1):
      ath10k: fix wmm params per vdev

Markus Elfring (1):
      ath10k: delete unnecessary checks before the function call "relea=
se_firmware"

Michal Kazior (9):
      ath10k: defer AP self-peer removal wait
      ath10k: add vdev stats processing
      ath10k: change request stats command prototype
      ath10k: add more wmi fw stat defines
      ath10k: implement fw stats for wmi-tlv
      ath10k: add TxBF support
      ath10k: workaround corrupted htt rx events
      ath10k: workaround qca6174 sta powersave issue
      ath10k: disable multi-vif ps by default

Nicholas Mc Guire (2):
      brcmfmac: use msecs_to_jiffies for time conversion
      brcm80211: drop unreachable else case

Priit Laes (7):
      rtlwifi: Remove unused defines from rtl8192cu driver
      rtlwifi: Remove unused defines from driver-specific def.h
      rtlwifi: Remove unused RF6052_MAX_REG define
      rtlwifi: Remove unused defines from cam.h
      rtlwifi: Remove unused defines from base.h
      rtlwifi: Remove unused defines from efuse.h
      rtlwifi: Remove unused RTL_SUPPORTED_CTRL_FILTER define

Rafa=C5=82 Mi=C5=82ecki (10):
      brcmfmac: respect reason when deleting (deauthenticating) STA
      bcma: add helpers bringing PCIe hosted bus up / down
      bcma: change IRQ control function to accept bus as an argument
      bcma: support bringing up bus hosted on PCIe Gen 2
      bcma: enable support for PCIe Gen 2 host devices
      bcma: add missing includes
      bcma: gpio: enable GPIO IRQ domain on BCM5301X
      bcma: make bcma_host_pci_(up|down) calls safe for every config
      bcma: move internal function declarations to private header
      bcma: prepare Kconfig symbol for PCI driver

Rasmus Villemoes (1):
      rtlwifi: rtl8821ae: Remove duplicate hex prefixes

Shengzhen Li (1):
      mwifiex: more_task flag for main_process

Sujith Manoharan (22):
      ath9k: Fix descriptors for keep-alive frame
      ath9k: Set keep awake timer
      ath9k: Add new MCI states
      ath9k: Check MCI PowerSave state
      ath9k: Handle additional patterns on wakeup
      ath9k: Clear additional WoW events
      ath9k: Restart TSF2 timers on wakeup
      ath9k: Move MCI registers to reg_mci.h
      ath9k: Remove useless check in MCI reset
      ath9k: Add new MCI configuration parameters
      ath9k: Handle 2-ANT AR9565 in MCI reset
      ath9k: Fix MCI TX control
      ath9k: Setup MCI statistics properly
      ath9k: Prepare MCI interface correctly
      ath9k: Fix GPM initialization
      ath9k: Mute BT properly
      ath9k: Remove useless return value check
      ath9k: Initialize MCI state correctly
      ath9k: Fix MCI scheme initialization
      ath9k: Fix wlan-active gpio for the AR9003 family
      ath9k: Handle timers for MCI
      ath9k: Fix issues in the main btcoex timer

Taehee Yoo (2):
      rtlwifi: Modify some USB de-initialize code.
      rtlwifi: rtl8192cu: Add case in rtl92cu_get_hw_reg

Vladimir Kondratiev (6):
      wil6210: boot loader
      wil6210: remove support for old hardware
      wil6210: enable fix for HW bug in 802.11->803.3 transform
      wil6210: branch prediction hints
      wil6210: rename 'secure_pcp' to 'privacy'
      wil6210: track privacy connection attribute

Vladimir Shulman (1):
      wil6210: Change of threshold for tx vring idleness measurement

Zhaoyang Liu (1):
      mwifiex: fix usb tx data payload offset issue

 drivers/bcma/Kconfig                               |   19 +-
 drivers/bcma/Makefile                              |    4 +-
 drivers/bcma/bcma_private.h                        |   47 ++
 drivers/bcma/driver_gpio.c                         |    4 +-
 drivers/bcma/driver_pci.c                          |   26 +-
 drivers/bcma/driver_pci_host.c                     |    1 +
 drivers/bcma/driver_pcie2.c                        |   29 +-
 drivers/bcma/host_pci.c                            |   43 +-
 drivers/bcma/main.c                                |    2 +-
 drivers/net/wireless/ath/ath10k/ce.h               |    2 +-
 drivers/net/wireless/ath/ath10k/core.c             |    8 +-
 drivers/net/wireless/ath/ath10k/core.h             |   27 +
 drivers/net/wireless/ath/ath10k/debug.c            |  101 +++-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |    2 +-
 drivers/net/wireless/ath/ath10k/mac.c              |  164 +++++-
 drivers/net/wireless/ath/ath10k/pci.c              |    4 +-
 drivers/net/wireless/ath/ath10k/wmi-ops.h          |    7 +-
 drivers/net/wireless/ath/ath10k/wmi-tlv.c          |  132 ++++-
 drivers/net/wireless/ath/ath10k/wmi-tlv.h          |   15 +
 drivers/net/wireless/ath/ath10k/wmi.c              |   27 +-
 drivers/net/wireless/ath/ath10k/wmi.h              |   18 +-
 drivers/net/wireless/ath/ath9k/ar9003_mci.c        |  158 ++++--
 drivers/net/wireless/ath/ath9k/ar9003_mci.h        |   61 +-
 drivers/net/wireless/ath/ath9k/ar9003_wow.c        |   61 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    1 +
 drivers/net/wireless/ath/ath9k/btcoex.c            |   43 +-
 drivers/net/wireless/ath/ath9k/btcoex.h            |    1 +
 drivers/net/wireless/ath/ath9k/debug.c             |    5 +-
 drivers/net/wireless/ath/ath9k/gpio.c              |   95 ++--
 drivers/net/wireless/ath/ath9k/hif_usb.c           |    1 +
 drivers/net/wireless/ath/ath9k/hw.h                |    1 +
 drivers/net/wireless/ath/ath9k/main.c              |   52 +-
 drivers/net/wireless/ath/ath9k/mci.c               |    5 +-
 drivers/net/wireless/ath/ath9k/reg.h               |  275 ---------
 drivers/net/wireless/ath/ath9k/reg_mci.h           |  310 ++++++++++
 drivers/net/wireless/ath/ath9k/reg_wow.h           |   10 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |   42 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |   32 +-
 drivers/net/wireless/ath/wil6210/debugfs.c         |   28 +-
 drivers/net/wireless/ath/wil6210/ethtool.c         |   34 +-
 drivers/net/wireless/ath/wil6210/fw.c              |    3 +-
 drivers/net/wireless/ath/wil6210/fw_inc.c          |    4 +-
 drivers/net/wireless/ath/wil6210/interrupt.c       |   70 +--
 drivers/net/wireless/ath/wil6210/main.c            |  166 +++---
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |   22 +-
 drivers/net/wireless/ath/wil6210/txrx.c            |  123 ++--
 drivers/net/wireless/ath/wil6210/wil6210.h         |   34 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |    9 +-
 drivers/net/wireless/b43/main.c                    |    6 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |  166 +++++-
 drivers/net/wireless/brcm80211/brcmfmac/cfg80211.c |   13 +-
 drivers/net/wireless/brcm80211/brcmfmac/core.c     |   30 +
 drivers/net/wireless/brcm80211/brcmfmac/sdio.c     |  115 ++--
 drivers/net/wireless/brcm80211/brcmfmac/sdio.h     |   47 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |   10 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_n.c    |   11 +-
 drivers/net/wireless/iwlegacy/4965-rs.c            |    2 +-
 drivers/net/wireless/iwlwifi/dvm/main.c            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-7000.c            |    4 +-
 drivers/net/wireless/iwlwifi/iwl-8000.c            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.h        |   18 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c             |   68 ++-
 drivers/net/wireless/iwlwifi/iwl-fw-error-dump.h   |   46 ++
 drivers/net/wireless/iwlwifi/iwl-fw-file.h         |  151 ++++-
 drivers/net/wireless/iwlwifi/iwl-fw.h              |   53 +-
 drivers/net/wireless/iwlwifi/iwl-phy-db.c          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |    1 -
 drivers/net/wireless/iwlwifi/iwl-trans.h           |    4 +-
 drivers/net/wireless/iwlwifi/mvm/coex.c            |    4 +-
 drivers/net/wireless/iwlwifi/mvm/coex_legacy.c     |   12 +-
 drivers/net/wireless/iwlwifi/mvm/d3.c              |    9 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs-vif.c     |   54 ++
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |    6 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-mac.h      |    1 +
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h     |  191 -------
 drivers/net/wireless/iwlwifi/mvm/fw-api-stats.h    |   64 ++-
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |   27 +-
 drivers/net/wireless/iwlwifi/mvm/fw.c              |  133 ++++-
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |   36 ++
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |  180 +++++-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |  125 +++-
 drivers/net/wireless/iwlwifi/mvm/ops.c             |   44 +-
 drivers/net/wireless/iwlwifi/mvm/phy-ctxt.c        |    2 +
 drivers/net/wireless/iwlwifi/mvm/rs.c              |  215 +++----
 drivers/net/wireless/iwlwifi/mvm/rs.h              |    7 +-
 drivers/net/wireless/iwlwifi/mvm/rx.c              |  150 ++++-
 drivers/net/wireless/iwlwifi/mvm/scan.c            |  600 +-----------=
--------
 drivers/net/wireless/iwlwifi/mvm/tx.c              |    4 +
 drivers/net/wireless/iwlwifi/mvm/utils.c           |  207 ++++++-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |    6 +-
 drivers/net/wireless/libertas/debugfs.c            |    3 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |   14 +-
 drivers/net/wireless/mwifiex/decl.h                |    1 +
 drivers/net/wireless/mwifiex/init.c                |    1 -
 drivers/net/wireless/mwifiex/main.c                |   16 +-
 drivers/net/wireless/mwifiex/main.h                |    5 +
 drivers/net/wireless/mwifiex/pcie.c                |   10 +-
 drivers/net/wireless/mwifiex/pcie.h                |    6 +-
 drivers/net/wireless/mwifiex/sdio.c                |   13 +-
 drivers/net/wireless/mwifiex/sdio.h                |   62 +-
 drivers/net/wireless/mwifiex/txrx.c                |    8 +-
 drivers/net/wireless/mwifiex/util.c                |   30 +
 drivers/net/wireless/rtlwifi/base.h                |    6 -
 drivers/net/wireless/rtlwifi/cam.h                 |    2 -
 drivers/net/wireless/rtlwifi/core.h                |    2 -
 drivers/net/wireless/rtlwifi/efuse.h               |    6 -
 drivers/net/wireless/rtlwifi/rtl8188ee/def.h       |   41 --
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/phy.c       |    3 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/rf.h        |    1 -
 drivers/net/wireless/rtlwifi/rtl8192ce/def.h       |   41 --
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/rf.h        |    1 -
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.h        |    2 -
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.h        |    1 -
 drivers/net/wireless/rtlwifi/rtl8192de/def.h       |   39 --
 drivers/net/wireless/rtlwifi/rtl8192ee/hw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ee/rf.h        |    1 -
 drivers/net/wireless/rtlwifi/rtl8192se/def.h       |    1 -
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/def.h       |   41 --
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/rf.h        |    1 -
 drivers/net/wireless/rtlwifi/rtl8723be/hw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723be/rf.h        |    1 -
 drivers/net/wireless/rtlwifi/rtl8821ae/def.h       |   41 --
 drivers/net/wireless/rtlwifi/rtl8821ae/hw.c        |    4 +-
 drivers/net/wireless/rtlwifi/rtl8821ae/rf.h        |    1 -
 drivers/net/wireless/rtlwifi/usb.c                 |   11 +-
 drivers/ssb/main.c                                 |    2 +
 include/linux/bcma/bcma.h                          |   12 +
 include/linux/bcma/bcma_driver_chipcommon.h        |   11 -
 include/linux/bcma/bcma_driver_gmac_cmn.h          |    6 -
 include/linux/bcma/bcma_driver_mips.h              |   15 -
 include/linux/bcma/bcma_driver_pci.h               |    6 +-
 include/linux/bcma/bcma_driver_pcie2.h             |    4 +-
 137 files changed, 3304 insertions(+), 2340 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/reg_mci.h

--=20
Kalle Valo
