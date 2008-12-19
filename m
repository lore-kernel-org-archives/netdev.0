From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2008-12-19
Date: Fri, 19 Dec 2008 15:40:08 -0500
Message-ID: <20081219204008.GD4041@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49101 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392AbYLSUpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 15:45:12 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is yet another big round of patches intended for 2.6.29 -- wireles=
s
seems to continue its break-neck pace of development...  At least this
batch continues the trend of being primarily driver updates rather than
huge changes farther up the stack...

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6/

---

The following changes since commit 221b3d60cbb2740ec7d46a4f1ea6d3318a11=
2e51:
  Anton Vorontsov (1):
        ucc_geth: Remove UGETH_FILTERING dead code

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git master

Benoit PAPILLAULT (1):
      ath5k: fix 802.11 header padding on RX, unpadding on TX

Bob Copeland (1):
      ath5k: correct packet length in tx descriptors

Christian Lamparter (5):
      p54: move statistic timer update routine into a workqueue
      p54: update ACK failure statistic counter in real-time
      p54: more accurate rssi to dBm conversion
      p54: remove free_on_tx parameter
      p54usb: bring first generation devices back to life

Henning Rogge (1):
      nl80211: Add signal strength and bandwith to nl80211station info

Herton Ronaldo Krzesinski (1):
      rtl8187: Fix crash on unload when using SLUB debug

Ilpo J=E4rvinen (1):
      libertas: use roundup instead of opencoding

Jay Sternberg (1):
      iwlwifi: indicate txpower is off in sysfs

Jouni Malinen (10):
      mac80211: Add HT rates into RX status reporting
      ath9k: Report HT rates in RX status
      mac80211: Send Layer 2 Update frame on reassociation
      mac80211: Remove radiotap rate-present flag for HT
      ath9k: Fix TX status reporting for retries and MCS index
      ath9k: Remove MAC header pad before reporting TX status
      ath9k: Fix a NULL pointer dereference in ath_rate_get
      ath9k: Key cache allocation for AP mode
      ath9k: Fix key cache slot selection for splitmic
      ath9k: Fixed RX decryption status reporting

Kalle Valo (3):
      mac80211: enable IEEE80211_CONF_PS only when associated
      mac80211: track master queue status
      mac80211: implement dynamic power save

Larry Finger (2):
      rtl8187: Fix error returns
      mac80211: Print unknown packet type in tasklet_handler

Michael Buesch (3):
      b43: Fix some MAC locking
      b43: Suspend MAC while killing the radio
      b43: Add key memory dumping

Mohamed Abbas (1):
      iwlagn: fix agn rate scaling

Rami Rosen (3):
      iwlwifi: remove a parameter (dest) from *_fill_beacon_frame() met=
hods.
      mac80211: fix a typo in ieee80211_send_assoc() method.
      iwlwifi: iwl-tx.c cleanup (remove unused parameter and unused loc=
al variable).

Sujith (3):
      mac80211: Fix HT channel selection
      ath9k: Do not use association state to update rate table
      ath9k: Protect config() callback with a mutex

Vasanthakumar Thiagarajan (2):
      ath9k: Synchronize DMA transfer with CPU at right place
      ath9k: Move rate control alg register/unregister to appropriate p=
lace

Winkler, Tomas (1):
      iwlwifi: cleanup iwl-dev.h

Wu Fengguang (1):
      iwlwifi: remove useless goto

Wu, Fengguang (4):
      iwlwifi: add line feed to printk
      iwlwifi: update comments on the debug interface
      iwlwifi: use type uint for module param debug
      iwlwifi: use meaningful vars in _iwl_poll_bit()

Zhu Yi (1):
      iwlwifi: use GFP_KERNEL to allocate Rx SKB memory

 drivers/net/wireless/ath5k/ath5k.h          |    5 +
 drivers/net/wireless/ath5k/base.c           |   38 ++--
 drivers/net/wireless/ath5k/desc.c           |    4 +-
 drivers/net/wireless/ath9k/core.h           |    1 +
 drivers/net/wireless/ath9k/main.c           |  377 +++++++++++++------=
--------
 drivers/net/wireless/ath9k/rc.c             |    3 +-
 drivers/net/wireless/ath9k/recv.c           |   75 +++---
 drivers/net/wireless/ath9k/xmit.c           |   22 ++-
 drivers/net/wireless/b43/debugfs.c          |    1 +
 drivers/net/wireless/b43/debugfs.h          |    1 +
 drivers/net/wireless/b43/main.c             |  103 +++++---
 drivers/net/wireless/b43/phy_common.c       |   18 ++
 drivers/net/wireless/b43/phy_g.c            |    8 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c     |    1 -
 drivers/net/wireless/iwlwifi/iwl-3945.h     |    9 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c     |   10 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c     |   10 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c   |   26 ++-
 drivers/net/wireless/iwlwifi/iwl-agn.c      |   41 ++--
 drivers/net/wireless/iwlwifi/iwl-calib.c    |    9 +
 drivers/net/wireless/iwlwifi/iwl-commands.h |    2 +
 drivers/net/wireless/iwlwifi/iwl-core.h     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h    |   17 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h      |   29 +--
 drivers/net/wireless/iwlwifi/iwl-io.h       |   11 +-
 drivers/net/wireless/iwlwifi/iwl-led.c      |    2 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c       |   29 ++-
 drivers/net/wireless/iwlwifi/iwl-tx.c       |    8 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    6 +-
 drivers/net/wireless/libertas/if_sdio.c     |    3 +-
 drivers/net/wireless/mac80211_hwsim.c       |    6 +-
 drivers/net/wireless/p54/p54.h              |   23 ++-
 drivers/net/wireless/p54/p54common.c        |  198 +++++++++-----
 drivers/net/wireless/p54/p54common.h        |   25 +-
 drivers/net/wireless/p54/p54pci.c           |   12 +-
 drivers/net/wireless/p54/p54usb.c           |   43 +--
 drivers/net/wireless/rtl818x/rtl8187_dev.c  |   16 +-
 include/linux/nl80211.h                     |   53 +++-
 include/net/cfg80211.h                      |   42 +++-
 include/net/mac80211.h                      |   26 ++-
 net/mac80211/cfg.c                          |   42 +++-
 net/mac80211/ht.c                           |   35 ++-
 net/mac80211/ieee80211_i.h                  |   25 ++-
 net/mac80211/main.c                         |   39 ++--
 net/mac80211/mlme.c                         |   70 +++++-
 net/mac80211/rx.c                           |   59 ++++-
 net/mac80211/tx.c                           |   13 +
 net/mac80211/util.c                         |   88 ++++++-
 net/mac80211/wext.c                         |   46 +++-
 net/wireless/nl80211.c                      |   85 +++++-
 50 files changed, 1166 insertions(+), 651 deletions(-)

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2008-12-19.patch.bz2

--=20
John W. Linville		Linux should be at the core
linville@tuxdriver.com			of your literate lifestyle.
