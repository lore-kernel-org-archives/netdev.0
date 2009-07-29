From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2009-07-29
Date: Wed, 29 Jul 2009 16:54:23 -0400
Message-ID: <20090729205423.GC10056@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53191 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387AbZG2VBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 17:01:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is another batch of wireless bits intended for 2.6.32...  Once
again, there is no particular theme to the bunch.  This does cover the
usual round of driver updates for iwlwifi, ath9k, and others.  There ar=
e
also some mac80211 and cfg80211 updates, including the final piece for
cfg80211 to supplant wireless extensions -- hooray!

Please let me know if there are problems!

John

P.S.  There is a merge-test branch that contains sample merge conflict
resolutions.  They are mostly simple.

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6/

---

The following changes since commit 70034918930d2e5b68c09bced637228c50d9=
561a:
  Stephen Rothwell (1):
        net: fix multiple definitions of setup_w6692

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git master

Alexander Beregalov (1):
      ar9170: fix build error when !CONFIG_AR9170_LEDS

Gabor Juhos (2):
      ath9k: fix race with IEEE80211_CONF_PS checks
      ath9k: get rid of unnecessary setpower calls

Helmut Schaa (8):
      mac80211: refactor the scan code
      mac80211: advance the state machine immediately if no delay is ne=
eded
      mac80211: introduce a new scan state "decision"
      mac80211: Replace {sw, hw}_scanning variables with a bitfield
      mac80211: implement basic background scanning
      mac80211: rename scan_state to next_scan_state
      cfg80211: increase scan result expire time
      mac80211: fix an oops in ieee80211_scan_state_set_channel

Johannes Berg (16):
      mac80211: cooperate more with network namespaces
      cfg80211: make aware of net namespaces
      mac80211: allow using network namespaces
      mac80211: fix mlme timeouts
      mac80211: fix PS-poll response, race
      iwlwifi: fix up command sending
      iwlwifi: remove command callback return value
      cfg80211: fix circular lock dependency (1)
      mac80211: fix receiving deauth
      nl80211: add missing parameter clearing
      cfg80211: fix disassoc while not associated
      mac80211: verify info->control.vif is not NULL
      cfg80211: combine iwfreq implementations
      cfg80211: combine IWAP handlers
      cfg80211: combine IWESSID handlers
      cfg80211: self-contained wext handling where possible

John W. Linville (1):
      ray_cs: remove bogus NULL check at head of ray_get_wireless_stats

Lars Ericsson (1):
      rt2x00: Don't alter rt2x00dev->default_ant

Luis R. Rodriguez (4):
      ath: map TH to FCC3_WORLD
      mac80211: fix MLME issuing of probe requests while scanning
      mac80211: fix oops due to missing private data
      ath9k: remove unused ATH_PCI_VERSION

Pavel Machek (1):
      iwlwifi: fix LED config option

Reinette Chatre (3):
      iwlwifi: print packet contents in error case
      iwlagn: fix null pointer access during ucode load on 1000
      iwlagn: fix sparse warning when compiling without debug

Sujith (7):
      mac80211: Add a few 802.11n defines for AMPDU parameters
      ath9k: Trivial fix in Kconfig
      ath9k: Fix a sparse warning
      ath9k: Remove redundant HT macros
      ath9k: Cleanup return values
      ath9k: Remove a few redundant variables/macros
      ath9k: Add debug counters for TX

Vivek Natarajan (2):
      ath9k: Add init values for AR9287 based chipsets.
      ath9k: Add support for AR9287 based chipsets.

Wey-Yi Guy (7):
      iwlwifi: revert to active table when rate is not valid
      iwlwifi: critical temperature enter/exit condition
      iwlwifi: Thermal Throttling Management - Part 1
      iwlwifi: Thermal Throttling Management - part 2
      iwlwifi: Thermal Throttling debugfs function
      iwlwifi: Name fix for MPDU density for TX aggregation
      iwlwifi: debugFs to enable/disable HT40 support

 drivers/net/wireless/ath/ar9170/main.c      |    2 +
 drivers/net/wireless/ath/ath9k/Kconfig      |    4 +-
 drivers/net/wireless/ath/ath9k/ath9k.h      |   11 +-
 drivers/net/wireless/ath/ath9k/calib.c      |   22 +-
 drivers/net/wireless/ath/ath9k/debug.c      |   85 ++
 drivers/net/wireless/ath/ath9k/debug.h      |   54 +
 drivers/net/wireless/ath/ath9k/eeprom.c     | 1203 +++++++++++++++++++=
++-
 drivers/net/wireless/ath/ath9k/eeprom.h     |  163 +++-
 drivers/net/wireless/ath/ath9k/hw.c         |  133 ++-
 drivers/net/wireless/ath/ath9k/hw.h         |    5 +-
 drivers/net/wireless/ath/ath9k/initvals.h   | 1516 +++++++++++++++++++=
++++++++
 drivers/net/wireless/ath/ath9k/main.c       |   35 +-
 drivers/net/wireless/ath/ath9k/pci.c        |    2 +
 drivers/net/wireless/ath/ath9k/phy.h        |    1 +
 drivers/net/wireless/ath/ath9k/xmit.c       |   85 +-
 drivers/net/wireless/ath/regd_common.h      |    2 +-
 drivers/net/wireless/iwlwifi/Kconfig        |    3 +
 drivers/net/wireless/iwlwifi/iwl-1000.c     |   77 ++-
 drivers/net/wireless/iwlwifi/iwl-3945-led.c |   11 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c     |   18 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h     |    9 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c     |    4 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c     |   45 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c     |   59 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c   |   85 ++-
 drivers/net/wireless/iwlwifi/iwl-agn.c      |   23 +-
 drivers/net/wireless/iwlwifi/iwl-calib.c    |    4 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h |    7 +
 drivers/net/wireless/iwlwifi/iwl-core.c     |   35 +-
 drivers/net/wireless/iwlwifi/iwl-core.h     |    6 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h    |    2 +
 drivers/net/wireless/iwlwifi/iwl-debugfs.c  |   84 ++
 drivers/net/wireless/iwlwifi/iwl-dev.h      |  116 ++-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c     |   63 +-
 drivers/net/wireless/iwlwifi/iwl-led.c      |    4 +-
 drivers/net/wireless/iwlwifi/iwl-power.c    |  526 ++++++++++
 drivers/net/wireless/iwlwifi/iwl-power.h    |   93 ++
 drivers/net/wireless/iwlwifi/iwl-scan.c     |    8 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c      |   48 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c       |  100 ++-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   20 +-
 drivers/net/wireless/iwmc3200wifi/Kconfig   |    1 -
 drivers/net/wireless/iwmc3200wifi/Makefile  |    2 +-
 drivers/net/wireless/iwmc3200wifi/iwm.h     |    2 -
 drivers/net/wireless/iwmc3200wifi/netdev.c  |    1 -
 drivers/net/wireless/iwmc3200wifi/wext.c    |  187 ----
 drivers/net/wireless/p54/txrx.c             |    2 +-
 drivers/net/wireless/ray_cs.c               |    3 -
 drivers/net/wireless/rt2x00/rt2x00config.c  |   12 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h     |    2 +-
 drivers/net/wireless/rt2x00/rt2x00link.c    |    4 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c     |    2 +-
 include/linux/ieee80211.h                   |   25 +
 include/linux/nl80211.h                     |    9 +
 include/net/cfg80211.h                      |  104 +-
 include/net/mac80211.h                      |    4 +
 net/core/dev.c                              |    1 +
 net/mac80211/Kconfig                        |    1 -
 net/mac80211/Makefile                       |    1 -
 net/mac80211/cfg.c                          |   14 +-
 net/mac80211/ibss.c                         |    2 +-
 net/mac80211/ieee80211_i.h                  |   45 +-
 net/mac80211/iface.c                        |   22 +-
 net/mac80211/main.c                         |    3 +-
 net/mac80211/mesh.c                         |    2 +-
 net/mac80211/mlme.c                         |   35 +-
 net/mac80211/rx.c                           |   21 +-
 net/mac80211/scan.c                         |  304 ++++--
 net/mac80211/sta_info.h                     |   13 -
 net/mac80211/tx.c                           |  109 +--
 net/mac80211/util.c                         |   13 +
 net/mac80211/wext.c                         |  235 -----
 net/wireless/core.c                         |   78 ++-
 net/wireless/core.h                         |    8 +-
 net/wireless/ibss.c                         |   13 +-
 net/wireless/mlme.c                         |    8 +
 net/wireless/nl80211.c                      |  206 +++--
 net/wireless/scan.c                         |   25 +-
 net/wireless/sme.c                          |    5 +-
 net/wireless/wext-compat.c                  |  180 +++-
 net/wireless/wext-compat.h                  |   50 +
 net/wireless/wext-sme.c                     |   13 +-
 82 files changed, 5381 insertions(+), 1159 deletions(-)
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/wext.c
 delete mode 100644 net/mac80211/wext.c
 create mode 100644 net/wireless/wext-compat.h

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2009-07-29.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
			=A1Viva Honduras Libre!
