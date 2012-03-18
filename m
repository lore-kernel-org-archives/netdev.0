From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 17 Mar 2012 17:53:04 -0700 (PDT)
Message-ID: <20120317.175304.364418700190702312.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46297 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756368Ab2CRAxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 20:53:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) icmp6_dst_alloc() returns NULL instead of ERR_PTR() leading to
   crashes, particularly during shutdown.  Reported by Dave
   Jones and fixed by Eric Dumazet.

2) hyperv and wimax/i2400m return NETDEV_TX_BUSY when they have
   already freed the SKB, which causes crashes as to the caller
   this means requeue the packet.  Fixes from Eric Dumazet.

3) usbnet driver doesn't allocate the right amount of headroom
   on fresh RX SKBs, fix from Eric Dumazet.

4) Fix regression in ip6_mc_find_dev_rcu(), as an RCU lookup it
   abolutely should not take a reference to 'dev', this leads
   to leaks.  Fix from RonQing Li.

5) Fix netfilter ctnetlink race between delete and timeout
   expiration.  From Pablo Neira Ayuso.

6) Revert SFQ change which causes regressions, specifically queueing
   to tail can lead to unavoidable flow starvation.  From Eric
   Dumazet.

7) Fix a memory leak and a crash on corrupt firmware files in bnx2x,
   from Michal Schmidt.

Please pull, thanks a lot!

The following changes since commit cb1ecf25a84aec8c9d1fc6ad0c78adf4fd8335de:

  Merge branch 'akpm' (more patches from Andrew) (2012-03-16 17:14:55 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

Eric Dumazet (5):
      ipv6: fix icmp6_dst_alloc()
      sch_sfq: revert dont put new flow at the end of flows
      net/usbnet: reserve headroom on rx skbs
      net/hyperv: fix erroneous NETDEV_TX_BUSY use
      wimax/i2400m: fix erroneous NETDEV_TX_BUSY use

Michal Schmidt (2):
      bnx2x: fix a crash on corrupt firmware file
      bnx2x: fix memory leak in bnx2x_init_firmware()

Pablo Neira Ayuso (1):
      netfilter: ctnetlink: fix race between delete and timeout expiration

RongQing.Li (1):
      ipv6: Don't dev_hold(dev) in ip6_mc_find_dev_rcu.

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   51 +++++++++++-----------
 drivers/net/hyperv/netvsc_drv.c                  |    4 +-
 drivers/net/usb/usbnet.c                         |    4 +-
 drivers/net/wimax/i2400m/netdev.c                |   30 ++++--------
 net/ipv6/mcast.c                                 |    1 -
 net/ipv6/route.c                                 |    2 +-
 net/netfilter/nf_conntrack_netlink.c             |   23 +++++-----
 net/sched/sch_sfq.c                              |    6 ++-
 8 files changed, 57 insertions(+), 64 deletions(-)
