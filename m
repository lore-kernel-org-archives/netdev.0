From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 17 Jul 2012 07:36:50 -0700 (PDT)
Message-ID: <20120717.073650.1950536711269323582.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50440 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753191Ab2GQOgv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 10:36:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I know this looks like a lot more than you want to see right now,
however a) the stuff here are real OOPS'ers, memory leaks, and
regressions and b) it's been a full 2 weeks since I last sent bug
fixes your way.

If it makes you feel any better, my default has been to toss fixes
into net-next unless it was really serious like the stuff below.

I have a CIPSO ipv4 option processing oops'er I intend to work on
fixing myself if the maintainer of the code doesn't look at it in the
24 hours.

1) IPVS oops'ers:
   a) Should not reset skb->nf_bridge in forwarding hook (Lin Ming)
   b) 3.4 commit can cause ip_vs_control_cleanup to be invoked after
      the ipvs_core_ops are unregistered during rmmod (Julian ANastasov=
)

2) ixgbevf bringup failure can crash in TX descriptor cleanup (Alexande=
r Duyck)

3) AX25 switch missing break statement hoses ROSE sockets (Alan Cox)

4) CAIF accesses freed per-net memory (Sjur Brandeland)

5) Network cgroup code has out-or-bounds accesses (Eric DUmazet), and a=
ccesses
   freed memory (Gao Feng)

6) Fix a crash in SCTP reported by Dave Jones caused by freeing an asso=
ciation
   still on a list (Neil HOrman)

7) __netdev_alloc_skb() regresses on GFP_DMA using drivers because that=
 GFP
   flag is not being retained for the allocation (Eric Dumazet).

8) Missing NULL hceck in sch_sfb netlink message parsing (Alan Cox)

9) bnx2 crashes because TX index iteration is not bounded correctly (Mi=
chael
   Chan)

10) IPoIB generates warnings in TCP queue collapsing (via
    skb_try_coalesce) because it does not set skb->truesize correctly
    (Eric Dumazet)

11) vlan_info objects leak for the implicit vlan with ID 0 (Amir Hanani=
a)

12) A fix for TX time stamp handling in gianfar does not transfer
    socket ownership from one packet to another correctly, resulting
    in a socket write space imbalance (Eric Dumazet)

13) Julia Lawall found several cases where we do a list iteration, and
    then at the loop termination unconditionally assume we ended up wit=
h
    real list object, rather than the list head itself (CNIC, RXRPC,
    mISDN).

14) The bonding driver handles procfs moving incorrectly when a device
    it manages is moved from one namespace to another (Eric Biederman)

15) Missing memory barriers in stmmac descriptor accesses result in
    various crashes (Deepak Sikri)

16) Fix handling of broadcast packets in batman-adv (Simon Wunderlich)

17) Properly check the sanity of sendmsg() lengths in ieee802154's
    dgram_sendmsg().  Dave Jones and others have hit and reported this
    bug (Sasha Levin)

18) Some drivers (b44 and b43legacy) on 64-bit machines stopped
    working because of how netdev_alloc_skb() was adjusted.  Such
    drivers should now use alloc_skb() for obtaining bounce buffers.
    (Eric Dumazet)

19) atl1c mis-managed it's link state in that it stops the queue by
    hand on link down.  The generic networking takes care of that and
    this double stop locks the queue down.  So simply removing the
    driver's queue stop call fixes the problem (Cloud Ren)

20) Fix out-of-memory due to mis-accounting in net_em packet scheduler
    (Eric Dumazet)

21) If DCB and SR-IOV are configured at the same time in IXGBE the chip
    will hang because this is not supported (Alexander Duyck)

22) A commit to stop drivers using netdev->base_addr broke the CNIC
    driver (Michael Chan)   =20

23) Timeout regression in ipset caused by an attempt to fix an overflow
    bug (Jozsef Kadlecsik).

24) mac80211 minstrel code allocates memory using incorrect size
    (Thomas Huehn)

25) llcp_sock_getname() needs to check for a NULL device otherwise we
    OOPS (Sasha Levin)

26) mwifiex leaks memory (Bing Zhao)

27) Propagate iwlwifi fix to iwlegacy, even when we're not associated
    we need to monitor for stuck queues in the watchdog handler
    (Stanislaw Geuszka)

Please pull, thanks a lot.

The following changes since commit 9e85a6f9dc231f3ed3c1dc1b12217505d970=
142a:

  Merge tag 'clk-fixes-for-linus' of git://git.linaro.org/people/mturqu=
ette/linux (2012-07-03 18:06:49 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to 602e65a3b0c4f6b09fba19817ff798647a08e706=
:

  Merge branch 'master' of git://1984.lsi.us.es/nf (2012-07-17 03:19:33=
 -0700)

----------------------------------------------------------------

Alan Cox (2):
      sch_sfb: Fix missing NULL check
      ax25: Fix missing break

Alexander Duyck (2):
      ixgbe: DCB and SR-IOV can not co-exist and will cause hangs
      ixgbevf: Fix panic when loading driver

Amir Hanania (1):
      net: Fix memory leak - vlan_info struct

Bing Zhao (1):
      mwifiex: fix Coverity SCAN CID 709078: Resource leak (RESOURCE_LE=
AK)

Bj=F8rn Mork (1):
      net: qmi_wwan: add ZTE MF60

Bruce Allan (1):
      e1000e: fix test for PHY being accessible on 82577/8/9 and I217

Cloud Ren (1):
      atl1c: fix issue of transmit queue 0 timed out

David Daney (1):
      netdev/phy: Fixup lockdep warnings in mdio-mux.c

David S. Miller (4):
      Merge branch 'master' of git://1984.lsi.us.es/nf
      Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/l=
inux-merge
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net
      Merge branch 'master' of git://1984.lsi.us.es/nf

Deepak Sikri (2):
      stmmac: Fix for nfs hang on multiple reboot
      stmmac: Fix for higher mtu size handling

Dmitry Eremin-Solenikov (1):
      MAINTAINERS: reflect actual changes in IEEE 802.15.4 maintainersh=
ip

Eliad Peller (1):
      mac80211: destroy assoc_data correctly if assoc fails

Emmanuel Grumbach (1):
      iwlegacy: don't mess up the SCD when removing a key

Eric Dumazet (6):
      net: dont use __netdev_alloc_skb for bounce buffer
      netem: add limitation to reordered packets
      net: cgroup: fix out of bounds accesses
      gianfar: fix potential sk_wmem_alloc imbalance
      IPoIB: fix skb truesize underestimatiom
      net: respect GFP_DMA in __netdev_alloc_skb()

Eric W. Biederman (2):
      bonding: Manage /proc/net/bonding/ entries from the netdev events
      bonding: debugfs and network namespaces are incompatible

Gao feng (2):
      cgroup: fix panic in netprio_cgroup
      net: cgroup: fix access the unallocated memory in netprio cgroup

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Jozsef Kadlecsik (1):
      netfilter: ipset: timeout fixing bug broke SET target special tim=
eout value

Julia Lawall (3):
      drivers/isdn/mISDN/stack.c: remove invalid reference to list iter=
ator variable
      net/rxrpc/ar-peer.c: remove invalid reference to list iterator va=
riable
      drivers/net/ethernet/broadcom/cnic.c: remove invalid reference to=
 list iterator variable

Julian Anastasov (1):
      ipvs: fix oops in ip_vs_dst_event on rmmod

Lin Ming (1):
      ipvs: fix oops on NAT reply in br_nf context

Michael Chan (2):
      cnic: Don't use netdev->base_addr
      bnx2: Fix bug in bnx2_free_tx_skbs().

Narendra K (1):
      ixgbevf: Prevent RX/TX statistics getting reset to zero

Neil Horman (1):
      sctp: Fix list corruption resulting from freeing an association o=
n a list

Pablo Neira Ayuso (1):
      netfilter: nf_ct_ecache: fix crash with multiple containers, one =
shutting down

Sasha Levin (2):
      ieee802154: verify packet size before trying to allocate it
      NFC: Prevent NULL deref when getting socket name

Simon Wunderlich (1):
      batman-adv: check incoming packet type for bla

Sjur Br=E6ndeland (1):
      caif: Fix access to freed pernet memory

Stanislaw Gruszka (2):
      rt2x00usb: fix indexes ordering on RX queue kick
      iwlegacy: always monitor for stuck queues

Thomas Huehn (1):
      mac80211: correct size the argument to kzalloc in minstrel_ht

Tushar Dave (1):
      e1000e: Correct link check logic for 82571 serdes

 MAINTAINERS                                       |    3 +-
 drivers/infiniband/ulp/ipoib/ipoib_ib.c           |   12 ++++---
 drivers/isdn/mISDN/stack.c                        |    4 +--
 drivers/net/bonding/bond_debugfs.c                |    2 +-
 drivers/net/bonding/bond_main.c                   |    9 ++++--
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c   |    1 -
 drivers/net/ethernet/broadcom/b44.c               |    4 +--
 drivers/net/ethernet/broadcom/bnx2.c              |    6 ++--
 drivers/net/ethernet/broadcom/cnic.c              |   10 ++++--
 drivers/net/ethernet/freescale/gianfar.c          |    7 ++--
 drivers/net/ethernet/intel/e1000e/82571.c         |    3 ++
 drivers/net/ethernet/intel/e1000e/ich8lan.c       |   42 +++++++++++++=
+++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    5 +++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   15 ++-------
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c   |    3 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    3 ++
 drivers/net/phy/mdio-mux.c                        |   10 ++++--
 drivers/net/usb/qmi_wwan.c                        |   18 +++++++++++
 drivers/net/wireless/b43legacy/dma.c              |    2 +-
 drivers/net/wireless/iwlegacy/4965-mac.c          |    4 +--
 drivers/net/wireless/iwlegacy/common.c            |   14 ++++----
 drivers/net/wireless/mwifiex/cfg80211.c           |    1 +
 drivers/net/wireless/rt2x00/rt2x00usb.c           |    2 +-
 include/net/ip_vs.h                               |    2 +-
 include/net/netfilter/nf_conntrack_ecache.h       |    2 +-
 net/8021q/vlan.c                                  |    3 ++
 net/ax25/af_ax25.c                                |    1 +
 net/batman-adv/bridge_loop_avoidance.c            |   15 ++++++---
 net/batman-adv/bridge_loop_avoidance.h            |    5 +--
 net/batman-adv/soft-interface.c                   |    6 +++-
 net/caif/caif_dev.c                               |    2 +-
 net/core/dev.c                                    |    8 +++--
 net/core/netprio_cgroup.c                         |   78 +++++++++++++=
++++++++++++++++++++------------
 net/core/skbuff.c                                 |    2 +-
 net/ieee802154/dgram.c                            |   12 +++----
 net/mac80211/mlme.c                               |    6 ++--
 net/mac80211/rc80211_minstrel_ht.c                |    2 +-
 net/netfilter/ipvs/ip_vs_ctl.c                    |    5 +--
 net/netfilter/xt_set.c                            |    4 ++-
 net/nfc/llcp/sock.c                               |    2 +-
 net/rxrpc/ar-peer.c                               |    2 +-
 net/sched/sch_netem.c                             |   42 +++++++++----=
-----------
 net/sched/sch_sfb.c                               |    2 ++
 net/sctp/input.c                                  |    7 ++--
 net/sctp/socket.c                                 |   12 +++++--
 45 files changed, 256 insertions(+), 144 deletions(-)
