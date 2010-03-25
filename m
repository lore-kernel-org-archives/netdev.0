From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Thu, 25 Mar 2010 12:58:00 -0700 (PDT)
Message-ID: <20100325.125800.155352663.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) ISDN driver section mismatch fixes from Henrik Kretzschmar.

2) xt_hashlimit netfilter fixes (leaks, missing break in IPV6
   header parsing switch statement) from Eric Dumazet.

3) netpoll silently sets dport to zero when spaces are in
   kernel command line parameters, at least warn about this.
   From Amerigo Wang.

4) IGB crashes in promisc mode when VLAN packet is received
   without any vlans registered, fix from Alexander Duyck.

5) skb_shared_info causes all packets to use 4K SLABs instead
   of 2K ones, due to completely unused dma_head and dma_maps
   fields which we removed all references to recently.  Kill
   them, also from Alexander Duyck.

6) Via Andrew Morton, allow nls_cls to be modular.

7) netpoll crashes in bnx2 because it invokes wrong interrupt
   handler, fix from Benjamin Li.  Also, need to invoke
   netif_napi_add() after we know exactly how many irq vectors
   will be used, also from Benjamin Li.

8) af_key loses errors and returns zero on some memory allocation
   failures, fix from Dan Carpenter.

9) VIA Velocity programs advertisement MII registers incorrectly
   when both RX and TX flow control are enabled, from your's truly.
   Noticed by Roel Kluin.

10) Update TIPC maintainers entry, from Jon Maloy.

11) VLANs do not do TX queue selection properly when the device
    has a ->select_queue() override.   Also add some validation
    to make sure we do not choose a queue larger than the number
    the device actually has.  From Vasu Dev.

12) RXRPX protocol does not check for allocation failures in
    incomping call accept code, fix from Tetsuo Handa.

13) Fix regression in xt_recent netfilter module wrt. zero hit_count
    rules.  From Thomas Jarosch.

14) blackfin CAN driver register definitions moved to asm/bfin_can.h,
    from Mike Frysinger.

15) Disallow acceptance of NX_P3_B1 rev chips by the netxen driver,
    these are preproduction chips and the driver doesn't work properly
    right now with them.  From Eric W. Biederman and ack'd by
    Qlogic folks, although another solution to this problem might be
    forthcoming.

16) ksz884x driver returns bogus error code from netdev_set_eeprom,
    fix from Jens Rottmann.

17) IGB mishandled RX FIFO errors and incorrectly changes TX queue
    len on link changes, fixes from Mitch Williams and Emil
    Tantilov.

18) IPV6 RAW netfilter table priority is set wrong, fix from
    Jozsef Kadlecsik.

Please pull, thanks a lot!

The following changes since commit 01e77706cdde7c0b47e5ca1f4284a795504c7c40:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://gitorious.org/linux-omap-dss2/linux

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexander Duyck (2):
      igb: only use vlan_gro_receive if vlans are registered
      skbuff: remove unused dma_head & dma_maps fields

Amerigo Wang (1):
      netpoll: warn when there are spaces in parameters

Ben Blum (1):
      cgroups: net_cls as module

Benjamin Li (1):
      bnx2: Fix netpoll crash.

Dan Carpenter (1):
      af_key: return error if pfkey_xfrm_policy2msg_prep() fails

David S. Miller (3):
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6
      via-velocity: Fix FLOW_CNTL_TX_RX handling in set_mii_flow_control()

Emil Tantilov (1):
      igb: do not modify tx_queue_len on link speed change

Eric Dumazet (2):
      netfilter: xt_hashlimit: dl_seq_stop() fix
      netfilter: xt_hashlimit: IPV6 bugfix

Eric W. Biederman (1):
      netxen: The driver doesn't work on NX_P3_B1 so cause probe to fail.

Henrik Kretzschmar (4):
      isdn: Cleanup Sections in PCMCIA driver sedlbauer
      isdn: Cleanup Sections in PCMCIA driver teles
      isdn: Cleanup Sections in PCMCIA driver avma1
      isdn: Cleanup Sections in PCMCIA driver elsa

Jens Rottmann (1):
      ksz884x: fix return value of netdev_set_eeprom

Jon Maloy (1):
      TIPC: Removed inactive maintainer

Jozsef Kadlecsik (1):
      netfilter: ip6table_raw: fix table priority

Michael Chan (1):
      bnx2: Use proper handler during netpoll.

Mike Frysinger (1):
      can: bfin_can: switch to common Blackfin can header

Mitch Williams (1):
      igb: count Rx FIFO errors correctly

Patrick McHardy (1):
      netfilter: xt_recent: fix regression in rules using a zero hit_count

Tetsuo Handa (1):
      rxrpc: Check allocation failure.

Vasu Dev (2):
      vlan: adds vlan_dev_select_queue
      vlan: updates vlan real_num_tx_queues

 MAINTAINERS                          |    1 -
 drivers/isdn/hisax/avma1_cs.c        |   12 ++--
 drivers/isdn/hisax/elsa_cs.c         |   12 ++--
 drivers/isdn/hisax/sedlbauer_cs.c    |   12 ++--
 drivers/isdn/hisax/teles_cs.c        |   12 ++--
 drivers/net/bnx2.c                   |   14 +++--
 drivers/net/can/bfin_can.c           |   97 +++-------------------------------
 drivers/net/igb/igb.h                |    1 -
 drivers/net/igb/igb_main.c           |   22 +++-----
 drivers/net/ksz884x.c                |    2 +-
 drivers/net/netxen/netxen_nic_main.c |    4 +-
 drivers/net/via-velocity.c           |    2 +-
 include/linux/netfilter_ipv6.h       |    1 +
 include/linux/skbuff.h               |    6 --
 net/8021q/vlan.c                     |    2 +
 net/8021q/vlan_dev.c                 |   71 ++++++++++++++++++++++++-
 net/core/netpoll.c                   |    7 ++-
 net/ipv6/netfilter/ip6table_raw.c    |    2 +-
 net/key/af_key.c                     |    8 +--
 net/netfilter/xt_hashlimit.c         |    4 +-
 net/netfilter/xt_recent.c            |    2 +-
 net/sched/Kconfig                    |    5 ++-
 net/sched/cls_cgroup.c               |   36 +++++++++---
 23 files changed, 166 insertions(+), 169 deletions(-)
