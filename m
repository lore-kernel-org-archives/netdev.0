From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 21 Apr 2015 22:58:27 -0400 (EDT)
Message-ID: <20150421.225827.1165782705436050301.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Just a few fixes trickling in at this point.

1) If we see an attached socket on an skb in the ipv4 forwarding
   path, bail.  This can happen due to races with FIB rule addition,
   and deletion, and we should just drop such frames.  From Sebastian
   P=F6hn.

2) pppoe receive should only accept packets destined for this hosts's
   MAC address.  From Joakim Tjernlund.

3) Handle checksum unwrapping properly in ppp receive properly when
   it's encapsulated in UDP in some way, fix from Tom Herbert.

4) Fix some bugs in mv88e6xxx DSA driver resulting from the conversion
   from register offset constants to mnenomic macros.  From Vivien
   Didelot.

5) Fix handling of HCA max message size in mlx4 adapters, from Eran
   Ben ELisha.

Please pull, thanks a lot.

The following changes since commit 04b7fe6a4a231871ef681bc95e08fe66992f=
7b1f:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/ide (2015-0=
4-17 16:36:59 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git=20

for you to fetch changes up to fab9adfb71fc8690e20c3c280d39d49c8f4a3f0a=
:

  net/mlx4_core: Fix reading HCA max message size in mlx4_QUERY_DEV_CAP=
 (2015-04-21 17:36:08 -0400)

----------------------------------------------------------------
Andreas Oetken (1):
      altera tse: Error-Bit on tx-avalon-stream always set.

David S. Miller (1):
      Merge branch 'ppp_csum_unset'

Eran Ben Elisha (1):
      net/mlx4_core: Fix reading HCA max message size in mlx4_QUERY_DEV=
_CAP

Joakim Tjernlund (1):
      pppoe: Lacks DST MAC address check

Sebastian P=F6hn (1):
      ip_forward: Drop frames with attached skb->sk

Tom Herbert (2):
      net: add skb_checksum_complete_unset
      ppp: call skb_checksum_complete_unset in ppp_receive_frame

Vivien Didelot (2):
      net: dsa: mv88e6xxx: fix setup of port control 1
      net: dsa: mv88e6xxx: use PORT_DEFAULT_VLAN

jbaron@akamai.com (1):
      tcp: add memory barriers to write space paths

 drivers/net/dsa/mv88e6xxx.c                   |  6 +++---
 drivers/net/ethernet/altera/altera_msgdmahw.h |  1 -
 drivers/net/ethernet/mellanox/mlx4/fw.c       |  2 +-
 drivers/net/ppp/ppp_generic.c                 |  1 +
 drivers/net/ppp/pppoe.c                       |  3 +++
 include/linux/skbuff.h                        | 12 ++++++++++++
 net/ipv4/ip_forward.c                         |  3 +++
 net/ipv4/tcp.c                                |  4 +++-
 net/ipv4/tcp_input.c                          |  2 ++
 9 files changed, 28 insertions(+), 6 deletions(-)
