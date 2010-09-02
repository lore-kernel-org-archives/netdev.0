From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2010-09-02
Date: Thu, 2 Sep 2010 14:08:27 -0400
Message-ID: <20100902180826.GC6802@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48856 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753434Ab0IBSOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 14:14:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is another batch of patches intended for 2.6.37.  There are a
variety of changes ranging from spelling fixes to more significant
driver and infrastructure enhancements.  As usual iwlwifi is a
major target, supplemented in this batch by rt2x00, ath5k, wl1251,
and others.  Johannes seems to have had an itch to tweak mac80211 a
bit as well.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 3e502e63586920f219ed2590f69c1f5a8888=
cfa4:

  starfire: Temporary kludge to fix powerpc build. (2010-09-01 19:19:54=
 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git for-davem

Arnaud Patard (1):
      rt2x00: fix "buffer size not provably correct" build warning

Bob Copeland (4):
      mac80211: trivial spelling fixes
      ath5k: trivial spelling fixes
      ath5k: log descriptor chains at a new debug level
      ath5k: fix off-by-one in pilot magnitude mask

Christian Lamparter (5):
      p54spi: Kconfig option for config blob
      p54usb: fix off-by-one on !CONFIG_PM
      mac80211: cancel restart_work in ieee80211_unregister_hw
      mac80211: fix rcu-unsafe pointer dereference
      p54: better rssi->dbm conversion for longbow phys

Dan Carpenter (1):
      ath5k: re-order one of the frees on unwind

David Kilroy (2):
      orinoco: Fix walking past the end of the buffer
      orinoco: update status in MAINTAINERS

Denis 'GNUtoo' Carikli (1):
      wl1251: Fix queue stopping/waking for TX path

=46elix Fietkau (1):
      ath9k: fix spurious MIC failure reports

Helmut Schaa (2):
      rt2x00: Rename txentry_desc.queue -> txentry_desc.qid
      rt2x00: Update rt2800 comments regarding AMPDU and PACKET_ID in T=
XWI

Ivo van Doorn (16):
      rt2x00: Simplify arguments to rt2x00 driver callback functions
      rt2x00: Reduce indenting
      rt2x00: Move direct access to queue->entries to rt2x00queue.c
      rt2x00: Remove Q_INDEX_CRYPTO and ENTRY_OWNER_DEVICE_CRYPTO
      rt2x00: Fix rt2800 retry calculation
      rt2x00: Merge rt2800{pci/usb} radio enabling/disabling code to rt=
2800lib
      rt2x00: Fix channel configuration for RF3052
      rt2x00: Fix max TX power settings
      rt2x00: Add rt2800_wait_csr_ready
      rt2x00: Validate TX status results with current data entry
      rt2x00: Wakeup hardware before loading firmware
      rt2x00: Don't set unicast/BSSID masks when clearning MAC or BSSID
      rt2x00: Set PWR_PIN_CFG during initialization
      rt2x00: Correctly kill beacon queue
      rt2x00: Split watchdog check into a DMA and STATUS timeout
      rt2x00: Cleanup rt2x00usb_watchdog_reset_tx

Joe Perches (2):
      net/mac80211: Use wiphy_<level>
      MAINTAINERS: add info for include/linux/spi/wl12xx.h

Johannes Berg (55):
      iwlwifi: add 6000g2b BT coexist API
      iwlagn: implement advance BT config command
      iwlagn: set BT IGNORE for some frames
      iwlwifi: add BT notification support for bt coex
      iwlagn: let bluetooth traffic load impact rate scale
      iwlwifi: reset BT when going down
      iwlagn: disable gen2b BT coexistence in IBSS
      iwlagn: keep BT settings across restart
      iwlwifi: use antenna A only under high BT load
      iwlwifi: disable aggregation queue if stopped early
      nl80211: fix missing nesting
      mac80211: fix mesh advertisement
      iwlwifi: initial contextification
      iwlwifi: prepare for PAN queue/fifo assignment
      iwlwifi: define PAN queues/FIFOs
      iwlwifi: contextify broadcast station
      iwlwifi: contextify-stations-completely
      iwlwifi: contextify command sending
      iwlwifi: move QoS into context
      iwlwifi: add context into tx descriptor
      iwlwifi: move virtual interface pointer into context
      iwlwifi: clamp scanning dwell time to all contexts
      iwlwifi: move AP sta ID to context
      iwlwifi: make hw crypto context aware
      iwlwifi: store default station flags in context
      iwlwifi: add context pointer to station
      iwlwifi: move HT configuration data into context
      iwlwifi: introduce beacon context
      iwlwifi: add PAN API
      iwlagn: detect PAN capability
      iwlagn: remove iw_mode check for beacon
      iwlagn: queue frames according to context
      iwlagn: send RXON timing before associating
      iwlagn: send beacon before committing associated RXON
      iwlwifi: send PAN parameters
      iwlwifi: pass context to iwl_send_rxon_timing
      iwlagn: always send RXON timing
      iwlwifi: follow main beacon interval
      iwlwifi: allow using multiple contexts
      mac80211: remove unused scan expire define
      mac80211: allow scan to complete from any context
      wl12xx: remove unneeded locking
      cfg80211 docbook: remove erronous !A
      cfg80211: allow vendor specific cipher suites
      mac80211: allow vendor specific cipher suites
      cfg80211: allow changing port control protocol
      mac80211: allow changing port control protocol
      mac80211: use subqueue helpers
      mac80211: clean up ifdown/cleanup paths
      mac80211: switch to ieee80211_sdata_running
      mac80211: simplify zero address checks
      mac80211: split out concurrent vif checks
      mac80211: support runtime interface type changes
      mac80211_hwsim: support runtime iftype changes
      mac80211: fix offchannel queue stop

John W. Linville (4):
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlw=
ifi/iwlwifi-2.6
      mac80211: cancel scan in ieee80211_restart_hw if software scan pe=
nding
      mac80211: only cancel software-based scans on suspend
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6 into for-davem

Jouni Malinen (2):
      mac80211: Fix signal strength average initialization for CQM even=
ts
      mac80211: Do not generate CQM events based on first Beacon frames

Julia Lawall (1):
      net/wireless: Remove double test

Kalle Valo (4):
      wl1251: update my email address
      wl12xx: change contact person for the include file
      wl1251: remove copyright contact person
      wl1251: move include guard after the license

Rafa=C5=82 Mi=C5=82ecki (1):
      b43: N-PHY: add missing phyrxchain setting and fix warning in RX =
core function

Rajkumar Manoharan (1):
      ath9k_htc: Enable ANI in associated state only

Stanislaw Gruszka (1):
      iwlwifi: fix canceling monitor_recover timer

Vivek Natarajan (1):
      ath9k: Change the default LED pattern.

Wey-Yi Guy (18):
      mac80211: fix warning for un-used parameter
      iwlwifi: update out-of-date comments
      iwlwifi: comments cleanup
      iwlwifi: Relax uCode timeout/error checking for 6000g2b
      iwlwifi: add bt full concurrency support
      iwlagn: wifi/bt coex configuration sequence
      iwlwifi: indicate bt_kill condition when receive tx reply
      iwlwifi: add debugfs to control stuck queue timer
      iwlwifi: add bt_init_traffic_load as configurable parameter
      iwlagn: add bt prio_boost to .cfg
      iwlagn: parsing uart message and take actions
      iwlagn: add additional bt related parameters
      iwlagn: add bt_ch_announce module parameter
      iwlagn: set traffic load based on multiple factors
      iwlagn: generic bt coex functions
      iwlagn: update bt status upon scan complete
      iwlwifi: add bt traffic load debugfs file
      iwlwifi: fix compile error without debugging support

 Documentation/DocBook/80211.tmpl              |    1 -
 MAINTAINERS                                   |    8 +-
 drivers/net/wireless/ath/ath.h                |    1 +
 drivers/net/wireless/ath/ath5k/base.c         |    4 +-
 drivers/net/wireless/ath/ath5k/debug.c        |    5 +-
 drivers/net/wireless/ath/ath5k/debug.h        |    2 +
 drivers/net/wireless/ath/ath5k/pcu.c          |    4 +-
 drivers/net/wireless/ath/ath5k/phy.c          |    4 +-
 drivers/net/wireless/ath/ath5k/reset.c        |    6 +-
 drivers/net/wireless/ath/ath9k/common.c       |   11 +
 drivers/net/wireless/ath/ath9k/htc_drv_main.c |    9 +-
 drivers/net/wireless/ath/ath9k/init.c         |    2 +-
 drivers/net/wireless/ath/ath9k/mac.c          |    3 +-
 drivers/net/wireless/ath/ath9k/recv.c         |   19 +-
 drivers/net/wireless/b43/phy_n.c              |    4 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c       |    4 +-
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h    |    3 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c    |    7 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c       |   86 ++--
 drivers/net/wireless/iwlwifi/iwl-4965.c       |   57 +-
 drivers/net/wireless/iwlwifi/iwl-5000-hw.h    |    2 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c       |   25 +-
 drivers/net/wireless/iwlwifi/iwl-6000-hw.h    |    2 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c       |  156 +++++-
 drivers/net/wireless/iwlwifi/iwl-agn-calib.c  |   18 +-
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c   |  112 ++++-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c    |  422 ++++++++++++++-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c     |  294 +++++++++--
 drivers/net/wireless/iwlwifi/iwl-agn-rs.h     |    2 +
 drivers/net/wireless/iwlwifi/iwl-agn-tt.c     |   26 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c     |  137 +++--
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c  |   95 +++-
 drivers/net/wireless/iwlwifi/iwl-agn.c        |  546 ++++++++++++++---=
--
 drivers/net/wireless/iwlwifi/iwl-agn.h        |   12 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h   |  470 +++++++++++++++-
 drivers/net/wireless/iwlwifi/iwl-core.c       |  747 +++++++++++++++--=
--------
 drivers/net/wireless/iwlwifi/iwl-core.h       |   65 ++-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c    |  106 +++-
 drivers/net/wireless/iwlwifi/iwl-dev.h        |  165 +++++-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c       |   13 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h       |    9 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c         |    9 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c       |   57 ++-
 drivers/net/wireless/iwlwifi/iwl-sta.c        |  183 ++++---
 drivers/net/wireless/iwlwifi/iwl-sta.h        |   64 ++-
 drivers/net/wireless/iwlwifi/iwl-tx.c         |   34 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c   |  175 ++++---
 drivers/net/wireless/mac80211_hwsim.c         |   13 +
 drivers/net/wireless/orinoco/hw.c             |    9 +-
 drivers/net/wireless/orinoco/wext.c           |   11 +-
 drivers/net/wireless/p54/Kconfig              |   17 +
 drivers/net/wireless/p54/p54spi.c             |    7 +-
 drivers/net/wireless/p54/p54usb.c             |    2 +-
 drivers/net/wireless/p54/txrx.c               |    8 +-
 drivers/net/wireless/rt2x00/rt2400pci.c       |   31 +-
 drivers/net/wireless/rt2x00/rt2500pci.c       |   37 +-
 drivers/net/wireless/rt2x00/rt2500usb.c       |   31 +-
 drivers/net/wireless/rt2x00/rt2800.h          |   13 +-
 drivers/net/wireless/rt2x00/rt2800lib.c       |  305 ++++++++---
 drivers/net/wireless/rt2x00/rt2800lib.h       |    9 +-
 drivers/net/wireless/rt2x00/rt2800pci.c       |  114 +---
 drivers/net/wireless/rt2x00/rt2800usb.c       |  105 +---
 drivers/net/wireless/rt2x00/rt2x00.h          |   15 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c     |    9 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c       |    8 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c     |   71 ++-
 drivers/net/wireless/rt2x00/rt2x00queue.h     |   48 ++-
 drivers/net/wireless/rt2x00/rt2x00usb.c       |  199 ++++----
 drivers/net/wireless/rt2x00/rt2x00usb.h       |   12 +-
 drivers/net/wireless/rt2x00/rt61pci.c         |   57 +-
 drivers/net/wireless/rt2x00/rt73usb.c         |   35 +-
 drivers/net/wireless/wl12xx/wl1251.h          |    7 +-
 drivers/net/wireless/wl12xx/wl1251_acx.h      |    2 -
 drivers/net/wireless/wl12xx/wl1251_boot.c     |    2 -
 drivers/net/wireless/wl12xx/wl1251_boot.h     |    2 -
 drivers/net/wireless/wl12xx/wl1251_cmd.h      |    2 -
 drivers/net/wireless/wl12xx/wl1251_debugfs.c  |    2 -
 drivers/net/wireless/wl12xx/wl1251_debugfs.h  |    2 -
 drivers/net/wireless/wl12xx/wl1251_event.c    |    4 -
 drivers/net/wireless/wl12xx/wl1251_event.h    |    2 -
 drivers/net/wireless/wl12xx/wl1251_init.c     |    2 -
 drivers/net/wireless/wl12xx/wl1251_init.h     |    2 -
 drivers/net/wireless/wl12xx/wl1251_io.c       |    2 -
 drivers/net/wireless/wl12xx/wl1251_main.c     |   18 +-
 drivers/net/wireless/wl12xx/wl1251_ps.c       |    2 -
 drivers/net/wireless/wl12xx/wl1251_ps.h       |    8 +-
 drivers/net/wireless/wl12xx/wl1251_reg.h      |    2 -
 drivers/net/wireless/wl12xx/wl1251_rx.c       |    2 -
 drivers/net/wireless/wl12xx/wl1251_rx.h       |    2 -
 drivers/net/wireless/wl12xx/wl1251_sdio.c     |    2 +-
 drivers/net/wireless/wl12xx/wl1251_spi.c      |    4 +-
 drivers/net/wireless/wl12xx/wl1251_spi.h      |    2 -
 drivers/net/wireless/wl12xx/wl1251_tx.c       |   22 +-
 drivers/net/wireless/wl12xx/wl1251_tx.h       |    2 -
 drivers/net/wireless/wl12xx/wl1271_main.c     |    2 -
 drivers/net/wireless/wl12xx/wl1271_scan.c     |    2 -
 include/linux/nl80211.h                       |   16 +-
 include/linux/spi/wl12xx.h                    |    2 +-
 include/net/cfg80211.h                        |   24 +-
 include/net/mac80211.h                        |   22 +-
 net/mac80211/cfg.c                            |   53 +--
 net/mac80211/debugfs.c                        |    6 +-
 net/mac80211/driver-ops.h                     |   14 +
 net/mac80211/driver-trace.h                   |   25 +
 net/mac80211/ibss.c                           |    4 +-
 net/mac80211/ieee80211_i.h                    |   46 ++-
 net/mac80211/iface.c                          |  314 ++++++-----
 net/mac80211/key.c                            |   52 ++-
 net/mac80211/key.h                            |    6 +-
 net/mac80211/main.c                           |   82 +++-
 net/mac80211/mlme.c                           |   36 +-
 net/mac80211/offchannel.c                     |   19 +-
 net/mac80211/pm.c                             |    3 +-
 net/mac80211/rate.c                           |    9 +-
 net/mac80211/rx.c                             |   33 +-
 net/mac80211/scan.c                           |   34 +-
 net/mac80211/sta_info.c                       |   21 +-
 net/mac80211/status.c                         |    9 +-
 net/mac80211/tx.c                             |   45 ++-
 net/mac80211/util.c                           |   11 +-
 net/wireless/nl80211.c                        |   27 +-
 net/wireless/util.c                           |    9 +-
 net/wireless/wext-core.c                      |    2 +-
 net/wireless/wext-sme.c                       |    2 +
 124 files changed, 4513 insertions(+), 1866 deletions(-)

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2010-09-02.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
