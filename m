From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2015-01-22
Date: Thu, 22 Jan 2015 13:52:11 +0200
Message-ID: <87h9vjnic4.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:47686 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940AbbAVLwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 06:52:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

now a bigger pull request for net-next. Rafal found a UTF-8 bug in
patchwork[1] and because of that two commits (d0c102f70aec and
d0f66df5392a) have his name corrupted:

    Acked-by: Rafa? Mi?ecki <zajec5@gmail.com>

Somehow I failed to spot that when I commited the patches. As rebasing
public git trees is bad, I thought we can live with these and decided
not to rebase. But I'll pay close attention to this in the future to
make sure that it won't happen again. Also we requested an update to
patchwork.kernel.org, the latest patchwork doesn't seem to have this
bug.

Also please note this pull request also adds one DT binding doc, but
this was reviewed in the device tree list:

 .../bindings/net/wireless/qcom,ath10k.txt          |   30 +

Please let me know if you have any issues.

Kalle

[1] https://lists.ozlabs.org/pipermail/patchwork/2015-January/001261.html

The following changes since commit dd9553988879a3ff71a86323b88409e7631c4e5d:

  Merge branch 'timecounter-next' (2015-01-02 16:47:51 -0500)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git master

for you to fetch changes up to bc48a51c2a29e231256c2f96daf80c2b7a45f390:

  MAINTAINERS: remove ath5k mailing list (2015-01-22 12:59:46 +0200)

----------------------------------------------------------------
iwlwifi:

* more work on d0i3 power state
* enhancements to the firmware debugging infrastructure
* support for 2 concurrent channel contexts
* fixes / cleanups in the rate control
* general cleanups

brcmfmac:

* add support for the BCM43340 and BCM43341 SDIO chipsets
* number of changes are related to AP mode

mwifiex:

* debug enhancements:
  * dump SDIO function registers/scratch registers
    upon FW crash
  * histogram support
  * adapter structure dump
  * TDLS peer information via debugfs
* control auto deepsleep via module load parameter
* recovery mechanism when host fails to wakeup the firmware
* wowlan disconnect feature

wlcore:

* add DFS support
* enable AP wowlan so that the host can sleep while AP mode is enabled

rtlwifi:

* simplify the drivers and convert them to share more code

ath10k:

* Device tree support
* Major restructuring how to handle different WMI interface versions
* Add WMI TLV interface in preparation for new firmware interface support
* Support new firmware branch 10.2.4
* Add thermal cooling interface
* Add hwmon interface to read temparture from the device

ath9k:

* add support QCA956x
* per-packet Transmit Power Control for AR9002

wil6210:

* block ack with secure and insecure connection
* fix MTU calculation
* some infrastructure fixes
* some debugfs changes

----------------------------------------------------------------
Amitkumar Karwar (5):
      mwifiex: remove redundant flag MWIFIEX_HW_STATUS_FW_READY
      mwifiex: add wakeup timer based recovery mechanism
      mwifiex: wakeup pending wait queues
      mwifiex: do not release lock during list_for_each_entry_safe()
      mwifiex: Increase priority of firmware download message

Arend van Spriel (6):
      brcmfmac: remove unused/duplicate defines in chip.c
      brcmfmac: follow user-space regulatory domain selection
      brcmfmac: enable 802.11d support in firmware
      brcmfmac: Add support for bcm43340/1 wireless chipsets
      brcmfmac: get rid of duplicate SDIO device identifiers
      ath: ath9k: use debugfs_create_devm_seqfile() helper for seq_file entries

Avinash Patil (3):
      mwifiex: module parameter for deep sleep configuration
      mwifiex: enable -D__CHECK_ENDIAN__ for sparse by default
      mwifiex: get supported BA stream info from FW

Chen Gang (1):
      wil6210: use 'uint64_t' instead of 'cycles_t' to avoid warnings

Dor Shaish (1):
      Revert "iwlwifi: use correct fw file in 8000 b-step"

Eliad Peller (18):
      iwlwifi: pcie: add basic reference accounting
      iwlwifi: mvm: allow both d0i3 and d3 wowlan configuration modes
      iwlwifi: support multiple d0i3 modes
      iwlwifi: mvm: support IWL_D0I3_MODE_ON_SUSPEND d0i3 mode
      iwlwifi: mvm: consider d0i3_disable in iwl_mvm_is_d0i3_supported()
      iwlwifi: mvm: wait for d0i3 exit on hw restart
      iwlwifi: mvm: clean refs before stop_device()
      iwlwifi: mvm: ask the fw to wakeup (from d0i3) on sysassert
      wlcore: fix WLCORE_VENDOR_ATTR_GROUP_KEY policy
      wlcore: fix sparse warning
      wlcore/wl18xx: handle rc updates in a separate work
      wlcore: enable AP wowlan
      wl18xx: add radar detection implementation
      wl18xx: add debugfs file to emulate radar event
      wlcore: add support for ap csa
      wlcore: add dfs master restart calls
      wlcore: allow using dfs channels
      wl18xx: declare radar_detect_widths support for ap interfaces

Emmanuel Grumbach (7):
      iwlwifi: pcie: let the Manageability Engine know when we leave
      iwlwifi: mvm: add debugfs to trigger fw debug logs collection
      iwlwifi: mvm: allow RSSI compensation
      iwlwifi: mvm: change SMEM dump to general purpose memory dump
      iwlwifi: mvm: convert the SRAM dump to the generic memory dump
      iwlwifi: mvm: support 2 different channels
      iwlwifi: remove useless extern definition of iwl4265_2ac_sdio_cfg

Eran Harary (2):
      iwlwifi: mvm: support additional nvm_file in family 8000 B step
      iwlwifi: mvm: call to pcie_apply_destination also on family 8000 B step

Eyal Shapira (2):
      iwlwifi: mvm: rs: fix max rate allowed if no rate is allowed
      iwlwifi: mvm: rs: organize and cleanup consts

Fred Chou (1):
      rt2x00: use helper to check capability/requirement

Guy Mishol (1):
      wlcore: add dfs region to reg domain update cmd

Haim Dreyfuss (2):
      iwlwifi: mvm: Configure EBS scan ratio
      iwlwifi: mvm: Alter passive scan fragmentation parameters in case of multi-MAC

Hante Meuleman (4):
      brcmfmac: Fix incorrect casting of 64 bit physical address.
      brcmfmac: Fix WEP configuration for AP mode.
      brcmfmac: Change error log in standard log for rxbufpost.
      brcmfmac: signal completion of 802.1x.

Ido Yariv (1):
      iwlwifi: mvm: Set the HW step in the core dump

Janusz Dziedzic (2):
      ath10k: fix low TX rates when IBSS and HT
      ath10k: send (re)assoc peer command when NSS changed

Jiri Slaby (1):
      MAINTAINERS: remove ath5k mailing list

Johannes Berg (4):
      iwlwifi: remove MODULE_VERSION
      iwlwifi: mvm: use iwl_mvm_vif_from_mac80211() consistently
      iwlwifi: mvm: use iwl_mvm_sta_from_mac80211() consistently
      orinoco/hermes: select CFG80211_WEXT

Julia Lawall (12):
      iwlwifi: dvm: tt: Use setup_timer
      iwlwifi: dvm: main: Use setup_timer
      wireless: cw1200: Use setup_timer
      cw1200: main: Use setup_timer
      cw1200: queue: Use setup_timer
      iwl4965: Use setup_timer
      iwl3945: Use setup_timer
      orinoco_usb: Use setup_timer
      mwifiex: main: Use setup_timer
      mwifiex: 11n_rxreorder: Use setup_timer
      mwifiex: tdls: Use setup_timer
      adm8211: fix error return code

Kalle Valo (11):
      dt: bindings: add ath10k wireless device
      ath10k: clean up error handling in ath10k_core_probe_fw()
      ath10k: create ath10k_core_init_features()
      ath10k: add ATH10K_FW_IE_WMI_OP_VERSION
      ath10k: set max_num_pending_tx in ath10k_core_init_firmware_features()
      ath10k: set max_num_vdevs based on wmi op version
      ath10k: use wmi op version to check which iface combination to use
      ath10k: print ath10k wmi op version
      Merge tag 'iwlwifi-next-for-kalle-2014-12-30' of https://git.kernel.org/.../iwlwifi/iwlwifi-next
      ath10k: fix build error when hwmon is off
      Merge ath-next from ath.git

Kobi L (1):
      wlcore: enable sleep during AP mode operation

Larry Finger (11):
      rtlwifi: Unify variable naming for all drivers
      rtlwifi: rtl8723be: Improve modinfo output
      rtlwifi: Create new routine to initialize the DM tables
      rtlwifi: rtl8188ee: Convert driver to use the common DM table init routine
      rtlwifi: rtl8192c-common: Convert driver to use common DM table initialization
      rtlwifi: rtl8192de: Convert driver to use common DM table initialization
      rtlwifi: rtl8192ee: Convert driver to use common DM table initialization
      rtlwifi: rtl8723ae: Convert driver to use common DM table initialization
      rtlwifi: rtl8723be: Convert driver to use common DM table initialization
      rtlwifi: rtl8821ae: Convert driver to use common DM table initialization
      rtlwifi: Move macro definitions to core

Liad Kaufman (3):
      iwlwifi: mvm: add fw runtime stack to dump data
      iwlwifi: mvm: add smem content to dump data
      iwlwifi: tlv: add support for IWL_UCODE_TLV_SDIO_ADMA_ADDR TLV

Lorenzo Bianconi (3):
      ath9k: add power per-rate tables for AR9002 chips
      ath9k: add TPC to TX path for AR9002 based chips
      ath9k: enable per-packet TPC on AR9002 based chips

Luciano Coelho (1):
      iwlwifi: mvm: clear tt values when entering CT-kill

Maithili Hinge (2):
      mwifiex: Move code for wowlan magic-packet and patterns to a function
      mwifiex: Add support for wowlan disconnect

Marc Yang (2):
      mwifiex: Adjust calling place of mwifiex_terminate_workqueue
      mwifiex: increase delay during card reset

Miaoqing Pan (4):
      ath9k: Add HW IDs for QCA956x
      ath9k: Add initvals for QCA956x
      ath9k: Fix register definitions for QCA956x
      ath9k: Add QCA956x HW support

Michal Kazior (12):
      ath10k: create a chip revision whitelist
      ath10k: put board size into hw_params
      ath10k: move uart pin config into hw_params
      ath10k: implement intermediate event args
      ath10k: introduce wmi ops
      ath10k: make some wmi functions public
      ath10k: implement wmi-tlv backend
      ath10k: improve 11b coex
      ath10k: fix STA u-APSD
      ath10k: prevent invalid ps timeout config
      ath10k: enable per-vif sta powersave
      ath10k: advertise p2p dev support

Moshe Harel (1):
      iwlwifi: mvm: support LnP 1x1 antenna configuration

Oscar Forner Martinez (1):
      bcma: fix three coding style issues, more than 80 characters per line

Peter Oh (4):
      ath10k: add new pdev parameters for fw 10.2
      ath10k: add new wmi interface of NF cal period
      ath10k: unregister and remove frag_threshold callback
      ath10k: set phymode to 11b when NO_OFDM flag set

Rajkumar Manoharan (5):
      ath10k: add 10.2.4 firmware support
      ath10k: add wmi support for pdev_set_quiet_mode
      ath10k: add thermal cooling device support
      ath10k: add wmi interface for pdev_get_temperature
      ath10k: add thermal sensor device support

Ram Amrani (1):
      wlcore: add ability to reduce FW interrupts during suspend

Rickard Strandqvist (1):
      b43legacy: Remove unused b43legacy_radio_set_tx_iq()

Sujith Manoharan (1):
      ath9k: Update PCI IDs for AR9565

Toshi Kikuchi (1):
      ath10k: read calibration data from Device Tree

Vladimir Kondratiev (22):
      wil6210: ADDBA/DELBA flows
      wil6210: simple ADDBA on originator (Tx) side
      wil6210: allow to configure ADDBA request
      wil6210: improve debugfs for reorder buffer
      wil6210: fix disconnect 1 STA in AP
      wil6210: improve debugfs for VRING
      wil6210: control AMSDU on Tx side of Block Ack
      wil6210: delba for responder
      wil6210: fix max. MPDU size
      wil6210: consider SNAP header in MTU calculations
      wil6210: Increase number of associated stations
      wil6210: use bitmap API for "status"
      wil6210: fix Tx VRING for STA mode
      wil6210: rework debugfs for BACK
      wil6210: detect HW capabilities
      wil6210: use HW capabilities mask in reset
      wil6210: add advanced interrupt moderation
      wil6210: RX high threshold interrupt configuration
      wil6210: fix reordering for MCAST
      wil6210: Tx/Rx descriptors documentation
      wil6210: workaround for BACK establishment race
      wil6210: relax spinlocks in rx reorder

Wolfram Sang (1):
      ath5k: drop owner assignment from platform_drivers

Xinming Hu (9):
      mwifiex: report tdls peers in debugfs
      mwifiex: add bcn_rcv_cnt and bcn_miss_cnt in getlog debugfs
      mwifiex: add rx histogram statistics support
      mwifiex: move pm_wakeup_card_complete definition to usb.c
      mwifiex: move debug_data dump function to common utililty file
      mwifiex: save driver information to file when firmware dump
      mwifiex: save sdio register values before firmware dump
      mwifiex: do not send key material cmd when delete wep key
      mwifiex: make tx packet 64 byte DMA aligned

 .../bindings/net/wireless/qcom,ath10k.txt          |   30 +
 MAINTAINERS                                        |    1 -
 drivers/bcma/driver_chipcommon.c                   |   10 +-
 drivers/net/wireless/adm8211.c                     |    1 +
 drivers/net/wireless/ath/ath10k/Makefile           |    2 +
 drivers/net/wireless/ath/ath10k/ce.c               |    2 +
 drivers/net/wireless/ath/ath10k/core.c             |  250 ++-
 drivers/net/wireless/ath/ath10k/core.h             |   21 +-
 drivers/net/wireless/ath/ath10k/debug.c            |   88 +-
 drivers/net/wireless/ath/ath10k/htt_tx.c           |    5 -
 drivers/net/wireless/ath/ath10k/hw.h               |   30 +
 drivers/net/wireless/ath/ath10k/mac.c              |  192 +-
 drivers/net/wireless/ath/ath10k/pci.c              |   31 +
 drivers/net/wireless/ath/ath10k/pci.h              |    5 +
 drivers/net/wireless/ath/ath10k/spectral.c         |    1 +
 drivers/net/wireless/ath/ath10k/testmode.c         |    5 +-
 drivers/net/wireless/ath/ath10k/thermal.c          |  243 +++
 drivers/net/wireless/ath/ath10k/thermal.h          |   58 +
 drivers/net/wireless/ath/ath10k/wmi-ops.h          |  860 ++++++++
 drivers/net/wireless/ath/ath10k/wmi-tlv.c          | 2222 ++++++++++++++++++++
 drivers/net/wireless/ath/ath10k/wmi-tlv.h          | 1380 ++++++++++++
 drivers/net/wireless/ath/ath10k/wmi.c              | 1737 ++++++++++-----
 drivers/net/wireless/ath/ath10k/wmi.h              |  302 ++-
 drivers/net/wireless/ath/ath5k/ahb.c               |    1 -
 drivers/net/wireless/ath/ath9k/ahb.c               |    4 +
 drivers/net/wireless/ath/ath9k/ani.c               |    3 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |   80 +
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |   15 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |   61 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   47 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |   19 +-
 drivers/net/wireless/ath/ath9k/ar956x_initvals.h   | 1046 +++++++++
 drivers/net/wireless/ath/ath9k/debug.c             |  134 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |   14 +
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       |   15 +
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |   14 +
 drivers/net/wireless/ath/ath9k/hw.c                |   44 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    3 +
 drivers/net/wireless/ath/ath9k/mac.c               |    3 +-
 drivers/net/wireless/ath/ath9k/pci.c               |   85 +
 drivers/net/wireless/ath/ath9k/recv.c              |    3 +-
 drivers/net/wireless/ath/ath9k/reg.h               |    4 +
 drivers/net/wireless/ath/ath9k/xmit.c              |   68 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |   12 +-
 drivers/net/wireless/ath/wil6210/debugfs.c         |  164 +-
 drivers/net/wireless/ath/wil6210/ethtool.c         |   46 +-
 drivers/net/wireless/ath/wil6210/interrupt.c       |  109 +-
 drivers/net/wireless/ath/wil6210/main.c            |  194 +-
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |   65 +-
 drivers/net/wireless/ath/wil6210/rx_reorder.c      |  275 ++-
 drivers/net/wireless/ath/wil6210/txrx.c            |   70 +-
 drivers/net/wireless/ath/wil6210/txrx.h            |  158 +-
 drivers/net/wireless/ath/wil6210/wil6210.h         |  161 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |  221 +-
 drivers/net/wireless/ath/wil6210/wmi.h             |   12 +-
 drivers/net/wireless/b43legacy/radio.c             |   19 -
 drivers/net/wireless/b43legacy/radio.h             |    1 -
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |   20 +-
 drivers/net/wireless/brcm80211/brcmfmac/cfg80211.c |  176 +-
 drivers/net/wireless/brcm80211/brcmfmac/cfg80211.h |    5 +
 drivers/net/wireless/brcm80211/brcmfmac/chip.c     |   15 +-
 drivers/net/wireless/brcm80211/brcmfmac/common.c   |    3 +
 drivers/net/wireless/brcm80211/brcmfmac/common.h   |   20 +
 drivers/net/wireless/brcm80211/brcmfmac/core.c     |    3 +-
 drivers/net/wireless/brcm80211/brcmfmac/core.h     |    4 +-
 drivers/net/wireless/brcm80211/brcmfmac/flowring.c |    6 +-
 drivers/net/wireless/brcm80211/brcmfmac/fwil.h     |    4 +
 .../net/wireless/brcm80211/brcmfmac/fwil_types.h   |   14 +
 drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c   |   24 +-
 drivers/net/wireless/brcm80211/brcmfmac/pcie.c     |   10 +-
 drivers/net/wireless/brcm80211/brcmfmac/sdio.c     |    7 +-
 .../net/wireless/brcm80211/include/brcm_hw_ids.h   |   12 +-
 drivers/net/wireless/cw1200/main.c                 |    5 +-
 drivers/net/wireless/cw1200/pm.c                   |    5 +-
 drivers/net/wireless/cw1200/queue.c                |    4 +-
 drivers/net/wireless/iwlegacy/3945-mac.c           |    4 +-
 drivers/net/wireless/iwlegacy/4965-mac.c           |    9 +-
 drivers/net/wireless/iwlwifi/dvm/main.c            |   24 +-
 drivers/net/wireless/iwlwifi/dvm/tt.c              |   13 +-
 drivers/net/wireless/iwlwifi/iwl-7000.c            |   23 +-
 drivers/net/wireless/iwlwifi/iwl-8000.c            |   17 +-
 drivers/net/wireless/iwlwifi/iwl-config.h          |   10 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h             |    1 +
 drivers/net/wireless/iwlwifi/iwl-drv.c             |   81 +-
 drivers/net/wireless/iwlwifi/iwl-drv.h             |    1 -
 drivers/net/wireless/iwlwifi/iwl-fw-error-dump.h   |   22 +-
 drivers/net/wireless/iwlwifi/iwl-fw-file.h         |    1 +
 drivers/net/wireless/iwlwifi/iwl-fw.h              |    4 +
 drivers/net/wireless/iwlwifi/iwl-modparams.h       |    2 +
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c       |    6 +
 drivers/net/wireless/iwlwifi/iwl-prph.h            |    5 +
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   21 +
 drivers/net/wireless/iwlwifi/mvm/coex.c            |    4 +-
 drivers/net/wireless/iwlwifi/mvm/coex_legacy.c     |    4 +-
 drivers/net/wireless/iwlwifi/mvm/constants.h       |   28 +
 drivers/net/wireless/iwlwifi/mvm/d3.c              |   51 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs-vif.c     |    2 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |   56 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h     |    7 +-
 drivers/net/wireless/iwlwifi/mvm/fw.c              |   31 +-
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |    2 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |  102 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |   34 +
 drivers/net/wireless/iwlwifi/mvm/ops.c             |   41 +-
 drivers/net/wireless/iwlwifi/mvm/phy-ctxt.c        |    2 +-
 drivers/net/wireless/iwlwifi/mvm/rs.c              |  169 +-
 drivers/net/wireless/iwlwifi/mvm/rs.h              |   39 -
 drivers/net/wireless/iwlwifi/mvm/scan.c            |   28 +-
 drivers/net/wireless/iwlwifi/mvm/sta.c             |   16 +-
 drivers/net/wireless/iwlwifi/mvm/tt.c              |    7 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c              |    2 +-
 drivers/net/wireless/iwlwifi/mvm/utils.c           |    4 +-
 drivers/net/wireless/iwlwifi/pcie/internal.h       |    8 +
 drivers/net/wireless/iwlwifi/pcie/trans.c          |   64 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c             |   34 +-
 drivers/net/wireless/mwifiex/11n.h                 |   14 +-
 drivers/net/wireless/mwifiex/11n_aggr.c            |   15 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.c       |    6 +-
 drivers/net/wireless/mwifiex/Makefile              |    2 +
 drivers/net/wireless/mwifiex/cfg80211.c            |   99 +-
 drivers/net/wireless/mwifiex/cfp.c                 |   18 +
 drivers/net/wireless/mwifiex/cmdevt.c              |    6 -
 drivers/net/wireless/mwifiex/debugfs.c             |  281 +--
 drivers/net/wireless/mwifiex/decl.h                |   34 +-
 drivers/net/wireless/mwifiex/ethtool.c             |   16 +-
 drivers/net/wireless/mwifiex/fw.h                  |    3 +
 drivers/net/wireless/mwifiex/init.c                |   23 +
 drivers/net/wireless/mwifiex/ioctl.h               |   11 +-
 drivers/net/wireless/mwifiex/main.c                |  133 +-
 drivers/net/wireless/mwifiex/main.h                |   24 +-
 drivers/net/wireless/mwifiex/pcie.c                |    5 +-
 drivers/net/wireless/mwifiex/sdio.c                |  104 +-
 drivers/net/wireless/mwifiex/sdio.h                |   26 +
 drivers/net/wireless/mwifiex/sta_cmd.c             |    7 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |    2 +
 drivers/net/wireless/mwifiex/sta_event.c           |    7 +
 drivers/net/wireless/mwifiex/sta_ioctl.c           |    6 +-
 drivers/net/wireless/mwifiex/sta_rx.c              |    9 +
 drivers/net/wireless/mwifiex/sta_tx.c              |   19 +-
 drivers/net/wireless/mwifiex/tdls.c                |   35 +-
 drivers/net/wireless/mwifiex/uap_event.c           |    2 +
 drivers/net/wireless/mwifiex/uap_txrx.c            |   28 +-
 drivers/net/wireless/mwifiex/usb.c                 |   11 +-
 drivers/net/wireless/mwifiex/usb.h                 |    7 -
 drivers/net/wireless/mwifiex/util.c                |  220 ++
 drivers/net/wireless/mwifiex/util.h                |   20 +
 drivers/net/wireless/orinoco/Kconfig               |    3 +-
 drivers/net/wireless/orinoco/orinoco_usb.c         |    4 +-
 drivers/net/wireless/rt2x00/rt2x00config.c         |    4 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |   18 +-
 drivers/net/wireless/rt2x00/rt2x00firmware.c       |    2 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |   18 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c            |    8 +-
 drivers/net/wireless/rtlwifi/core.c                |   37 +
 drivers/net/wireless/rtlwifi/core.h                |   41 +
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.c        |   36 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.h        |   41 -
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |   45 +-
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.h  |   38 -
 drivers/net/wireless/rtlwifi/rtl8192ce/dm.c        |    1 +
 drivers/net/wireless/rtlwifi/rtl8192ce/dm.h        |   13 -
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c        |   33 +-
 drivers/net/wireless/rtlwifi/rtl8192de/dm.h        |   38 -
 drivers/net/wireless/rtlwifi/rtl8192ee/dm.c        |   55 +-
 drivers/net/wireless/rtlwifi/rtl8192ee/dm.h        |   16 -
 drivers/net/wireless/rtlwifi/rtl8192se/dm.c        |    7 +-
 drivers/net/wireless/rtlwifi/rtl8192se/dm.h        |   28 -
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.c        |   42 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.h        |   38 -
 drivers/net/wireless/rtlwifi/rtl8723be/dm.c        |   55 +-
 drivers/net/wireless/rtlwifi/rtl8723be/dm.h        |   33 -
 drivers/net/wireless/rtlwifi/rtl8723be/sw.c        |   10 +-
 drivers/net/wireless/rtlwifi/rtl8821ae/dm.c        |   58 +-
 drivers/net/wireless/rtlwifi/rtl8821ae/dm.h        |   41 -
 drivers/net/wireless/rtlwifi/wifi.h                |    2 -
 drivers/net/wireless/ti/wl12xx/main.c              |    4 +
 drivers/net/wireless/ti/wl18xx/acx.c               |   88 +
 drivers/net/wireless/ti/wl18xx/acx.h               |   46 +-
 drivers/net/wireless/ti/wl18xx/cmd.c               |   93 +-
 drivers/net/wireless/ti/wl18xx/cmd.h               |   27 +
 drivers/net/wireless/ti/wl18xx/conf.h              |   23 +-
 drivers/net/wireless/ti/wl18xx/debugfs.c           |   43 +
 drivers/net/wireless/ti/wl18xx/event.c             |   21 +
 drivers/net/wireless/ti/wl18xx/event.h             |   14 +-
 drivers/net/wireless/ti/wl18xx/main.c              |   37 +-
 drivers/net/wireless/ti/wl18xx/wl18xx.h            |    4 +-
 drivers/net/wireless/ti/wlcore/cmd.c               |   20 +-
 drivers/net/wireless/ti/wlcore/cmd.h               |    8 +
 drivers/net/wireless/ti/wlcore/conf.h              |    7 +-
 drivers/net/wireless/ti/wlcore/debugfs.c           |    9 +-
 drivers/net/wireless/ti/wlcore/event.c             |   11 +-
 drivers/net/wireless/ti/wlcore/hw_ops.h            |   48 +-
 drivers/net/wireless/ti/wlcore/init.c              |    8 +-
 drivers/net/wireless/ti/wlcore/main.c              |  381 +++-
 drivers/net/wireless/ti/wlcore/ps.c                |    8 +-
 drivers/net/wireless/ti/wlcore/vendor_cmd.c        |    2 +-
 drivers/net/wireless/ti/wlcore/wlcore.h            |   12 +-
 drivers/net/wireless/ti/wlcore/wlcore_i.h          |    7 +
 include/linux/mmc/sdio_ids.h                       |    6 +-
 200 files changed, 12262 insertions(+), 2587 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/wireless/qcom,ath10k.txt
 create mode 100644 drivers/net/wireless/ath/ath10k/thermal.c
 create mode 100644 drivers/net/wireless/ath/ath10k/thermal.h
 create mode 100644 drivers/net/wireless/ath/ath10k/wmi-ops.h
 create mode 100644 drivers/net/wireless/ath/ath10k/wmi-tlv.c
 create mode 100644 drivers/net/wireless/ath/ath10k/wmi-tlv.h
 create mode 100644 drivers/net/wireless/ath/ath9k/ar956x_initvals.h
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/common.h

-- 
Kalle Valo
