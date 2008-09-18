From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request wireless-next-2.6 2008-09-15
Date: Thu, 18 Sep 2008 10:09:54 -0400
Message-ID: <20080918140953.GE4552@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

(I know that today is 2008-09-18 -- I decided to let this cook in
-next for a couple of days before sending the request...)

Dave,

Here is another round of stuff for 2.6.28.  Included in this is the
support for the new userland component for regulatory enforcement.
There is also a Kconfig option to preserve regulatory behavior
compatible with earlier kernels.  Also included is another huge round of
mac80211 cleanups, etc from Johannes and a smattering of other bits.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit 63f2c0464875b6ef2132cecb19b2a5abbf061227:
  Stephen Rothwell (1):
        net: ip_vs_proto_{tcp,udp} build fix

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Abhijeet Kolekar (1):
      mac80211 : Fix mode change hard_start_xmit function

Dan Williams (2):
      libertas: remove unused generic RESET command
      libertas: convert SNMP_MIB to a direct command

David Kilroy (1):
      orinoco: Fix compile warnings

Henrique de Moraes Holschuh (1):
      rfkill: remove transmitter blocking on suspend

Javier Cardona (1):
      libertas: Reduce the WPA key installation time.

Johannes Berg (31):
      mac80211: move ieee80211_sta_expire
      mac80211: move STA timer restart
      mac80211: dont set REQ_RUN when scan finishes
      mac80211: split off mesh handling entirely
      mac80211: fix work race
      mac80211: fix scan vs. interface removal race
      mac80211: reorder MLME code more
      mac80211: move ieee80211_set_freq to utils
      mac80211: make bridge_packets a virtual interface option
      mac80211: clean up scan namespace
      mac80211: clean up some comments
      mac80211: inform driver of basic rateset
      mac80211: use nl80211 interface types
      mac80211: move regular interface handling
      mac80211: warn on some invalid vlan operations
      mac80211 hwsim: verify vif pointers
      mac80211: share STA information with driver
      mac80211 hwsim: verify sta pointers
      mac80211: small rate control changes
      mac80211: move last_txrate_idx into RC algorithms
      mac80211: share sta->supp_rates
      mac80211: move txrate_idx into RC algorithms
      mac80211: share sta_info->ht_info
      iwlwifi: don't access mac80211's AMPDU state machine
      mac80211: pass AP vif pointer for VLANs
      mac80211: fix virtual interfaces vs. injection
      mac80211 hwsim: make radio list dynamic
      mac80211: fix sta_info kernel-doc warning
      mac80211: clean up kdoc
      mac80211: remove beacon counters
      mac80211: remove debug frame dumping

John W. Linville (1):
      libertas: correct "limited range of data type" warning

Lorenzo Nava (1):
      b43: fix QoS parameters initialization

Luis R. Rodriguez (2):
      cfg80211: Add new wireless regulatory infrastructure
      zd1211rw: make use of new regulatory_hint()

Tomas Winkler (2):
      iwlwifi: update 5350 Wifi PCI IDs
      iwlwifi: add MODULE_FIRMWARE for 5000 HW

Vasanthakumar Thiagarajan (2):
      ath9k: Re-order functions in main.c
      ath9k: Add RF kill support

Zhu Yi (1):
      iwl3945: add MODULE_FIRMWARE for 3945 HW

 Documentation/DocBook/mac80211.tmpl          |   12 +-
 Documentation/feature-removal-schedule.txt   |   18 +
 Documentation/networking/regulatory.txt      |  194 ++++
 Documentation/rfkill.txt                     |   32 +-
 drivers/net/wireless/adm8211.c               |   22 +-
 drivers/net/wireless/ath5k/ath5k.h           |    4 +-
 drivers/net/wireless/ath5k/attach.c          |    2 +-
 drivers/net/wireless/ath5k/base.c            |   50 +-
 drivers/net/wireless/ath5k/base.h            |    2 +-
 drivers/net/wireless/ath5k/pcu.c             |   12 +-
 drivers/net/wireless/ath5k/reset.c           |    2 +-
 drivers/net/wireless/ath9k/ath9k.h           |    7 +-
 drivers/net/wireless/ath9k/core.h            |   16 +
 drivers/net/wireless/ath9k/hw.c              |   70 +-
 drivers/net/wireless/ath9k/main.c            | 1262 ++++++++++++++++----------
 drivers/net/wireless/ath9k/rc.c              |    3 +-
 drivers/net/wireless/b43/b43.h               |    2 +-
 drivers/net/wireless/b43/main.c              |   43 +-
 drivers/net/wireless/b43/phy_common.c        |    4 +-
 drivers/net/wireless/b43legacy/main.c        |   32 +-
 drivers/net/wireless/b43legacy/phy.c         |    4 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c   |   30 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c      |    6 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h      |    2 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c      |    2 +
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c    |   66 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c       |   81 +-
 drivers/net/wireless/iwlwifi/iwl-core.c      |    8 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-power.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c        |    8 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c      |    4 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c       |   20 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c        |    4 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c  |   86 +-
 drivers/net/wireless/libertas/assoc.c        |    6 +-
 drivers/net/wireless/libertas/cmd.c          |  198 ++---
 drivers/net/wireless/libertas/cmd.h          |    4 +
 drivers/net/wireless/libertas/cmdresp.c      |   47 -
 drivers/net/wireless/libertas/defs.h         |   27 -
 drivers/net/wireless/libertas/dev.h          |    3 -
 drivers/net/wireless/libertas/host.h         |   24 +-
 drivers/net/wireless/libertas/hostcmd.h      |   10 +-
 drivers/net/wireless/libertas/if_usb.c       |    5 +-
 drivers/net/wireless/libertas/wext.c         |  156 ++--
 drivers/net/wireless/libertas_tf/main.c      |   18 +-
 drivers/net/wireless/mac80211_hwsim.c        |  192 +++-
 drivers/net/wireless/orinoco.c               |   14 +-
 drivers/net/wireless/p54/p54common.c         |   14 +-
 drivers/net/wireless/p54/p54pci.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2500usb.c      |    2 +-
 drivers/net/wireless/rt2x00/rt2x00.h         |    2 +-
 drivers/net/wireless/rt2x00/rt2x00config.c   |    8 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c      |    8 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h      |    2 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c      |   18 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c    |   21 +-
 drivers/net/wireless/rtl8180_dev.c           |   10 +-
 drivers/net/wireless/rtl8187_dev.c           |    8 +-
 drivers/net/wireless/zd1211rw/Makefile       |    2 +-
 drivers/net/wireless/zd1211rw/zd_chip.c      |    1 -
 drivers/net/wireless/zd1211rw/zd_ieee80211.c |  100 --
 drivers/net/wireless/zd1211rw/zd_ieee80211.h |   95 --
 drivers/net/wireless/zd1211rw/zd_mac.c       |   60 +-
 drivers/net/wireless/zd1211rw/zd_mac.h       |   65 ++-
 drivers/net/wireless/zd1211rw/zd_rf.c        |    2 +-
 include/linux/nl80211.h                      |   96 ++-
 include/net/cfg80211.h                       |   60 ++
 include/net/mac80211.h                       |  105 ++-
 include/net/wireless.h                       |   58 ++
 net/mac80211/Kconfig                         |   13 -
 net/mac80211/cfg.c                           |   86 +-
 net/mac80211/debugfs.c                       |    4 -
 net/mac80211/debugfs_key.c                   |    3 +-
 net/mac80211/debugfs_netdev.c                |   72 +-
 net/mac80211/debugfs_sta.c                   |    6 +-
 net/mac80211/ht.c                            |   28 +-
 net/mac80211/ieee80211_i.h                   |  233 +++---
 net/mac80211/iface.c                         |  608 ++++++++++++-
 net/mac80211/key.c                           |    8 +-
 net/mac80211/main.c                          |  608 ++-----------
 net/mac80211/mesh.c                          |  337 ++++++--
 net/mac80211/mesh.h                          |   15 +-
 net/mac80211/mesh_hwmp.c                     |  108 ++--
 net/mac80211/mesh_pathtbl.c                  |    8 +-
 net/mac80211/mesh_plink.c                    |   66 +-
 net/mac80211/mlme.c                          |  875 ++++++++----------
 net/mac80211/rate.h                          |    2 +-
 net/mac80211/rc80211_pid.h                   |    2 +
 net/mac80211/rc80211_pid_algo.c              |   53 +-
 net/mac80211/rx.c                            |   98 +-
 net/mac80211/scan.c                          |  208 +++---
 net/mac80211/sta_info.c                      |   89 ++-
 net/mac80211/sta_info.h                      |   27 +-
 net/mac80211/tkip.c                          |    2 +-
 net/mac80211/tx.c                            |  187 ++--
 net/mac80211/util.c                          |  135 +++-
 net/mac80211/wext.c                          |  122 +--
 net/mac80211/wme.c                           |    2 +-
 net/mac80211/wme.h                           |    1 -
 net/mac80211/wpa.c                           |    2 +-
 net/rfkill/rfkill.c                          |   16 +-
 net/wireless/Kconfig                         |   32 +
 net/wireless/core.c                          |  162 ++++-
 net/wireless/core.h                          |    2 +-
 net/wireless/nl80211.c                       |  151 +++
 net/wireless/reg.c                           |  805 ++++++++++++++---
 net/wireless/reg.h                           |   44 +
 108 files changed, 5312 insertions(+), 3467 deletions(-)
 create mode 100644 Documentation/networking/regulatory.txt
 delete mode 100644 drivers/net/wireless/zd1211rw/zd_ieee80211.c
 delete mode 100644 drivers/net/wireless/zd1211rw/zd_ieee80211.h
 create mode 100644 net/wireless/reg.h

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2008-09-15.patch.bz2

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
