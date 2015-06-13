From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 12 Jun 2015 17:00:05 -0700 (PDT)
Message-ID: <20150612.170005.462061126587878954.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix uninitialized struct station_info in cfg80211_wireless_stats(), from
   Johannes Berg.

2) Revert commit attempt to fix ipv6 protocol resubmission, it adds
   regressions.

3) Endless loops can be created in bridge port lists, fix from Nikolay
   Aleksandrov.

4) Don't WARN_ON() if sk->sk_forward_alloc is non-zero in
   sk_clear_memalloc, it is a legal situation during swap deactivation.
   Fix from Mel Gorman.

5) Fix order of disabling interrupts and unlocking NAPI in enic driver
   to avoid a race.  From Govindarajulu Varadarajan.

6) High and low register writes are swapped when programming the start
   of periodic output in igb driver.  From RIchard Cochran.

7) Fix device rename handling in mpls stack, from Robert Shearman.

8) Do not trigger compaction synchronously when optimistically trying
   to allocate an order 3 page in alloc_skb_with_frags() and
      skb_page_frag_refill().  From Shaohua Li.

9) Authentication with COOKIE_ECHO is not handled properly in SCTP,
   fix from Marcelo Ricardo Leitner.

Please pull, thanks a lot!

The following changes since commit 5879ae5fd052a63d5ac0684320cb7df3e83da7de:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-06-08 17:41:04 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net 

for you to fetch changes up to b07d496177cd3bc4b70fb8a5e85ede24cb403a11:

  Doc: networking: Fix URL for wiki.wireshark.org in udplite.txt (2015-06-12 14:21:29 -0700)

----------------------------------------------------------------
David S. Miller (1):
      Revert "ipv6: Fix protocol resubmission"

Erik Hugne (1):
      tipc: disconnect socket directly after probe failure

Govindarajulu Varadarajan (3):
      enic: unlock napi busy poll before unmasking intr
      enic: check return value for stat dump
      enic: fix memory leak in rq_clean

Johannes Berg (1):
      cfg80211: wext: clear sinfo struct before calling driver

Marcelo Ricardo Leitner (1):
      sctp: allow authenticating DATA chunks that are bundled with COOKIE_ECHO

Masanari Iida (1):
      Doc: networking: Fix URL for wiki.wireshark.org in udplite.txt

Mel Gorman (1):
      net, swap: Remove a warning and clarify why sk_mem_reclaim is required when deactivating swap

Nikolay Aleksandrov (1):
      bridge: fix multicast router rlist endless loop

Richard Cochran (1):
      net: igb: fix the start time for periodic output signals

Robert Shearman (1):
      mpls: handle device renames for per-device sysctls

Shaohua Li (1):
      net: don't wait for order-3 page allocation

 Documentation/networking/udplite.txt           |  2 +-
 drivers/net/ethernet/cisco/enic/enic_ethtool.c | 20 +++++++++++++++++---
 drivers/net/ethernet/cisco/enic/enic_main.c    | 11 +++++++++--
 drivers/net/ethernet/cisco/enic/vnic_rq.c      |  9 ++++-----
 drivers/net/ethernet/intel/igb/igb_ptp.c       |  4 ++--
 net/bridge/br_multicast.c                      |  7 +++----
 net/core/skbuff.c                              |  2 +-
 net/core/sock.c                                | 15 ++++++---------
 net/ipv6/ip6_input.c                           |  8 +++-----
 net/mpls/af_mpls.c                             | 11 +++++++++++
 net/sctp/auth.c                                | 11 ++++++++++-
 net/tipc/socket.c                              | 16 +++++++++++-----
 net/wireless/wext-compat.c                     |  2 ++
 13 files changed, 80 insertions(+), 38 deletions(-)
