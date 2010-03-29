From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 29 Mar 2010 13:45:32 -0700 (PDT)
Message-ID: <20100329.134532.259205360.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Intel drivers change tx_queue_len on link speed change and
   this can very seriously screw configs up on people, particularly
   wrt. packet scheduler setups.  From Emil Tantilov.

2) In IXGBE, if FIP negotatiation frames don't get steered to the FCoE
   queues, drops can happen because FCoE frames going through the
   switches can send packets larger than the standard MTU and we must
   accept them.  Fix from Chris Leech.

3) The long overdue fix for the r8169 CVE length check issue.
   Should have merged this over a month ago but it slipped
   through the cracks.  From Neil Horman.

4) We tried to enable 64-bit DMA by default in the r8169 driver
   but some people are hitting regressions due to this and
   analyzing this will take some time, so revert.

5) If dev_alloc_skb() fails in Tulip's uli526x_rx_packet, we honk
   on a NULL pointer.  Fix from Kyle McMartin.

6) Fix bug in ipv4/ipv6 netlink address dumping, if we got interrupted
   at the very end of a hash chain we wouldn't restart at the right
   spot.  From Patrick McHardy.

7) When we bump the generation count and rebuild the ipv4 routing
   cache after finding abnormally long hash chains, we proceed to
   accidently add a new entry with the old generation count which
   will never subsequently match.  Fix from Pavel Emelyanov.

8) The new recvmmsg() system call is significantly less useful
   then intended because there is no way to say "well, if you get
   at least one packet, return just that if nothing else is
   pending."  This adds the MSG_WAITFORONE flag for this purpose.
   From Brandon L. Black

9) benet driver is missing "ULL" marker in 64-bit constants.
   Fix from Zhitong Wang.

10) Because of the way we mark unresolved IP multicast routing
    cache entries, we can end up accidently accessing past the
    end of the vif_table[] array.  Fix from Nicolas Dichtel.

11) Multicast in round-robin mode of the bonding driver is broken
    because we don't handle properly the cases where the link
    that sends out the IGMP join goes down.  Fix from
    Andy Gospodarek.

12) New ID for pcnet_cs PCMCIA driver, from Ken Kawasaki.

13) Attempt to fix r8169 MAC address writes that end up with the
    registers showing zero later.  From Francois Romieu.

    This will need some more tweaks because Al Viro showed
    a case yesterday where this fix is not completely sufficient
    for a card he has.

14) In ipv4 we fixed a case where a socket giving negative advice
    on a route inadvertantly purged an entry created by an icmp
    redirect, even if it hadn't expired yet.  This is the ipv6
    side of that fix, from YOSHFUJI Hideaki.

15) NetXEN bug fixes via Amit Kumar Salecha:

    a) BIOS fw image version checks use wrong shifts.
    b) Status consumer I/O address calculation is wrong for
       some chip variants.
    c) PCI ioremap calls not checked for failure at all.

16) IXGBEVF driver checks unsigned value for negative.  Fix from
    Greg Rose.

17) IXGBE chips in SR-IOV mode need a delay on bringup to handle
    delayed response to PF indications.  This is not the most
    desirable fix in the long term, but good enough to fix the
    problem for the time being.  From Greg Rose.

18) In the IXGBE driver we need to clear all of the per-VF
    ->clear_to_send flags before we invoke ixgbe_ping_all_vfs().
    Fix from Greg Rose.

19) Max TX queue calculations in IXGBE are slightly busted, fix from
    John Fastabend.

20) In IXGBE, properly enforce a limit of 255 for the FCOE DDP user
    buffer count, otherwise we program garbage into registers.  Fix
    from Robert Love.

21) Gianfar's RX recycling code can corrupt SKBs because it can
    accidently double skb_reserve() on a packet before using it.  Fix
    from Ben Machaca.

22) IGB checks wrong bits in MANC register to see if managability
    is enabled.  Fix from Alexander Duyck.

23) Elide some diagnostic checks when VFs are online otherwise they
    will be confused by home some of these checks take the PF
    offline momentarily.  Fix from Greg Rose.

Please pull, thanks a lot!

The following changes since commit b72c40949b0f04728f2993a1434598d3bad094ea:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://git.kernel.org/.../jbarnes/pci-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexander Duyck (1):
      igb: use correct bits to identify if managability is enabled

Amit Kumar Salecha (4):
      netxen: fix bios version calculation
      netxen: fix warning in ioaddr for NX3031 chip
      netxen: added sanity check for pci map
      netxen: update version to 4.0.73

Andy Gospodarek (1):
      bonding: fix broken multicast with round-robin mode

Ben Menchaca (1):
      gianfar: fix undo of reserve()

Brandon L Black (1):
      net: Add MSG_WAITFORONE flag to recvmmsg

Chris Leech (1):
      ixgbe: filter FIP frames into the FCoE offload queues

David S. Miller (3):
      isdn: Add netdev to lists in MAINTAINERS entry.
      Revert "r8169: enable 64-bit DMA by default for PCI Express devices (v2)"
      tulip: Add missing parens.

Emil Tantilov (3):
      igbvf: do not modify tx_queue_len on link speed change
      e1000e: do not modify tx_queue_len on link speed change
      e1000: do not modify tx_queue_len on link speed change

Francois Romieu (1):
      r8169: fix broken register writes

Greg Rose (4):
      ixgbevf: Fix signed/unsigned int error
      ixgbe: In SR-IOV mode insert delay before bring the adapter up
      ixgbe: Change where clear_to_send_flag is reset to zero.
      ixgbe: Do not run all Diagnostic offline tests when VFs are active

Joe Perches (1):
      drivers/net: Fix continuation lines

John Fastabend (1):
      ixgbe: cleanup maximum number of tx queues

Ken Kawasaki (1):
      pcnet_cs: add new id

Kyle McMartin (1):
      tulip: Fix null dereference in uli526x_rx_packet()

Neil Horman (1):
      r8169: offical fix for CVE-2009-4537 (overlength frame DMAs)

Nicolas Dichtel (1):
      net: ipmr/ip6mr: prevent out-of-bounds vif_table access

Patrick McHardy (1):
      net: fix netlink address dumping in IPv4/IPv6

Pavel Emelyanov (2):
      ipv4: Cleanup struct net dereference in rt_intern_hash
      ipv4: Restart rt_intern_hash after emergency rebuild (v2)

Robert Love (2):
      ixgbe: Don't allow user buffer count to exceed 256
      ixgbe: Priority tag FIP frames

YOSHIFUJI Hideaki / 吉藤英明 (1):
      ipv6: Don't drop cache route entry unless timer actually expired.

wzt wzt (1):
      benet: Fix compile warnnings in drivers/net/benet/be_ethtool.c

 MAINTAINERS                          |    1 +
 drivers/net/atlx/atl1.c              |    2 +-
 drivers/net/benet/be_ethtool.c       |    2 +-
 drivers/net/bonding/bond_main.c      |   40 ++++++++++++++++++++-----
 drivers/net/e1000/e1000.h            |    1 -
 drivers/net/e1000/e1000_main.c       |    9 +-----
 drivers/net/e1000e/e1000.h           |    1 -
 drivers/net/e1000e/netdev.c          |   11 +------
 drivers/net/gianfar.c                |    5 ++-
 drivers/net/gianfar.h                |    6 ++++
 drivers/net/igb/e1000_mac.c          |    6 ++--
 drivers/net/igbvf/igbvf.h            |    1 -
 drivers/net/igbvf/netdev.c           |   11 +------
 drivers/net/ixgbe/ixgbe.h            |    7 +++-
 drivers/net/ixgbe/ixgbe_ethtool.c    |   21 +++++++++++++
 drivers/net/ixgbe/ixgbe_fcoe.c       |   33 +++++++++++++++-----
 drivers/net/ixgbe/ixgbe_main.c       |   43 +++++++++++++++++++--------
 drivers/net/ixgbe/ixgbe_type.h       |    1 +
 drivers/net/ixgbevf/ixgbevf_main.c   |    3 +-
 drivers/net/netxen/netxen_nic.h      |    4 +-
 drivers/net/netxen/netxen_nic_ctx.c  |   14 +++++----
 drivers/net/netxen/netxen_nic_init.c |    2 +-
 drivers/net/netxen/netxen_nic_main.c |   45 +++++++++++++++++-----------
 drivers/net/pcmcia/pcnet_cs.c        |    3 +-
 drivers/net/r8169.c                  |   54 ++++++++++++++++++++-------------
 drivers/net/tulip/uli526x.c          |    8 +++--
 drivers/serial/serial_cs.c           |    1 +
 include/linux/socket.h               |    1 +
 net/ipv4/devinet.c                   |    2 +-
 net/ipv4/ipmr.c                      |   11 ++++--
 net/ipv4/route.c                     |   21 ++++++++-----
 net/ipv6/addrconf.c                  |    2 +-
 net/ipv6/ip6mr.c                     |   11 ++++--
 net/ipv6/route.c                     |   13 +++++--
 net/socket.c                         |    4 ++
 35 files changed, 256 insertions(+), 144 deletions(-)
