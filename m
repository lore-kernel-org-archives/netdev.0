From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 10 Mar 2011 15:34:44 -0800 (PST)
Message-ID: <20110310.153444.115930379.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I think all the major known regressions are cured and we should be
ready to go for 2.6.38-final

1) Fix regression in IPV6 route lookups, cures BZ 29252 and 30462

2) We use ifa_address where we mean ifa_local in ipv4 stack,
   reported by Julian Anastasov.

3) pktgen time reporting units are wrong, fix from Daniel Turull

4) IPV6=3Dm/BRIDGE=3Dy results in broken build, fix from Randy Dunlap.

5) Network modloading security fix needs to handle ip6 tunnel case,
   fix from Stephen Hemminger.

6) bnx2x driver fixes from Dmitry Kravkov and Eilon Greenstein.

7) smsc911x drops full sized VLAN packets erroneously, fix from G=F6ran
   Weinholt.

8) Fix Makefile logic for entering net/ipv6 directory for the case
   where we are only building {exthdrs,addrconf}_core.o Fix from
   Thomas Graf.

9) Multi-threaded signal handling is botched because we use plain
   mutex_lock() to synchronize readers in recvmsg(), change to use
   mutex_lock_interruptible().  Fix from Rainer Weikusat.

10) Bonding driver state machine locking doesn't cover enough code,
    fix from Nils Carlson.

12) Fix BUG_ON trigger in RDS stack, fix from Neil Horman.

13) Multicase handling fixes to r6040 driver from Shawn Lin.

Please pull, thanks a lot!

The following changes since commit 9179746652faf0aba07b8b7f770dcf29892a=
24c6:

  Merge branch 'media_fixes' of git://git.kernel.org/pub/scm/linux/kern=
el/git/mchehab/linux-2.6 (2011-03-10 13:22:10 -0800)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Daniel Turull (1):
      pktgen: fix errata in show results

David S. Miller (3):
      ipv4: Fix erroneous uses of ifa_address.
      ipv6: Don't create clones of host routes.
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/

Dmitry Kravkov (4):
      bnx2x: fix non-pmf device load flow
      bnx2x: fix link notification
      bnx2x: (NPAR) prevent HW access in D3 state
      bnx2x: fix MaxBW configuration

=46lorian Fainelli (1):
      r6040: bump to version 0.27 and date 23Feb2011

G=F6ran Weinholt (1):
      net/smsc911x.c: Set the VLAN1 register to fix VLAN MTU problem

Jon Mason (1):
      vxge: update MAINTAINERS

Neil Horman (1):
      rds: prevent BUG_ON triggering on congestion map updates

Nicolas Kaiser (1):
      drivers/net/macvtap: fix error check

Nils Carlson (2):
      bonding 802.3ad: Fix the state machine locking v2
      bonding 802.3ad: Rename rx_machine_lock to state_machine_lock

Rainer Weikusat (1):
      net: fix multithreaded signal handling in unix recv routines

Randy Dunlap (1):
      net: bridge builtin vs. ipv6 modular

Shawn Lin (1):
      r6040: fix multicast operations

Thomas Graf (1):
      net: Enter net/ipv6/ even if CONFIG_IPV6=3Dn

j223yang@asset.uwaterloo.ca (1):
      ariadne: remove redundant NULL check

stephen hemminger (1):
      ip6ip6: autoload ip6 tunnel

 MAINTAINERS                       |    5 +-
 drivers/net/ariadne.c             |    5 --
 drivers/net/bnx2x/bnx2x.h         |    5 +-
 drivers/net/bnx2x/bnx2x_cmn.c     |   22 +++++++
 drivers/net/bnx2x/bnx2x_cmn.h     |    9 +++
 drivers/net/bnx2x/bnx2x_ethtool.c |   18 +++---
 drivers/net/bnx2x/bnx2x_main.c    |   19 +++---
 drivers/net/bonding/bond_3ad.c    |   32 ++++++----
 drivers/net/bonding/bond_3ad.h    |    3 +-
 drivers/net/macvtap.c             |    3 +-
 drivers/net/r6040.c               |  115 +++++++++++++++++++++--------=
--------
 drivers/net/smsc911x.c            |    5 ++
 net/Makefile                      |    4 +-
 net/bridge/Kconfig                |    1 +
 net/core/pktgen.c                 |    2 +-
 net/ipv4/devinet.c                |    6 +-
 net/ipv6/ip6_tunnel.c             |    1 +
 net/ipv6/route.c                  |    4 +-
 net/rds/ib_send.c                 |    5 +-
 net/rds/loop.c                    |   11 +++-
 net/unix/af_unix.c                |   17 ++++-
 21 files changed, 182 insertions(+), 110 deletions(-)
