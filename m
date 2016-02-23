From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211-next 2016-02-23
Date: Tue, 23 Feb 2016 15:45:55 +0100
Message-ID: <1456238756-9818-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:33175 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752429AbcBWOqD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 09:46:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Here's a (first, even? I didn't have much until before the conference..=
=2E)
pull request for net-next.

There's nothing out of the ordinary, I think, except that I have an ARM
Tegra patch in here. It's part of an rfkill series and needed to be mer=
ged
with those patches, it also has the relevant ACKs from Thierry and Arnd=
=2E

Let me know if there's any problem.

Thanks,
johannes



The following changes since commit 725da8dee445662beea77d3f42c3f4c79f7a=
7a0e:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-0=
1-13 00:22:13 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git=
 tags/mac80211-next-for-davem-2016-02-23

for you to fetch changes up to c4b29719e095c1aa42e1dec691d6178611c1096f=
:

  rfkill: Notify userspace of airplane-mode state changes (2016-02-23 1=
1:53:56 +0100)

----------------------------------------------------------------
Here's another round of updates for -next:
 * big A-MSDU RX performance improvement (avoid linearize of paged RX)
 * big rfkill changes: airplane mode indicator and cleanups
 * basic PBSS support in cfg80211
 * MU-MIMO action frame processing support
 * BlockAck reordering & duplicate detection offload support
 * various cleanups & little fixes

----------------------------------------------------------------
Arnd Bergmann (1):
      mac80211: avoid excessive stack usage in sta_info

Beni Lev (1):
      cfg80211: Add global RRM capability

Bjorn Andersson (1):
      mac80211: Make addr const in SET_IEEE80211_PERM_ADDR()

Bob Copeland (1):
      mac80211: mesh: drop constant field mean_chain_len

Eliad Peller (3):
      mac80211: move TKIP TX IVs to public part of key struct
      iwlwifi: mvm: move TX PN assignment for TKIP to the driver
      mac80211: remove ieee80211_get_key_tx_seq/ieee80211_set_key_tx_se=
q

Emmanuel Grumbach (1):
      mac80211: limit the A-MSDU Tx based on peer's capabilities

=46elix Fietkau (5):
      mac80211: move A-MSDU skb_linearize call to ieee80211_amsdu_to_80=
23s
      cfg80211: add function for 802.3 conversion with separate output =
buffer
      cfg80211: add support for non-linear skbs in ieee80211_amsdu_to_8=
023s
      cfg80211: fix faulty variable initialization in ieee80211_amsdu_t=
o_8023s
      cfg80211: reuse existing page fragments in A-MSDU rx

Geliang Tang (1):
      cfg80211/mac80211: use to_delayed_work

Grzegorz Bajorski (1):
      mac80211: allow drivers to report (non-)monitor frames

Heikki Krogerus (4):
      net: rfkill: add rfkill_find_type function
      net: rfkill: gpio: get the name and type from device property
      ARM: tegra: use build-in device properties with rfkill_gpio
      net: rfkill: gpio: remove rfkill_gpio_platform_data

Henning Rogge (3):
      mac80211: Remove MPP table entries with MPath
      mac80211: let unused MPP table entries timeout
      mac80211: Unify mesh and mpp path removal function

Ilan Peer (1):
      mac80211: Recalc min chandef when station is associated

Johannes Berg (8):
      cfg80211: remove CFG80211_REG_DEBUG
      mac80211: document status.freq restrictions
      mac80211: refactor HT/VHT to chandef code
      mac80211_hwsim: remove shadowing variable
      rfkill: disentangle polling pause and suspend
      mac80211: add RX_FLAG_MACTIME_PLCP_START
      mac80211: always print a message when disconnecting
      mac80211: change ieee80211_rx_reorder_ready() arguments

Jouni Malinen (1):
      mac80211: Interoperability workaround for 80+80 and 160 MHz chann=
els

Jo=C3=A3o Paulo Rechi Vita (14):
      rfkill: use variable instead of duplicating the expression
      rfkill: remove/inline __rfkill_set_hw_state
      rfkill: Remove obsolete "claim" sysfs interface
      rfkill: Update userspace API documentation
      rfkill: Improve documentation language
      rfkill: Remove extra blank line
      rfkill: Point to the correct deprecated doc location
      rfkill: Move "state" sysfs file back to stable
      rfkill: Factor rfkill_global_states[].cur assignments
      rfkill: Add documentation about LED triggers
      rfkill: Create "rfkill-airplane-mode" LED trigger
      rfkill: Use switch to demux userspace operations
      rfkill: Userspace control for airplane mode
      rfkill: Notify userspace of airplane-mode state changes

Lior David (1):
      cfg80211: basic support for PBSS network type

Lorenzo Bianconi (2):
      mac80211: fix wiphy supported_band access
      cfg80211: add radiotap VHT info to rtap_namespace_sizes

Michal Kazior (3):
      mac80211: fix txq queue related crashes
      mac80211: fix unnecessary frame drops in mesh fwding
      mac80211: expose txq queue depth and size to drivers

Ola Olsson (2):
      cfg80211: add more warnings for inconsistent ops
      cfg80211: Fix some linguistics in Kconfig

Sara Sharon (10):
      mac80211: process and save VHT MU-MIMO group frame
      mac80211: add flag for duplication check
      mac80211: pass RX aggregation window size to driver
      mac80211: pass block ack session timeout to to driver
      mac80211: support hw managing reorder logic
      mac80211: fix ibss scan parameters
      mac80211: add API to allow filtering frames in BA sessions
      mac80211: fix VHT MU-MIMO frame processing
      mac80211: provide interface to driver to set VHT MU-MIMO data
      mac80211: move MU_MIMO_OWNER flag to ieee80211_vif

Sudip Mukherjee (1):
      mac80211: fix memory leak

Sunil Shahu (1):
      mac80211: mesh_plink: remove redundant sta_info check

Sven Eckelmann (1):
      mac80211: Parse legacy and HT rate in injected frames

 Documentation/ABI/obsolete/sysfs-class-rfkill      |  29 --
 Documentation/ABI/removed/sysfs-class-rfkill       |  13 +
 Documentation/ABI/stable/sysfs-class-rfkill        |  27 +-
 Documentation/networking/mac80211-injection.txt    |  17 ++
 Documentation/rfkill.txt                           |  17 ++
 arch/arm/mach-tegra/board-paz00.c                  |  17 +-
 drivers/net/wireless/ath/ath10k/mac.c              |   7 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |   7 +-
 drivers/net/wireless/ath/ath9k/main.c              |   8 +-
 drivers/net/wireless/ath/carl9170/main.c           |   8 +-
 drivers/net/wireless/ath/wcn36xx/main.c            |   8 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |  10 +
 .../broadcom/brcm80211/brcmsmac/mac80211_if.c      |   8 +-
 drivers/net/wireless/intel/iwlegacy/4965-mac.c     |   8 +-
 drivers/net/wireless/intel/iwlegacy/4965.h         |   4 +-
 drivers/net/wireless/intel/iwlwifi/dvm/lib.c       |  20 +-
 drivers/net/wireless/intel/iwlwifi/dvm/mac80211.c  |   9 +-
 drivers/net/wireless/intel/iwlwifi/mvm/d3.c        |  15 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |  11 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c        |   2 +
 drivers/net/wireless/mac80211_hwsim.c              |  12 +-
 drivers/net/wireless/marvell/mwl8k.c               |  10 +-
 drivers/net/wireless/mediatek/mt7601u/main.c       |   8 +-
 drivers/net/wireless/ralink/rt2x00/rt2800lib.c     |   7 +-
 drivers/net/wireless/ralink/rt2x00/rt2800lib.h     |   4 +-
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.c   |   6 +-
 drivers/net/wireless/realtek/rtlwifi/core.c        |   8 +-
 drivers/net/wireless/rsi/rsi_91x_mac80211.c        |  19 +-
 drivers/net/wireless/st/cw1200/sta.c               |   4 +-
 drivers/net/wireless/st/cw1200/sta.h               |   4 +-
 drivers/net/wireless/ti/wlcore/main.c              |   8 +-
 drivers/staging/vt6655/rxtx.c                      |  12 +-
 drivers/staging/vt6656/rxtx.c                      |  12 +-
 include/linux/ieee80211.h                          |  26 ++
 include/linux/rfkill-gpio.h                        |  37 ---
 include/linux/rfkill.h                             |  18 +-
 include/net/cfg80211.h                             |   8 +
 include/net/mac80211.h                             | 198 ++++++++++---=
-
 include/uapi/linux/nl80211.h                       |  14 +
 include/uapi/linux/rfkill.h                        |   8 +
 net/mac80211/agg-rx.c                              |  50 +++-
 net/mac80211/agg-tx.c                              |  53 ++--
 net/mac80211/cfg.c                                 |  34 ++-
 net/mac80211/chan.c                                |   2 +-
 net/mac80211/debugfs.c                             |   1 +
 net/mac80211/debugfs_key.c                         |   5 +-
 net/mac80211/driver-ops.c                          |  10 +-
 net/mac80211/driver-ops.h                          |   4 +-
 net/mac80211/ht.c                                  |   5 +
 net/mac80211/ibss.c                                |  32 ++-
 net/mac80211/ieee80211_i.h                         |  37 +--
 net/mac80211/iface.c                               |  14 +
 net/mac80211/key.c                                 |  86 ------
 net/mac80211/key.h                                 |  10 +-
 net/mac80211/mesh.c                                |   9 +-
 net/mac80211/mesh.h                                |   3 -
 net/mac80211/mesh_pathtbl.c                        | 111 ++++++--
 net/mac80211/mesh_plink.c                          |  10 +-
 net/mac80211/mlme.c                                |  79 +++---
 net/mac80211/rx.c                                  | 139 ++++++++--
 net/mac80211/sta_info.c                            |  35 ++-
 net/mac80211/sta_info.h                            |  24 +-
 net/mac80211/tkip.c                                |  36 +--
 net/mac80211/tkip.h                                |   2 -
 net/mac80211/trace.h                               |  43 +--
 net/mac80211/tx.c                                  |  92 ++++++-
 net/mac80211/util.c                                | 116 ++++++--
 net/mac80211/vht.c                                 |  57 ++++
 net/mac80211/wpa.c                                 |  11 +-
 net/rfkill/Kconfig                                 |   3 +-
 net/rfkill/core.c                                  | 297 +++++++++++++=
+-------
 net/rfkill/rfkill-gpio.c                           |  24 +-
 net/wireless/Kconfig                               |  25 +-
 net/wireless/core.c                                |  10 +
 net/wireless/mlme.c                                |   3 +-
 net/wireless/nl80211.c                             |  29 +-
 net/wireless/radiotap.c                            |   1 +
 net/wireless/reg.c                                 | 122 +++------
 net/wireless/sme.c                                 |   9 +-
 net/wireless/util.c                                | 275 ++++++++++++-=
------
 80 files changed, 1652 insertions(+), 924 deletions(-)
 delete mode 100644 Documentation/ABI/obsolete/sysfs-class-rfkill
 create mode 100644 Documentation/ABI/removed/sysfs-class-rfkill
 delete mode 100644 include/linux/rfkill-gpio.h
