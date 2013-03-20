From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2013-03-20
Date: Wed, 20 Mar 2013 16:10:41 -0400
Message-ID: <20130320201040.GA8895@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gKMricLos+KVdGMg"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46118 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756069Ab3CTUPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 16:15:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--gKMricLos+KVdGMg
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

This is a big pull request for new features intended for the 3.10
stream...

Regarding mac80211, Johannes says:

"First, I merged mac80211/master to avoid some conflicts. This brings in
a bunch of fixes you're already familiar with. For real -next material,
I have a whole bunch of minstrel work, minstrel_ht from Felix and legacy
minstrel from Thomas (Huehn). The other Thomas (Pedersen) did a number
of changes in mesh to allow userspace peering management even when the
mesh isn't secured. Stanislaw changes suspend/resume to always
disconnect the networks. This is typically already done by
network-manager so won't make a huge difference for most users, but
fixes a number problems, particularly with USB drivers that can easily
disconnect while suspended. Ilan has a small change to allow mac80211
drivers to differentiate remain-on-channel reasons, and Jouni extends
nl80211 to allow fast roaming with full-MAC devices. I have a fairly
large number of patches as well, many of them fairly simple cleanups,
but also allowing split wiphy dumps and adding back the full wiphy
information in nl80211, station entry change checking and more VHT work
including VHT capability overrides (mostly for testing purposes)."

And for iwlwifi, Johannes says:

"Here, I also merged iwlwifi-fixes to avoid conflicts, and otherwise have
various cleanups and improvements on the MVM driver, along with a few
throughout the driver. Other than Bluetooth Coexistence from Emmanuel
there's no over-arching theme, so listing them would pretty much
reproduce the shortlog."

Regarding NFC, Samuel says:

"The 2 features we have with this one are:

- An LLCP Service Name Lookup (SNL) netlink interface for querying LLCP
  service availability from user space.
  Along the way, Thierry also improved the existing SNL interface for
  aggregating SNL responses.

- An initial LLCP socket options implementation, for setting the Receive
  Window (RW) and the Maximum Information Unit Extension (MIUX) per socket.
  This is need for the LLCP validation tests.

We also have a microread MEI build failure here: I am not sending this one =
to
3.9 because the MEI bus code is not there yet, so it won't break for anyone
else than me."

And for ath6kl, Kalle says:

"I added tracing support to ath6kl, along with a new Kconfig option. Now
there's also a workaround to reset USB devices when the firmware upload
fails, this happened when host was warm rebooted. There are also quite a
few small fixes or cleanup."

On top of all that, there is the usual bundle of driver updates
with new features, new hardware support and the like mixed-in.
The ath9k, b43, brcmfmac, mwifiex, rt2800, and wil6210 drivers
are all well-represented, and a few other drivers are hit as well.
I also pulled-in the wireless fixes tree in order to resolve some
pending merge conflicts.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 4c1d8d0617a39c8325a7c2fd80ac14bf40fd8cc6:

  net: fix psock_fanout selftest bind error message (2013-03-20 13:42:41 -0=
400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 5470b462c3f0c6fa980c320968a165bd0f34ca8d:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2013-03-20 15:24:57 -0400)

----------------------------------------------------------------

Amitkumar Karwar (3):
      mwifiex: shorten the host sleep configuration macro names
      mwifiex: add "ethtool wol" command support
      mwifiex: add WOWLAN support

Amnon Paz (1):
      iwlwifi: fix indirect write bug

Andrei Epure (2):
      wireless:rtlwifi: replaced kmalloc+memcpy with kmemdup
      ath: changed kmalloc to kmemdup

Arend van Spriel (11):
      brcmfmac: introduce tracepoints for message logging
      brcmfmac: make debug module parameter more clear
      brcmfmac: cleanup module information macros
      brcmfmac: remove null-pointer check in .sched_scan_start() callback
      brcmfmac: increase required skbuff headroom for firmware signalling
      brcmutil: add macros for setting bitfields using mask/shift operations
      brcmfmac: add support for TLV based firmware signalling
      brcmfmac: release transmit packet in brcmf_txcomplete()
      brcmfmac: assure brcmf_txcomplete() is called in failure paths
      brcmutil: add dequeue function with filtering
      brcmfmac: add parameter to brcmf_proto_hdrpush() for data offset

Ashok Nagarajan (1):
      mwifiex: Trigger a card reset on reaching tx_timeout threshold

Avinash Patil (1):
      mwifiex: modify skb->truesize for PCIE Rx

Ben Greear (2):
      ath9k: Report txerr-filtered errors in debugfs.
      ath9k: Report rx-crc-errors in ethtool stats.

Beni Lev (2):
      iwlwifi: 7000: disable HT greenfield support
      iwlwifi: disable greenfield transmissions as a workaround

Bing Zhao (4):
      mwifiex: remove static forward declarations in pcie.c
      mwifiex: fix [-Wunused-function] warnings on pcie suspend/resume
      mwifiex: avoid [-Wmaybe-uninitialized] warnings in pcie.c
      mwifiex: fix potential null dereference 'mef_entry'

Bob Copeland (1):
      ath9k: simplify ATH_EP_RND

Chen Gang (1):
      drivers/net/wireless/ath/wil6210: Makefile, only -Werror when no -W* =
in EXTRA_CFLAGS

Christian Lamparter (1):
      carl9170: fix frame drop and WARN due to minstrel_ht change

Dan Carpenter (3):
      ray_cs: read past the end of the array
      ath6kl: small cleanup in ath6kl_htc_pipe_rx_complete()
      ath6kl: small cleanup in ath6kl_htc_pipe_rx_complete()

Dor Shaish (2):
      iwlwifi: mvm: don't use cts to self
      iwlwifi: mvm: Change NVM default section read size

Emmanuel Grumbach (15):
      iwlwifi: a few fixes in license
      iwlwifi: mvm: respect disable Tx AGG parameter
      iwlwifi: mvm: free AGG queue when we STA is removed
      iwlwifi: mvm: support IEEE80211_AMPDU_TX_STOP_FLUSH
      iwlwifi: dvm: pad iwl_compressed_ba_resp
      iwlwifi: make device configuration bus agnostic
      iwlwifi: mvm: add CARD_STATE_NOTIFICATION to the cmd strings
      iwlwifi: mvm: add BT Coex FW API
      iwlwifi: mvm: begin basic BT-Coex implementation
      iwlwifi: mvm: handle BT-coex notification
      iwlwifi: mvm: update SMPS when BT gets active
      iwlwifi: mvm: export last bt_notif through debugfs
      iwlwifi: mvm: update firmware API - MAC ID in RX
      iwlwifi: move firmware restart debugfs hook to op_mode
      iwlwifi: mvm: the SCD byte count is a TLV flag

Eytan Lifshitz (1):
      iwlwifi: mvm: advertise VHT capabilities

Felix Fietkau (7):
      ieee80211: mark 802.11 related structs as being 2-byte aligned
      mac80211/minstrel_ht: improve accuracy of throughput metric at high d=
ata rates
      mac80211/minstrel_ht: improve max_prob_rate selection
      minstrel_ht: increase sampling frequency
      mac80211/minstrel_ht: increase sampling frequency of some slower rates
      mac80211/minstrel_ht: fix spacing between sample attempts
      mac80211/minstrel_ht: disable multiple consecutive sample attempts

Hauke Mehrtens (2):
      ssb: fix unaligned access to mac address
      brcmsmac: export firmware version to ethtool

Helmut Schaa (2):
      rt2x00: Revert "rt2x00: remove unused argument"
      rt2x00: Fix tx status reporting for reordered frames in rt2800pci

Ilan Peer (3):
      mac80211: Allow drivers to differentiate between ROC types
      iwlwifi: mvm: Update MAC context filter flags
      iwlwifi: mvm: Add support for additional addresses

Jiri Slaby (1):
      ath5k: cleanup channel to eprom_mode function

Joe Perches (2):
      ssb: pci: Standardize a function to get mac address
      ssb: Convert ssb_printk to ssb_<level>

Johannes Berg (36):
      Merge remote-tracking branch 'mac80211/master' into HEAD
      cfg80211: clean up mesh plink station change API
      cfg80211: constify station parameter pointers
      cfg80211: clean up station WME attribute parsing
      cfg80211: unify station WME parsing
      cfg80211: comprehensively check station changes
      mac80211: clarify alignment comment
      nl80211: allow splitting wiphy information in dumps
      nl80211: conditionally add back radar information
      nl80211: conditionally add back TCP WoWLAN information
      wireless: move sequence number arithmetic to ieee80211.h
      nl80211: re-add channel width and extended capa advertising
      cfg80211: move exported event functions into nl80211
      wireless: remove unused VHT MCS defines
      cfg80211: add ability to override VHT capabilities
      mac80211: support VHT capability overrides
      cfg80211: refactor association parameters
      cfg80211: prohibit zero keepalive interval
      mac80211: remove IEEE80211_KEY_FLAG_WMM_STA
      mac80211: defer tailroom counter manipulation when roaming
      mac80211: flush keys when stopping AP
      mac80211: simplify AP interface stop
      mac80211: don't apply HT overrides to TDLS peers
      mac80211: fix HT capability overrides for AP station
      mac80211: restrict peer's VHT capabilities to own
      mac80211: add VHT capabilities station debugfs file
      cfg80211: enable TDLS on P2P client interfaces
      regulatory: allow VHT channels in world roaming
      Merge remote-tracking branch 'iwlwifi-fixes/master' into HEAD
      iwlwifi: support DSSS/CCK mode in 40 MHz
      iwlwifi: use __get_str in tracing
      iwlwifi: mvm: implement remote wake
      iwlwifi: mvm: set up initial SMPS/NSS station info
      iwlwifi: mvm: don't read system time when modifying AP/GO MAC
      iwlwifi: allow selecting only MVM driver
      iwlwifi: export symbols only conditionally

John W. Linville (6):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge tag 'nfc-next-3.10-1' of git://git.kernel.org/.../sameo/nfc-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge tag 'for-linville-20130318' of git://github.com/kvalo/ath6kl
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Jonas Gorski (1):
      mwl8k: don't overwrite regulatory settings on fw reload

Jouni Malinen (1):
      cfg80211: Extend support for IEEE 802.11r Fast BSS Transition

Jussi Kivilinna (1):
      rndis_wlan: update email address

Kalle Valo (14):
      ath6kl: print firmware capabilities
      ath6kl: cleanup ath6kl_reset_device()
      ath6kl: fix usb related error handling and warnings
      ath6kl: cold reset target after host warm boot
      ath6kl: add tracing support and tracing points for wmi packets
      ath6kl: add tracing points for sdio transfers
      ath6kl: add tracing point for hif irqs
      ath6kl: adding tracing points for htc_mbox
      ath6kl: convert ath6kl_info/err/warn macros to real functions
      ath6kl: add tracing support to log functions
      ath6kl: add tracing support to debug message macros
      ath6kl: add an extra band check to ath6kl_wmi_beginscan_cmd()
      ath6kl: remove false check from ath6kl_rx()
      ath6kl: fix size_t printf warnings

Larry Finger (1):
      ssb: pci: Fix flipping of MAC address

Michal Pecio (1):
      orinoco_usb: don't release nonexistent firmware

Mohammed Shafi Shajakhan (5):
      ath6kl: Cosmetic change in checking for free vif slot
      ath6kl: Protect ath6kl_cfg80211_vif_cleanup using rtnl_locks
      ath6kl: Return error from ath6kl_bmi_done()
      ath6kl: Remove NETDEV_REGISTERED flag
      ath6kl: Fix a debugfs crash for USB devices

Myoungje Kim (1):
      ath6kl: Fix the byte alignment rule to avoid loss of bytes in a TCP s=
egment

Nishant Sarmukadam (2):
      mwl8k: Adding support for 8764 4x4 AP
      mwl8k: Load 8764 firmware image

Piotr Haber (1):
      brcmsmac: radio on led support

Rafa=C5=82 Mi=C5=82ecki (17):
      bcma: ignore extra GMAC cores on BCM4706
      bcma: implement disabling PLLs
      b43: define BCMA wireless specific PLLs
      b43: HT-PHY: make it BCMA-only
      b43: HT-PHY: rename AFE defines
      b43: HT-PHY: add classifier control function
      b43: HT-PHY: move TX fix to the separated function
      b43: HT-PHY: implement spurious tone avoidance
      b43: HT-PHY: implement MAC reclocking
      b43: HT-PHY: implement CCA reset
      b43: HT-PHY: implement PA override
      b43: HT-PHY: implement controlling TX power control
      b43: HT-PHY: implement stopping sample tone playback
      b43: HT-PHY: implement playing sample tone
      b43: HT-PHY: implement RSSI polling
      b43: HT-PHY: setup TX power control
      b43: HT-PHY: enable basic TX power setup

Sachin Kamat (1):
      net: rfkill: Fix sparse warning in rfkill-regulator.c

Samuel Ortiz (5):
      NFC: microread: Fix MEI build failure
      NFC: llcp: Rename socket rw and miu fields
      NFC: llcp: Implement socket options
      NFC: llcp: Use socket specific link parameters before the local ones
      NFC: llcp: Remove redundant printk

Stanislaw Gruszka (32):
      mac80211: remove napi
      cfg80211/mac80211: disconnect on suspend
      mac80211: cleanup generic suspend/resume procedures
      mac80211: cleanup suspend/resume on managed mode
      mac80211: cleanup suspend/resume on ibss mode
      mac80211: cleanup suspend/resume on mesh mode
      mac80211: merge reconfig assign chanctx code
      rt2800: do not crash if spec->channels is NULL
      rt2800: 5592: early defines
      rt2800: 5592: add channels table
      rt2800: 5592: channel config stub
      rt2800: 5592: MAC registers initalization
      rt2800: 5592: BBP registers initialization
      rt2800: 5592: common BBP initialization
      rt2800: 5592: RF early registers initialization
      rt2800: 5592: initalize RF_R27 on older revisions
      rt2800: 5592: initalize BBP_R103 register on new revisions
      rt2800: 5592: initialize BBP_R138 register
      rt2800: 5592: initialize RF_38/39/30 registers
      rt2800: 5592: init frequency calibration
      rt2800: 5592: setup LDO_CFG0 when configuring channel
      rt2800: 5592: enable rf init
      rt2800: 5592: more channel switch registers settings (BBP & GLRT)
      rt2800: 5592: add iq calibration
      rt2800: rearrange bbp/rfcsr initialization
      rt2800: add write_with_rx_chain function
      rt2800: 5592: add AGC init
      rt2800: 5592: add chip specific vgc calculations
      rt2800: 5592: TXWI & RXWI descriptors size
      rt2800: 5592: add Kconfig
      rt2800: 5592: iq calibration for 5GHz
      rt2800: 5592: add more USB devices IDs

Stephen Hemminger (1):
      iwlegacy: fix sparse warnings

Sujith Manoharan (4):
      ath9k_hw: Remove CHANNEL_CW_INT
      ath9k_hw: Use helper functions to simplify HW reset
      ath9k_hw: Update initvals for AR9462
      ath9k_hw: Fix fixed antenna for AR9462

Syam Sidhardhan (1):
      rndis_wlan: Remove redundant NULL check before kfree

Thierry Escande (4):
      NFC: Add missing type policies for netlink attributes
      NFC: llcp: Service Name Lookup SDRES aggregation
      NFC: llcp: Service Name Lookup netlink interface
      NFC: llcp: Add cleanup support for unreplied SNL requests

Thomas Huehn (7):
      mac80211: merge EWMA calculation of minstrel_ht and minstrel
      mac80211: merge value scaling macros of minstrel_ht and minstrel
      mac80211: add documentation and verbose variable names in
      mac80211: extend minstrel's rate sampling to avoid unsampled rates
      mac80211: add lowest rate into minstrel's random rate sampling table
      mac80211: treat minstrel success probabilities below 10% as implausib=
le
      mac80211: improve minstrels rate sorting by means of throughput & pro=
bability

Thomas Pedersen (6):
      nl80211: explicit userspace MPM
      cfg80211: rename mesh station types
      mac80211: support userspace MPM
      nl80211: user_mpm overrides auto_open_plinks
      mac80211: disallow changing auto_open_plinks
      mac80211: init mesh timer for user authed STAs

Tim Gardner (1):
      rt2x00: rt2x00pci_regbusy_read() - only print register access failure=
 once

Vladimir Kondratiev (14):
      wil6210: Remove local implementation of dynamic hexdump
      wil6210: handle linkup/linkdown WMI events
      wil6210: handle WMI_BA_STATUS_EVENTID
      wil6210: do not set IE's for beacon
      wil6210: Fix garbage sent to the FW with wmi_set_ie()
      wil6210: refactor connect_worker
      wil6210: use cfg80211_inform_bss_frame()
      wil6210: report all received mgmt frames
      wil6210: fix FW error notification
      wil6210: use WLAN_CAPABILITY_DMG_TYPE_MASK
      wil6210: headers clean-up
      wil6210: new SW reset
      wil6210: sync with new firmware
      wil6210: temperature measurement

W. Trevor King (1):
      b43: Fix 'me' -> 'be' typo in Kconfig

Wei Yongjun (3):
      iwlwifi: convert to use simple_open()
      wil6210: convert to use simple_open()
      wil6210: remove unused including <linux/version.h>

Yogesh Ashok Powar (1):
      mwifiex: cleanup VHT cap

 MAINTAINERS                                        |    2 +-
 drivers/bcma/core.c                                |    8 +-
 drivers/bcma/main.c                                |    5 +
 drivers/net/wireless/ath/ath5k/ath5k.h             |    3 +-
 drivers/net/wireless/ath/ath5k/eeprom.c            |    6 +-
 drivers/net/wireless/ath/ath5k/eeprom.h            |    3 -
 drivers/net/wireless/ath/ath5k/phy.c               |   20 +-
 drivers/net/wireless/ath/ath5k/reset.c             |    4 +-
 drivers/net/wireless/ath/ath6kl/Kconfig            |    9 +
 drivers/net/wireless/ath/ath6kl/Makefile           |    5 +
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |   15 +-
 drivers/net/wireless/ath/ath6kl/core.h             |    3 -
 drivers/net/wireless/ath/ath6kl/debug.c            |   72 +-
 drivers/net/wireless/ath/ath6kl/debug.h            |   11 +-
 drivers/net/wireless/ath/ath6kl/hif.c              |    3 +
 drivers/net/wireless/ath/ath6kl/htc_mbox.c         |   21 +-
 drivers/net/wireless/ath/ath6kl/htc_pipe.c         |   15 +-
 drivers/net/wireless/ath/ath6kl/init.c             |  116 +-
 drivers/net/wireless/ath/ath6kl/main.c             |   41 +-
 drivers/net/wireless/ath/ath6kl/sdio.c             |   16 +-
 drivers/net/wireless/ath/ath6kl/target.h           |    2 +-
 drivers/net/wireless/ath/ath6kl/trace.c            |   23 +
 drivers/net/wireless/ath/ath6kl/trace.h            |  332 ++++
 drivers/net/wireless/ath/ath6kl/txrx.c             |    5 +-
 drivers/net/wireless/ath/ath6kl/usb.c              |   38 +-
 drivers/net/wireless/ath/ath6kl/wmi.c              |    6 +
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |   17 +
 .../net/wireless/ath/ath9k/ar9462_2p0_initvals.h   |   49 +-
 drivers/net/wireless/ath/ath9k/calib.c             |    4 +-
 drivers/net/wireless/ath/ath9k/common.h            |    2 +-
 drivers/net/wireless/ath/ath9k/debug.c             |    5 +
 drivers/net/wireless/ath/ath9k/debug.h             |    2 +
 drivers/net/wireless/ath/ath9k/hw.c                |  188 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    1 -
 drivers/net/wireless/ath/carl9170/tx.c             |   69 +-
 drivers/net/wireless/ath/wil6210/Makefile          |    4 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |   33 +-
 drivers/net/wireless/ath/wil6210/dbg_hexdump.h     |   20 -
 drivers/net/wireless/ath/wil6210/debugfs.c         |   58 +-
 drivers/net/wireless/ath/wil6210/interrupt.c       |   25 +-
 drivers/net/wireless/ath/wil6210/main.c            |   60 +-
 drivers/net/wireless/ath/wil6210/netdev.c          |    3 -
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |    3 -
 drivers/net/wireless/ath/wil6210/txrx.c            |    5 +-
 drivers/net/wireless/ath/wil6210/wil6210.h         |   17 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |  154 +-
 drivers/net/wireless/ath/wil6210/wmi.h             |  363 +++-
 drivers/net/wireless/b43/Kconfig                   |    6 +-
 drivers/net/wireless/b43/b43.h                     |    6 +
 drivers/net/wireless/b43/main.c                    |    7 +-
 drivers/net/wireless/b43/phy_ht.c                  |  610 ++++++-
 drivers/net/wireless/b43/phy_ht.h                  |   77 +-
 drivers/net/wireless/brcm80211/Kconfig             |    5 +-
 drivers/net/wireless/brcm80211/brcmfmac/Makefile   |    3 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |    7 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h  |    2 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_cdc.c  |   30 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_common.c   |   33 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.c  |   42 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h  |   34 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |   39 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_proto.h    |    2 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |   28 +-
 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c |  382 ++++
 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.h |   25 +
 .../net/wireless/brcm80211/brcmfmac/tracepoint.c   |   22 +
 .../net/wireless/brcm80211/brcmfmac/tracepoint.h   |   87 +
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |   37 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |    6 +-
 drivers/net/wireless/brcm80211/brcmsmac/Makefile   |    4 +
 drivers/net/wireless/brcm80211/brcmsmac/led.c      |  126 ++
 drivers/net/wireless/brcm80211/brcmsmac/led.h      |   36 +
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |    4 +
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.h  |    4 +
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |   11 +-
 drivers/net/wireless/brcm80211/brcmutil/utils.c    |   25 +
 .../net/wireless/brcm80211/include/brcmu_utils.h   |   27 +
 drivers/net/wireless/iwlegacy/3945-mac.c           |    2 +-
 drivers/net/wireless/iwlegacy/3945.h               |    4 -
 drivers/net/wireless/iwlegacy/4965-mac.c           |   29 +-
 drivers/net/wireless/iwlegacy/common.c             |    2 +-
 drivers/net/wireless/iwlegacy/common.h             |    4 -
 drivers/net/wireless/iwlwifi/Kconfig               |   11 +-
 drivers/net/wireless/iwlwifi/Makefile              |    3 +-
 drivers/net/wireless/iwlwifi/dvm/agn.h             |    2 +-
 drivers/net/wireless/iwlwifi/dvm/calib.c           |    2 +-
 drivers/net/wireless/iwlwifi/dvm/calib.h           |    2 +-
 drivers/net/wireless/iwlwifi/dvm/commands.h        |    3 +-
 drivers/net/wireless/iwlwifi/dvm/debugfs.c         |   26 +-
 drivers/net/wireless/iwlwifi/dvm/lib.c             |    2 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |    3 +-
 drivers/net/wireless/iwlwifi/dvm/scan.c            |    2 +-
 drivers/net/wireless/iwlwifi/dvm/testmode.c        |    2 +-
 drivers/net/wireless/iwlwifi/dvm/tx.c              |   13 +-
 drivers/net/wireless/iwlwifi/dvm/ucode.c           |    2 +-
 .../wireless/iwlwifi/{pcie/1000.c =3D> iwl-1000.c}   |    1 -
 .../wireless/iwlwifi/{pcie/2000.c =3D> iwl-2000.c}   |    1 -
 .../wireless/iwlwifi/{pcie/5000.c =3D> iwl-5000.c}   |    1 -
 .../wireless/iwlwifi/{pcie/6000.c =3D> iwl-6000.c}   |    1 -
 .../wireless/iwlwifi/{pcie/7000.c =3D> iwl-7000.c}   |   63 +-
 drivers/net/wireless/iwlwifi/iwl-agn-hw.h          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-config.h          |   49 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h             |    2 +-
 drivers/net/wireless/iwlwifi/iwl-debug.c           |   13 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.h        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c             |   14 +-
 drivers/net/wireless/iwlwifi/iwl-drv.h             |   17 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c    |    9 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.h    |    2 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom-read.c     |    5 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom-read.h     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-fh.h              |    2 +-
 drivers/net/wireless/iwlwifi/iwl-fw-file.h         |    2 +-
 drivers/net/wireless/iwlwifi/iwl-fw.h              |    4 +-
 drivers/net/wireless/iwlwifi/iwl-io.c              |   19 +-
 drivers/net/wireless/iwlwifi/iwl-modparams.h       |    4 +-
 drivers/net/wireless/iwlwifi/iwl-notif-wait.c      |   15 +-
 drivers/net/wireless/iwlwifi/iwl-notif-wait.h      |    2 +-
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c       |   51 +-
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-op-mode.h         |    2 +-
 drivers/net/wireless/iwlwifi/iwl-phy-db.c          |   11 +-
 drivers/net/wireless/iwlwifi/iwl-phy-db.h          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-test.c            |   11 +-
 drivers/net/wireless/iwlwifi/iwl-test.h            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-testmode.h        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |    5 +-
 drivers/net/wireless/iwlwifi/mvm/Makefile          |    2 +-
 drivers/net/wireless/iwlwifi/mvm/binding.c         |    2 +-
 drivers/net/wireless/iwlwifi/mvm/bt-coex.c         |  347 ++++
 drivers/net/wireless/iwlwifi/mvm/d3.c              |  260 ++-
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |  138 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-bt-coex.h  |  319 ++++
 drivers/net/wireless/iwlwifi/mvm/fw-api-d3.h       |   53 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-mac.h      |    2 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-power.h    |    2 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-rs.h       |    2 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h     |    2 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-sta.h      |    2 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-tx.h       |    2 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |   12 +-
 drivers/net/wireless/iwlwifi/mvm/fw.c              |   14 +-
 drivers/net/wireless/iwlwifi/mvm/led.c             |    2 +-
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |   45 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |   57 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |   17 +-
 drivers/net/wireless/iwlwifi/mvm/nvm.c             |   11 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c             |   12 +-
 drivers/net/wireless/iwlwifi/mvm/phy-ctxt.c        |    2 +-
 drivers/net/wireless/iwlwifi/mvm/power.c           |    2 +-
 drivers/net/wireless/iwlwifi/mvm/quota.c           |    2 +-
 drivers/net/wireless/iwlwifi/mvm/rs.c              |   14 +-
 drivers/net/wireless/iwlwifi/mvm/rx.c              |    2 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c            |    2 +-
 drivers/net/wireless/iwlwifi/mvm/sta.c             |   91 +-
 drivers/net/wireless/iwlwifi/mvm/sta.h             |    4 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.c      |    2 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.h      |    2 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c              |    4 +-
 drivers/net/wireless/iwlwifi/mvm/utils.c           |    2 +-
 drivers/net/wireless/iwlwifi/pcie/cfg.h            |  115 --
 drivers/net/wireless/iwlwifi/pcie/drv.c            |    4 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |   25 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c             |    2 +-
 drivers/net/wireless/mac80211_hwsim.c              |    3 +-
 drivers/net/wireless/mwifiex/Makefile              |    1 +
 drivers/net/wireless/mwifiex/cfg80211.c            |  218 ++-
 drivers/net/wireless/mwifiex/cmdevt.c              |    2 +-
 drivers/net/wireless/mwifiex/ethtool.c             |   70 +
 drivers/net/wireless/mwifiex/fw.h                  |   72 +-
 drivers/net/wireless/mwifiex/init.c                |    6 +-
 drivers/net/wireless/mwifiex/ioctl.h               |   23 +
 drivers/net/wireless/mwifiex/main.c                |   15 +-
 drivers/net/wireless/mwifiex/main.h                |    9 +
 drivers/net/wireless/mwifiex/pcie.c                |  156 +-
 drivers/net/wireless/mwifiex/sta_cmd.c             |   79 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |    2 +
 drivers/net/wireless/mwifiex/sta_ioctl.c           |   10 +-
 drivers/net/wireless/mwifiex/txrx.c                |    2 +
 drivers/net/wireless/mwifiex/util.c                |    5 +-
 drivers/net/wireless/mwl8k.c                       |  111 +-
 drivers/net/wireless/orinoco/orinoco_usb.c         |    2 +-
 drivers/net/wireless/ray_cs.c                      |    6 +-
 drivers/net/wireless/rndis_wlan.c                  |    5 +-
 drivers/net/wireless/rt2x00/Kconfig                |    7 +
 drivers/net/wireless/rt2x00/rt2800.h               |  103 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |  857 ++++++++-
 drivers/net/wireless/rt2x00/rt2800pci.c            |  116 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |   63 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |   10 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |   10 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h          |    9 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c            |   20 +-
 drivers/net/wireless/rtlwifi/usb.c                 |    3 +-
 drivers/net/wireless/rtlwifi/wifi.h                |    3 -
 drivers/net/wireless/ti/wlcore/main.c              |    3 +-
 drivers/nfc/microread/mei.c                        |    2 +-
 drivers/ssb/driver_chipcommon.c                    |    2 +-
 drivers/ssb/driver_chipcommon_pmu.c                |   41 +-
 drivers/ssb/driver_mipscore.c                      |   25 +-
 drivers/ssb/driver_pcicore.c                       |   15 +-
 drivers/ssb/embedded.c                             |    5 +-
 drivers/ssb/main.c                                 |   51 +-
 drivers/ssb/pci.c                                  |   97 +-
 drivers/ssb/pcmcia.c                               |   46 +-
 drivers/ssb/scan.c                                 |   31 +-
 drivers/ssb/sprom.c                                |    4 +-
 drivers/ssb/ssb_private.h                          |   19 +-
 include/linux/ieee80211.h                          |   52 +-
 include/linux/socket.h                             |    1 +
 include/linux/ssb/ssb.h                            |    6 +-
 include/net/cfg80211.h                             |  126 +-
 include/net/mac80211.h                             |   29 +-
 include/uapi/linux/nfc.h                           |   16 +
 include/uapi/linux/nl80211.h                       |  117 +-
 net/mac80211/cfg.c                                 |  151 +-
 net/mac80211/debugfs_sta.c                         |   31 +
 net/mac80211/driver-ops.h                          |    7 +-
 net/mac80211/ht.c                                  |   52 +-
 net/mac80211/ibss.c                                |   29 +-
 net/mac80211/ieee80211_i.h                         |   26 +-
 net/mac80211/iface.c                               |   14 +-
 net/mac80211/key.c                                 |  103 +-
 net/mac80211/key.h                                 |    5 +-
 net/mac80211/main.c                                |   55 +-
 net/mac80211/mesh.c                                |   59 +-
 net/mac80211/mesh.h                                |   12 -
 net/mac80211/mesh_plink.c                          |   37 +-
 net/mac80211/mlme.c                                |  100 +-
 net/mac80211/offchannel.c                          |    2 +-
 net/mac80211/pm.c                                  |  117 +-
 net/mac80211/rc80211_minstrel.c                    |  204 ++-
 net/mac80211/rc80211_minstrel.h                    |   31 +-
 net/mac80211/rc80211_minstrel_debugfs.c            |   12 +-
 net/mac80211/rc80211_minstrel_ht.c                 |   79 +-
 net/mac80211/rc80211_minstrel_ht.h                 |    6 +-
 net/mac80211/rx.c                                  |   61 +-
 net/mac80211/sta_info.c                            |   11 +-
 net/mac80211/sta_info.h                            |    2 -
 net/mac80211/trace.h                               |   11 +-
 net/mac80211/util.c                                |   73 +-
 net/mac80211/vht.c                                 |  212 ++-
 net/nfc/llcp/commands.c                            |  205 ++-
 net/nfc/llcp/llcp.c                                |  112 +-
 net/nfc/llcp/llcp.h                                |   36 +-
 net/nfc/llcp/sock.c                                |  130 +-
 net/nfc/netlink.c                                  |  172 ++
 net/nfc/nfc.h                                      |   14 +
 net/rfkill/rfkill-regulator.c                      |    2 +-
 net/wireless/ap.c                                  |   62 -
 net/wireless/core.c                                |   73 +-
 net/wireless/core.h                                |   22 +-
 net/wireless/mesh.c                                |   15 +-
 net/wireless/mlme.c                                |  230 +--
 net/wireless/nl80211.c                             | 1885 +++++++++++++---=
----
 net/wireless/nl80211.h                             |   68 -
 net/wireless/rdev-ops.h                            |   20 +-
 net/wireless/reg.c                                 |    6 +-
 net/wireless/sme.c                                 |   26 +-
 net/wireless/sysfs.c                               |   25 +-
 net/wireless/trace.h                               |   46 +
 263 files changed, 9534 insertions(+), 3414 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath6kl/trace.c
 create mode 100644 drivers/net/wireless/ath/ath6kl/trace.h
 delete mode 100644 drivers/net/wireless/ath/wil6210/dbg_hexdump.h
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.h
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/tracepoint.c
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/tracepoint.h
 create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/led.c
 create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/led.h
 rename drivers/net/wireless/iwlwifi/{pcie/1000.c =3D> iwl-1000.c} (99%)
 rename drivers/net/wireless/iwlwifi/{pcie/2000.c =3D> iwl-2000.c} (99%)
 rename drivers/net/wireless/iwlwifi/{pcie/5000.c =3D> iwl-5000.c} (99%)
 rename drivers/net/wireless/iwlwifi/{pcie/6000.c =3D> iwl-6000.c} (99%)
 rename drivers/net/wireless/iwlwifi/{pcie/7000.c =3D> iwl-7000.c} (58%)
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/bt-coex.c
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/fw-api-bt-coex.h
 delete mode 100644 drivers/net/wireless/iwlwifi/pcie/cfg.h
 create mode 100644 drivers/net/wireless/mwifiex/ethtool.c
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--gKMricLos+KVdGMg
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRShfAAAoJEJctW/TcYTgGdZQQAIVnKL6RssmBO7+Gh8RK+qtY
vKSWD0RVmecwYyieqtwHniLY8Es8VAdtgP15d/5waOcYGbnVTxCJmg/QSIvpqZ7D
2RjTIKDf9gylqIJqk5r2qnkj/HjZB/RkmvttUELi9fhZfFaJuV83I1MiQ1BobwHy
nWzTdq6uM5uH/EUSoRRbqtxqh3S5XNtiwAvuFa9sbYzDCFyjwHPFA3vJ6yXwsuZw
z6NuoWu4LzA3EOGS+OcnaWYebEntdMDi0TCdLqI8anrcJrM3B4VGZoPv0WBUdUok
bEcivtJ1Hlj3Ors+9EU+lMyON1ZCxFNMYAQCFWwQBTurvvGNaO0dc2Qv7DXyrFP5
8Uo1COcY4VhXzUXPgOr4jDi9fhLcNByAbDbVGelKrOMlgLtgjQ84EB5Vwkrg4kow
8X3GSzM7860vYCR1s//mW17rWiLn70XnokM024wESIl2D2yCbK01T0CKSSPHUupr
liO0v9eTOoKOHV38ZhPgulhQsKO3XwL9KCqd1Y/0ZiRYi2FHrroK04Ub4SWLyy9Q
z0QZYB0xx+0shwAOky0QrLw+BQjiFpGL6ao5XbvTwJwMBg0Na+3IMlUkSaY55Hua
eo3WUI8XVGmxAhq+uUA6UNZGF7bc2uTl99gmb3QyVYF/pEl49YKlMdWdIJ1yXTcp
n/KVvi/52yaCJFMoo3NM
=TSbQ
-----END PGP SIGNATURE-----

--gKMricLos+KVdGMg--
