From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/7] net: Convert aligned memcpy to ether_addr_copy
Date: Mon, 20 Jan 2014 09:52:13 -0800
Message-ID: <cover.1390239869.git.joe@perches.com>
References: <20140115.164540.450877805879786067.davem@davemloft.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140115.164540.450877805879786067.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-01-15 at 16:45 -0800, David Miller wrote:
From: Joe Perches <joe@perches.com>
> Date: Wed, 15 Jan 2014 16:07:58 -0800
> 
> > If you want the ones for net-next net/ now (but not
> > for batman-adv, that maybe could use a new function like
> > ether_addr_copy_unaligned) here's a changestat.
> > 
> > Otherwise, I'll wait for the next cycle.
> 
> This looks fine, why don't you toss it my way over the weekend as I
> still have some backlog to process at the moment?
 
I didn't get that done this weekend, so next cycle
for most of net/.

I don't want to introduce any breakage this late and
there are possible unaligned memcpy(foo, bar, ETH_ALEN)
where one or both of foo/bar are stack pointers where
the alignment is hard to verify.

There are also statics declared without __aligned(2)
that will need updating.

Maybe ether_addr_copy_unaligned should be added too.

Here are the ones I could easily verify...
No worries if it's this cycle or next.

Joe Perches (7):
  8021q: Use ether_addr_copy
  appletalk: Use ether_addr_copy
  atm: Use ether_addr_copy
  caif_usb: Use ether_addr_copy
  netpoll: Use ether_addr_copy
  pktgen: Use ether_addr_copy
  dsa: Use ether_addr_copy

 net/8021q/vlan.c     |  2 +-
 net/8021q/vlan_dev.c |  6 +++---
 net/appletalk/aarp.c | 12 ++++++------
 net/atm/lec.c        |  9 +++++----
 net/atm/mpc.c        |  2 +-
 net/caif/caif_usb.c  |  4 ++--
 net/core/netpoll.c   |  4 ++--
 net/core/pktgen.c    |  8 ++++----
 net/dsa/slave.c      |  2 +-
 9 files changed, 25 insertions(+), 24 deletions(-)

-- 
1.8.1.2.459.gbcd45b4.dirty
