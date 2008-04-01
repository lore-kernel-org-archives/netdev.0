From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6.26 2008-04-01
Date: Tue, 1 Apr 2008 18:02:26 -0400
Message-ID: <20080401220225.GA32555@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4075 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756129AbYDAWda (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2008 18:33:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Another week, another load of patches for 2.6.26.  This round includes
some locking and other cleanups for mac80211, a few important rt2x00
patches that fix problems already living in net-2.6.26, and some more
libertas and iwlwifi patches.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6.26/

---

The following changes since commit dfb12eb70fc926562488515a9596c88b8eadc545:
  Pavel Emelyanov (1):
        [IPV6][NETNS]: Display per-net info in sockstat6 file.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.26.git master

Al Viro (1):
      endianness annotations: drivers/net/wireless/rtl8180_dev.c

Andrew Morton (1):
      net/mac80211/debugfs_netdev.c: use of bool triggers a gcc bug

Holger Schurig (4):
      libertas: convert CMD_802_11_MAC_ADDRESS to a direct command
      libertas: convert CMD_802_11_EEPROM_ACCESS to a direct command
      libertas: convert sleep/wake config direct commands
      libertas: don't depend on IEEE80211

Ivo van Doorn (3):
      rt2x00: Invert scheduled packet_filter check
      rt2x00: TO_DS filter depends on intf_ap_count
      rt2x00: Remove MAC80211_LEDS dependency

Johannes Berg (6):
      mac80211 ibss: flush only stations belonging to current interface
      mac80211: fix sta_info_destroy(NULL)
      mac80211: automatically free sta struct when insertion fails
      mac80211: clean up sta_info_destroy() users wrt. RCU/locking
      mac80211: sta_info_flush() fixes
      mac80211: fix sparse complaint in ieee80211_sta_def_wmm_params

John W. Linville (2):
      rt2x00: fixup some non-functional merge errors
      wireless: fix various printk warnings on ia64 (and others)

Luis Carlos Cobo (5):
      mac80211: fix deadlocks in debugfs_netdev.c
      mac80211: fix spinlock recursion on sta expiration
      mac80211: use recent multicast table for all mesh multicast frames
      mac80211: check for mesh_config length on incoming management frames
      mac80211: use a struct for bss->mesh_config

Mohamed Abbas (3):
      iwlwifi: add notification infrastructure to iwlcore
      iwlwifi: hook iwlwifi with Linux rfkill
      iwlwifi: fix race condition during driver unload

Reinette Chatre (1):
      iwlwifi: move rate registration to module load

Ron Rindjunsky (1):
      iwlwifi: unregister to upper stack before releasing resources

Tomas Winkler (2):
      iwlwifi: LED initialize before registering
      iwlwifi: Fix synchronous host command

 drivers/net/wireless/Kconfig                |    1 -
 drivers/net/wireless/ath5k/base.c           |    9 +-
 drivers/net/wireless/iwlwifi/Kconfig        |    6 +
 drivers/net/wireless/iwlwifi/Makefile       |    4 +
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c  |    6 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.h  |    4 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h     |   35 +++---
 drivers/net/wireless/iwlwifi/iwl-4965-rs.c  |    6 +-
 drivers/net/wireless/iwlwifi/iwl-4965-rs.h  |    4 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c     |   12 +-
 drivers/net/wireless/iwlwifi/iwl-4965.h     |   40 +++---
 drivers/net/wireless/iwlwifi/iwl-core.c     |   25 ++++
 drivers/net/wireless/iwlwifi/iwl-core.h     |   16 ++-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c     |    8 +-
 drivers/net/wireless/iwlwifi/iwl-led.c      |    6 +-
 drivers/net/wireless/iwlwifi/iwl-rfkill.c   |  174 ++++++++++++++++++++++++
 drivers/net/wireless/iwlwifi/iwl-rfkill.h   |   56 ++++++++
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   65 ++++++++--
 drivers/net/wireless/iwlwifi/iwl4965-base.c |  124 +++++++++++------
 drivers/net/wireless/libertas/cmd.c         |   84 ++----------
 drivers/net/wireless/libertas/cmdresp.c     |   63 +--------
 drivers/net/wireless/libertas/decl.h        |    5 +
 drivers/net/wireless/libertas/dev.h         |    6 +-
 drivers/net/wireless/libertas/ethtool.c     |   67 +++-------
 drivers/net/wireless/libertas/hostcmd.h     |   22 ++--
 drivers/net/wireless/libertas/main.c        |   68 ++++++----
 drivers/net/wireless/libertas/wext.h        |   11 --
 drivers/net/wireless/rt2x00/Kconfig         |   14 +--
 drivers/net/wireless/rt2x00/rt2400pci.c     |   66 ++++++----
 drivers/net/wireless/rt2x00/rt2500pci.c     |   66 ++++++----
 drivers/net/wireless/rt2x00/rt2500usb.c     |   88 ++++++-------
 drivers/net/wireless/rt2x00/rt2x00.h        |    7 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c     |   14 +-
 drivers/net/wireless/rt2x00/rt2x00leds.c    |  131 +++++++++---------
 drivers/net/wireless/rt2x00/rt2x00leds.h    |   21 +---
 drivers/net/wireless/rt2x00/rt2x00lib.h     |   12 ++
 drivers/net/wireless/rt2x00/rt2x00mac.c     |   17 ++-
 drivers/net/wireless/rt2x00/rt61pci.c       |   67 ++++++----
 drivers/net/wireless/rt2x00/rt73usb.c       |   73 ++++++----
 drivers/net/wireless/rtl8180_dev.c          |    4 +-
 net/mac80211/cfg.c                          |    8 +-
 net/mac80211/debugfs_netdev.c               |   16 ++-
 net/mac80211/ieee80211.c                    |    2 +-
 net/mac80211/ieee80211_i.h                  |   15 ++-
 net/mac80211/ieee80211_sta.c                |   54 +++++---
 net/mac80211/key.c                          |    9 ++
 net/mac80211/mesh.c                         |    4 -
 net/mac80211/mesh.h                         |   10 ++
 net/mac80211/mesh_plink.c                   |    6 +-
 net/mac80211/rx.c                           |    2 +-
 net/mac80211/sta_info.c                     |  193 +++++++++++++++++++++------
 net/mac80211/sta_info.h                     |    3 +
 52 files changed, 1134 insertions(+), 695 deletions(-)
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-rfkill.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-rfkill.h

Omnibus patch available here:

	http://www.kenrnel.org/pub/linux/kernel/people/linville/wireless-2.6.26-2008-04-01.patch.bz2
-- 
John W. Linville
linville@tuxdriver.com
