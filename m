From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 28 Sep 2011 01:36:33 -0400 (EDT)
Message-ID: <20110928.013633.2247775129404573208.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix two SKB leaks in ipv6 multicast cost, from Ben Greear.

2) BNX2X needs to hit the registers differently for HW Attention
   and Wake-On-Lan, from Dmitry Kravkov.

3) Missing break statement in dcbnl handling of bnx2x, fix from
   Shmulik Ravid.

4) dst_alloc() return value not checked in IPSEC, fix from Madalin
   Bucur.

5) Fix calculation of do_bcast in batman-adv stack, from Antonio Quartulli.

6) Wireless:
   a) Fix DMA getting stuck on ath9k AR9003 chips, from Rajkumar Manoharan.
   b) Mirror iwlagn command queue timeout fix in iwlegacy, from Johannes
      Berg.
   c) Similarly, mirror iwlagn interruptible wait fix in iwlegacy, from
      Stanislaw Gruszka.
   d) NL80211_ATTR_AKM_SUITES netlink blobs were not validated using
      the correct variable, fix from Jouni Malinen.
   e) iwl_scan_request() leaves ->scan_request and ->scan_vif dangling
      on failure, causing crashes later, fix from Johannes Berg.
   f) tcb_desc needs to be initialized fully in rtlwifi USB, from Larry
      Finger.
   g) DMA mappings left dangling on module unload in ath9k driver, from
      Mohammed Shafi.  Another bug found by the DMA debugging code.

Please pull, thanks a lot!

The following changes since commit a102a9ece5489e1718cd7543aa079082450ac3a2:

  Linux 3.1-rc8 (2011-09-27 15:48:34 -0700)

are available in the git repository at:
  git://github.com/davem330/net.git master

Antonio Quartulli (1):
      batman-adv: do_bcast has to be true for broadcast packets only

Ben Greear (2):
      ipv6-multicast: Fix memory leak in input path.
      ipv6-multicast: Fix memory leak in IPv6 multicast.

David S. Miller (2):
      Merge branch 'batman-adv/maint' of git://git.open-mesh.org/linux-merge
      Merge branch 'for-davem' of git://git.infradead.org/users/linville/wireless

Dmitry Kravkov (2):
      bnx2x: fix hw attention handling
      bnx2x: fix WOL by enablement PME in config space

Jason Wang (1):
      net: fix a typo in Documentation/networking/scaling.txt

Johannes Berg (1):
      iwlagn: fix dangling scan request

John W. Linville (1):
      Merge branch 'master' of git://git.infradead.org/users/linville/wireless into for-davem

Jouni Malinen (1):
      cfg80211: Fix validation of AKM suites

Larry Finger (1):
      rtlwifi: rtl8192cu: Fix unitialized struct

Madalin Bucur (2):
      net: check return value for dst_alloc
      ipv6: check return value for dst_alloc

Mohammed Shafi Shajakhan (1):
      ath9k: Fix a dma warning/memory leak

Rajkumar Manoharan (1):
      ath9k_hw: Fix Rx DMA stuck for AR9003 chips

Shmulik Ravid (1):
      bnx2x: add missing break in bnx2x_dcbnl_get_cap

Stanislaw Gruszka (2):
      iwlegacy: fix command queue timeout
      iwlegacy: do not use interruptible waits

 Documentation/networking/scaling.txt               |    2 +-
 drivers/net/bnx2x/bnx2x_dcb.c                      |    1 +
 drivers/net/bnx2x/bnx2x_main.c                     |   16 ++++++++--
 drivers/net/bnx2x/bnx2x_reg.h                      |   12 ++++++++
 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |    2 +-
 drivers/net/wireless/ath/ath9k/recv.c              |   10 ++++++-
 drivers/net/wireless/iwlegacy/iwl-core.c           |    4 +-
 drivers/net/wireless/iwlegacy/iwl-hcmd.c           |    2 +-
 drivers/net/wireless/iwlegacy/iwl-tx.c             |    4 ++-
 drivers/net/wireless/iwlegacy/iwl3945-base.c       |    8 ++--
 drivers/net/wireless/iwlegacy/iwl4965-base.c       |   10 +++---
 drivers/net/wireless/iwlwifi/iwl-scan.c            |   30 ++++++++++---------
 drivers/net/wireless/rtlwifi/usb.c                 |    1 +
 net/batman-adv/soft-interface.c                    |   10 +++---
 net/ipv6/ip6mr.c                                   |    8 ++++-
 net/ipv6/route.c                                   |    4 ++-
 net/wireless/nl80211.c                             |    5 ++-
 net/xfrm/xfrm_policy.c                             |   10 ++++--
 18 files changed, 93 insertions(+), 46 deletions(-)
