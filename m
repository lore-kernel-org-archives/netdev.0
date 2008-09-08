From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2008-09-08
Date: Mon, 8 Sep 2008 15:04:32 -0400
Message-ID: <20080908190431.GB24557@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is another round intended for 2.6.28.  There are some
big cleanups, etc. for ath5k and b43 as well as a smattering of
fixes/updates for p54 and iwlwifi, and a few other bits.  There is
also a toshiba_acpi patch that depends on some of the rfkill patches
that have come through my tree.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6/

---

The following changes since commit a505f4ff49ff05ca9030069fab7de229dae7=
c819:
  Ilpo J=E4rvinen (1):
        s2io: reindented misleading for loop

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git master

Abhijeet Kolekar (6):
      iwlwifi : Added bss_info_changed callback to 3945
      iwl3945: fix unbalanced mutex
      iwl3945: replace association and beacon hooks with bss_info_chang=
ed cb
      iwl3945: removed bg_post_associate work
      iwl3945: avoid redundant iwl3945_get_active_dwell_time
      iwl3945: enable active scanning on active channels

Christian Lamparter (6):
      p54pci: increase ring buffer index counter when skipping
      p54: enhance firmware parser to reduce memory waste
      p54: move eeprom code into common library
      p54usb: support LM87 firmwares
      p54: set_filter refactoring
      p54: better firmware support

Emmanuel Grumbach (4):
      mac80211: Fix rate scale initialization in IBSS
      iwlwifi: fix strict_strtoul error checking
      iwlwifi: allow association on radar channel in power save
      iwlwifi: take a fresh set of supported rates at each cycle

Luis R. Rodriguez (1):
      cfg80211: keep track of supported interface modes

Michael Buesch (9):
      b43: Don't use memcpy for overlapping areas
      b43: Move remaining code from phy.c to phy_a.c
      b43: Move code from nphy.* to phy_n.*
      b43: Add LP-PHY template
      b43: Add LP-PHY read/write phyops
      b43: Add LP-PHY radio register definitions
      b43: Split PHY alloc and init
      b43: Move Analog switching into phy code
      b43: Replace hardcoded Analog switch

Nick Kossifidis (1):
      ath5k: HW code cleanup

Randy Dunlap (2):
      ath9k: uses/needs led_classdev_[un]register
      mac80211: add missing kernel-doc

Ron Rindjunsky (2):
      iwlwifi: remove obsolete 4965 forward declarations
      iwlwifi: allow consecutive scans in unassociated state

Stefanik G=E1bor (1):
      iwlwifi: enable packet injection for iwlagn

Tomas Winkler (10):
      mac80211: Fix low bit rate in IBSS
      iwlwifi: clean up hw scan handler
      iwlwifi: align set channel with mac80211
      iwlwifi: use strict_strtoul instead of simple_strtoul
      iwlwifi: replace readl and writel with io/read/write/32
      iwlwifi: remove rfkill warning from iwl-io
      iwlwifi: generic init calibrations framework
      iwlwifi: cleanup PCI register handling
      iwlwifi: fix host command header according the HW spec
      iwlwifi: remove bad language from the comments

philipl-tB29R6EoPa3YtjvyW6yDsg@public.gmane.org (1):
      toshiba_acpi: Add support for bluetooth toggling through rfkill (=
v8)

 drivers/acpi/Kconfig                         |    3 +
 drivers/acpi/toshiba_acpi.c                  |  261 ++-
 drivers/net/wireless/adm8211.c               |    1 +
 drivers/net/wireless/ath5k/Makefile          |   12 +-
 drivers/net/wireless/ath5k/ath5k.h           |  390 ++-
 drivers/net/wireless/ath5k/attach.c          |  315 ++
 drivers/net/wireless/ath5k/base.c            |   38 +-
 drivers/net/wireless/ath5k/caps.c            |  193 ++
 drivers/net/wireless/ath5k/debug.c           |    4 +-
 drivers/net/wireless/ath5k/desc.c            |  667 ++++
 drivers/net/wireless/ath5k/desc.h            |  332 ++
 drivers/net/wireless/ath5k/dma.c             |  566 ++++
 drivers/net/wireless/ath5k/eeprom.c          |  466 +++
 drivers/net/wireless/ath5k/eeprom.h          |  215 ++
 drivers/net/wireless/ath5k/gpio.c            |  176 +
 drivers/net/wireless/ath5k/hw.c              | 4492 ------------------=
--------
 drivers/net/wireless/ath5k/hw.h              |  616 ----
 drivers/net/wireless/ath5k/initvals.c        |   22 +-
 drivers/net/wireless/ath5k/pcu.c             | 1002 ++++++
 drivers/net/wireless/ath5k/phy.c             |   10 +-
 drivers/net/wireless/ath5k/qcu.c             |  488 +++
 drivers/net/wireless/ath5k/reg.h             |  102 +-
 drivers/net/wireless/ath5k/reset.c           |  925 ++++++
 drivers/net/wireless/ath9k/Kconfig           |    3 +
 drivers/net/wireless/ath9k/main.c            |    5 +
 drivers/net/wireless/b43/Kconfig             |   12 +
 drivers/net/wireless/b43/Makefile            |    3 +-
 drivers/net/wireless/b43/main.c              |   69 +-
 drivers/net/wireless/b43/phy.c               |  489 ---
 drivers/net/wireless/b43/phy_a.c             |  130 +-
 drivers/net/wireless/b43/phy_a.h             |    8 +-
 drivers/net/wireless/b43/phy_common.c        |   20 +-
 drivers/net/wireless/b43/phy_common.h        |   44 +-
 drivers/net/wireless/b43/phy_g.c             |  104 +-
 drivers/net/wireless/b43/phy_g.h             |    4 +-
 drivers/net/wireless/b43/phy_lp.c            |  155 +
 drivers/net/wireless/b43/phy_lp.h            |  540 ++++
 drivers/net/wireless/b43/{nphy.c =3D> phy_n.c} |   44 +-
 drivers/net/wireless/b43/{nphy.h =3D> phy_n.h} |    2 -
 drivers/net/wireless/b43/tables_nphy.c       |    2 +-
 drivers/net/wireless/b43legacy/main.c        |    5 +
 drivers/net/wireless/iwlwifi/iwl-3945-io.h   |   24 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c      |   81 -
 drivers/net/wireless/iwlwifi/iwl-3945.h      |    1 -
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h   |   13 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c      |    6 +-
 drivers/net/wireless/iwlwifi/iwl-5000-hw.h   |    7 +
 drivers/net/wireless/iwlwifi/iwl-5000.c      |   69 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c    |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c       |  127 +-
 drivers/net/wireless/iwlwifi/iwl-calib.c     |   60 +
 drivers/net/wireless/iwlwifi/iwl-commands.h  |   24 +-
 drivers/net/wireless/iwlwifi/iwl-core.c      |   34 +-
 drivers/net/wireless/iwlwifi/iwl-core.h      |   12 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h       |   27 +-
 drivers/net/wireless/iwlwifi/iwl-io.h        |   22 +-
 drivers/net/wireless/iwlwifi/iwl-power.c     |   66 +-
 drivers/net/wireless/iwlwifi/iwl-power.h     |    4 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c       |    5 +
 drivers/net/wireless/iwlwifi/iwl-tx.c        |   17 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c  |  145 +-
 drivers/net/wireless/mac80211_hwsim.c        |    3 +
 drivers/net/wireless/p54/p54.h               |   38 +-
 drivers/net/wireless/p54/p54common.c         |  293 ++-
 drivers/net/wireless/p54/p54common.h         |   75 +-
 drivers/net/wireless/p54/p54pci.c            |  173 +-
 drivers/net/wireless/p54/p54usb.c            |  180 +-
 drivers/net/wireless/p54/p54usb.h            |    5 +
 drivers/net/wireless/rt2x00/rt2x00dev.c      |    5 +
 drivers/net/wireless/rtl8187_dev.c           |    2 +
 drivers/net/wireless/zd1211rw/zd_mac.c       |    5 +
 include/linux/nl80211.h                      |    6 +
 include/net/wireless.h                       |    3 +
 net/mac80211/main.c                          |    7 +
 net/mac80211/mlme.c                          |   90 +-
 net/mac80211/rx.c                            |    4 -
 net/mac80211/sta_info.h                      |    1 +
 net/wireless/core.c                          |    9 +-
 net/wireless/nl80211.c                       |   22 +-
 79 files changed, 7906 insertions(+), 6698 deletions(-)
 create mode 100644 drivers/net/wireless/ath5k/attach.c
 create mode 100644 drivers/net/wireless/ath5k/caps.c
 create mode 100644 drivers/net/wireless/ath5k/desc.c
 create mode 100644 drivers/net/wireless/ath5k/desc.h
 create mode 100644 drivers/net/wireless/ath5k/dma.c
 create mode 100644 drivers/net/wireless/ath5k/eeprom.c
 create mode 100644 drivers/net/wireless/ath5k/eeprom.h
 create mode 100644 drivers/net/wireless/ath5k/gpio.c
 delete mode 100644 drivers/net/wireless/ath5k/hw.c
 delete mode 100644 drivers/net/wireless/ath5k/hw.h
 create mode 100644 drivers/net/wireless/ath5k/pcu.c
 create mode 100644 drivers/net/wireless/ath5k/qcu.c
 create mode 100644 drivers/net/wireless/ath5k/reset.c
 delete mode 100644 drivers/net/wireless/b43/phy.c
 create mode 100644 drivers/net/wireless/b43/phy_lp.c
 create mode 100644 drivers/net/wireless/b43/phy_lp.h
 rename drivers/net/wireless/b43/{nphy.c =3D> phy_n.c} (96%)
 rename drivers/net/wireless/b43/{nphy.h =3D> phy_n.h} (99%)

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2008-09-08.patch.bz2

--=20
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
