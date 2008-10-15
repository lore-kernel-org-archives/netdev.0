From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 15 Oct 2008 16:38:17 -0700 (PDT)
Message-ID: <20081015.163817.193700221.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52524
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751973AbYJOXil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2008 19:38:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Highlights:

1) Memory leak and ipv6 statistic fix for network namespaces from
   Alexey Dobriyan.

2) Fixes and new device ID additions in wireless via John Linville
   and co.

3) IPV6 default gateway selection fix from Pedro Ribeiro

4) Netfilter fixups from Patrick McHardy and Pablo Neira Ayuso:
   a) an #ifdef got lost in a conversion, breaking defragmentation
      handling in some configurations

   b) ctnetlink and nf_nat have an awful dependency, and Pablo found
      a clean way to get rid of it

   c) ebtables missing dependency fix based upon build failure
      report by Ingo

5) decnet should use offsetof() instead of hand-written version
   that generates build warnings

Please pull, thanks a lot!

The following changes since commit 485013717020cd8961337309e359d6cef43d6022:
  Ron Mercer (1):
        qlge: Fix page size ifdef test.

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexey Dobriyan (2):
      netns: fix net_generic array leak
      netns: correct mib stats in ip6_route_me_harder()

Andrey Borzenkov (1):
      orinoco: fix unsafe locking in orinoco_cs_resume

Christian Lamparter (1):
      p54usb: Device ID updates

David Kilroy (1):
      orinoco: fix unsafe locking in spectrum_cs_suspend

David S. Miller (2):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      decnet: Fix compiler warning in dn_dev.c

Felix Fietkau (1):
      rt2x00: fix regression introduced by "mac80211: free up 2 bytes in skb->cb"

Florent Fourcot (1):
      rtl8187: Add USB ID for Belkin F5D7050 with RTL8187B chip

Johannes Berg (5):
      mac80211: fix debugfs lockup
      mac80211: fix HT information element parsing
      mac80211: fix debugfs netdev rename
      cfg80211: fix debugfs error handling
      ath9k/mac80211: disallow fragmentation in ath9k, report to userspace

John W. Linville (1):
      rtl8187: add device ID 0bda:8198

Jouni Malinen (1):
      mac80211: Fix scan RX processing oops

Larry Finger (1):
      p54: Fix compilation problem on PPC

Manish Katiyar (2):
      libertas : Remove unused variable warning for "old_channel" from cmd.c
      net/802/fc.c: Fix compilation warnings

Pablo Neira Ayuso (1):
      netfilter: ctnetlink: remove bogus module dependency between ctnetlink and nf_nat

Patrick McHardy (2):
      netfilter: restore lost #ifdef guarding defrag exception
      netfilter: fix ebtables dependencies

Pedro Ribeiro (1):
      IPV6: Fix default gateway criteria wrt. HIGH/LOW preference radv option

Rami Rosen (1):
      iwlwifi: fix compilation warning when CONFIG_IWLWIFI_DEBUG is not set.

Randy Dunlap (1):
      mac80211: fixme for kernel-doc

Randy Macleod (1):
      Phonet: Simple doc fix.

Tomas Winkler (1):
      iwlwifi: fix ct kill configuration for 5350

 Documentation/networking/phonet.txt       |    4 +-
 drivers/net/wireless/ath9k/main.c         |    8 ++-
 drivers/net/wireless/iwlwifi/iwl-5000.c   |    6 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c |    2 +-
 drivers/net/wireless/libertas/cmd.c       |    2 +
 drivers/net/wireless/orinoco_cs.c         |    5 +-
 drivers/net/wireless/p54/p54common.c      |    1 -
 drivers/net/wireless/p54/p54usb.c         |    3 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c |    9 +-
 drivers/net/wireless/rtl8187_dev.c        |    3 +
 drivers/net/wireless/spectrum_cs.c        |    5 +-
 include/linux/icmpv6.h                    |    6 +-
 include/linux/netfilter/nfnetlink.h       |    3 +
 include/net/mac80211.h                    |    3 +-
 include/net/netfilter/nf_nat_core.h       |    8 ++
 net/802/fc.c                              |    2 +-
 net/bridge/netfilter/Kconfig              |    1 +
 net/core/net_namespace.c                  |    2 +-
 net/decnet/dn_dev.c                       |    2 +-
 net/ipv4/netfilter/nf_defrag_ipv4.c       |    3 +-
 net/ipv4/netfilter/nf_nat_core.c          |   97 ++++++++++++++++++
 net/ipv6/ndisc.c                          |    2 +-
 net/ipv6/netfilter.c                      |    6 +-
 net/mac80211/debugfs_netdev.c             |    6 +-
 net/mac80211/debugfs_sta.c                |   11 ++
 net/mac80211/ieee80211_i.h                |    6 +-
 net/mac80211/mlme.c                       |    3 -
 net/mac80211/scan.c                       |    3 +-
 net/mac80211/sta_info.c                   |    7 +-
 net/mac80211/sta_info.h                   |    1 +
 net/mac80211/util.c                       |    8 +-
 net/mac80211/wext.c                       |    2 +-
 net/netfilter/nf_conntrack_core.c         |    7 ++
 net/netfilter/nf_conntrack_netlink.c      |  151 ++++++++++++-----------------
 net/netfilter/nfnetlink.c                 |   12 ++-
 net/wireless/core.c                       |    5 +-
 36 files changed, 268 insertions(+), 137 deletions(-)
