From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 06 Oct 2011 16:23:43 -0400 (EDT)
Message-ID: <20111006.162343.1556311465620900007.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) MD5 signature pool leak fix in TCP, from Zheng Yan.

2) Fix carrier state regression in bridging, from Stephen Hemminger.

3) Unicast forwards between macvtap interfaces should use
   dev_forward_skb() not the vlan->forward() method.  Fix from David
   Ward.

4) TCP's lost_cnt_hint is updated one too many times in some situations,
   fix from Zheng Yan.

5) netfilter needs to use rwlock_init(), from Thomas Gleixner.

Please pull, thanks a lot!

The following changes since commit 6367f1775ebb66b0f0e9e3512159f3257a6fde0e:

  Merge branch 'for-linus' of http://people.redhat.com/agk/git/linux-dm (2011-10-06 08:31:47 -0700)

are available in the git repository at:

  git://github.com/davem330/net.git master

Benjamin Poirier (1):
      net: fix typos in Documentation/networking/scaling.txt

David Ward (1):
      macvlan/macvtap: Fix unicast between macvtap interfaces in bridge mode

Thomas Gleixner (1):
      netfilter: Use proper rwlock init function

Yan, Zheng (2):
      tcp: properly handle md5sig_pool references
      tcp: properly update lost_cnt_hint during shifting

stephen hemminger (1):
      bridge: leave carrier on for empty bridge

 Documentation/networking/scaling.txt |   10 +++++-----
 drivers/net/macvlan.c                |    2 +-
 net/bridge/br_device.c               |    3 ---
 net/ipv4/tcp_input.c                 |    4 +---
 net/ipv4/tcp_ipv4.c                  |   11 +++++++----
 net/ipv6/tcp_ipv6.c                  |    8 +++++---
 net/netfilter/ipvs/ip_vs_ctl.c       |    2 +-
 7 files changed, 20 insertions(+), 20 deletions(-)
