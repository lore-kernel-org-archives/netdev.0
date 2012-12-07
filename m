From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 07 Dec 2012 15:35:05 -0500 (EST)
Message-ID: <20121207.153505.105761715622578247.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Two stragglers:

1) The new code that adds new flushing semantics to GRO can cause
   SKB pointer list corruption, manage the lists differently to	
   avoid the OOPS.  Fix from Eric Dumazet.

2) When TCP fast open does a retransmit of data in a SYN-ACK or
   similar, we update retransmit state that we shouldn't triggering
   a WARN_ON later.  Fix from Yuchung Cheng.

Please pull, thanks a lot!

The following changes since commit 1afa471706963643ceeda7cbbe9c605a1e883d53:

  Merge tag 'mmc-fixes-for-3.7' of git://git.kernel.org/pub/scm/linux/kernel/git/cjb/mmc (2012-12-07 09:15:20 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to c3c7c254b2e8cd99b0adf288c2a1bddacd7ba255:

  net: gro: fix possible panic in skb_gro_receive() (2012-12-07 14:39:29 -0500)

----------------------------------------------------------------
Eric Dumazet (1):
      net: gro: fix possible panic in skb_gro_receive()

Yuchung Cheng (1):
      tcp: bug fix Fast Open client retransmission

 include/linux/netdevice.h |  3 +++
 include/net/tcp.h         |  1 +
 net/core/dev.c            |  2 ++
 net/core/skbuff.c         |  6 +++---
 net/ipv4/tcp_input.c      |  6 +++++-
 net/ipv4/tcp_output.c     | 15 ++++++++++-----
 6 files changed, 24 insertions(+), 9 deletions(-)
