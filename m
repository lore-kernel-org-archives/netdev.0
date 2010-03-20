From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Sat, 20 Mar 2010 15:23:12 -0700 (PDT)
Message-ID: <20100320.152312.212695203.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42043
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752262Ab0CTWWu convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Mar 2010 18:22:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) The TCP TTL limiting extension added to 2.6.34 needs to
   check ICMP packets destined for such TCP sockets too.
   Fix from Stephen Hemminger.

2) KS8851 regression, OOPS on multicast changes.  Fix from
   Abraham Arce.

3) TCP started setting POLLIN for pure OOB data accidently.
   Noticed and fixed by Alexandra Kossovsky.

4) Add PCI IDs for new IGB device, from Carolyn Wyborny.

5) skb_bond_should_drop() should use ACCESS_ONCE() on
   skb->dev_master to avoid potential oops, from Eric Dumazet.

6) TCP can mark the retransmit queue head SKB lost even when
   ->packets_out =3D=3D 0, causing early retransmits.  Fix from
   Lennart Schulte.

7) NET_DMA can wedge a TCP socket if receive water marks are high
   and the user does a large read.  Fix by periodically submitting
   and purging completed NET_DMA requests, instead of doing so only
   when exiting tcp_recvmsg().  Fix from Steven J. Magnani.

8) Netlink fixes from Pablo Neira Ayuso:

   a) nla_get_be64() needs to use nla_memcpy() since the object
      will always be unaligned.

   b) Fix NETLINK_RECV_NO_ENOBUFS to elide the error even when
      it gets signalled via netlink_set_err().

   c) Use the fix #b to cure ctnetlink from losing events.

9) VHOST bug fixes from Jeff Dike, Michael S. Tsirkin:

   a) vhost_net_set_backend() can return with mutex held.
   b) logic error causes interrupt mitigation to never trigger
   c) several vring ioctls accidently return with mutex held

10) JME driver bug fixes from Guo-Fu Tseng:

    a) VLAN RX code paths leaks memory
    b) VLGRP acceses are racy

11) Fix Fibre link issues and and wake on lan in IXGBE driver.
    From Mallikarjuna R Chilakala and Jeff Kirsher.

12) smsc95xx needs workaround for checksum offload of tiny UDP packets.

13) Recent bug fix unearthed an error in IPSEC route updating for
    ipv4.  We need to implement ipv4_dst_check() properly, otherwise
    PMTU updates et al. never propagate any more to IPSEC routes.
    Fix from Timo Teras, with help from Herbert Xu.

14) IXGBE indicates netdev feature changes too early, it must
    occur after FCOE tx queue setup is done.  Fix from Vasu Dev.

15) IXGBE can potentially double unmap DMA mappings, noticed by
    Simon Horman and fixed by Mallikarjuna R Chilakala.

16) Multicast code can access vif_table[] outside of array bounds.
    Fix from Patrick McHardy.

17) KS8695 updates descriptor head way too often, only hit it at
    end of RX processing loop.  From Yegor Yefremov with help
    from Eric Dumazet.

18) IXGBEVF driver fixes from Greg Rose and Jeff Kirsher:

    a) VF stats don't account properly across reset
    b) recovery from PF resets take way too long, reduce
       watchdog delay

Please pull, thanks a lot!

The following changes since commit 220bf991b0366cc50a94feede3d7341fa571=
0ee4:
  Linus Torvalds (1):
        Linux 2.6.34-rc2

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Abraham Arce (1):
      KS8851: Avoid NULL pointer in set rx mode

Adel Gadllah (1):
      iwlwifi: Silence tfds_in_queue message

Alexandra Kossovsky (1):
      tcp: Fix OOB POLLIN avoidance.

Carolyn Wyborny (1):
      igb: Add support for 82576 ET2 Quad Port Server Adapter

David S. Miller (2):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge branch 'vhost' of git://git.kernel.org/.../mst/vhost

Eric Dumazet (1):
      net: Potential null skb->dev dereference

=46elix Fietkau (1):
      ath9k: fix BUG_ON triggered by PAE frames

Grazvydas Ignotas (1):
      wl1251: fix potential crash

Greg Rose (3):
      ixgbevf: Fix VF Stats accounting after reset
      ixgbevf: Shorten up delay timer for watchdog task
      ixgbevf: Message formatting cleanups

Guo-Fu Tseng (3):
      jme: Fix VLAN memory leak
      jme: Protect vlgrp structure by pause RX actions.
      jme: Advance driver version number

Herbert Xu (1):
      ipv6: Remove redundant dst NULL check in ip6_dst_check

Jeff Dike (1):
      vhost: fix error path in vhost_net_set_backend

Lennart Schulte (1):
      tcp: Fix tcp_mark_head_lost() with packets =3D=3D 0

Mallikarjuna R Chilakala (3):
      ixgbe: Fix 82599 multispeed fiber link issues due to Tx laser fla=
pping
      ixgbe: Fix 82599 KX4 Wake on LAN issue after an improper system s=
hutdown
      ixgbe: Set IXGBE_RSC_CB(skb)->DMA field to zero after unmapping t=
he address

Michael S. Tsirkin (2):
      vhost: fix interrupt mitigation with raw sockets
      vhost: fix error handling in vring ioctls

Pablo Neira Ayuso (3):
      netlink: fix unaligned access in nla_get_be64()
      netlink: fix NETLINK_RECV_NO_ENOBUFS in netlink_set_err()
      netfilter: ctnetlink: fix reliable event delivery if message buil=
ding fails

Patrick McHardy (1):
      net: ipmr/ip6mr: fix potential out-of-bounds vif_table access

Steve Glendinning (1):
      smsc95xx: Fix tx checksum offload for small packets

Steven J. Magnani (1):
      NET_DMA: free skbs periodically

Timo Ter=E4s (1):
      ipv4: check rt_genid in dst_check

Vasu Dev (1):
      ixgbe: fix for real_num_tx_queues update issue

Yegor Yefremov (1):
      KS8695: update ksp->next_rx_desc_read at the end of rx loop

stephen hemminger (1):
      TCP: check min TTL on received ICMP packets

 drivers/net/arm/ks8695net.c                  |   24 +++-----
 drivers/net/igb/e1000_82575.c                |    1 +
 drivers/net/igb/e1000_hw.h                   |    1 +
 drivers/net/igb/igb_main.c                   |    1 +
 drivers/net/ixgbe/ixgbe_82599.c              |   78 ++++++++++++++----=
--------
 drivers/net/ixgbe/ixgbe_fcoe.c               |    6 +-
 drivers/net/ixgbe/ixgbe_main.c               |   22 ++++++--
 drivers/net/ixgbe/ixgbe_type.h               |    1 +
 drivers/net/ixgbevf/ethtool.c                |   42 +++++++++-----
 drivers/net/ixgbevf/ixgbevf_main.c           |   74 +++++++++++++++---=
------
 drivers/net/ixgbevf/vf.h                     |    6 ++
 drivers/net/jme.c                            |   35 ++++++++++++
 drivers/net/jme.h                            |    2 +-
 drivers/net/ks8851.c                         |    1 -
 drivers/net/usb/smsc95xx.c                   |   18 +++++-
 drivers/net/wireless/ath/ath9k/xmit.c        |   21 +-------
 drivers/net/wireless/iwlwifi/iwl-tx.c        |    2 +-
 drivers/net/wireless/wl12xx/wl1251_debugfs.c |    3 +-
 drivers/vhost/net.c                          |   10 ++-
 drivers/vhost/vhost.c                        |   18 ++++--
 include/linux/netdevice.h                    |    8 +-
 include/linux/netfilter/nfnetlink.h          |    2 +-
 include/linux/netlink.h                      |    2 +-
 include/net/netlink.h                        |    6 ++-
 net/8021q/vlan_core.c                        |    4 +-
 net/core/dev.c                               |    8 ++-
 net/ipv4/ipmr.c                              |    3 +
 net/ipv4/route.c                             |   14 +++-
 net/ipv4/tcp.c                               |   65 ++++++++++++++----=
---
 net/ipv4/tcp_input.c                         |    3 +
 net/ipv4/tcp_ipv4.c                          |    5 ++
 net/ipv6/ip6mr.c                             |    3 +
 net/ipv6/route.c                             |    2 +-
 net/netfilter/nf_conntrack_netlink.c         |    4 +-
 net/netfilter/nfnetlink.c                    |    4 +-
 net/netlink/af_netlink.c                     |   17 +++++-
 36 files changed, 335 insertions(+), 181 deletions(-)
