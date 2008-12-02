From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 01 Dec 2008 23:19:24 -0800 (PST)
Message-ID: <20081201.231924.42426300.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45981
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750957AbYLBHTY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2008 02:19:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) We still had some problem with that AF_UNIX test case.

   As I mentioned the other week when this all came up, it is
   possible to get this test case into a state where the child
   still running can queue new SCM passed fds to the parent
   faster than the exit'ing parent can clean them up in UNIX
   garbage collection.

   People have even triggered OOM with this situation.

   The solution I designed, and Dann Frazier implemented, is to
   make threads of control about to hit scm_send() wait until
   any pending UNIX garbage collection finishes.

2) Make skb_truesize_bug() WARN() so that we can get more information
   about the cause of the problem, from Arjan.

3) Socket leak in pppol2tp_release(), fix from Fr=E9d=E9ric Moulins.

4) update_mtu() method can crash with GRE tunnels over bridging.
   Fix from Herbert Xu.

5) TCP urgent data should avoid trying to use TSO/GSO.  From Petr
   Tesarik.

6) Fix hp-plus driver link errors and use of wrong 8390 lib poll
   handler, from Randy Dunlap.

7) OOPS fix in phonet_address_del(), from R=E9mi Denis-Courmont.

8) Wireless bug fixes from the wireless crew, via John Linville.

9) Catalin Marinas found a leak in the proto_register() handling.

Please pull, thanks a lot.

The following changes since commit 13d428afc007fcfcd6deeb215618f54cf9c0=
cae6:
  Linus Torvalds (1):
        Linux 2.6.28-rc6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Abhijeet Kolekar (1):
      mac80211 : Fix setting ad-hoc mode and non-ibss channel

Andreas Petlund (1):
      pci: Added quirk to disable msi for MCP55 NIC on Asus P5N32-SLI P=
remium

Arjan van de Ven (1):
      net: make skb_truesize_bug() call WARN()

Bernard Pidoux (1):
      rose: zero length frame filtering in af_rose.c

Catalin Marinas (1):
      net: Fix memory leak in the proto_register function

Cheng Renquan (1):
      ath5k: fix Security issue in DebugFS part of ath5k

Cord Walter (1):
      axnet_cs / pcnet_cs: moving PCMCIA_DEVICE_PROD_ID for Netgear FA4=
11

David S. Miller (2):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      sungem: Fix PCS_MIICTRL register write in gem_init_phy().

=46r=E9d=E9ric Moulins (1):
      pppol2tp: Add missing sock_put() in pppol2tp_release()

Giuseppe Cavallaro (1):
      phy: fix phy_id detection also for broken hardware.

Herbert Xu (1):
      bridge: netfilter: fix update_pmtu crash with GRE

Ingo Molnar (1):
      net/wireless/reg.c: fix bad WARN_ON in if statement

Jan Engelhardt (1):
      netfilter: xtables: add missing const qualifier to xt_tgchk_param

Jiri Slaby (2):
      ATM: horizon, fix hrz_probe fail path
      MAINTAINERS: add netdev to ATM

Johannes Berg (1):
      iwlagn: fix DMA sync

Luis R. Rodriguez (2):
      ath9k: Fix SW-IOMMU bounce buffer starvation
      ath9k: correct expected max RX buffer size

Martin Xu (1):
      ath5k: disable beacon filter when station is not associated

Patrick McHardy (3):
      netfilter: ctnetlink: fix conntrack creation race
      netfilter: ctnetlink: fix GFP_KERNEL allocation under spinlock
      macvlan: don't broadcast PAUSE frames to macvlan devices

Petr Tesarik (1):
      tcp: Do not use TSO/GSO when there is urgent data

Qinghuang Feng (2):
      driver/net/*: remove redundant argument comments
      drivers/net/chelsio/sge.c: remove redundant argument comments

Randy Dunlap (2):
      net/hp-plus: fix link errors
      net: hp-plus uses eip_poll

R=E9mi Denis-Courmont (1):
      Phonet: fix oops in phonet_address_del() on non-Phonet device

Trent Piepho (1):
      phylib: Add Vitesse VSC8221 SGMII PHY

dann frazier (1):
      net: Fix soft lockups/OOM issues w/ unix garbage collector

 MAINTAINERS                            |    1 +
 drivers/atm/horizon.c                  |    2 +-
 drivers/net/Makefile                   |    2 +-
 drivers/net/chelsio/sge.c              |    4 --
 drivers/net/e1000e/netdev.c            |    1 -
 drivers/net/hp-plus.c                  |    2 +-
 drivers/net/igb/igb_main.c             |    4 --
 drivers/net/ixgbe/ixgbe_main.c         |    1 -
 drivers/net/macvlan.c                  |    3 +
 drivers/net/pcmcia/axnet_cs.c          |    2 +-
 drivers/net/pcmcia/pcnet_cs.c          |    1 -
 drivers/net/phy/phy_device.c           |   13 +++++-
 drivers/net/phy/vitesse.c              |   64 ++++++++++++++++++++++++=
+++----
 drivers/net/pppol2tp.c                 |    1 +
 drivers/net/sis900.c                   |    1 -
 drivers/net/spider_net.c               |    4 --
 drivers/net/sungem.c                   |    2 +-
 drivers/net/wireless/ath5k/base.c      |   35 +++++++++++++++++-
 drivers/net/wireless/ath5k/base.h      |    1 +
 drivers/net/wireless/ath5k/debug.c     |   10 ++--
 drivers/net/wireless/ath9k/beacon.c    |   10 ++--
 drivers/net/wireless/ath9k/recv.c      |   19 +++++++--
 drivers/net/wireless/iwlwifi/iwl-agn.c |    8 ++-
 drivers/pci/quirks.c                   |   17 ++++++++
 include/linux/netfilter/x_tables.h     |    2 +-
 include/net/af_unix.h                  |    1 +
 include/net/request_sock.h             |    1 +
 include/net/timewait_sock.h            |    1 +
 net/bridge/br_netfilter.c              |   13 ++++++
 net/core/skbuff.c                      |    2 +-
 net/core/sock.c                        |   31 ++++++---------
 net/ipv4/tcp_output.c                  |    7 ++-
 net/mac80211/wext.c                    |    8 ++++
 net/netfilter/nf_conntrack_core.c      |    2 -
 net/netfilter/nf_conntrack_netlink.c   |    7 ++-
 net/phonet/pn_dev.c                    |    2 +-
 net/rose/af_rose.c                     |   10 +++++
 net/unix/af_unix.c                     |    2 +
 net/unix/garbage.c                     |   13 +++++-
 net/wireless/reg.c                     |    4 +-
 40 files changed, 229 insertions(+), 85 deletions(-)
