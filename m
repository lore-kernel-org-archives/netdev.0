From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 28 Sep 2009 23:17:38 -0700 (PDT)
Message-ID: <20090928.231738.93632992.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752729AbZI2GRV@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Refcount bugs in ax25, from Ralf Baechle and Jarek Poplawski.

2) Wireless regression fixes:

   sony laptop rfkill handling loses state over suspend/resume,
   and hard block isn't checked at load time, from Alan Jenkins

   sysfs registry of wireless devices is borked, fix from Johannes Berg.

   cfg80211 can set privacy without key, this was hitting quite a few
   folks, fix from Johannes

   Memory leak and ucode info retrieval iwlwifi fixes.  One of the
   commits looks sizable, but it's predominantly moving code around.
   From Reinette Chatre.

3) netlink/dcbnl fixes from John Fastabend.  In particular, vlan messages
   weren't being sized large enough, nlmsg size for error ACKs was
   completely wrong, and dcbnl could double free message SKB.

4) ISDN driver build fix from Randy Dunlap.

5) Several e1000 bug fixes and fixups from Jesse Brandeburg:

   Timers stopped incorrectly.

   PCI-E support code is completely unused, identical code is only
   active in e1000e driver, not here.

   MTU changing is racy

   queues aren't stopped correctly during shutdown

   Fix namespacecheck warnings.

   Hopefully this driver is less of a screaming pile of poo than it used
   to be.

6) User bound checks in net/socket.c and wireless extensions, from Arjan
   van de Ven.

7) Revert stateless autoconf support for ipv6 isatap in SIT driver.

   It was not implemented according to spec properly, and doing it
   fully and correctly is a lot of code and thus should be done in
   userspace.

Please pull, thanks a lot!

The following changes since commit 17d857be649a21ca90008c6dc425d849fa83db5c:
  Linus Torvalds (1):
        Linux 2.6.32-rc1

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alan Jenkins (2):
      sony-laptop: check for rfkill hard block at load time
      sony-laptop: re-read the rfkill state when resuming from suspend

Arjan van de Ven (2):
      net: Add explicit bound checks in net/socket.c
      wext: Add bound checks for copy_from_user

David S. Miller (1):
      Merge branch 'master' of ssh://master.kernel.org/.../linville/wireless-2.6

Don Skidmore (1):
      e1000: cleanup unused prototype

Jeff Hansen (1):
      bridge: Fix double-free in br_add_if.

Jesse Brandeburg (12):
      e1000: drop dead pcie code from e1000
      e1000: remove unused functions
      e1000: use netif_tx_disable
      e1000: stop timers at appropriate times
      e1000: test link state conclusively
      e1000: fix tx waking queue after queue stopped during shutdown
      e1000: two workarounds were incomplete, fix them
      e1000: remove races when changing mtu
      e1000: drop redunant line of code, cleanup
      e1000: updated whitespace and comments
      e1000: drop unused functionality for eeprom write/read
      e1000: fix namespacecheck warnings

Johannes Berg (5):
      cfg80211: wext: don't display BSSID unless associated
      cfg80211: don't set privacy w/o key
      cfg80211: always get BSS
      mac80211: improve/fix mlme messages
      wext: add back wireless/ dir in sysfs for cfg80211 interfaces

John Fastabend (3):
      net: fix vlan_get_size to include vlan_flags size
      net: fix nlmsg len size for skb when error bit is set.
      net: fix double skb free in dcbnl

Juha Leppanen (1):
      atm: dereference of he_dev->rbps_virt in he_init_group()

Ralf Baechle (1):
      ax25: Add missing dev_put in ax25_setsockopt

Randy Dunlap (1):
      isdn: fix netjet/isdnhdlc build errors

Reinette Chatre (3):
      iwlwifi: fix debugfs buffer handling
      iwlwifi: fix memory leak in command queue handling
      iwlwifi: fix 3945 ucode info retrieval after failure

Sascha Hlusiak (1):
      Revert "sit: stateless autoconf for isatap"

 drivers/atm/he.c                            |   14 +-
 drivers/isdn/hardware/mISDN/Kconfig         |    1 +
 drivers/isdn/i4l/Kconfig                    |    3 +-
 drivers/net/e1000/e1000.h                   |    3 -
 drivers/net/e1000/e1000_ethtool.c           |  202 +-
 drivers/net/e1000/e1000_hw.c                |12914 ++++++++++-----------------
 drivers/net/e1000/e1000_hw.h                | 3231 +++----
 drivers/net/e1000/e1000_main.c              |  825 +--
 drivers/net/e1000/e1000_param.c             |   22 -
 drivers/net/wireless/iwlwifi/iwl-1000.c     |    2 +
 drivers/net/wireless/iwlwifi/iwl-3945.c     |    2 +
 drivers/net/wireless/iwlwifi/iwl-3945.h     |    2 +
 drivers/net/wireless/iwlwifi/iwl-4965.c     |    2 +
 drivers/net/wireless/iwlwifi/iwl-5000.c     |    4 +
 drivers/net/wireless/iwlwifi/iwl-6000.c     |    2 +
 drivers/net/wireless/iwlwifi/iwl-agn.c      |  185 +
 drivers/net/wireless/iwlwifi/iwl-core.c     |  187 +-
 drivers/net/wireless/iwlwifi/iwl-core.h     |   14 +
 drivers/net/wireless/iwlwifi/iwl-debugfs.c  |    8 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c       |    6 +
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   31 +-
 drivers/platform/x86/sony-laptop.c          |    9 +
 include/linux/if_tunnel.h                   |    2 +-
 include/net/ipip.h                          |    7 -
 include/net/wext.h                          |    1 +
 net/8021q/vlan_netlink.c                    |    1 +
 net/ax25/af_ax25.c                          |   19 +-
 net/bridge/br_if.c                          |    1 +
 net/core/net-sysfs.c                        |   12 +-
 net/dcb/dcbnl.c                             |   15 +-
 net/ipv6/ndisc.c                            |    1 -
 net/ipv6/sit.c                              |   58 -
 net/mac80211/mlme.c                         |   18 +-
 net/netlink/af_netlink.c                    |    2 +-
 net/socket.c                                |    7 +-
 net/wireless/sme.c                          |    5 +-
 net/wireless/wext-sme.c                     |    8 +-
 net/wireless/wext.c                         |   11 +-
 38 files changed, 6792 insertions(+), 11045 deletions(-)
