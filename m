From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 26 Jul 2010 23:31:51 -0700 (PDT)
Message-ID: <20100726.233151.91355923.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36585
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751709Ab0G0Gbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 02:31:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Add wimax device IDs for devices found in thinkpad laptops.  From
   Alexey Shvetsov.

2) Caching netfilter settings across dev_forward_skb() breaks
   namespaces and conntrack zones, we need to call nf_reset() here.
   From Ben Greear.

3) pskb_expand_head() can corrupt skb->csum with some devices.  Fix
   from Andrea Shepard.  skb_copy_expand() had the same bug, so fix it
   there too.

4) Fix crashes wrt. RLB mode in bonding, from Greg Edwards.

5) macvtap must limit packet queue backlog size else OOM, fix from
   Herbert Xu.

6) GSO errors in tun driver trigger a BUG(), which makes it impossible
   to get useful data and debug this problem.  Just warn, print a
   useful message, and drop the packet.  From Michael S. Tsirkin.

7) The mirred packet scheduler action holds references to network
   devices.  However, it doesn't have a netdevice notifier so those
   entries can drop their refs on unregister.  This makes network	
   devices unremovable and leads to hangs.  Fix from Stephen Hemminger.

8) ath9k driver uses wrong DMA direction values in map/unmap calls
   during ath_rx_tasklet.  Fix from Ming Lei.

9) ieee80211_send_layer2_update does receive from process context,
   therefore it must use netif_rx_ni().  From John Linville.

10) When ipv6 is disabled on an interface, we should never add ipv6 routes
    to it.  From Brian Haley.

11) Trap invalid virtual function settings in ixgbe/igb driver, from
    Andy Gospodarek.

12) bnx2x driver needs more mutual exclusion to prevent corruption of
    the statistics handling and state.  From Vladislav Zolotarov.

Please pull, thanks a lot!

The following changes since commit 1a041a23da7c77b53c71fe11b4f940388bee37b1:

  Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip (2010-07-26 16:02:07 -0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexey Shvetsov (1):
      wimax/i2400m: Add PID & VID for Intel WiMAX 6250

Andrea Shepard (1):
      net: Fix corruption of skb csum field in pskb_expand_head() of net/core/skbuff.c

Andy Gospodarek (1):
      ixgbe/igb: catch invalid VF settings

Ben Greear (1):
      net: dev_forward_skb should call nf_reset

Breno Leitao (1):
      s2io: fixing DBG_PRINT() macro

Brian Haley (1):
      ipv6: Don't add routes to ipv6 disabled interfaces.

David S. Miller (3):
      net: Fix skb_copy_expand() handling of ->csum_start
      Merge branch 'wimax-2.6.35.y' of git://git.kernel.org/.../inaky/wimax
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

Greg Edwards (1):
      bonding: set device in RLB ARP packet handler

Herbert Xu (1):
      macvtap: Limit packet queue length

John W. Linville (1):
      wireless: use netif_rx_ni in ieee80211_send_layer2_update

Michael S. Tsirkin (1):
      tun: avoid BUG, dump packet on GSO errors

Ming Lei (1):
      ath9k: fix dma direction for map/unmap in ath_rx_tasklet

Vladislav Zolotarov (3):
      bnx2x: Protect a SM state change
      bnx2x: Protect statistics ramrod and sequence number
      bnx2x: Advance a module version

stephen hemminger (1):
      net sched: fix race in mirred device removal

 drivers/net/bnx2x.h                   |    4 +++
 drivers/net/bnx2x_main.c              |   42 ++++++++++++++++++++-----------
 drivers/net/bonding/bond_alb.c        |    2 +-
 drivers/net/igb/igb_main.c            |    9 +++++++
 drivers/net/ixgbe/ixgbe_main.c        |    9 +++++++
 drivers/net/macvlan.c                 |   10 ++++++-
 drivers/net/macvtap.c                 |   18 ++++++++++++-
 drivers/net/s2io.h                    |    2 +-
 drivers/net/tun.c                     |   14 +++++++++-
 drivers/net/wimax/i2400m/i2400m-usb.h |    1 +
 drivers/net/wimax/i2400m/usb.c        |    2 +
 drivers/net/wireless/ath/ath9k/recv.c |    4 +-
 include/linux/if_macvlan.h            |    2 +
 include/net/tc_act/tc_mirred.h        |    1 +
 net/core/dev.c                        |    1 +
 net/core/skbuff.c                     |    7 ++++-
 net/ipv6/addrconf.c                   |   14 +++++++----
 net/mac80211/cfg.c                    |    2 +-
 net/sched/act_mirred.c                |   43 ++++++++++++++++++++++++++++++--
 19 files changed, 151 insertions(+), 36 deletions(-)
