From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 06 May 2013 17:05:37 -0400 (EDT)
Message-ID: <20130506.170537.2116026617074159336.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35460 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757683Ab3EFVFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 17:05:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Just a small pile of fixes:

1) Fix race conditions in IP fragmentation LRU list handling,
   from Konstantin Khlebnikov.

2) vfree() is no longer verboten in interrupts, so deferring is
   pointless, from Al Viro.

3) Conversion from mutex to semaphore in netpoll left trylock
   test inverted, caught by Dan Carpenter.

4) 3c59x uses wrong base address when releasing regions, from
   Sergei Shtylyov.

5) Bounds checking in TIPC from Dan Carpenter.

6) Fastopen cookies should not be expired as aggressively as other
   TCP metrics.  From Eric Dumazet.

7) Fix retrieval of MAC address in ibmveth, from Ben Herrenschmidt.

8) Don't use "u16" in virtio user headers, from Stephen Hemminger.

Please pull, thanks a lot!

The following changes since commit f8ce1faf55955de62e0a12e330c6d9a526071f65:

  Merge tag 'modules-next-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/rusty/linux (2013-05-05 10:58:06 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to 6bf15191f666c5965d212561d7a5c7b78b808dfa:

  tipc: potential divide by zero in tipc_link_recv_fragment() (2013-05-06 16:16:52 -0400)

----------------------------------------------------------------
Al Viro (2):
      fib_trie: no need to delay vfree()
      rps_dev_flow_table_release(): no need to delay vfree()

Benjamin Herrenschmidt (1):
      net/eth/ibmveth: Fixup retrieval of MAC address

Dan Carpenter (3):
      netpoll: inverted down_trylock() test
      tipc: add a bounds check in link_recv_changeover_msg()
      tipc: potential divide by zero in tipc_link_recv_fragment()

Eric Dumazet (1):
      tcp: do not expire TCP fastopen cookies

Konstantin Khlebnikov (1):
      net: frag, fix race conditions in LRU list maintenance

Sergei Shtylyov (1):
      3c59x: fix freeing nonexistent resource on driver unload

hayeswang (1):
      net/usb: new driver for RTL8152

stephen hemminger (1):
      virtio: don't expose u16 in userspace api

 drivers/net/ethernet/3com/3c59x.c  |    2 +-
 drivers/net/ethernet/ibm/ibmveth.c |   23 +-
 drivers/net/usb/Kconfig            |   11 +
 drivers/net/usb/Makefile           |    1 +
 drivers/net/usb/cdc_ether.c        |   10 +
 drivers/net/usb/r8152.c            | 1767 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/netdevice.h          |    1 -
 include/net/inet_frag.h            |    5 +-
 include/uapi/linux/virtio_net.h    |    2 +-
 net/core/net-sysfs.c               |   12 +-
 net/core/netpoll.c                 |    2 +-
 net/ipv4/fib_trie.c                |   13 +-
 net/ipv4/inet_fragment.c           |    1 +
 net/ipv4/tcp_metrics.c             |   15 +-
 net/tipc/link.c                    |   11 +-
 15 files changed, 1826 insertions(+), 50 deletions(-)
 create mode 100644 drivers/net/usb/r8152.c
