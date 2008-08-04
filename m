From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-08-04
Date: Mon, 4 Aug 2008 15:37:53 -0400
Message-ID: <20080804193753.GA30345@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Another big round of fixes for 2.6.27.  Included is also a renaming
patch and some related patches that rename iwl4965 to iwlagn (reflecting
that is supports iwl5000 as well).

The other big(ger) thing here is the new ath9k driver.  It is probably
still far from perfect, but I'm hearing good reports on its
functionality and the Atheros team (and others) have already been quite
responsive on comments, etc.  I think it is best to go ahead and get it
into 2.6.27.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit adf044c8778de98dae29c5ce9973b7e43964674f:
  Sven Wegener (1):
        net: Add missing extra2 parameter for ip_default_ttl sysctl

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Daniel Drake (1):
      mac80211: automatic IBSS channel selection

Denis V. Lunev (1):
      iwlwifi: RS small compile warnings without CONFIG_IWLWIFI_DEBUG

Emmanuel Grumbach (3):
      mac80211: pass dtim_period to low level driver
      iwlwifi: bug fix in AGG flow - cast const to ULL
      iwlwifi: decrement rx skb counter in scan abort handler

Esti Kummer (2):
      iwlwifi: corrects power_level in sysfs
      iwlwifi: set led register in disassociation

Gregory Greenman (1):
      iwlwifi: memory allocation optimization

Ivo van Doorn (1):
      rt2x00: Disable link tuning in rt2500usb

Larry Finger (1):
      p54: Fix potential concurrent access to private data

Luis R. Rodriguez (4):
      list.h: Add list_splice_tail() and list_splice_tail_init()
      list.h: add list_cut_position()
      ath5k: remove Atheros 11n devices from supported list
      ath9k: Add new Atheros IEEE 802.11n driver

Mohamed Abbas (1):
      iwlwifi: add power save to 5000 HW

Sven Wegener (1):
      iwlwifi: Don't use buffer allocated on the stack for led names

Tomas Winkler (14):
      mac80211: make listen_interval be limited by low level driver
      iwlwifi: move iwl4965_mac_ampdu_action to iwl4965-base.c
      iwlwifi: move beacon handling to iwl4965-base.c
      iwlwifi: move iwl4965_set_pwr_src to iwl4965-base.c
      iwlwifi: rename iwl-4695-rs to iwl-agn-rs
      iwlwifi: kill iwl4965_fill_rs_info
      iwlwifi: use dtim_period from association, and set listen_interval
      iwlwifi: rename iwl4965-base.c to iwl-agn.c
      iwlwifi: fix checkpatch.pl errors
      iwlwifi: rename 4965 to AGN
      iwlwifi: HW bug fixes
      iwlwifi: implement iwl5000_calc_rssi
      iwlwifi: fix unhandled interrupt when HW rfkill is on
      iwlwifi: grap nic access before accessing periphery registers

Zhu Yi (1):
      iwl3945: fix merge mistake for packet injection

 MAINTAINERS                                        |    9 +
 drivers/net/wireless/Kconfig                       |    1 +
 drivers/net/wireless/Makefile                      |    1 +
 drivers/net/wireless/ath5k/base.c                  |    2 -
 drivers/net/wireless/ath9k/Kconfig                 |    8 +
 drivers/net/wireless/ath9k/Makefile                |   11 +
 drivers/net/wireless/ath9k/ath9k.h                 | 1066 +++
 drivers/net/wireless/ath9k/beacon.c                |  977 +++
 drivers/net/wireless/ath9k/core.c                  | 1961 +++++
 drivers/net/wireless/ath9k/core.h                  | 1097 +++
 drivers/net/wireless/ath9k/hw.c                    | 8563 ++++++++++++++++++++
 drivers/net/wireless/ath9k/hw.h                    |  969 +++
 drivers/net/wireless/ath9k/initvals.h              | 3146 +++++++
 drivers/net/wireless/ath9k/main.c                  | 1533 ++++
 drivers/net/wireless/ath9k/phy.c                   |  436 +
 drivers/net/wireless/ath9k/phy.h                   |  543 ++
 drivers/net/wireless/ath9k/rc.c                    | 2126 +++++
 drivers/net/wireless/ath9k/rc.h                    |  316 +
 drivers/net/wireless/ath9k/recv.c                  | 1318 +++
 drivers/net/wireless/ath9k/reg.h                   | 1385 ++++
 drivers/net/wireless/ath9k/regd.c                  | 1031 +++
 drivers/net/wireless/ath9k/regd.h                  |  412 +
 drivers/net/wireless/ath9k/regd_common.h           | 1915 +++++
 drivers/net/wireless/ath9k/xmit.c                  | 2870 +++++++
 drivers/net/wireless/iwlwifi/Kconfig               |   98 +-
 drivers/net/wireless/iwlwifi/Makefile              |   13 +-
 drivers/net/wireless/iwlwifi/iwl-3945-led.c        |   33 +-
 drivers/net/wireless/iwlwifi/iwl-3945-led.h        |    1 +
 drivers/net/wireless/iwlwifi/iwl-3945.c            |    7 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c            |  156 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   71 +-
 .../iwlwifi/{iwl-4965-rs.c => iwl-agn-rs.c}        |  327 +-
 .../iwlwifi/{iwl-4965-rs.h => iwl-agn-rs.h}        |   23 +-
 .../wireless/iwlwifi/{iwl4965-base.c => iwl-agn.c} |  232 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |   44 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |    7 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |    3 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h             |   10 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h           |    4 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |   11 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   22 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |    3 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-led.c             |   69 +-
 drivers/net/wireless/iwlwifi/iwl-led.h             |    1 +
 drivers/net/wireless/iwlwifi/iwl-power.c           |   45 +-
 drivers/net/wireless/iwlwifi/iwl-power.h           |   33 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |   12 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c              |   59 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |    1 +
 drivers/net/wireless/iwlwifi/iwl-sta.c             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c              |   78 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |   58 +-
 drivers/net/wireless/p54/p54.h                     |    1 +
 drivers/net/wireless/p54/p54common.c               |    6 +
 drivers/net/wireless/rt2x00/rt2500usb.c            |   14 +
 include/linux/ieee80211.h                          |   13 +
 include/linux/list.h                               |   77 +-
 include/net/mac80211.h                             |   13 +-
 net/mac80211/ieee80211_i.h                         |    1 +
 net/mac80211/main.c                                |    5 +
 net/mac80211/mlme.c                                |   39 +-
 62 files changed, 32565 insertions(+), 727 deletions(-)
 create mode 100644 drivers/net/wireless/ath9k/Kconfig
 create mode 100644 drivers/net/wireless/ath9k/Makefile
 create mode 100644 drivers/net/wireless/ath9k/ath9k.h
 create mode 100644 drivers/net/wireless/ath9k/beacon.c
 create mode 100644 drivers/net/wireless/ath9k/core.c
 create mode 100644 drivers/net/wireless/ath9k/core.h
 create mode 100644 drivers/net/wireless/ath9k/hw.c
 create mode 100644 drivers/net/wireless/ath9k/hw.h
 create mode 100644 drivers/net/wireless/ath9k/initvals.h
 create mode 100644 drivers/net/wireless/ath9k/main.c
 create mode 100644 drivers/net/wireless/ath9k/phy.c
 create mode 100644 drivers/net/wireless/ath9k/phy.h
 create mode 100644 drivers/net/wireless/ath9k/rc.c
 create mode 100644 drivers/net/wireless/ath9k/rc.h
 create mode 100644 drivers/net/wireless/ath9k/recv.c
 create mode 100644 drivers/net/wireless/ath9k/reg.h
 create mode 100644 drivers/net/wireless/ath9k/regd.c
 create mode 100644 drivers/net/wireless/ath9k/regd.h
 create mode 100644 drivers/net/wireless/ath9k/regd_common.h
 create mode 100644 drivers/net/wireless/ath9k/xmit.c
 rename drivers/net/wireless/iwlwifi/{iwl-4965-rs.c => iwl-agn-rs.c} (89%)
 rename drivers/net/wireless/iwlwifi/{iwl-4965-rs.h => iwl-agn-rs.h} (93%)
 rename drivers/net/wireless/iwlwifi/{iwl4965-base.c => iwl-agn.c} (96%)

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6-2008-08-04.patch.bz2

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
