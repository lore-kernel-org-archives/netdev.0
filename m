From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2008-07-14
Date: Mon, 14 Jul 2008 15:23:02 -0400
Message-ID: <20080714192302.GA2541@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3044 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755291AbYGNTiF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jul 2008 15:38:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is one last(?) round of miscellaneous patches I hope to get into
2.6.27.  There are mostly driver updates, including a sizable iwlwifi
set of changes.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit 79d16385c7f287a33ea771c4dbe60ae43f791b49:
  David S. Miller (1):
        netdev: Move atomic queue state bits into netdev_queue.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Abhijeet Kolekar (2):
      iwlwifi: Fix LEDs for 3945
      iwlwifi: make index unsigned int for iwl_send_led_cmd

Adel Gadllah (1):
      iwl3965: remove useless network and duplicate checking

Emmanuel Grumbach (4):
      mac80211: Fix ieee80211_rx_reorder_ampdu: ignore QoS null packets
      mac80211: dont add a STA which is not in the same IBSS
      iwlwifi: fixes RTS / CTS support
      iwlwifi: make iwl4965_mac_conf_tx in atomic context

Esti Kummer (1):
      iwlwifi: adding pci device ids to iwl_hw_card_ids

Herton Ronaldo Krzesinski (1):
      rtl8187: use different ANAPARAM*_OFF values for 8187B

Ihar Hrachyshka (1):
      rtl8187: Fixed section mismatch in rtl8187_dev.c

Ivo van Doorn (4):
      rt2x00: Fix NULL pointer error in adhoc/master mode
      rt2x00: Add support for CTS protection in rt2x00lib
      rt2x00: Reorganize beacon handling
      rt2x00: Reset LED assoc status after firmware update

Johannes Berg (9):
      mac80211: make master netdev handling sane
      mac80211: revamp virtual interface handling
      mac80211: push interface checks down
      mac80211: revamp beacon configuration
      mac80211: fix RX sequence number check
      wext: make sysfs bits optional and deprecate them
      mac80211: fix TX sequence numbers
      mac80211: fix struct ieee80211_tx_queue_params
      mac80211 hwsim: fix endianness bug

Michael Buesch (1):
      ssb: Include dma-mapping.h

Samuel Ortiz (1):
      mac80211: power management wext hooks

Tomas Winkler (8):
      iwlwif: remove compilation warnings iwl_add_radiotap
      iwlwifi: remove post associate work
      iwlwifi: rs always set lq_sta->priv
      iwlwifi: differentiate 4965 and 5000 hw ampdu queues number
      iwlwifi: fix LED stall
      iwlwifi: LED use correctly blink table
      iwlwifi: unify 4965 and 5000 scanning code
      iwlwifi: enable active scanning

Zhu Yi (1):
      iwlwifi: send TXPOWER command after a new RXON command

 Documentation/feature-removal-schedule.txt   |   10 +
 drivers/net/wireless/ath5k/base.c            |   13 +-
 drivers/net/wireless/b43/main.c              |   48 ++--
 drivers/net/wireless/b43/xmit.c              |    3 +-
 drivers/net/wireless/b43legacy/main.c        |   45 ++--
 drivers/net/wireless/b43legacy/xmit.c        |    3 +-
 drivers/net/wireless/iwlwifi/iwl-3945-led.c  |  146 ++++------
 drivers/net/wireless/iwlwifi/iwl-3945-led.h  |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c      |   50 ++--
 drivers/net/wireless/iwlwifi/iwl-3945.h      |   20 +--
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h   |    1 +
 drivers/net/wireless/iwlwifi/iwl-4965-rs.c   |    2 -
 drivers/net/wireless/iwlwifi/iwl-4965.c      |   42 +++-
 drivers/net/wireless/iwlwifi/iwl-5000-hw.h   |    1 +
 drivers/net/wireless/iwlwifi/iwl-5000.c      |   48 +++-
 drivers/net/wireless/iwlwifi/iwl-commands.h  |   30 ++-
 drivers/net/wireless/iwlwifi/iwl-core.c      |    2 +-
 drivers/net/wireless/iwlwifi/iwl-core.h      |    5 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h       |   27 +--
 drivers/net/wireless/iwlwifi/iwl-led.c       |  207 ++++++--------
 drivers/net/wireless/iwlwifi/iwl-led.h       |    5 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c        |   37 ++--
 drivers/net/wireless/iwlwifi/iwl-scan.c      |  103 ++++----
 drivers/net/wireless/iwlwifi/iwl-tx.c        |    8 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c  |  145 +---------
 drivers/net/wireless/iwlwifi/iwl4965-base.c  |  108 ++++----
 drivers/net/wireless/mac80211_hwsim.c        |    2 +-
 drivers/net/wireless/rt2x00/rt2400pci.c      |   89 +++----
 drivers/net/wireless/rt2x00/rt2500pci.c      |   90 +++----
 drivers/net/wireless/rt2x00/rt2500usb.c      |  154 ++++------
 drivers/net/wireless/rt2x00/rt2x00.h         |   37 +---
 drivers/net/wireless/rt2x00/rt2x00config.c   |    2 +
 drivers/net/wireless/rt2x00/rt2x00dev.c      |    9 +-
 drivers/net/wireless/rt2x00/rt2x00firmware.c |    8 +
 drivers/net/wireless/rt2x00/rt2x00lib.h      |    8 +
 drivers/net/wireless/rt2x00/rt2x00mac.c      |   40 ++-
 drivers/net/wireless/rt2x00/rt2x00queue.c    |   67 ++++-
 drivers/net/wireless/rt2x00/rt61pci.c        |  103 +++-----
 drivers/net/wireless/rt2x00/rt73usb.c        |  115 +++-----
 drivers/net/wireless/rtl8187_dev.c           |   23 +-
 drivers/net/wireless/rtl8187_rtl8225.c       |   21 ++-
 drivers/net/wireless/rtl8187_rtl8225.h       |   15 +-
 drivers/net/wireless/zd1211rw/zd_mac.c       |   22 +-
 include/linux/ssb/ssb.h                      |    1 +
 include/net/mac80211.h                       |   73 +++---
 net/core/net-sysfs.c                         |    4 +-
 net/mac80211/cfg.c                           |   36 +--
 net/mac80211/debugfs.c                       |   15 +-
 net/mac80211/debugfs_netdev.c                |   48 ++--
 net/mac80211/debugfs_netdev.h                |    5 -
 net/mac80211/ieee80211_i.h                   |   67 ++---
 net/mac80211/iface.c                         |  392 +++++++++++---------------
 net/mac80211/main.c                          |  171 ++++--------
 net/mac80211/mlme.c                          |  172 +++++-------
 net/mac80211/rc80211_pid_algo.c              |    8 +-
 net/mac80211/rx.c                            |   38 ++--
 net/mac80211/sta_info.c                      |   29 ++-
 net/mac80211/sta_info.h                      |    1 +
 net/mac80211/tx.c                            |  126 +++++---
 net/mac80211/util.c                          |    4 -
 net/mac80211/wext.c                          |   65 +++--
 net/wireless/Kconfig                         |   11 +
 62 files changed, 1458 insertions(+), 1724 deletions(-)

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2008-07-14.patch.bz2

-- 
John W. Linville
linville@tuxdriver.com
