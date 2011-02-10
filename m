From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 10 Feb 2011 11:33:20 -0800 (PST)
Message-ID: <20110210.113320.104051706.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50891
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756718Ab1BJTco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Feb 2011 14:32:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Fix for x25 rmmod hang w/DEBUG_PAGE_ALLOC found by Randy Dunlap.

2) Fix for the hysdn "writes to const" bug, also found by Randy.

3) virtio_net napi_enable() fix from Bruce Rogers via Rusty.

4) Fix network device queue lockdep regression, we initialize the
   lockdep class (based upon dev->type) before we invoke setup()
   callback, which is where dev->type is actually set properly.

5) While fixing #4 I found a bug in net/caif wherein is uses
   the setup() function to create state that would need to
   be unwound on failure, which isn't possible in this context.

6) x25 leaks SKBs on bad facilities, fix from Andrew Hendry.

7) pch_gbe wedges when rx offload is set by ethtool, fix from Toshiharu Okada.

8) pch_can bug fixes from Tomoya MORINAGA.

9) batman-adv packet merging can crash on non-linear packets, fix from
   Sven Eckelmann.

10) Double SKB free fix in ath9k from Mohammed Shafi Shajakhan.

11) Mem leak in sis900 RX error path, from Jesper Juhl.

12) Fix mac80211 SKB clone check in TX path, from Felix Fietkau.

13) ixgbe header split erratum fix from Don Skidmore.

Please pull, thanks a lot!

The following changes since commit 6148a47ac3872092d4bc4888838bec6dff16654d:

  Merge branch 'rc-fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/mmarek/kbuild-2.6 (2011-02-09 16:56:33 -0800)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ajit Khaparde (1):
      benet: Avoid potential null deref in be_cmd_get_seeprom_data()

Alexander Duyck (1):
      ixgbe: limit VF access to network traffic

Alexey Orishko (2):
      CDC NCM errata updates for cdc.h
      USB CDC NCM errata updates for cdc_ncm host driver

Bruce Rogers (1):
      virtio_net: Add schedule check to napi_enable call

Christian Lamparter (1):
      carl9170: fix typo in PS code

David S. Miller (8):
      Merge branch 'batman-adv/merge' of git://git.open-mesh.org/ecsv/linux-merge
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      Merge branch 'master' of master.kernel.org:/.../jkirsher/net-2.6
      net/caif: Fix dangling list pointer in freed object on error.
      net: Fix lockdep regression caused by initializing netdev queues too early.
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6
      isdn: hysdn: Kill (partially buggy) CVS regision log reporting.
      x25: Do not reference freed memory.

Don Fry (1):
      iwlagn: Re-enable RF_KILL interrupt when down

Don Skidmore (3):
      ixgbe: fix for 82599 erratum on Header Splitting
      ixgbe: cleanup variable initialization
      ixgbe: update version string

Emil Tantilov (1):
      ixgbe: fix variable set but not used warnings by gcc 4.6

Felix Fietkau (1):
      mac80211: fix the skb cloned check in the tx path

Florian Fainelli (1):
      e1000: add support for Marvell Alaska M88E1118R PHY

Jesper Juhl (2):
      wireless, wl1251: Fix potential NULL pointer dereference in wl1251_op_bss_info_changed()
      sis900: Fix mem leak in sis900_rx error path

Jesse Brandeburg (1):
      e1000e: tx_timeout should not increment for non-hang events

Johannes Berg (1):
      mac80211: fix TX status cookie in HW offload case

Michael Buesch (1):
      ssb-pcmcia: Fix parsing of invariants tuples

Mohammed Shafi Shajakhan (1):
      ath9k: Fix possible double free of PAPRD skb's

Pablo Neira Ayuso (1):
      netfilter: nf_conntrack: set conntrack templates again if we return NF_REPEAT

Randy Dunlap (1):
      can: softing_cs needs slab.h

Sven Eckelmann (1):
      batman-adv: Linearize fragment packets before merge

Tomoya (3):
      pch_can: fix 800k comms issue
      pch_can: fix rmmod issue
      pch_can: fix module reload issue with MSI

Tomoya MORINAGA (1):
      pch_can: fix tseg1/tseg2 setting issue

Toshiharu Okada (1):
      pch_gbe: Fix the issue which a driver locks when rx offload is set by ethtool

Vladislav Zolotarov (1):
      bnx2x: Duplication in promisc mode

Wey-Yi Guy (1):
      iwlagn: overwrite EEPROM chain setting for 6250 devices

andrew hendry (1):
      x25: possible skb leak on bad facilities

 drivers/isdn/hysdn/hysdn_defs.h         |    2 -
 drivers/isdn/hysdn/hysdn_init.c         |   26 +----
 drivers/isdn/hysdn/hysdn_net.c          |    3 -
 drivers/isdn/hysdn/hysdn_procconf.c     |    3 +-
 drivers/net/benet/be_cmds.c             |    5 +
 drivers/net/bnx2x/bnx2x_main.c          |   32 +++--
 drivers/net/can/pch_can.c               |    5 +-
 drivers/net/can/softing/softing_cs.c    |    1 +
 drivers/net/e1000/e1000_hw.c            |    4 +-
 drivers/net/e1000/e1000_hw.h            |    1 +
 drivers/net/e1000e/netdev.c             |    1 -
 drivers/net/ixgbe/ixgbe_common.c        |    3 +
 drivers/net/ixgbe/ixgbe_fcoe.c          |    2 +-
 drivers/net/ixgbe/ixgbe_main.c          |   16 ++-
 drivers/net/ixgbe/ixgbe_sriov.c         |    2 -
 drivers/net/ixgbe/ixgbe_x540.c          |    6 +-
 drivers/net/pch_gbe/pch_gbe_main.c      |   12 +-
 drivers/net/sis900.c                    |    1 +
 drivers/net/usb/cdc_ncm.c               |  227 ++++++++++++++++++++-----------
 drivers/net/virtio_net.c                |   27 ++--
 drivers/net/wireless/ath/ath9k/ath9k.h  |    2 +-
 drivers/net/wireless/ath/ath9k/main.c   |    2 -
 drivers/net/wireless/ath/ath9k/xmit.c   |    7 +-
 drivers/net/wireless/ath/carl9170/rx.c  |    2 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c |    2 +
 drivers/net/wireless/iwlwifi/iwl-agn.c  |    6 +
 drivers/net/wireless/wl1251/main.c      |    3 +
 drivers/ssb/pcmcia.c                    |    2 +-
 include/linux/usb/cdc.h                 |   23 +++-
 net/batman-adv/unicast.c                |   15 ++-
 net/caif/chnl_net.c                     |    4 +-
 net/core/dev.c                          |   27 ++--
 net/mac80211/cfg.c                      |    2 +
 net/mac80211/ieee80211_i.h              |    2 +-
 net/mac80211/status.c                   |    7 +-
 net/mac80211/tx.c                       |    2 +-
 net/netfilter/nf_conntrack_core.c       |   11 ++-
 net/x25/x25_facilities.c                |   28 +++--
 net/x25/x25_in.c                        |   14 ++-
 net/x25/x25_link.c                      |    5 +-
 40 files changed, 342 insertions(+), 203 deletions(-)
