From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 17 May 2012 18:44:30 -0400 (EDT)
Message-ID: <20120517.184430.2079213200908401641.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Thanks to Willy Tarreau and Eric Dumazet, we've unlocked a bug that's
   been present in do_tcp_sendpages() since that function was written in
   2002.

   When we block to wait for memory we have to unconditionally try and
   push out pending TCP data, otherwise we can block for an
   unreasonably long amount of time.

2) Fix deadlock in e1000, fixes kernel bugzilla 43132

   From Tushar Dave.

Please pull, thanks a lot!

The following changes since commit 1be5f0b7575e090fd100a98b303860879b5800de:

  Merge branch 'fixes' of git://git.infradead.org/users/vkoul/slave-dma (2012-05-17 09:57:13 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to 8ce6909f77ba1b7bcdea65cc2388fd1742b6d669:

  e1000: Prevent reset task killing itself. (2012-05-17 18:32:41 -0400)

----------------------------------------------------------------
Tushar Dave (1):
      e1000: Prevent reset task killing itself.

Willy Tarreau (1):
      tcp: do_tcp_sendpages() must try to push data out on oom conditions

 drivers/net/ethernet/intel/e1000/e1000_main.c |    6 +++++-
 net/ipv4/tcp.c                                |    3 +--
 2 files changed, 6 insertions(+), 3 deletions(-)
