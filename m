From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6.26 2008-04-16
Date: Wed, 16 Apr 2008 16:44:17 -0400
Message-ID: <20080416204417.GA3127@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3468 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752589AbYDPU7e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 16:59:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Another week and still another 40 patches...  The biggest piece of this
is iwlwifi updates, but mac80211 and other drivers are represented as
well.  At least some of these are bugfixes for problems already in
net-2.6.26.

Let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6.26/

---

The following changes since commit dd9e0dda66ba38a2ddd1405ac279894260dc5c36:
  John Heffner (1):
        [TCP]: Increase the max_burst threshold from 3 to tp->reordering.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.26.git master

Abhijeet Kolekar (1):
      iwlwifi: replace sprintf with scnprintf for debugfs output

Alexey Dobriyan (1):
      proc: switch /proc/driver/ray_cs/ray_cs to seq_file interface

Emmanuel Grumbach (8):
      iwlwifi: add default WEP key host command
      iwlwifi: default WEP HW encryption
      iwlwifi: add 1X HW WEP support
      iwlwifi: maintain uCode key table state
      iwlwifi: moves security functions to iwl-sta.c
      iwlwifi: remove the statistics work
      iwlwifi: Fix TKIP update key and get_free_ucode_key
      iwlwifi: Use HW acceleration decryption by default

Holger Schurig (2):
      libertas: convert libertas driver to use an event/cmdresp queue
      libertas: un-garbage various command structs

Ivo van Doorn (1):
      rt2x00: Only free skb when beacon_update fails

Johannes Berg (6):
      mac80211: fix key hwaccel race
      mac80211: further RCU fixes
      mac80211: fix spinlock recursion
      mac80211: fix key todo list order
      mac80211: allow WDS mode
      mac80211: rework scanning to account for probe response/beacon difference

John W. Linville (1):
      mlme.c: fixup some merge damage

Michael Buesch (2):
      ssb-pcicore: Remove b44 TPS flag workaround
      b43: Add fastpath to b43_mac_suspend()

Mohamed Abbas (1):
      iwlwifi: fix unload warning and error

Nick Kossifidis (2):
      ath5k: Add RF2425 initvals
      ath5k: Misc fixes/cleanups

Reinette Chatre (4):
      mac80211: no BSS changes to driver from beacons processed during scanning
      iwl4965: make iwl4965_send_rxon_assoc asynchronous
      iwlwifi: make Makefile more concise
      iwlwifi: perform bss_info_changed post association work right away

Ron Rindjunsky (2):
      iwlwifi: move HW device registration
      iwlwifi: arrange max number of Tx queues

Stefano Brivio (1):
      b43legacy: fix TBTT and PU timings

Tomas Winkler (8):
      iwlwifi: generalize iwlwifi init flow
      iwlwifi: Fix byte count table for fragmented packets
      iwlwifi: move shared pointers to iwl_priv
      iwlwifi: hw_setting cleanup
      iwlwifi: support different num of tx and rx antennas
      iwlwifi: move the creation of LQ host command to iwlcore
      iwlwifi: introduce host commands callbacks
      iwlwifi: move rxon associated command to hcmd

 drivers/net/wireless/ath5k/ath5k.h               |   11 +-
 drivers/net/wireless/ath5k/base.c                |   14 +-
 drivers/net/wireless/ath5k/hw.c                  |  152 +++++-
 drivers/net/wireless/ath5k/initvals.c            |  234 +++++++++
 drivers/net/wireless/ath5k/phy.c                 |  123 +++++-
 drivers/net/wireless/ath5k/regdom.c              |  121 -----
 drivers/net/wireless/ath5k/regdom.h              |  500 -------------------
 drivers/net/wireless/b43/main.c                  |    7 +
 drivers/net/wireless/b43legacy/b43legacy.h       |    3 +
 drivers/net/wireless/b43legacy/main.c            |   34 ++-
 drivers/net/wireless/iwlwifi/Kconfig             |    2 +-
 drivers/net/wireless/iwlwifi/Makefile            |   29 +-
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h          |    2 +
 drivers/net/wireless/iwlwifi/iwl-4965-commands.h |   50 ++-
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h       |   22 +-
 drivers/net/wireless/iwlwifi/iwl-4965-rs.c       |   65 +---
 drivers/net/wireless/iwlwifi/iwl-4965.c          |  373 ++++++++++----
 drivers/net/wireless/iwlwifi/iwl-4965.h          |   41 +-
 drivers/net/wireless/iwlwifi/iwl-core.c          |   13 +
 drivers/net/wireless/iwlwifi/iwl-core.h          |   32 ++-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c       |   73 ++--
 drivers/net/wireless/iwlwifi/iwl-hcmd.c          |    1 +
 drivers/net/wireless/iwlwifi/iwl-rfkill.c        |    3 +
 drivers/net/wireless/iwlwifi/iwl-rfkill.h        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c           |  355 +++++++++++++
 drivers/net/wireless/iwlwifi/iwl-sta.h           |   49 ++
 drivers/net/wireless/iwlwifi/iwl3945-base.c      |    6 +-
 drivers/net/wireless/iwlwifi/iwl4965-base.c      |  575 ++++++----------------
 drivers/net/wireless/libertas/cmd.c              |   32 +-
 drivers/net/wireless/libertas/cmdresp.c          |   23 +-
 drivers/net/wireless/libertas/debugfs.c          |    1 -
 drivers/net/wireless/libertas/decl.h             |   10 +-
 drivers/net/wireless/libertas/defs.h             |    2 -
 drivers/net/wireless/libertas/dev.h              |   27 +-
 drivers/net/wireless/libertas/if_cs.c            |  244 ++++------
 drivers/net/wireless/libertas/if_sdio.c          |   65 +--
 drivers/net/wireless/libertas/if_usb.c           |   71 +--
 drivers/net/wireless/libertas/if_usb.h           |    2 -
 drivers/net/wireless/libertas/main.c             |  158 ++++---
 drivers/net/wireless/libertas/rx.c               |    4 +-
 drivers/net/wireless/libertas/tx.c               |   20 +-
 drivers/net/wireless/ray_cs.c                    |   73 ++--
 drivers/net/wireless/rt2x00/rt2x00dev.c          |    6 +-
 drivers/ssb/driver_pcicore.c                     |   12 +-
 include/net/mac80211.h                           |    3 +-
 net/mac80211/cfg.c                               |   22 +-
 net/mac80211/ieee80211_i.h                       |   12 +-
 net/mac80211/key.c                               |  101 +++--
 net/mac80211/key.h                               |   11 +-
 net/mac80211/main.c                              |    2 +
 net/mac80211/mlme.c                              |  144 ++++--
 net/mac80211/wext.c                              |    8 +
 53 files changed, 2077 insertions(+), 1870 deletions(-)
 delete mode 100644 drivers/net/wireless/ath5k/regdom.c
 delete mode 100644 drivers/net/wireless/ath5k/regdom.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-sta.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-sta.h

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6.26-2008-04-16.patch.gz
-- 
John W. Linville
linville@tuxdriver.com
