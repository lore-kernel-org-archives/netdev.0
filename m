From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2014-03-21
Date: Fri, 21 Mar 2014 14:49:42 -0400
Message-ID: <20140321184941.GA4404@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZGiS0Q5IWpPtfppv"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50093 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbaCUSy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 14:54:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of wireless updates intended for 3.15!

For the mac80211 bits, Johannes says:

"This has a whole bunch of bugfixes for things that went into -next
previously as well as some other bugfixes I didn't want to rush into
3.14 at this point. The rest of it is some cleanups and a few small
features, the biggest of which is probably Janusz's regulatory DFS CAC
time code."

For the Bluetooth bits, Gustavo says:

"One more pull request to 3.15. This is mostly and bug fix pull request, it
contains several fixes and clean up all over the tree, plus some small new
features."

For the NFC bits, Samuel says:

"This is the NFC pull request for 3.15. With this one we have:

- Support for ISO 15693 a.k.a. NFC vicinity a.k.a. Type 5 tags. ISO
  15693 are long range (1 - 2 meters) vicinity tags/cards. The kernel
  now supports those through the NFC netlink and digital APIs.

- Support for TI's trf7970a chipset. This chipset relies on the NFC
  digital layer and the driver currently supports type 2, 4A and 5 tags.

- Support for NXP's pn544 secure firmare download. The pn544 C3 chipsets
  relies on a different firmware download protocal than the C2 one. We
  now support both and use the right one depending on the version we
  detect at runtime.

- Support for 4A tags from the NFC digital layer.

- A bunch of cleanups and minor fixes from Axel Lin and Thierry Escande."

For the iwlwifi bits, Emmanuel says:

"We were sending a host command while the mutex wasn't held. This
led to hard-to-catch races."

And...

"I have a fix for a "merge damage" which is not really a merge
damage: it enables scheduled scan which has been disabled in
wireless.git. Since you merged wireless.git into wireless-next.git,
this can now be fixed in wireless-next.git.

Besides this, Alex made a workaround for a hardware bug. This fix
allows us to consume less power in S3. Arik and Eliad continue to
work on D0i3 which is a run-time power saving feature. Eliad also
contributes a few bits to the rate scaling logic to which Eyal adds his
own contribution. Avri dives deep in the power code - newer firmware
will allow to enable power save in newer scenarios. Johannes made a few
clean-ups. I have the regular amount of BT Coex boring stuff. I disable
uAPSD since we identified firmware bugs that cause packet loss. One
thing that do stand out is the udev event that we now send when the
FW asserts. I hope it will allow us to debug the FW more easily."

Also included is one last iwlwifi pull for a build breakage fix...

For the Atheros bits, Kalle says:

"Michal now did some optimisations and was able to improve throughput by
100 Mbps on our MIPS based AP135 platform. Chun-Yeow added some
workarounds to be able to better use ad-hoc mode. Ben improved log
messages and added support for MSDU chaining. And, as usual, also some
smaller fixes."

Beyond that...

Andrea Merello continues his rtl8180 refactoring, in preparation for
a long-awaited rtl8187 driver.  We get a new driver (rsi) for the
RS9113 chip, from Fariya Fatima.  And, of course, we get the usual
round of updates for ath9k, brcmfmac, mwifiex, wil6210, etc. as well.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit a85ae0e97879f51bccd8511668b07d346d98b3eb:

  Merge branch 'bcmgenet-next' (2014-03-20 17:36:23 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 49c0ca17ee8dd3530f688052d4eb2ae6d3e55119:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2014-03-21 14:02:04 -0400)

----------------------------------------------------------------

Alexander Aring (1):
      Bluetooth: make bluetooth 6lowpan as an option

Alexander Bondar (5):
      iwlwifi: pcie: enable LP XTAL to reduce power consumption
      iwlwifi: mvm: Change beacon filter enablement condition
      iwlwifi: mvm: restructure scan parameters calculation
      iwlwifi: mvm: configure low latency dependent scan parameters
      mac80211: release sched_scan_sdata when stopping sched scan

Alexey Khoroshilov (1):
      p54usb: fix leaks at failure path in p54u_probe()

Amitkumar Karwar (6):
      mwifiex: extract firmware API version number
      mwifiex: add VHT MCS rate configuration support
      mwifiex: use VHT MCS mask in set bitrate mask handler
      mwifiex: code rearrangement for better readability
      mwifiex: create separate function mwifiex_11n_dispatch_pkt()
      mwifiex: add AMSDU inside AMPDU support

Andre Guedes (1):
      Bluetooth: Enable duplicates filter in background scan

Andrea Merello (6):
      rtl8180: prepare to handle more than two chip types
      rtl8180: remove too-early-added rtl8187se enum value
      rtl8180: support for BSS_CHANGED_BASIC_RATES
      rtl8180: make *IFS and CW tunable by mac80211, and set them in the pr=
oper place
      rtl8180: move eeprom read stuff in a separate function
      rtl818x: remove unused conf_erp callback from RF ops struct

Andrew Earl (1):
      Bluetooth: Fix aborting eSCO connection in case of error 0x20

Arend van Spriel (5):
      brcmfmac: assure active clock request upon entering SLEEP state
      brcmfmac: remove mode field from brcmf_cfg80211_vif structure
      brcmfmac: reinit watchdog completion after handling watchdog
      brcmfmac: only show error message when brcmf_sdiod_regrw_helper() fai=
ls
      brcmfmac: fallback to mimo_bw_cap for older firmwares

Arik Nemtsov (3):
      iwlwifi: mvm: wait for stop sched-scan completion
      iwlwifi: mvm: abort scan on sched_scan request
      iwlwifi: mvm: reconfigure qos seq on D0i3 exit

Arnd Bergmann (2):
      Bluetooth: make sure 6LOWPAN_IPHC is built-in if needed
      wireless: Kconfig: add missing dependency for airo_cs

Arron Wang (2):
      NFC: pn544: Pass hardware variant information when downloading firmwa=
re
      NFC: pn544: i2c: Support PN544 C3 secure firmware download

Avinash Patil (2):
      mwifiex: handle extended scan event for AP interface
      mwifiex: add support for sleep cookie in PCIe

Avri Altman (1):
      iwlwifi: mvm: disable power on P2P client when BSS is added

Axel Lin (9):
      NFC: NCI: Use reinit_completion() at appropriate places
      NFC: port100: Convert to use USB_DEVICE macro
      NFC: pn533: Convert to use USB_DEVICE macro
      NFC: Use list_for_each_entry in nfc_find_se()
      NFC: digital: Use matching_[im|tm]_protocols to check with NFC protoc=
ols masks
      NFC: Use LIST_HEAD() at appropriate places
      NFC: Remove redundant test for dev->n_targets in nfc_find_target
      NFC: Move checking valid gb_len value to nfc_llcp_set_remote_gb
      NFC: llcp: Use list_for_each_entry in nfc_llcp_find_local()

Ben Greear (3):
      ath10k:  add more details to some debug messages
      ath10k: add vdev-id, return code to error codes
      ath10k: support msdu chaining

Chun-Yeow Yeoh (3):
      ath10k: implement drv_get_tsf for ibss merging
      ath10k: set the mactime of ieee80211_rx_status
      mac80211: add missing update on rx status VHT flag

Claudio Takahasi (1):
      Bluetooth: Fix removing Long Term Key

Daniel Kim (1):
      brcmfmac: Enable 40MHz bandwidth in 2GHz band and OBSS scanning opera=
tions

Eliad Peller (6):
      iwlwifi: mvm: check for d0i3 fw capability
      iwlwifi: rs: split rs_collect_tx_data
      iwlwifi: add rs_rate_scale_clear_tbl_windows helper function
      iwlwifi: mvm: configure seq_num to D0i3
      iwlwifi: mvm: configure protocol offloading on D0i3
      mac80211: add status_driver_data array to ieee80211_tx_info

Emil Goode (2):
      brcmsmac: fix deadlock on missing firmware
      brcmsmac: update comment to reflect the code

Emmanuel Grumbach (16):
      iwlwifi: mvm: fix quota for D3 image
      iwlwifi: mvm: fix scan offload for BGN SKU
      iwlwifi: dvm: take mutex when sending SYNC BT config command
      iwlwifi: mvm: BT Coex add support for Co-running block
      iwlwifi: mvm: make bt-coex.c generic
      iwlwifi: mvm: BT Coex - classify packet priority in BT code
      iwlwifi: mvm: BT Coex - enable per-AC BT priority
      iwlwifi: mvm: fix merge damage
      iwlwifi: mvm: don't fail completely if led mode is not supported
      iwlwifi: mvm: send udev event upon firmware error to dump logs
      iwlwifi: mvm: BT Coex - add debugfs hook to set BT Tx priority
      iwlwifi: mvm: fix theoretical NULL ptr dereference
      iwlwifi: mvm: disable uAPSD due to bugs in the firmware
      iwlwifi: mvm: add missing include
      cfg80211/mac80211: ignore signal if the frame was heard on wrong chan=
nel
      mac80211: set beamforming bit in radiotap

Eyal Shapira (3):
      iwlwifi: mvm: cleanups in iwl_dbgfs_frame_stats_read
      iwlwifi: mvm: rs: fix search cycle rules
      iwlwifi: mvm: don't enable protection for all AMPDUs

Fariya Fatima (1):
      rsi: Add RS9113 wireless driver

Felix Fietkau (5):
      ath9k: fix ready time of the multicast buffer queue
      ath9k: clean up and enhance ANI debugfs file
      ath9k_hw: remove ANI function restrictions for AP mode
      ath9k_hw: set ANI cycpwr_thr1 as absolute values instead of relative
      ath9k_hw: set ANI firstep as absolute values instead of relative

Franky Lin (1):
      brcmfmac: add BCM4354 SDIO interface support

Gustavo Padovan (1):
      Bluetooth: Fix skb allocation check for A2MP

Hante Meuleman (2):
      brcmfmac: Protect tx seq number for data and control
      brcmfmac: Improve scanning settings for connect.

Ilan Peer (1):
      cfg80211: send stop AP event only due to internal reason

Janusz Dziedzic (6):
      cfg80211: regulatory: allow user to set world regdomain
      cfg80211: regulatory: allow getting DFS CAC time from userspace
      cfg80211: DFS get CAC time from regulatory database
      ath10k: enable spectrum management support
      ath10k: bitrate_mask add force_sgi support
      ath10k: skip management frames in HTT path

Jean Delvare (1):
      brcmfmac: Make probe function __init

Joe Perches (3):
      Bluetooth: Convert uses of __constant_<foo> to <foo>
      ath9k: Convert uses of __constant_<foo> to <foo>
      rsi: Add pr_fmt,__printf, fix format & arg mismatch

Johan Hedberg (9):
      Bluetooth: Fix expected key count debug logs
      Bluetooth: Fix updating SMP remote key distribution information
      Bluetooth: Fix const declaration for swap function src parameter
      Bluetooth: Fix smp_e byte order to be consistent with SMP specificati=
on
      Bluetooth: Fix MITM flag when initiating SMP pairing
      Bluetooth: Simplify logic when checking SMP_FLAG_TK_VALID
      Bluetooth: Increase SMP re-encryption delay to 500ms
      Bluetooth: Fix SMP user passkey notification mgmt event
      Bluetooth: Fix Pair Device response parameters for pairing failure

Johannes Berg (11):
      cfg80211: regulatory: simplify uevent sending
      iwlwifi: mvm: init drv_stats_lock
      iwlwifi: pcie: suppress ACPI related error message
      iwlwifi: nvm: fix VHT capability antenna-dependent fields
      iwlwifi: return whether to stop from rfkill method
      iwlwifi: mvm: remove using max_duration in firmware API
      iwlwifi: mvm: remove spurious blank line
      iwlwifi: mvm: ignore unchanged low-latency flag
      mac80211: fix potential use-after-free
      mac80211: verify deauthentication and return error on failure
      mac80211: fix suspend vs. authentication race

John Greene (1):
      ath5k: add missing dma_map_error call

John W. Linville (9):
      Merge branch 'for-linville' of git://github.com/kvalo/ath
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge tag 'nfc-next-3.15-1' of git://git.kernel.org/.../sameo/nfc-next
      rsi: make rsi_dbg a regular function
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Luis R. Rodriguez (1):
      cfg80211: allow reprocessing of pending requests

Maithili Hinge (1):
      mwifiex: update MCS set as per RX-STBC bit from hostapd

Marcel Holtmann (3):
      Bluetooth: Add support for handling signature resolving keys
      Bluetooth: Make LTK and CSRK only persisent when bonding
      Bluetooth: Enforce strict Secure Connections Only mode security

Marek Puzyniak (1):
      ath10k: do not overwrite max_antenna_gain

Mark A. Greer (8):
      NFC: Add ISO/IEC 15693 header definitions
      NFC: digital: Add Digital Layer support for ISO/IEC 15693
      NFC: Add netlink support for ISO/IEC 15693
      NFC: digital: Rename Type V tags to Type 5 tags
      NFC: trf7970a: Add driver with ISO/IEC 14443 Type 2 Tag Support
      NFC: trf7970a: Add support for Type 4A Tags
      NFC: trf7970a: Add ISO/IEC 15693 and Type 5 tag Support
      NFC: trf7970a: Add DTS Documentation

Michael Braun (1):
      mac80211: fix WPA with VLAN on AP side with ps-sta again

Michael Knudsen (1):
      Bluetooth: Stop BCSP/H5 timer before cleaning up

Michal Kazior (11):
      ath10k: fix 4addr rx
      ath10k: fix sta_rc_update for non-ap iftype
      ath10k: remove DMA mapping wrappers
      ath10k: remove is_aborted from skb_cb
      ath10k: replace send_head() with tx_sg()
      ath10k: bypass htc for htt tx path
      ath10k: batch htt tx/rx completions
      ath10k: reduce htt tx/rx spinlock overhead
      ath10k: remove pci completion list
      ath10k: minimize coherent dma accesses
      mac80211: refactor channel switch function

Oleksij Rempel (23):
      ath9k: move struct ath_beacon_config to common
      ath9k_htc: use common ath_beacon_config
      ath9k_htc: move beaconq to struct htc_beacon
      ath9k_htc: use ath_beacon_conf.enable_beacon
      ath9k: move sc_flags to ath_common
      ath9k_htc: use common->op_flags
      ath9k_htc: add ATH_OP_PRIM_STA_VIF
      ath9k: remove unused bc_tstamp
      ath9k_htc: sync beacon slot code with ath9k
      ath9k: remove unused beacon_qi
      ath9k|ath9k_htc: move IEEE80211_MS_TO_TU to common
      ath9k-common: add nexttbtt and intval to ath_beacon_config
      ath9k: move ath9k_beacon_config_sta to common-beacon
      ath9k_htc: use ath9k_cmn_beacon_config_sta
      ath9k: move ath9k_beacon_config_adhoc to common
      ath9k_htc: add ath9k_htc_beacon_init (but not use it)
      ath9k_htc: use ath9k_htc_beacon_init in ath9k_htc_beacon_config_ap
      ath9k_htc: use ath9k_htc_beacon_init in ath9k_htc_beacon_config_adhoc
      ath9k_htc: use ath9k_cmn_beacon_config_adhoc
      ath9k: move ath9k_beacon_config_ap common
      ath9k: remove unused ath9k_get_next_tbtt
      ath9k_htc: use ath9k_cmn_beacon_config_ap
      ath9k_htc: move DEFAULT_SWBA_RESPONSE check to ath9k_htc_beacon_init

Peng Chen (2):
      Bluetooth: Add a new PID/VID 0cf3/e005 for AR3012.
      Bluetooth: Fix endianess issue in the ath3k driver

Sujith Manoharan (3):
      ath9k: Add QCA953x WMAC platform support
      ath9k: Disable AR_INTR_SYNC_HOST1_FATAL for QCA953x
      ath9k: Fix temperature compensation

Thierry Escande (6):
      NFC: port100: Fix possible buffer overflow
      NFC: digital: Add poll support for type 4A tag platform
      NFC: digital: Add ISO-DEP support for data exchange
      NFC: port100: Add support for type 4A tag platform
      NFC: digital: Add missing break in switch statement
      NFC: digital: Fix a possible memory leak

Valentin Ilie (1):
      Bluetooth: Remove assignments in if-statements

Vladimir Kondratiev (22):
      wil6210: Helpers to deal with 'cidxtid' fields
      wil6210: Block data till "data port open" reported
      wil6210: enable scan while connected
      wil6210: add scatter-gather support
      wil6210: generalize tx desc mapping
      wil6210: update target reset to support new HW
      wil6210: reduce dmesg pollution after FW crash
      wil6210: report reset time
      wil6210: fix for HW bug in interrupt setup logic
      wil6210: sort HW registers definitions
      wil6210: reset on power good
      wil6210: reduce printing
      wil6210: fix memory leak in the AP flow
      wil6210: Fix kernel oops in reset flow
      wil6210: fw error recovery
      wil6210: fix secondary connect
      wil6210: serialize fw_recovery and start_ap
      wil6210: use GRO
      wil6210: target reset flow update
      wil6210: add memory barriers for the reset flow
      wil6210: fix race between disconnect and Tx NAPI
      wireless: max MSDU size for DMG networks

Zhao, Gang (3):
      cfg80211: make __cfg80211_join_ibss() static
      cfg80211: remove unnecessary check
      cfg80211: remove macro ASSERT_RDEV_LOCK(rdev)

 .../devicetree/bindings/net/nfc/trf7970a.txt       |   34 +
 MAINTAINERS                                        |    1 +
 drivers/bluetooth/ath3k.c                          |   13 +-
 drivers/bluetooth/bfusb.c                          |   14 +-
 drivers/bluetooth/bluecard_cs.c                    |    9 +-
 drivers/bluetooth/bt3c_cs.c                        |    7 +-
 drivers/bluetooth/btuart_cs.c                      |    6 +-
 drivers/bluetooth/btusb.c                          |    1 +
 drivers/bluetooth/dtl1_cs.c                        |    9 +-
 drivers/bluetooth/hci_bcsp.c                       |   31 +-
 drivers/bluetooth/hci_h5.c                         |   10 +-
 drivers/bluetooth/hci_ldisc.c                      |    9 +-
 drivers/net/wireless/Kconfig                       |    3 +-
 drivers/net/wireless/Makefile                      |    1 +
 drivers/net/wireless/ath/ath.h                     |   10 +
 drivers/net/wireless/ath/ath10k/ce.c               |   16 +-
 drivers/net/wireless/ath/ath10k/ce.h               |    9 +-
 drivers/net/wireless/ath/ath10k/core.h             |   34 +-
 drivers/net/wireless/ath/ath10k/hif.h              |   25 +-
 drivers/net/wireless/ath/ath10k/htc.c              |   25 +-
 drivers/net/wireless/ath/ath10k/htt.h              |   18 +
 drivers/net/wireless/ath/ath10k/htt_rx.c           |  236 +++-
 drivers/net/wireless/ath/ath10k/htt_tx.c           |  205 +--
 drivers/net/wireless/ath/ath10k/mac.c              |  268 ++--
 drivers/net/wireless/ath/ath10k/pci.c              |  389 ++----
 drivers/net/wireless/ath/ath10k/pci.h              |   28 -
 drivers/net/wireless/ath/ath10k/txrx.c             |   24 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |   18 +-
 drivers/net/wireless/ath/ath5k/base.c              |    3 +
 drivers/net/wireless/ath/ath9k/Makefile            |    3 +-
 drivers/net/wireless/ath/ath9k/ahb.c               |   11 +-
 drivers/net/wireless/ath/ath9k/ani.c               |   11 -
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |   85 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |   63 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |   22 -
 drivers/net/wireless/ath/ath9k/beacon.c            |  165 +--
 drivers/net/wireless/ath/ath9k/common-beacon.c     |  180 +++
 drivers/net/wireless/ath/ath9k/common-beacon.h     |   26 +
 drivers/net/wireless/ath/ath9k/common.h            |   14 +
 drivers/net/wireless/ath/ath9k/debug.c             |   60 +-
 drivers/net/wireless/ath/ath9k/htc.h               |   25 +-
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c    |  252 +---
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |   10 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |   53 +-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |    3 +-
 drivers/net/wireless/ath/ath9k/hw.c                |    3 +-
 drivers/net/wireless/ath/ath9k/link.c              |   16 +-
 drivers/net/wireless/ath/ath9k/mac.c               |    2 +-
 drivers/net/wireless/ath/ath9k/main.c              |   45 +-
 drivers/net/wireless/ath/ath9k/mci.c               |    2 +-
 drivers/net/wireless/ath/ath9k/pci.c               |    8 +-
 drivers/net/wireless/ath/ath9k/tx99.c              |    2 +-
 drivers/net/wireless/ath/ath9k/wow.c               |    4 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |   11 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |   43 +-
 drivers/net/wireless/ath/wil6210/debugfs.c         |   64 +-
 drivers/net/wireless/ath/wil6210/interrupt.c       |   33 +-
 drivers/net/wireless/ath/wil6210/main.c            |  119 +-
 drivers/net/wireless/ath/wil6210/netdev.c          |    5 +-
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |    5 +
 drivers/net/wireless/ath/wil6210/txrx.c            |  223 ++--
 drivers/net/wireless/ath/wil6210/wil6210.h         |   82 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |   20 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |   44 +-
 drivers/net/wireless/brcm80211/brcmfmac/chip.c     |    5 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |  261 ++--
 .../net/wireless/brcm80211/brcmfmac/fwil_types.h   |   10 +
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c      |    6 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |  130 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.h  |   17 -
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |   20 +-
 .../net/wireless/brcm80211/include/brcm_hw_ids.h   |    1 +
 drivers/net/wireless/iwlwifi/dvm/main.c            |   12 +-
 drivers/net/wireless/iwlwifi/iwl-7000.c            |    4 +
 drivers/net/wireless/iwlwifi/iwl-config.h          |    1 +
 drivers/net/wireless/iwlwifi/iwl-csr.h             |   38 +
 drivers/net/wireless/iwlwifi/iwl-fw.h              |   16 +
 drivers/net/wireless/iwlwifi/iwl-io.c              |    4 +-
 drivers/net/wireless/iwlwifi/iwl-io.h              |    2 +
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c       |   19 +-
 drivers/net/wireless/iwlwifi/iwl-op-mode.h         |   11 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |   23 +-
 drivers/net/wireless/iwlwifi/mvm/Makefile          |    4 +-
 .../net/wireless/iwlwifi/mvm/{bt-coex.c =3D> coex.c} |  336 ++++-
 drivers/net/wireless/iwlwifi/mvm/constants.h       |    4 +-
 drivers/net/wireless/iwlwifi/mvm/d3.c              |  195 +--
 drivers/net/wireless/iwlwifi/mvm/debugfs-vif.c     |    5 +
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |  112 +-
 .../mvm/{fw-api-bt-coex.h =3D> fw-api-coex.h}        |    4 +
 drivers/net/wireless/iwlwifi/mvm/fw-api-d3.h       |    8 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-tx.h       |    3 +
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |    3 +-
 drivers/net/wireless/iwlwifi/mvm/fw-error-dump.h   |  106 ++
 drivers/net/wireless/iwlwifi/mvm/led.c             |    2 +
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |  145 ++-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |   56 +-
 drivers/net/wireless/iwlwifi/mvm/offloading.c      |  215 +++
 drivers/net/wireless/iwlwifi/mvm/ops.c             |  232 +++-
 drivers/net/wireless/iwlwifi/mvm/power.c           |   17 +-
 drivers/net/wireless/iwlwifi/mvm/quota.c           |   23 +-
 drivers/net/wireless/iwlwifi/mvm/rs.c              |   88 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c            |  240 ++--
 drivers/net/wireless/iwlwifi/mvm/sta.c             |   12 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c              |   16 +-
 drivers/net/wireless/iwlwifi/mvm/utils.c           |   49 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c            |    5 +-
 drivers/net/wireless/iwlwifi/pcie/internal.h       |    2 +
 drivers/net/wireless/iwlwifi/pcie/rx.c             |    2 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |  143 +-
 drivers/net/wireless/mwifiex/11n.c                 |   51 +-
 drivers/net/wireless/mwifiex/11n.h                 |   14 +
 drivers/net/wireless/mwifiex/11n_rxreorder.c       |  144 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |   18 +-
 drivers/net/wireless/mwifiex/cmdevt.c              |    1 +
 drivers/net/wireless/mwifiex/fw.h                  |    8 +
 drivers/net/wireless/mwifiex/ioctl.h               |    1 +
 drivers/net/wireless/mwifiex/main.h                |    7 +-
 drivers/net/wireless/mwifiex/pcie.c                |   26 +
 drivers/net/wireless/mwifiex/pcie.h                |    2 +
 drivers/net/wireless/mwifiex/sta_cmd.c             |   14 +
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |    9 +
 drivers/net/wireless/mwifiex/sta_rx.c              |   21 +-
 drivers/net/wireless/mwifiex/uap_cmd.c             |   20 +
 drivers/net/wireless/mwifiex/uap_event.c           |    6 +
 drivers/net/wireless/mwifiex/uap_txrx.c            |   22 +-
 drivers/net/wireless/mwifiex/wmm.c                 |   37 +-
 drivers/net/wireless/p54/p54usb.c                  |    4 +
 drivers/net/wireless/rsi/Kconfig                   |   30 +
 drivers/net/wireless/rsi/Makefile                  |   12 +
 drivers/net/wireless/rsi/rsi_91x_core.c            |  342 +++++
 drivers/net/wireless/rsi/rsi_91x_debugfs.c         |  339 +++++
 drivers/net/wireless/rsi/rsi_91x_mac80211.c        | 1008 ++++++++++++++
 drivers/net/wireless/rsi/rsi_91x_main.c            |  295 +++++
 drivers/net/wireless/rsi/rsi_91x_mgmt.c            | 1303 ++++++++++++++++=
+++
 drivers/net/wireless/rsi/rsi_91x_pkt.c             |  196 +++
 drivers/net/wireless/rsi/rsi_91x_sdio.c            |  850 ++++++++++++
 drivers/net/wireless/rsi/rsi_91x_sdio_ops.c        |  566 ++++++++
 drivers/net/wireless/rsi/rsi_91x_usb.c             |  575 ++++++++
 drivers/net/wireless/rsi/rsi_91x_usb_ops.c         |  177 +++
 drivers/net/wireless/rsi/rsi_boot_params.h         |  126 ++
 drivers/net/wireless/rsi/rsi_common.h              |   87 ++
 drivers/net/wireless/rsi/rsi_debugfs.h             |   48 +
 drivers/net/wireless/rsi/rsi_main.h                |  218 ++++
 drivers/net/wireless/rsi/rsi_mgmt.h                |  285 ++++
 drivers/net/wireless/rsi/rsi_sdio.h                |  129 ++
 drivers/net/wireless/rsi/rsi_usb.h                 |   68 +
 drivers/net/wireless/rtl818x/rtl8180/dev.c         |  293 +++--
 drivers/net/wireless/rtl818x/rtl8180/rtl8180.h     |   10 +-
 drivers/net/wireless/rtl818x/rtl8180/rtl8225.c     |   22 -
 drivers/net/wireless/rtl818x/rtl818x.h             |    1 -
 drivers/nfc/Kconfig                                |   12 +
 drivers/nfc/Makefile                               |    1 +
 drivers/nfc/pn533.c                                |   28 +-
 drivers/nfc/pn544/i2c.c                            |  194 ++-
 drivers/nfc/pn544/pn544.c                          |    2 +-
 drivers/nfc/pn544/pn544.h                          |    3 +-
 drivers/nfc/port100.c                              |   25 +-
 drivers/nfc/trf7970a.c                             | 1370 ++++++++++++++++=
++++
 include/linux/ieee80211.h                          |    4 +
 include/linux/mmc/sdio_ids.h                       |    1 +
 include/net/bluetooth/hci_core.h                   |   11 +-
 include/net/bluetooth/mgmt.h                       |   12 +
 include/net/cfg80211.h                             |   23 +-
 include/net/mac80211.h                             |    6 +-
 include/net/nfc/digital.h                          |    7 +
 include/net/nfc/nfc.h                              |    3 +
 include/net/regulatory.h                           |   21 +-
 include/uapi/linux/nfc.h                           |    9 +-
 include/uapi/linux/nl80211.h                       |    6 +
 net/bluetooth/6lowpan.h                            |   21 +
 net/bluetooth/Kconfig                              |    8 +-
 net/bluetooth/Makefile                             |    3 +-
 net/bluetooth/a2mp.c                               |   12 +-
 net/bluetooth/hci_conn.c                           |   37 +-
 net/bluetooth/hci_core.c                           |   14 +-
 net/bluetooth/hci_event.c                          |   27 +-
 net/bluetooth/hci_sock.c                           |   16 +-
 net/bluetooth/l2cap_core.c                         |   90 +-
 net/bluetooth/l2cap_sock.c                         |    6 +-
 net/bluetooth/mgmt.c                               |   83 +-
 net/bluetooth/rfcomm/core.c                        |    4 +-
 net/bluetooth/sco.c                                |   10 +-
 net/bluetooth/smp.c                                |  208 ++-
 net/bluetooth/smp.h                                |    4 +-
 net/mac80211/cfg.c                                 |  121 +-
 net/mac80211/ibss.c                                |   12 +-
 net/mac80211/ieee80211_i.h                         |    1 +
 net/mac80211/mlme.c                                |   70 +-
 net/mac80211/pm.c                                  |   14 +-
 net/mac80211/rx.c                                  |    3 +
 net/mac80211/scan.c                                |    6 +-
 net/mac80211/tx.c                                  |    2 +-
 net/nfc/core.c                                     |   10 +-
 net/nfc/digital.h                                  |    6 +
 net/nfc/digital_core.c                             |   67 +-
 net/nfc/digital_technology.c                       |  247 +++-
 net/nfc/hci/llc.c                                  |    4 +-
 net/nfc/llcp_core.c                                |   16 +-
 net/nfc/nci/core.c                                 |    3 +-
 net/nfc/nci/spi.c                                  |    3 +-
 net/nfc/netlink.c                                  |    8 +
 net/wireless/ap.c                                  |    9 +-
 net/wireless/chan.c                                |   56 +
 net/wireless/core.c                                |    2 +-
 net/wireless/core.h                                |   10 +-
 net/wireless/genregdb.awk                          |    8 +-
 net/wireless/ibss.c                                |    8 +-
 net/wireless/mlme.c                                |    2 +-
 net/wireless/nl80211.c                             |   24 +-
 net/wireless/reg.c                                 |   86 +-
 net/wireless/reg.h                                 |    1 -
 net/wireless/scan.c                                |   31 +-
 net/wireless/sme.c                                 |    1 -
 net/wireless/util.c                                |    5 +-
 net/wireless/wext-sme.c                            |    2 +-
 215 files changed, 13523 insertions(+), 2758 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/nfc/trf7970a.txt
 create mode 100644 drivers/net/wireless/ath/ath9k/common-beacon.c
 create mode 100644 drivers/net/wireless/ath/ath9k/common-beacon.h
 rename drivers/net/wireless/iwlwifi/mvm/{bt-coex.c =3D> coex.c} (70%)
 rename drivers/net/wireless/iwlwifi/mvm/{fw-api-bt-coex.h =3D> fw-api-coex=
=2Eh} (99%)
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/fw-error-dump.h
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/offloading.c
 create mode 100644 drivers/net/wireless/rsi/Kconfig
 create mode 100644 drivers/net/wireless/rsi/Makefile
 create mode 100644 drivers/net/wireless/rsi/rsi_91x_core.c
 create mode 100644 drivers/net/wireless/rsi/rsi_91x_debugfs.c
 create mode 100644 drivers/net/wireless/rsi/rsi_91x_mac80211.c
 create mode 100644 drivers/net/wireless/rsi/rsi_91x_main.c
 create mode 100644 drivers/net/wireless/rsi/rsi_91x_mgmt.c
 create mode 100644 drivers/net/wireless/rsi/rsi_91x_pkt.c
 create mode 100644 drivers/net/wireless/rsi/rsi_91x_sdio.c
 create mode 100644 drivers/net/wireless/rsi/rsi_91x_sdio_ops.c
 create mode 100644 drivers/net/wireless/rsi/rsi_91x_usb.c
 create mode 100644 drivers/net/wireless/rsi/rsi_91x_usb_ops.c
 create mode 100644 drivers/net/wireless/rsi/rsi_boot_params.h
 create mode 100644 drivers/net/wireless/rsi/rsi_common.h
 create mode 100644 drivers/net/wireless/rsi/rsi_debugfs.h
 create mode 100644 drivers/net/wireless/rsi/rsi_main.h
 create mode 100644 drivers/net/wireless/rsi/rsi_mgmt.h
 create mode 100644 drivers/net/wireless/rsi/rsi_sdio.h
 create mode 100644 drivers/net/wireless/rsi/rsi_usb.h
 create mode 100644 drivers/nfc/trf7970a.c
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--ZGiS0Q5IWpPtfppv
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTLInFAAoJEJctW/TcYTgGthAP/At1YGqEFYyviIbvtD2uyKR4
KTkNg/LPESum2uvGSP9UwA0SbBRh2SQ5/O+xGHxvt4MzunDGzc3NzhvA1SYWt2sH
kjxMbRcq+rYp5F2ctrDETF8yKFN14D/DwW16MlBnp6863XoiLj2YelY3g4KxYgBZ
I0jvIRwGwP9Q6RwXj22Gz65+5rTZGBVt/KO3FJFvChWyswMGrfpzKDuFFvTA840r
uSfz7aCpb3t/t393hg1FXwx4Iiaf8ZSYMAqv6WutBfWsyMqw04Fn9sQ7SS1eeh22
SiqqBAU66todFmZKyk2cDqbWWrEKmrcR+mCpNYUKL9V0PKaLeNAmyggYJf5QtDZk
c6Tur3sf/vEachAaBzwHQzq8Gsbgo3R/7XblSaaqYDINglYk30NljxG54nYhY2/p
KvsZTySfNopNfe84OYWQAHSj2DsNekHRXOR9HHhNfYqscVaBRjDhyTSYhuA3/vMM
NTdpSiMCQvgWKR9UAyqpf3yz6OpCJb/l4uAiYpdL+BPKuwpyiV2NRU2tDyobBP6t
iLfMHeZbLWiDURu9l1ImksUdg/mtyNM9JW5y2NuuEgFtNr/lr9D0nfvlv3swGs/D
7TVhkYFMr5B1l2o0e7ShNsx/7UbQo+G4tYehwgommHpA+BkK7ffUNPRp4yMKpJG6
fsurXq1dWpIwSpiPdYsq
=tGeP
-----END PGP SIGNATURE-----

--ZGiS0Q5IWpPtfppv--
