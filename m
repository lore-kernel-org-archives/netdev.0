From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2012-05-14
Date: Mon, 14 May 2012 15:55:08 -0400
Message-ID: <20120514195508.GC2428@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50044 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932263Ab2ENUCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 16:02:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 341352d13dae752610342923c53ebe461624ee2c

Dave,

This is essentially the same batch of updates for 3.5 that I originally
offered ~1.5 weeks ago.  The difference is that I rebased the tree
both to drop the offending bluetooth-next pull and to base on top of
a more recent net-next in order to resolve the continuing NLA_PUT_*
issues affecting linux-next.  I also took the opportunity to resolve
a little merge damage resulting from a recent pull of the net tree
into net-next.

Other highlights of this pull request include some HT enhancements
for mac80211, an expansion of the ethtool support for cfg80211-
and mac80211-based drivers, and some more iwlwifi refactoring.

Please let me know if there are problems!

John

---

The following changes since commit 9bb862beb6e5839e92f709d33fda07678f062f20:

  Merge branch 'master' of git://1984.lsi.us.es/net-next (2012-05-08 14:40:21 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git master

Amitkumar Karwar (1):
      mwifiex: fix static checker warnings

Anisse Astier (2):
      rt2x00: debugfs support - allow a register to be empty
      rt2x00: Add debugfs access for rfcsr register

Ashok Nagarajan (4):
      mac80211: Advertise HT protection mode in IEs
      mac80211: Implement HT mixed protection mode
      mac80211: Allow nonHT/HT peering in mesh
      {nl,cfg,mac}80211: Allow user to see/configure HT protection mode

Ben Greear (4):
      cfg80211: Add framework to support ethtool stats.
      mac80211: Support getting sta_info stats via ethtool.
      mac80211: Framework to get wifi-driver stats via ethtool.
      mac80211: Add more ethtools stats: survey, rates, etc

Ben Hutchings (2):
      ipw2200: Fix order of device registration
      ipw2100: Fix order of device registration

Dan Carpenter (1):
      wireless: at76c50x: allocating too much data

Emmanuel Grumbach (3):
      iwlwifi: use IWL_* instead of dev_printk when possible
      iwlwifi: don't init trans->reg_lock from the op_mode
      cfg80211: fix BSS comparison

Franky Lin (4):
      brcmfmac: stop releasing sdio host in irq handler
      brcmfmac: check bus state for status
      brcmfmac: postpone interrupt register function
      brcmfmac: add out of band interrupt support

John W. Linville (1):
      iwlwifi: fix-up some merge damage from commit 0d6c4a2

Luis R. Rodriguez (1):
      libertas: include sched.h on firmware.c

Meenakshi Venkataraman (1):
      iwlwifi: use correct released ucode version

Rajkumar Manoharan (1):
      mac80211: fix rate control update on 2040 bss change

Stanislav Yakovlev (1):
      net/wireless: ipw2200: Fix WARN_ON occurring in wiphy_register called by ipw_pci_probe

Stanislaw Gruszka (1):
      iwlwifi: add option to disable 5GHz band

Thomas Pedersen (2):
      mac80211: insert mesh peer after init
      mac80211: don't transmit 40MHz frames to 20MHz peer

WarheadsSE (1):
      mwifiex: add support for SD8786 sdio

Wey-Yi Guy (11):
      iwlwifi: remove unused macros
      iwlwifi: add BT reduced tx power flag
      iwlwifi: add checking for the condition to reduce tx power
      iwlwifi: add reduced tx power threshold define
      iwlwifi: small define change
      iwlwifi: send reduce tx power info in command
      iwlwifi: change kill mask based on reduce power state
      iwlwifi: add loose coex lut
      iwlwifi: modify #ifdef to avoid sparse complain
      iwlwifi: remove the iwl_shared reference
      iwlwifi: use 6000G2B for 6030 device series

 drivers/net/wireless/at76c50x-usb.c                |    4 +-
 drivers/net/wireless/brcm80211/Kconfig             |    9 +
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |   97 ++++++++++-
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |  105 +++++++++++-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |   39 +++--
 .../net/wireless/brcm80211/brcmfmac/sdio_host.h    |   22 ++-
 drivers/net/wireless/ipw2x00/ipw2100.c             |   24 ++--
 drivers/net/wireless/ipw2x00/ipw2200.c             |   44 ++---
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |  153 ++++++++---------
 drivers/net/wireless/iwlwifi/iwl-agn-rx.c          |    3 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |   38 ++--
 drivers/net/wireless/iwlwifi/iwl-agn.h             |    2 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |   21 ++-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |    1 +
 drivers/net/wireless/iwlwifi/iwl-drv.c             |   12 +-
 drivers/net/wireless/iwlwifi/iwl-modparams.h       |    8 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c      |    1 +
 drivers/net/wireless/libertas/firmware.c           |    1 +
 drivers/net/wireless/mwifiex/Kconfig               |    4 +-
 drivers/net/wireless/mwifiex/fw.h                  |    3 +-
 drivers/net/wireless/mwifiex/sdio.c                |    7 +
 drivers/net/wireless/mwifiex/sdio.h                |    1 +
 drivers/net/wireless/rt2x00/rt2800.h               |    2 +
 drivers/net/wireless/rt2x00/rt2800lib.c            |    7 +
 drivers/net/wireless/rt2x00/rt2x00debug.c          |   82 +++++----
 drivers/net/wireless/rt2x00/rt2x00debug.h          |    1 +
 include/linux/nl80211.h                            |    3 +
 include/net/cfg80211.h                             |   18 ++
 include/net/mac80211.h                             |   17 ++
 net/mac80211/cfg.c                                 |  182 ++++++++++++++++++++
 net/mac80211/driver-ops.h                          |   37 ++++
 net/mac80211/driver-trace.h                        |   15 ++
 net/mac80211/ibss.c                                |    2 +-
 net/mac80211/ieee80211_i.h                         |    3 +-
 net/mac80211/mesh.c                                |   18 ++-
 net/mac80211/mesh_plink.c                          |   96 ++++++++++-
 net/mac80211/mlme.c                                |    2 +-
 net/mac80211/sta_info.h                            |    1 +
 net/mac80211/util.c                                |    9 +-
 net/wireless/ethtool.c                             |   29 +++
 net/wireless/mesh.c                                |    1 +
 net/wireless/nl80211.c                             |    7 +-
 net/wireless/scan.c                                |    6 +-
 43 files changed, 893 insertions(+), 244 deletions(-)
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
