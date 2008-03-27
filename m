From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6.26 2008-03-27
Date: Thu, 27 Mar 2008 16:55:25 -0400
Message-ID: <20080327205525.GB17267@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2334 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757511AbYC0VUe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 17:20:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is another quick round of patches intended for 2.6.26.  Included
are libertas and iwlwifi updates, including the long-awaited LED support
for the iwlwifi drivers.  Also included is the fix for the
ieee80211_get_channel symbol conflict currently in the net-2.6.26 tree.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6.26/

---

The following changes since commit 5983a3dff0036d7ef6a2139473564f4f3e7b2a11:
  Benjamin Thery (1):
        [NETNS][IPV6] flowlabels - make proc per namespace

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.26.git master

Emmanuel Grumbach (1):
      iwlwifi: allow a default callback for ASYNC host commands

Holger Schurig (4):
      libertas: kill useless #define LBS_MONITOR_OFF 0
      libertas: remove CMD_802_11_PWR_CFG
      libertas: the compact flash driver is no longer experimental
      libertas: reduce debug output

Johannes Berg (2):
      cfg80211: don't export ieee80211_get_channel
      mac80211: reorder fields to make some structures smaller

John W. Linville (3):
      mac80211: silently accept deletion of non-existant key
      iwlwifi: do not register bands with no supported channels
      prism54: correct thinko in "prism54: Convert stats_sem in a mutex"

Mohamed Abbas (1):
      iwlwifi: Add led support

Ron Rindjunsky (2):
      mac80211: fix wrong Rx A-MPDU control via debugfs
      mac80211: A-MPDU MLME use dynamic allocation

Tomas Winkler (3):
      iwlwifi: rename iwl-4965-io.h to iwl-io.h
      iwlwifi: improve NIC i/o debug prints information
      iwlwifi: iwl_priv - clean up in types of members

 drivers/net/wireless/Kconfig                |    2 +-
 drivers/net/wireless/iwlwifi/Kconfig        |   20 ++
 drivers/net/wireless/iwlwifi/Makefile       |   10 +
 drivers/net/wireless/iwlwifi/iwl-3945-led.c |  433 ++++++++++++++++++++++++++
 drivers/net/wireless/iwlwifi/iwl-3945-led.h |   73 +++++
 drivers/net/wireless/iwlwifi/iwl-3945.c     |    6 +
 drivers/net/wireless/iwlwifi/iwl-3945.h     |   17 +-
 drivers/net/wireless/iwlwifi/iwl-4965-io.h  |  426 -------------------------
 drivers/net/wireless/iwlwifi/iwl-4965-rs.c  |    2 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c     |  221 +++++++-------
 drivers/net/wireless/iwlwifi/iwl-4965.h     |   17 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h      |    6 +
 drivers/net/wireless/iwlwifi/iwl-debugfs.c  |    8 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c   |   26 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c     |   30 ++-
 drivers/net/wireless/iwlwifi/iwl-io.h       |  429 +++++++++++++++++++++++++
 drivers/net/wireless/iwlwifi/iwl-led.c      |  447 +++++++++++++++++++++++++++
 drivers/net/wireless/iwlwifi/iwl-led.h      |   82 +++++
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   22 ++-
 drivers/net/wireless/iwlwifi/iwl4965-base.c |  253 ++++++++-------
 drivers/net/wireless/libertas/cmd.c         |   14 +-
 drivers/net/wireless/libertas/cmdresp.c     |   12 +-
 drivers/net/wireless/libertas/defs.h        |   10 +-
 drivers/net/wireless/libertas/host.h        |    1 -
 drivers/net/wireless/libertas/hostcmd.h     |    9 -
 drivers/net/wireless/libertas/main.c        |   12 +-
 drivers/net/wireless/libertas/rx.c          |    2 +-
 drivers/net/wireless/libertas/tx.c          |    5 +-
 drivers/net/wireless/libertas/wext.h        |    2 -
 drivers/net/wireless/prism54/isl_ioctl.c    |    2 +-
 include/net/wireless.h                      |   18 +-
 net/mac80211/debugfs_sta.c                  |   19 +-
 net/mac80211/ieee80211.c                    |   64 +++--
 net/mac80211/ieee80211_i.h                  |   50 ++--
 net/mac80211/ieee80211_ioctl.c              |    3 -
 net/mac80211/ieee80211_sta.c                |   84 ++++--
 net/mac80211/rx.c                           |   10 +-
 net/mac80211/sta_info.c                     |   30 +-
 net/mac80211/sta_info.h                     |   49 ++--
 net/wireless/util.c                         |    6 +-
 40 files changed, 2052 insertions(+), 880 deletions(-)
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-3945-led.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-3945-led.h
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-4965-io.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-io.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-led.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-led.h

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6.26-2008-03-27.patch.bz2
-- 
John W. Linville
linville@tuxdriver.com
