From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: pull-request: wireless-drivers-next 2015-02-07
Date: Sat, 07 Feb 2015 13:40:51 +0200
Message-ID: <87a90qosos.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here's one more pull request for 3.20. I hope I'm not too late, I didn'=
t
realise that the merge window is getting so close. Please note that I
had to merge from mac80211-next due to a build time dependency in a
patch but it should be ok as you had already pulled the same patches
into net-next. Also there are few bcma and ssb patches, we agreed with
John that I'll start taking them as well.

There's a small conflict in drivers/net/wireless/rtlwifi/pci.c, the fix
is to leave the two labels like this:

			schedule_work(&rtlpriv->works.lps_change_work);
		}
end:
		skb =3D new_skb;
no_new:
		if (rtlpriv->use_new_trx_flow) {


Please let me know if there are any issues and sorry for being late.

Kalle

The following changes since commit c5ed1df781cb544d4e4d189bb5b6ec7336d8=
888c:

  bcma: use standard bus scanning during early register (2015-01-23 21:=
47:55 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-=
next.git tags/wireless-drivers-next-for-davem-2015-02-07

for you to fetch changes up to d53071143aa5a7cb37cf7db8101042e700b5413f=
:

  Merge ath-next from ath.git (2015-02-06 16:14:11 +0200)

----------------------------------------------------------------

Major changes:

iwlwifi:

* more work for new devices (4165 / 8260)
* cleanups / improvemnts in rate control
* fixes for TDLS
* major statistics work from Johannes - more to come
* improvements for the fw error dump infrastructure
* usual amount of small fixes here and there (scan, D0i3 etc...)
* add support for beamforming
* enable stuck queue detection for iwlmvm
* a few fixes for EBS scan
* fixes for various failure paths
* improvements for TDLS Offchannel

wil6210:

* performance tuning
* some AP features

brcm80211:

* rework some code in SDIO part of the brcmfmac driver related to
  suspend/resume that were found doing stress testing
* in PCIe part scheduling of worker thread needed to be relaxed
* minor fixes and exposing firmware revision information to
  user-space, ie. ethtool.

mwifiex:

* enhancements for change virtual interface handling
* remove coupling between netdev and FW supported interface
  combination, now conversion from any type of supported interface
  types to any other type is possible
* DFS support in AP mode

ath9k:

* fix calibration issues on some boards
* Wake-on-WLAN improvements

ath10k:

* add support for qca6174 hardware
* enable RX batching to reduce CPU load

----------------------------------------------------------------
Amitkumar Karwar (4):
      mwifiex: correction in wakeup timer handling
      mwifiex: fix memory leak in mwifiex_send_processed_packet()
      mwifiex: fix NULL packet downloading issues
      mwifiex: disable UAPSD mode when AP starts

Arend van Spriel (9):
      brcmfmac: pass DEAUTH/DISASSOC reason code to user-space
      brcmfmac: wait for driver to go idle during suspend
      brcmfmac: do not load firmware when device is already running
      brcmutil: use define for boardrev string function
      brcmfmac: determine chip info when not provided by bus layer
      brcmfmac: always obtain device revision info upon intialization
      brcmfmac: show firmware release info in ethtool driver info
      brcmfmac: store revinfo retrieval result
      brcmfmac: fix nvram processing

Arik Nemtsov (2):
      iwlwifi: mvm: improve TDLS ch-sw state machine
      iwlwifi: mvm: ignore stale TDLS ch-switch responses

Avinash Patil (19):
      mwifiex: selectively choose ext_scan support
      mwifiex: remove redundant nick_name variable
      mwifiex: set wiphy params only once
      mwifiex: do not declare wdev as pointer
      mwifiex: store permanant mac address in adapter structure
      mwifiex: add init parameter to init command routine
      mwifiex: manage virtual interface limits efficiently
      mwifiex: handle PS events on AP interface as well
      mwifiex: support conversion to any virtual interface type
      mwifiex: do not send regulatory update while starting AP
      mwifiex: store AP configuration in private structure
      mwifiex: update IEs after AP has started
      mwifiex: refactor start_ap handler
      mwifiex: separate function for parsing head and tail IEs
      mwifiex: add cfg80211 start_radar_detection handler
      mwifiex: support for channel report for radar detection
      mwifiex: handle radar detect event from FW
      mwifiex: channel switch support for mwifiex
      mwifiex: 11h handling for AP interface

Chun-Yeow Yeoh (1):
      rtl8192cu: fix the mesh beaconing

Dedy Lansky (2):
      wil6210: fix timing of netif_carrier_on indication
      wil6210: ignore firmware failure to gracefully stop AP

Emmanuel Grumbach (7):
      iwlwifi: mvm: check IWL_UCODE_TLV_API_SCD_CFG in API and not in c=
apa
      iwlwifi: pcie: don't dump useless data when a TFD queue hangs
      iwlwifi: pcie: prepare the enablement of 31 TFD queues
      iwlwifi: pcie: disable the SCD_BASE_ADDR when we resume from WoWL=
AN
      iwlwifi: mvm: enable watchdog on Tx queues for mvm
      iwlwifi: allow to define the stuck queue timer per queue
      iwlwifi: mvm: don't send a command the firmware doesn't know

Eyal Shapira (2):
      iwlwifi: mvm: add beamformer support
      iwlwifi: mvm: rs: enable forcing single stream Tx decision

Haim Dreyfuss (2):
      iwlwifi: mvm: Fix a few EBS error handling bugs
      iwlwifi: mvm: Enable EBS also in single scan on umac interface

Hamad Kadmany (1):
      wil6210: Remove msm platform related code

Hante Meuleman (5):
      brcmfmac: Relax scheduling of msgbuf worker on high throughput.
      brcmfmac: prevent possible deadlock on resuming SDIO device.
      brcmfmac: use SDIO DPC for control frames.
      brcmfmac: SDIO: avoid using bus state for private states.
      brcmfmac: Reopen netdev queue on bus state data.

Helmut Schaa (1):
      ath10k: Use TX cksum offload only for CHECKSUM_PARTIAL

Hong Xu (1):
      ath9k and ath9k_htc: rename variable "led_blink"

Ilan Peer (1):
      iwlwifi: mvm: Fix building channels in scan_config_cmd

Janusz Dziedzic (2):
      ath10k: implement uapsd autotrigger command
      ath10k: implement sta keepalive command

Johannes Berg (3):
      mwifiex: set netif carrier off in ndo_open
      iwlwifi: mvm: remove space padding after sysassert description
      iwlwifi: mvm: reduce quota threshold

John W. Linville (1):
      ath10k: document switch case fall-through in __ath10k_scan_finish

Julia Lawall (1):
      ath10k: fix error return code

Kalle Valo (2):
      Merge tag 'iwlwifi-next-for-kalle-2015-02-03' of https://git.kern=
el.org/.../iwlwifi/iwlwifi-next
      Merge ath-next from ath.git

Larry Finger (1):
      rtlwifi: rtl8192ee: Fix problems with calculating free space in F=
IFO

Luciano Coelho (3):
      iwlwifi: mvm: don't reprobe if we fail during reconfig and fw_res=
tart is false
      iwlwifi: mvm: always use mac color zero
      iwlwifi: mvm: fix failure path when power_update fails in add_int=
erface

Marek Kwaczynski (2):
      ath10k: remove sw encryption for pmf
      ath10k: fix pmf for wmi-tlv on qca6174

Markus Elfring (6):
      cw1200: Delete an unnecessary check before the function call "rel=
ease_firmware"
      cw1200: Less function calls in cw1200_load_firmware_cw1200() afte=
r error detection
      ath9k: Delete an unnecessary check before the function call "rela=
y_close"
      orinoco: Delete an unnecessary check before the function call "kf=
ree"
      hostap: Delete an unnecessary check before the function call "kfr=
ee"
      brcm80211: Delete unnecessary checks before two function calls

Michael Buesch (1):
      b43: Fix locking FIXME in beacon update top half

Michal Kazior (28):
      ath10k: fill max_num_vdevs for wmi-tlv
      ath10k: implement new beacon tx status event
      ath10k: implement beacon template command
      ath10k: implement prb tmpl wmi command
      ath10k: implement p2p bcn ie command
      ath10k: implement support for ap beacon offloading
      ath10k: prevent fw reg dump spam
      ath10k: implement diag data container event
      ath10k: implement diag event
      ath10k: introduce struct ath10k_skb_rxcb
      ath10k: implement rx reorder support
      ath10k: reset chip before reading chip_id in probe
      ath10k: add support for qca6174 Rx descriptors
      ath10k: add support for qca6174
      ath10k: split fw pdev stats parsing
      ath10k: fix 10.2 fw stats parsing
      ath10k: use idr api for msdu_ids
      ath10k: fix dtim period with beacon templates
      ath10k: fix nullfunc workaround
      ath10k: disable uapsd autotrigger
      ath10k: disable irqs after fw crash
      ath10k: move wmm param storage to vif
      ath10k: implement per-vdev wmm param setup command
      ath10k: use per-vif wmm param setup if possible
      ath10k: disable sta keepalive
      ath10k: change dma beacon cmd prototype
      ath10k: fix beacon deadlock
      ath10k: enable qca6174 hw3.2

Nicholas Mc Guire (5):
      ath10k: fixup wait_for_completion_timeout return handling
      cw1200: use msecs_to_jiffies for conversion
      orinoco: orinoco_plx use msecs_to_jiffies for conversion
      orinoco: orinoco_pci use msecs_to_jiffies for conversion
      orinoco: orinoco_tmd use msecs_to_jiffies for conversion

Pramod Gurav (1):
      ssb: Fix Sparse error in main

Rafa=C5=82 Mi=C5=82ecki (8):
      bcma: fix watchdog on some ARM chipsets
      bcma: simplify freeing cores (internal devices structs)
      bcma: detect SPROM revision 11
      bcma: add empty PCIe hostmode functions if support is disabled
      bcma: add early_init function for PCIe core and move some fix int=
o it
      bcma: implement host code support for PCIe Gen 2 devices
      b43: support bcma core reset on AC-PHY hardware
      b43: AC-PHY: prepare place for developing new PHY support

Rajkumar Manoharan (12):
      ath10k: add wmi support for addba_clear_resp
      ath10k: add wmi support for addba_send
      ath10k: add wmi support for addba_set_resp
      ath10k: add wmi support for delba_send
      ath10k: Implement sta_add_debugfs
      ath10k: add support to send addba request
      ath10k: add support to send addba response
      ath10k: add support to send delba
      ath10k: fix config_enabled check for hwmon
      ath10k: fix duration calculation for quiet param
      ath10k: fix hwmon temperature input units
      ath10k: fix target wakeup timeout

SenthilKumar Jegadeesan (2):
      ath10k: prevent setting wrong key idx for station
      ath10k: add log level configuration for fw_dbglog

Sergey Ryazanov (1):
      ath5k: fix spontaneus AR5312 freezes

Sujith Manoharan (32):
      ath10k: Fix DMA burst size
      ath10k: Enable RX batching
      ath10k: Remove unused htt->max_throughput_mbps
      ath9k: Update QCA953x initvals
      ath9k: Update AR955x initvals
      ath9k: Add a macro to identify PCOEM chips
      ath9k: Fix manual peak calibration initialization
      ath9k: Set correct peak detect threshold
      ath9k: Enable manual peak detect calibration
      ath9k: Remove ATH9K_HW_WOW_DEVICE_CAPABLE
      ath9k: Return early for error conditions
      ath9k: Remove redundant device_can_wakeup() check
      ath9k: Check early for multi-vif/STA conditions
      ath9k: Check multi-channel context for WOW
      ath9k: Fix wow init/deinit
      ath9k: Check WOW triggers properly
      ath9k: Remove unused BMISS processing
      ath9k: Remove ath9k_hw_wow_event_to_string
      ath9k: Add a debugfs file for WOW
      ath9k: Simplify user pattern configuration
      ath9k: Add a HW structure for WOW
      ath9k: Register max WOW patterns
      ath9k: Move WOW registers to reg_wow.h
      ath9k: Remove incorrect register macros
      ath9k: Cleanup reg_wow.h
      ath9k: Fix max pattern check
      ath9k: Add support for more WOW patterns
      ath9k: Register correct WOW details with mac80211
      ath9k: Fix issues with WoW enable
      ath9k: Program AR_WA correctly
      ath9k: Clear TSF2 properly
      ath9k: Choose correct rate for 2GHz channel

Taehee Yoo (2):
      rtlwifi: add support to send beacon frame.
      rtlwifi: rtl8192cu: Set fw_ready flag

Troy Tan (5):
      rtlwifi: rtl8192ee: Fix adhoc fail
      rtlwifi: rtl8192ee: Fix TX hang due to failure to update TX write=
 point
      rtlwifi: rtl8192ee: Fix parsing of received packet
      rtlwifi: rtl8192ee: Fix DMA stalls
      rtlwifi: rtl8192ee: Fix handling of new style descriptors

Vasanthakumar Thiagarajan (1):
      ath10k: Fix potential Rx ring corruption

Vladimir Kondratiev (9):
      wil6210: sync WMI with firmware
      wil6210: implement skb Tx status reporting
      wil6210: implement cfg80211 probe_client() op
      wil6210: move Rx reorder buffer allocation out of spinlock
      wil6210: remove old Tx work-around
      wil6210: avoid Tx descriptor double write
      wil6210: fix race between xmit and Tx vring de-allocation
      wil6210: more Tx debug
      wil6210: print ciphers in debug info

Vladimir Shulman (4):
      wil6210: Add Tx queue len configuration
      wil6210: tuning rings size
      wil6210: interrupt moderation configuration update
      wil6210: remove unnecessary interrupt moderation module parameter=
s

Yanbo Li (1):
      ath10k: Enable the MCS8 and MCS9 at 2.4G band

Yogesh Ashok Powar (2):
      mwifiex: add support for SD8801
      mwifiex: add support for USB8801

 drivers/bcma/bcma_private.h                        |    8 +
 drivers/bcma/driver_chipcommon.c                   |   10 +-
 drivers/bcma/driver_pci.c                          |   68 +-
 drivers/bcma/host_pci.c                            |    6 +-
 drivers/bcma/main.c                                |   27 +-
 drivers/bcma/sprom.c                               |    3 +-
 drivers/net/wireless/ath/ath.h                     |    1 +
 drivers/net/wireless/ath/ath10k/Makefile           |    4 +-
 drivers/net/wireless/ath/ath10k/ce.c               |   12 +-
 drivers/net/wireless/ath/ath10k/ce.h               |    2 +-
 drivers/net/wireless/ath/ath10k/core.c             |   72 ++
 drivers/net/wireless/ath/ath10k/core.h             |   40 +-
 drivers/net/wireless/ath/ath10k/debug.c            |   34 +-
 drivers/net/wireless/ath/ath10k/debug.h            |   11 +-
 drivers/net/wireless/ath/ath10k/debugfs_sta.c      |  243 ++++++
 drivers/net/wireless/ath/ath10k/htc.c              |    6 +-
 drivers/net/wireless/ath/ath10k/htt.c              |    3 +-
 drivers/net/wireless/ath/ath10k/htt.h              |   87 ++-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |  402 +++++++++-
 drivers/net/wireless/ath/ath10k/htt_tx.c           |   94 +--
 drivers/net/wireless/ath/ath10k/hw.c               |   58 ++
 drivers/net/wireless/ath/ath10k/hw.h               |  106 ++-
 drivers/net/wireless/ath/ath10k/mac.c              |  455 ++++++++---
 drivers/net/wireless/ath/ath10k/pci.c              |  151 +++-
 drivers/net/wireless/ath/ath10k/pci.h              |    2 +-
 drivers/net/wireless/ath/ath10k/rx_desc.h          |   25 +-
 drivers/net/wireless/ath/ath10k/targaddrs.h        |    5 +
 drivers/net/wireless/ath/ath10k/thermal.c          |    7 +-
 drivers/net/wireless/ath/ath10k/trace.h            |   68 ++
 drivers/net/wireless/ath/ath10k/txrx.c             |    9 +-
 drivers/net/wireless/ath/ath10k/wmi-ops.h          |  222 +++++-
 drivers/net/wireless/ath/ath10k/wmi-tlv.c          |  532 ++++++++++++=
-
 drivers/net/wireless/ath/ath10k/wmi-tlv.h          |   64 ++
 drivers/net/wireless/ath/ath10k/wmi.c              |  519 ++++++++++--=
-
 drivers/net/wireless/ath/ath10k/wmi.h              |  155 +++-
 drivers/net/wireless/ath/ath5k/reset.c             |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |   61 +-
 drivers/net/wireless/ath/ath9k/ar9003_wow.c        |  315 ++++----
 drivers/net/wireless/ath/ath9k/ar953x_initvals.h   |    4 +-
 .../net/wireless/ath/ath9k/ar955x_1p0_initvals.h   |    4 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |   15 +-
 drivers/net/wireless/ath/ath9k/common-spectral.c   |    2 +-
 drivers/net/wireless/ath/ath9k/debug.c             |   68 ++
 drivers/net/wireless/ath/ath9k/gpio.c              |    2 +-
 drivers/net/wireless/ath/ath9k/htc.h               |    2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_gpio.c      |    2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |    4 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   10 +-
 drivers/net/wireless/ath/ath9k/hw.h                |   37 +-
 drivers/net/wireless/ath/ath9k/init.c              |    5 +-
 drivers/net/wireless/ath/ath9k/main.c              |    9 -
 drivers/net/wireless/ath/ath9k/pci.c               |    5 +-
 drivers/net/wireless/ath/ath9k/reg.h               |  125 +--
 drivers/net/wireless/ath/ath9k/reg_wow.h           |  128 +++
 drivers/net/wireless/ath/ath9k/wow.c               |  228 +++---
 drivers/net/wireless/ath/wil6210/Kconfig           |    9 -
 drivers/net/wireless/ath/wil6210/Makefile          |    1 -
 drivers/net/wireless/ath/wil6210/cfg80211.c        |  149 +++-
 drivers/net/wireless/ath/wil6210/main.c            |   73 +-
 drivers/net/wireless/ath/wil6210/netdev.c          |   15 +-
 drivers/net/wireless/ath/wil6210/rx_reorder.c      |    8 +-
 drivers/net/wireless/ath/wil6210/txrx.c            |   81 +-
 drivers/net/wireless/ath/wil6210/wil6210.h         |   26 +-
 drivers/net/wireless/ath/wil6210/wil_platform.c    |   12 +-
 .../net/wireless/ath/wil6210/wil_platform_msm.c    |  257 ------
 .../net/wireless/ath/wil6210/wil_platform_msm.h    |   24 -
 drivers/net/wireless/ath/wil6210/wmi.c             |   17 +-
 drivers/net/wireless/ath/wil6210/wmi.h             |   58 +-
 drivers/net/wireless/b43/Kconfig                   |    9 +
 drivers/net/wireless/b43/Makefile                  |    1 +
 drivers/net/wireless/b43/b43.h                     |    3 +
 drivers/net/wireless/b43/main.c                    |   70 +-
 drivers/net/wireless/b43/phy_ac.c                  |   92 +++
 drivers/net/wireless/b43/phy_ac.h                  |   38 +
 drivers/net/wireless/b43/phy_common.c              |    9 +-
 drivers/net/wireless/b43/phy_common.h              |    2 +
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |   70 +-
 drivers/net/wireless/brcm80211/brcmfmac/bus.h      |   24 +-
 drivers/net/wireless/brcm80211/brcmfmac/cfg80211.c |   31 +-
 drivers/net/wireless/brcm80211/brcmfmac/common.c   |   31 +-
 .../net/wireless/brcm80211/brcmfmac/commonring.h   |    2 +
 drivers/net/wireless/brcm80211/brcmfmac/core.c     |   39 +-
 drivers/net/wireless/brcm80211/brcmfmac/core.h     |   30 +
 drivers/net/wireless/brcm80211/brcmfmac/firmware.c |    6 +-
 drivers/net/wireless/brcm80211/brcmfmac/fwil.c     |    2 +-
 drivers/net/wireless/brcm80211/brcmfmac/fwil.h     |    1 +
 .../net/wireless/brcm80211/brcmfmac/fwil_types.h   |   41 +
 drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c   |   30 +-
 drivers/net/wireless/brcm80211/brcmfmac/pcie.c     |    2 +-
 drivers/net/wireless/brcm80211/brcmfmac/sdio.c     |  171 ++--
 drivers/net/wireless/brcm80211/brcmfmac/sdio.h     |   12 +-
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |    6 +-
 drivers/net/wireless/brcm80211/brcmsmac/debug.c    |    2 +-
 drivers/net/wireless/brcm80211/brcmutil/utils.c    |   32 +-
 .../net/wireless/brcm80211/include/brcmu_utils.h   |    4 +
 drivers/net/wireless/cw1200/fwio.c                 |   40 +-
 drivers/net/wireless/cw1200/scan.c                 |    8 +-
 drivers/net/wireless/hostap/hostap_ap.c            |    2 +-
 drivers/net/wireless/iwlwifi/dvm/main.c            |    7 +-
 drivers/net/wireless/iwlwifi/dvm/tx.c              |    2 +-
 drivers/net/wireless/iwlwifi/dvm/ucode.c           |    2 +-
 drivers/net/wireless/iwlwifi/iwl-config.h          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c             |    5 -
 drivers/net/wireless/iwlwifi/iwl-fw-file.h         |    2 +
 drivers/net/wireless/iwlwifi/iwl-modparams.h       |    2 -
 drivers/net/wireless/iwlwifi/iwl-prph.h            |   26 +-
 drivers/net/wireless/iwlwifi/iwl-scd.h             |   41 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   29 +-
 drivers/net/wireless/iwlwifi/mvm/constants.h       |    2 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-rs.h       |   43 +-
 drivers/net/wireless/iwlwifi/mvm/fw.c              |    3 +-
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |   10 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |   12 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |   23 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c             |   28 +-
 drivers/net/wireless/iwlwifi/mvm/rs.c              |  241 +++++-
 drivers/net/wireless/iwlwifi/mvm/rs.h              |   14 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c            |   24 +-
 drivers/net/wireless/iwlwifi/mvm/sta.c             |   15 +-
 drivers/net/wireless/iwlwifi/mvm/tdls.c            |   63 +-
 drivers/net/wireless/iwlwifi/mvm/utils.c           |   10 +-
 drivers/net/wireless/iwlwifi/pcie/internal.h       |   10 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |    5 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c             |   58 +-
 drivers/net/wireless/mwifiex/11h.c                 |  198 ++++-
 drivers/net/wireless/mwifiex/11n.c                 |    4 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.c       |    2 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |  816 ++++++++++++=
+++-----
 drivers/net/wireless/mwifiex/cfp.c                 |    4 +-
 drivers/net/wireless/mwifiex/cmdevt.c              |   40 +-
 drivers/net/wireless/mwifiex/decl.h                |   21 +
 drivers/net/wireless/mwifiex/fw.h                  |   58 ++
 drivers/net/wireless/mwifiex/ie.c                  |   89 ++-
 drivers/net/wireless/mwifiex/init.c                |   12 +-
 drivers/net/wireless/mwifiex/main.c                |   14 +-
 drivers/net/wireless/mwifiex/main.h                |   60 +-
 drivers/net/wireless/mwifiex/pcie.c                |    2 +
 drivers/net/wireless/mwifiex/pcie.h                |    3 +
 drivers/net/wireless/mwifiex/scan.c                |   10 +-
 drivers/net/wireless/mwifiex/sdio.c                |    7 +
 drivers/net/wireless/mwifiex/sdio.h                |   23 +
 drivers/net/wireless/mwifiex/sta_cmd.c             |   17 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |    5 +
 drivers/net/wireless/mwifiex/sta_event.c           |   15 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |   32 +-
 drivers/net/wireless/mwifiex/sta_tx.c              |    9 +-
 drivers/net/wireless/mwifiex/txrx.c                |    2 +-
 drivers/net/wireless/mwifiex/uap_cmd.c             |   70 ++
 drivers/net/wireless/mwifiex/uap_event.c           |   47 ++
 drivers/net/wireless/mwifiex/usb.c                 |   16 +
 drivers/net/wireless/mwifiex/usb.h                 |    4 +
 drivers/net/wireless/mwifiex/util.c                |    2 +-
 drivers/net/wireless/mwifiex/wmm.c                 |    3 +
 drivers/net/wireless/orinoco/main.c                |    2 +-
 drivers/net/wireless/orinoco/orinoco_pci.c         |    2 +-
 drivers/net/wireless/orinoco/orinoco_plx.c         |    2 +-
 drivers/net/wireless/orinoco/orinoco_tmd.c         |    2 +-
 drivers/net/wireless/rtlwifi/core.c                |   11 +
 drivers/net/wireless/rtlwifi/pci.c                 |   31 +-
 drivers/net/wireless/rtlwifi/pci.h                 |    7 +
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |    4 +
 drivers/net/wireless/rtlwifi/rtl8192ee/fw.c        |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192ee/hw.c        |  166 +++-
 drivers/net/wireless/rtlwifi/rtl8192ee/reg.h       |    2 +
 drivers/net/wireless/rtlwifi/rtl8192ee/sw.c        |    3 +-
 drivers/net/wireless/rtlwifi/rtl8192ee/trx.c       |   36 +-
 drivers/net/wireless/rtlwifi/rtl8192ee/trx.h       |    3 +
 drivers/net/wireless/rtlwifi/wifi.h                |    1 +
 drivers/ssb/main.c                                 |   19 -
 include/linux/bcma/bcma.h                          |    1 +
 include/linux/bcma/bcma_driver_pci.h               |    2 +
 include/linux/bcma/bcma_regs.h                     |    2 +
 include/linux/ssb/ssb_regs.h                       |    1 +
 173 files changed, 6463 insertions(+), 2183 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath10k/debugfs_sta.c
 create mode 100644 drivers/net/wireless/ath/ath10k/hw.c
 create mode 100644 drivers/net/wireless/ath/ath9k/reg_wow.h
 delete mode 100644 drivers/net/wireless/ath/wil6210/wil_platform_msm.c
 delete mode 100644 drivers/net/wireless/ath/wil6210/wil_platform_msm.h
 create mode 100644 drivers/net/wireless/b43/phy_ac.c
 create mode 100644 drivers/net/wireless/b43/phy_ac.h

--=20
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
