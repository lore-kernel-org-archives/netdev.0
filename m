From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2010-02-12
Date: Fri, 12 Feb 2010 16:45:06 -0500
Message-ID: <20100212214505.GA16783@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37847 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757553Ab0BLVvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 16:51:11 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is this weeks dump of wireless bits intended for 2.6.34.  It is th=
e
usual variety of driver updates and fixes to problems introduced by
updates earlier in the cycle.  Also, more progress on N-phy support in
b43 and the removal of the unused mac80211 op get_tx_stats.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 375c568844e49d292885c7485d4a255f7168=
0e56:
  stephen hemminger (1):
        sky2: receive checksum refactoring

are available in the git repository at:

  ssh://master.kernel.org/pub/scm/linux/kernel/git/linville/wireless-ne=
xt-2.6.git master

Andres Salomon (1):
      mac80211: make rate_control_alloc static

Ben M Cahill (2):
      iwlwifi: Add chain noise scaling factor
      iwlwifi: Add chain_noise support for 6050

Benoit Papillault (2):
      mac80211: Fix probe request filtering in IBSS mode
      mac80211: Added a new debugfs file for reading channel_type

Bob Copeland (1):
      ath5k: use correct packet type when transmitting

Christian Lamparter (1):
      ath: fix WARN_ON with Polish (Poland) Contry code

Deepak Saxena (1):
      Add Station and AdHoc mode support to libertas_tf

=46elix Fietkau (1):
      ath9k: add a workaround for ack timeout issues

Holger Schurig (1):
      libertas: don't retry commands

Jochen Friedrich (1):
      ssb: fix interrupt assignment

Johannes Berg (7):
      mac80211: fix deferred hardware scan requests
      mac80211_hwsim: add fake hw scan handler
      wireless: update radiotap parser
      mac80211: don't probe if we have probe response
      mac80211: allow station add/remove to sleep
      mac80211: fix bss_conf.dtim_period
      mac80211: fix deauth race

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6

Kalle Valo (11):
      wl1251: fix txop unit
      adm821: remove get_tx_stats() mac80211 op
      mwl8k: remove get_tx_stats() mac80211 op
      ar9170: remove get_tx_stats() mac80211 op
      ath5k: remove get_tx_stats() mac80211 op
      b43: remove get_tx_stats() mac80211 op
      b43legacy: remove get_tx_stats() mac80211 op
      iwlwifi: remove get_tx_stats() mac80211 op
      p54: remove get_tx_stats() mac80211 op
      rt2x00: remove get_tx_stats() mac80211 op
      mac80211: remove get_tx_stats() driver op

Larry Finger (2):
      b43: Fix throughput regression
      b43/b43legacy: Wake queues in wireless_core_start

Michael Buesch (1):
      ssb: Fix CONFIG_SSB_SDIOHOST typo

Ming Lei (1):
      ath9k: fix keycache leak in split tkip case

Rafa=C5=82 Mi=C5=82ecki (6):
      b43: N-PHY: implement overriding RF control intc
      b43: N-PHY: prepare code for reapplying TX cal coeffs
      b43: N-PHY: save calibration for further restore
      b43: N-PHY: partly implement SPUR workaround
      b43: N-PHY: load generated samples
      b43: N-PHY: handle allocation fail in samples generation

Randy Dunlap (1):
      libertas/if_spi: needs linux/semaphore.h

Samuel Ortiz (1):
      iwlwifi: Send broadcast probe request only when asked to

Senthil Balasubramanian (2):
      ath9k: configure the beacon only if the STA is associated
      ath9k: Enable TIM timer interrupt only when needed.

Sujith (1):
      mac80211: Deny TX BA session requests during disassociation

Vivek Natarajan (3):
      mac80211: Reset dynamic ps timer in Rx path.
      mac80211: Retry null data frame for power save.
      ath9k: Enable IEEE80211_HW_REPORTS_TX_ACK_STATUS flag for ath9k.

Wey-Yi Guy (2):
      iwlwifi: Fix to set correct ht configuration
      mac80211: tear down all agg queues when restart/reconfig hw

 Documentation/DocBook/mac80211.tmpl         |    1 -
 drivers/net/wireless/adm8211.c              |   13 -
 drivers/net/wireless/ath/ar9170/ar9170.h    |    8 +-
 drivers/net/wireless/ath/ar9170/main.c      |   13 -
 drivers/net/wireless/ath/ath5k/ath5k.h      |    1 -
 drivers/net/wireless/ath/ath5k/base.c       |   44 +-
 drivers/net/wireless/ath/ath5k/base.h       |    1 -
 drivers/net/wireless/ath/ath9k/ath9k.h      |    1 +
 drivers/net/wireless/ath/ath9k/beacon.c     |    8 +-
 drivers/net/wireless/ath/ath9k/hw.c         |   18 +-
 drivers/net/wireless/ath/ath9k/init.c       |    3 +-
 drivers/net/wireless/ath/ath9k/main.c       |   27 +-
 drivers/net/wireless/ath/ath9k/xmit.c       |    7 +-
 drivers/net/wireless/ath/regd.c             |    5 +-
 drivers/net/wireless/b43/b43.h              |    1 +
 drivers/net/wireless/b43/dma.c              |   17 -
 drivers/net/wireless/b43/dma.h              |    5 -
 drivers/net/wireless/b43/main.c             |   38 +-
 drivers/net/wireless/b43/phy_n.c            |  302 +++++++++++-
 drivers/net/wireless/b43/phy_n.h            |    4 +
 drivers/net/wireless/b43/pio.c              |   17 -
 drivers/net/wireless/b43/pio.h              |    5 -
 drivers/net/wireless/b43legacy/dma.c        |   20 -
 drivers/net/wireless/b43legacy/dma.h        |   10 -
 drivers/net/wireless/b43legacy/main.c       |   26 +-
 drivers/net/wireless/b43legacy/pio.c        |   13 -
 drivers/net/wireless/b43legacy/pio.h        |   11 -
 drivers/net/wireless/iwlwifi/iwl-1000.c     |    2 +
 drivers/net/wireless/iwlwifi/iwl-5000.c     |   21 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c     |   25 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c      |    3 +-
 drivers/net/wireless/iwlwifi/iwl-core.c     |   37 +--
 drivers/net/wireless/iwlwifi/iwl-core.h     |    3 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c     |   49 ++-
 drivers/net/wireless/iwlwifi/iwl-sta.c      |    4 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    1 -
 drivers/net/wireless/libertas/cmdresp.c     |    5 -
 drivers/net/wireless/libertas/dev.h         |    1 -
 drivers/net/wireless/libertas/if_spi.c      |    1 +
 drivers/net/wireless/libertas/main.c        |   31 +-
 drivers/net/wireless/libertas_tf/main.c     |    3 +
 drivers/net/wireless/mac80211_hwsim.c       |   44 ++-
 drivers/net/wireless/mwl8k.c                |   35 +-
 drivers/net/wireless/p54/main.c             |   11 -
 drivers/net/wireless/p54/p54.h              |    8 +-
 drivers/net/wireless/p54/txrx.c             |    2 +-
 drivers/net/wireless/rt2x00/rt2400pci.c     |    1 -
 drivers/net/wireless/rt2x00/rt2500pci.c     |    1 -
 drivers/net/wireless/rt2x00/rt2500usb.c     |    1 -
 drivers/net/wireless/rt2x00/rt2800lib.c     |    1 -
 drivers/net/wireless/rt2x00/rt2x00.h        |    2 -
 drivers/net/wireless/rt2x00/rt2x00mac.c     |   16 -
 drivers/net/wireless/rt2x00/rt61pci.c       |    1 -
 drivers/net/wireless/rt2x00/rt73usb.c       |    1 -
 drivers/net/wireless/wl12xx/wl1251_main.c   |    3 +-
 drivers/ssb/driver_mipscore.c               |    5 +-
 drivers/ssb/main.c                          |    3 +-
 include/net/cfg80211.h                      |   83 +++-
 include/net/ieee80211_radiotap.h            |    4 +
 include/net/mac80211.h                      |   49 +-
 net/mac80211/agg-tx.c                       |    8 +
 net/mac80211/cfg.c                          |   25 +-
 net/mac80211/debugfs.c                      |   33 ++
 net/mac80211/driver-ops.h                   |   42 ++-
 net/mac80211/driver-trace.h                 |   75 ++-
 net/mac80211/ibss.c                         |   24 +-
 net/mac80211/ieee80211_i.h                  |   19 +-
 net/mac80211/mesh_plink.c                   |   17 +-
 net/mac80211/mlme.c                         |   60 ++-
 net/mac80211/pm.c                           |   10 +-
 net/mac80211/rate.c                         |    2 +-
 net/mac80211/rate.h                         |    7 +-
 net/mac80211/rx.c                           |   12 +-
 net/mac80211/scan.c                         |   27 +-
 net/mac80211/sta_info.c                     |  731 +++++++++++++------=
--------
 net/mac80211/sta_info.h                     |   36 +-
 net/mac80211/status.c                       |   17 +-
 net/mac80211/tx.c                           |   11 +-
 net/mac80211/util.c                         |   24 +-
 net/wireless/radiotap.c                     |  305 ++++++++----
 80 files changed, 1465 insertions(+), 1096 deletions(-)

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2010-02-12.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
