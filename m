From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Thu, 12 Jun 2008 21:19:59 -0700 (PDT)
Message-ID: <20080612.211959.52937006.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45884
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752415AbYFMET7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 00:19:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As the bug fixes keep flowing:

1) Revert one of the deferred-accept TCP changes as it
   has tons of bugs with no imminent cures and the feature
   itself can wait to 2.6.27 if at all.

   This clears up an entry on the regression list.

2) Eliminate flush_scheduled_work() calls in network driver close
   methods as this is deadlock prone.  This should close an issue
   which has been reported by Dave Jones and others for quite some
   time now.

3) rawv6_prot has two assignment to it's destruct method, noticed by
   Al Viro.

4) Several other ipv6 bug fixes via YOSHIFUJI Hideaki.

5) DCCP bug fixes via Gerrit Renker.

6) Wired driver bug fixes via Jeff Garzik.

7) Two netfilter bug fixes from Eric Leblond and Patrick MacHardy

Please pull, thanks a lot!

The following changes since commit 513fd370e6832f81ab717df4645f5ce679e44f14:
  David S. Miller (1):
        Merge branch 'davem-fixes' of master.kernel.org:/.../jgarzik/netdev-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Christophe Jaillet (1):
      drivers/net/r6040.c: correct bad use of round_jiffies()

David S. Miller (6):
      Merge branch 'master' of git://eden-feed.erg.abdn.ac.uk/net-2.6
      Merge branch 'net-2.6-misc-20080611a' of git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-fix
      Merge branch 'davem-fixes' of master.kernel.org:/.../jgarzik/netdev-2.6
      net: Eliminate flush_scheduled_work() calls while RTNL is held.
      ipv6: Fix duplicate initialization of rawv6_prot.destroy
      tcp: Revert 'process defer accept as established' changes.

Eilon Greenstein (1):
      bnx2x: Updating the Maintainer

Eric Leblond (1):
      netfilter: Make nflog quiet when no one listen in userspace.

Gerrit Renker (6):
      dccp ccid-3: Bug-Fix - Zero RTT is possible
      dccp: Fix sparse warnings
      dccp ccid-2: Bug-Fix - Ack Vectors need to be ignored on request sockets
      dccp ccid-3: TFRC reverse-lookup Bug-Fix
      dccp ccid-3: X truncated due to type conversion
      dccp: Bug in initial acknowledgment number assignment

Patrick McHardy (1):
      netfilter: nf_conntrack: fix ctnetlink related crash in nf_nat_setup_info()

Roel Kluin (2):
      ipg: fix receivemode IPG_RM_RECEIVEMULTICAST{,HASH} in ipg_nic_set_multicast_list()
      fec_mpc52xx: MPC52xx_MESSAGES_DEFAULT: 2nd NETIF_MSG_IFDOWN => IFUP

Shan Wei (1):
      ipv6: Check the hop limit setting in ancillary data.

YOSHIFUJI Hideaki (4):
      ipv6 mcast: Check address family of gf_group in getsockopt(MS_FILTER).
      ipv6 route: Fix route lifetime in netlink message.
      ipv6: Check IPV6_MULTICAST_LOOP option value.
      ipv6: Fail with appropriate error code when setting not-applicable sockopt.

 MAINTAINERS                               |    4 +-
 drivers/net/bnx2.c                        |    9 +-----
 drivers/net/bnx2.h                        |    1 -
 drivers/net/bnx2x.c                       |    5 ++-
 drivers/net/bnx2x.h                       |    3 +-
 drivers/net/bnx2x_init.h                  |    3 +-
 drivers/net/ehea/ehea_main.c              |    3 +-
 drivers/net/fec_mpc52xx.c                 |    2 +-
 drivers/net/hamradio/baycom_epp.c         |    2 +-
 drivers/net/ipg.c                         |    4 +-
 drivers/net/r6040.c                       |    2 +-
 drivers/net/smc911x.c                     |   24 +++------------
 drivers/net/smc91x.c                      |   17 ++---------
 drivers/net/tulip/tulip_core.c            |    2 +-
 drivers/net/usb/kaweth.c                  |    2 +-
 drivers/net/wireless/hostap/hostap_main.c |    8 ++++-
 include/linux/tcp.h                       |    7 ----
 include/net/request_sock.h                |    4 +-
 include/net/tcp.h                         |    1 -
 net/dccp/ackvec.c                         |   29 +-----------------
 net/dccp/ccids/ccid3.c                    |   14 ++++++--
 net/dccp/ccids/lib/tfrc.c                 |    8 -----
 net/dccp/ccids/lib/tfrc.h                 |   25 +++++++++------
 net/dccp/ccids/lib/tfrc_equation.c        |    8 ++--
 net/dccp/minisocks.c                      |    8 ++--
 net/dccp/options.c                        |    4 ++-
 net/dccp/output.c                         |    2 +
 net/dccp/probe.c                          |    2 +-
 net/ipv4/inet_connection_sock.c           |   11 +++++--
 net/ipv4/tcp.c                            |   18 +++++++----
 net/ipv4/tcp_input.c                      |   45 -----------------------------
 net/ipv4/tcp_ipv4.c                       |    8 -----
 net/ipv4/tcp_minisocks.c                  |   32 ++++++++-------------
 net/ipv4/tcp_timer.c                      |    5 ---
 net/ipv6/datagram.c                       |    5 +++
 net/ipv6/ipv6_sockglue.c                  |   12 +++++--
 net/ipv6/raw.c                            |    4 +-
 net/ipv6/route.c                          |    8 ++++-
 net/netfilter/nf_conntrack_core.c         |    3 +-
 net/netfilter/nf_log.c                    |    4 --
 40 files changed, 130 insertions(+), 228 deletions(-)
