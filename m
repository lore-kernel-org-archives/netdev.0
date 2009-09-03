From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 02 Sep 2009 23:02:24 -0700 (PDT)
Message-ID: <20090902.230224.06686722.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42835
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754395AbZICGCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 02:02:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Packet scheduler classifier code can leak some uninitialized
   kernel bytes to userspace.  Fix from Eric Dumazet.

2) Revert tasklet_hrtimer conversions, naggling problems exist
   and -rcX is not the time to be tinkering with it.

3) Sockets can leak when sk_free()'d shortly after sk_alloc()
   with some protocols due to initialization order of
   sk->sk_mem_alloc.  Fix from Jarek Poplawski and Eric Dumazet.

4) gianfar frees netdev without unregistering it resulting in
   crashes on unload.  Fix from Toru UCHIYAMA.

5) ipw2200 uses large linear memory area (ie. high order allocation)
   for firmware loading via DMA, which easily can (and does) fail.
   Fix from Zhu Yi via John Linville.

Please pull, thanks a lot!

The following changes since commit 37d0892c5a94e208cf863e3b7bac014edee4346d:
  Ian Kent (1):
        autofs4 - fix missed case when changing to use struct path

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

David S. Miller (2):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      pkt_sched: Revert tasklet_hrtimer changes.

Eric Dumazet (1):
      tc: Fix unitialized kernel memory leak

Jarek Poplawski (1):
      net: sk_free() should be allowed right after sk_alloc()

Toru UCHIYAMA (1):
      gianfar: gfar_remove needs to call unregister_netdev()

Zhu Yi (1):
      ipw2200: firmware DMA loading rework

 drivers/net/gianfar.c                  |    1 +
 drivers/net/wireless/ipw2x00/ipw2200.c |  120 ++++++++++++++++++--------------
 include/net/pkt_sched.h                |    4 +-
 net/core/sock.c                        |    2 +-
 net/sched/sch_api.c                    |   12 ++--
 net/sched/sch_cbq.c                    |   25 +++----
 6 files changed, 89 insertions(+), 75 deletions(-)
