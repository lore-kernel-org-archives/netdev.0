From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking fixes
Date: Sun, 28 Jun 2009 17:45:32 -0700 (PDT)
Message-ID: <20090628.174532.182783116.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43917
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760532AbZF2Ap0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jun 2009 20:45:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Some of these address a few entries posted in the regression
list today.

1) BE2NET driver overruns SKB frags array when page size is
   huge (for example, 64K on PPC).  Fix from Ajit Khaparde.

2) SKY2 bolixes checksums on big endian, fix from Anton Vorontsov.

3) A fix for prevently corner case execution of netdev device
   destructor after module removal causes even bigger problems
   in normal operation, revert.

   Alternative fix is being worked out.

4) CAST algorithm string name misspelled, obviously nobody
   tries to use this stuff :-)  Fix from Herbert Xu.

5) When NAPI poll collides with netpoll, we don't flush pending
   GRO frames and crash instead.  Fix from Herbert Xu.

6) skb_orphan "fix" broke transparent proxy, fix that too.
   From Herbert Xu.

7) IPv6 address lifetimes can wrap around, fix from Jens Rosenboom.

8) Jesper Dangaard Brouer found some cases where we need an
   rcu_barrier() during module unload.

9) mdio module lacks license tag, taints module.

10) phonet doesn't advertise address delete events on interface
    down, which makes things next to useless.  Fix from
    R=E9mi Denis-Courmont.

11) TCP doesn't pass on frames lacking ACK when it should during
    FIN-WAIT-2.

Please pull, thanks a lot!

The following changes since commit 4142ac678a864972ce1dfad6d9cb22f075fe=
e5de:
  Linus Torvalds (1):
        Merge git://git.kernel.org/.../sfrench/cifs-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ajit Khaparde (1):
      be2net: Fix to avoid a crash seen on PPC with LRO and Jumbo frame=
s.

Anton Vorontsov (1):
      sky2: Fix checksum endianness

Brandon Philips (1):
      atl1*: add device_set_wakeup_enable to atl1*_set_wol

David S. Miller (1):
      Revert "veth: prevent oops caused by netdev destructor"

=46lorian Fainelli (1):
      cpmac: fix compilation failure introduced with netdev_ops convers=
ion

Herbert Xu (3):
      ipsec: Fix name of CAST algorithm
      inet: Call skb_orphan before tproxy activates
      gro: Flush GRO packets in napi_disable_pending path

Ionut Nicu (1):
      fsl_pq_mdio: Fix fsl_pq_mdio to work with modules

Jens Rosenboom (1):
      ipv6: avoid wraparound for expired preferred lifetime

Jesper Dangaard Brouer (5):
      decnet: Use rcu_barrier() on module unload.
      ipv6: Use rcu_barrier() on module unload.
      bridge: Use rcu_barrier() instead of syncronize_net() on unload.
      sunrpc: Use rcu_barrier() on unload.
      mac80211: Use rcu_barrier() on unload.

Nicolas Reinecke (1):
      mdio add missing GPL flag

R=E9mi Denis-Courmont (2):
      Phonet: publicize the Netlink notification function
      Phonet: generate Netlink RTM_DELADDR when destroying a device

Wei Yongjun (1):
      tcp: missing check ACK flag of received segment in FIN-WAIT-2 sta=
te

roel kluin (1):
      sh_eth: remove redundant test on unsigned

 drivers/net/atl1c/atl1c_ethtool.c |    2 +
 drivers/net/atl1e/atl1e_ethtool.c |    2 +
 drivers/net/benet/be.h            |    2 +-
 drivers/net/benet/be_ethtool.c    |    4 +-
 drivers/net/benet/be_main.c       |   45 ++++++++++++++++++++++-------=
--
 drivers/net/cpmac.c               |    2 +-
 drivers/net/fsl_pq_mdio.c         |    8 +++---
 drivers/net/mdio.c                |    4 +++
 drivers/net/sh_eth.c              |    9 +-----
 drivers/net/sky2.c                |    2 +-
 drivers/net/veth.c                |   41 +++++++++++++++++-----------
 include/net/phonet/pn_dev.h       |    1 +
 net/bridge/br.c                   |    2 +-
 net/core/dev.c                    |    8 +++--
 net/decnet/af_decnet.c            |    2 +
 net/ipv4/ip_input.c               |    3 ++
 net/ipv4/tcp_minisocks.c          |    3 +-
 net/ipv6/addrconf.c               |    5 +++-
 net/ipv6/af_inet6.c               |    2 +
 net/ipv6/ip6_input.c              |    3 ++
 net/mac80211/mesh.c               |    2 +-
 net/phonet/pn_dev.c               |   52 ++++++++++++++++++++++-------=
--------
 net/phonet/pn_netlink.c           |    4 +-
 net/sunrpc/sunrpc_syms.c          |    1 +
 net/xfrm/xfrm_algo.c              |    4 +-
 25 files changed, 135 insertions(+), 78 deletions(-)
