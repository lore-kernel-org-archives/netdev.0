From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 17 Jan 2014 19:25:05 -0800 (PST)
Message-ID: <20140117.192505.1901672539416947640.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) The value choosen for the new SO_MAX_PACING_RATE socket option on
   parisc was very poorly choosen, let's fix it while we still can.
   From Eric Dumazet.

2) Our generic reciprocal divide was found to handle some edge cases
   incorrectly, part of this is encoded into the BPF as deep as the
   JIT engines themselves.  Just use a real divide throughout for now.
   From Eric Dumazet.

3) Because the initial lookup is lockless, the TCP metrics engine
   can end up creating two entries for the same lookup key.  Fix this
   by doing a second lookup under the lock before we actually create
   the new entry.  From Christoph Paasch.

4) Fix scatter-gather list init in usbnet driver, from Bj=F8rn Mork.

5) Fix unintended 32-bit truncation in cxgb4 driver's bit shifting.
   From Dan Carpenter.

6) Netlink socket dumping uses the wrong socket state for timewait
   sockets.  Fix from Neal Cardwell.

7) Fix netlink memory leak in ieee802154_add_iface(), from Christian
   Engelmayer.

8) Multicast forwarding in ipv4 can overflow the per-rule reference
   counts, causing all multicast traffic to cease.  Fix from
   Hannes Frederic Sowa.

9) via-rhine needs to stop all TX queues when it resets the device,
   from Richard Weinberger.

10) Fix RDS per-cpu accesses broken by the this_cpu_* conversions.
    From Gerald Schaefer.

Please pull, thanks a lot!

The following changes since commit 228fdc083b017eaf90e578fa86fb1ecfd5ff=
ae87:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2014-0=
1-11 06:37:11 +0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 3af57f78c38131b7a66e2b01e06fdacae01992a3=
:

  s390/bpf,jit: fix 32 bit divisions, use unsigned divide instructions =
(2014-01-17 18:54:49 -0800)

----------------------------------------------------------------
Bj=F8rn Mork (1):
      net: usbnet: fix SG initialisation

Christian Engelmayer (1):
      ieee802154: Fix memory leak in ieee802154_add_iface()

Christoph Paasch (1):
      tcp: metrics: Avoid duplicate entries with the same destination-I=
P

Dan Carpenter (1):
      cxgb4: silence shift wrapping static checker warning

David S. Miller (1):
      Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/l=
inux-merge

Eric Dumazet (2):
      bpf: do not use reciprocal divide
      parisc: fix SO_MAX_PACING_RATE typo

Gerald Schaefer (1):
      net: rds: fix per-cpu helper usage

Hannes Frederic Sowa (2):
      net: avoid reference counter overflows on fib_rules in multicast =
forwarding
      ipv6: simplify detection of first operational link-local address =
on interface

Heiko Carstens (1):
      s390/bpf,jit: fix 32 bit divisions, use unsigned divide instructi=
ons

Ivan Vecera (1):
      be2net: add dma_mapping_error() check for dma_map_page()

Jitendra Kalsaria (1):
      qlge: Fix vlan netdev features.

Marek Lindner (1):
      batman-adv: fix batman-adv header overhead calculation

Michael S. Tsirkin (1):
      MAINTAINERS: add virtio-dev ML for virtio

Mika Westerberg (1):
      e1000e: Fix compilation warning when !CONFIG_PM_SLEEP

Neal Cardwell (1):
      inet_diag: fix inet_diag_dump_icsk() to use correct state for tim=
ewait sockets

Peter Korsgaard (1):
      dm9601: add USB IDs for new dm96xx variants

Richard Weinberger (1):
      net,via-rhine: Fix tx_timeout handling

Yuval Mintz (1):
      bnx2x: Don't release PCI bars on shutdown

 MAINTAINERS                                      |  3 +++
 arch/arm/net/bpf_jit_32.c                        |  6 +++---
 arch/parisc/include/uapi/asm/socket.h            |  2 +-
 arch/powerpc/net/bpf_jit_comp.c                  |  7 ++++---
 arch/s390/net/bpf_jit_comp.c                     | 29 ++++++++++++++++=
+-----------
 arch/sparc/net/bpf_jit_comp.c                    | 17 ++++++++++++++--=
-
 arch/x86/net/bpf_jit_comp.c                      | 14 ++++++++++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 29 ++++++++++++++--=
------------
 drivers/net/ethernet/chelsio/cxgb4/l2t.c         |  2 +-
 drivers/net/ethernet/emulex/benet/be_main.c      | 11 +++++++++--
 drivers/net/ethernet/intel/e1000e/netdev.c       |  8 ++------
 drivers/net/ethernet/qlogic/qlge/qlge_main.c     |  2 ++
 drivers/net/ethernet/via/via-rhine.c             |  1 +
 drivers/net/usb/dm9601.c                         | 12 ++++++++++++
 drivers/net/usb/usbnet.c                         |  2 +-
 include/net/if_inet6.h                           |  1 -
 net/batman-adv/main.c                            |  2 +-
 net/core/filter.c                                | 30 ++--------------=
-------------
 net/ieee802154/nl-phy.c                          |  6 ++++--
 net/ipv4/inet_diag.c                             |  5 ++++-
 net/ipv4/ipmr.c                                  |  7 +++++--
 net/ipv4/tcp_metrics.c                           | 51 ++++++++++++++++=
+++++++++++++++-------------------
 net/ipv6/addrconf.c                              | 38 ++++++++++++++++=
+--------------------
 net/ipv6/ip6mr.c                                 |  7 +++++--
 net/rds/ib_recv.c                                |  7 +++----
 25 files changed, 169 insertions(+), 130 deletions(-)
