From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 04 Jun 2010 23:03:02 -0700 (PDT)
Message-ID: <20100604.230302.35029921.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) act_nat miscomputes checksum when there isn't an address match.
   From Changli Gao.

2) cls_u32 and act_pedit access illegally past skb->data linear data
   end on fragmented packets, fix also from Changli Gao.

3) Fix integer overflow in tcp_hybla, from Daniele Lacamera.

4) Two SFC bug fixes from Ben Hutchings.

5) ppp fragment size fix in multilink code, from Ben McKeegan.

6) Fix survival of link over fec suspend/resume, from Eric B=E9nard.

7) Fix VLAN improper propagation of bonding device flags, from
   John Fastabend.

8) Fix bnx2 rmmod hang, from Michael Chan.

9) epic100 tests bogus CONFIG_BIG_ENDIAN, use __BIG_ENDIAN instead.
   From Roland Dreier.

10) IPSEC route popping accidently frees ref-less route objects,
    regression fix from Steffen Klassert.

11) RPS sock flow table is easily DOS'able on synflood, from Eric
    Dumazet.

12) TCP syncookies code uses wrong network namespace pointer, also
    from Eric Dumazet.

13) Two small wireless fixes from John Linville and the wireless
    team.

Please pull, thanks a lot!

The following changes since commit aef4b9aaae1decc775778903922bd0075cce=
7a88:
  Linus Torvalds (1):
        Merge branch 'next' of git://git.kernel.org/.../benh/powerpc

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ben Hutchings (2):
      sfc: Get port number from CS_PORT_NUM, not PCI function number
      sfc: Store port number in net_device::dev_id

Ben McKeegan (1):
      ppp_generic: fix multilink fragment sizes

Bruno Randolf (1):
      ath5k: wake queues on reset

Changli Gao (3):
      act_nat: fix the wrong checksum when addr isn't in old_addr/mask
      cls_u32: use skb_header_pointer() to dereference data safely
      act_pedit: access skb->data safely

Dan Carpenter (3):
      e1000e: change logical negate to bitwise
      isdn/kcapi: return -EFAULT on copy_from_user errors
      tehuti: return -EFAULT on copy_to_user errors

Daniele Lacamera (1):
      TCP: tcp_hybla: Fix integer overflow in slow start increment

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6

Eric B=E9nard (1):
      net/fec: fix pm to survive to suspend/resume

Eric Dumazet (3):
      xfrm: force a dst reference in __xfrm_route_forward()
      rps: tcp: fix rps_sock_flow_table table updates
      tcp: use correct net ns in cookie_v4_check()

=46lorian Westphal (1):
      syncookies: remove Kconfig text line about disabled-by-default

Huang Weiyi (1):
      X25: remove duplicated #include

Jeff Kirsher (1):
      ixgbe: return IXGBE_ERR_RAR_INDEX when out of range

Johannes Berg (2):
      mac80211: fix blockack-req processing
      mac80211: fix dialog token allocator

John Fastabend (3):
      net: init_vlan should not copy slave or master flags
      net: fix conflict between null_or_orig and null_or_bond
      ixgbe: only check pfc bits in hang logic if pfc is enabled

Michael Chan (1):
      bnx2: Fix hang during rmmod bnx2.

Phil Sutter (3):
      korina: fix deadlock on RX FIFO overrun
      korina: use netdev_alloc_skb_ip_align() here, too
      korina: count RX DMA OVR as rx_fifo_error

Roland Dreier (1):
      epic100: Test __BIG_ENDIAN instead of (non-existent) CONFIG_BIG_E=
NDIAN

Scott Feldman (1):
      enic: bug fix: make the set/get netlink VF_PORT support symmetric=
al

Steffen Klassert (1):
      net: check for refcount if pop a stacked dst_entry

 drivers/isdn/capi/kcapi.c             |    6 +-
 drivers/net/bnx2.c                    |   14 ++-
 drivers/net/e1000e/netdev.c           |    2 +-
 drivers/net/enic/enic.h               |    7 +
 drivers/net/enic/enic_main.c          |  196 ++++++++++++++++---------=
--------
 drivers/net/epic100.c                 |    7 +-
 drivers/net/fec.c                     |   16 ++--
 drivers/net/ixgbe/ixgbe_common.c      |    2 +
 drivers/net/ixgbe/ixgbe_main.c        |    2 +-
 drivers/net/ixgbe/ixgbe_type.h        |    1 +
 drivers/net/korina.c                  |   32 +++---
 drivers/net/ppp_generic.c             |    2 +-
 drivers/net/sfc/net_driver.h          |    2 +-
 drivers/net/sfc/siena.c               |    4 +
 drivers/net/tehuti.c                  |    4 +-
 drivers/net/wan/x25_asy.c             |    2 -
 drivers/net/wireless/ath/ath5k/base.c |   17 +---
 include/net/dst.h                     |    6 +-
 net/8021q/vlan_dev.c                  |    3 +-
 net/core/dev.c                        |    8 +-
 net/ipv4/Kconfig                      |   10 +-
 net/ipv4/syncookies.c                 |    2 +-
 net/ipv4/tcp_hybla.c                  |    4 +-
 net/ipv4/tcp_ipv4.c                   |    7 +-
 net/mac80211/agg-tx.c                 |    6 +-
 net/mac80211/rx.c                     |   13 ++-
 net/sched/act_nat.c                   |    4 +
 net/sched/act_pedit.c                 |   24 +++--
 net/sched/cls_u32.c                   |   49 ++++++--
 net/xfrm/xfrm_output.c                |    4 +-
 net/xfrm/xfrm_policy.c                |    1 +
 31 files changed, 254 insertions(+), 203 deletions(-)
