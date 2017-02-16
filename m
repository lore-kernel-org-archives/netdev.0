From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 15 Feb 2017 20:31:36 -0500 (EST)
Message-ID: <20170215.203136.1940941890600773041.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) In order to avoid problems in the future, make cgroup bpf
   overriding explicit using BPF_F_ALLOW_OVERRIDE.  From Alexei
   Staovoitov.

2) LLC sets skb->sk without proper skb->destructor and this explodes,
   fix from Eric Dumazet.

3) More gracefully handle rhashtable insertion errors when vmalloc is
   not possible, from Herbert Xu.

4) Make sure when we have an ipv4 mapped source address, the destination
   is either also an ipv4 mapped address or ipv6_addr_any().  Fix from
   Jonathan T. Leighton.

5) Avoid packet loss in fec driver by programming the multicast filter
   more intelligently.  From Rui Sousa.

6) Handle multiple threads invoking fanout_add(), fix from Eric
   Dumazet.

7) Since we can invoke the TCP input path in process context, without
   BH being disabled, we have to accomodate that in the locking of
   the TCP probe.  Also from Eric Dumazet.

8) Fix erroneous emission of NETEVENT_DELAY_PROBE_TIME_UPDATE when
   we aren't even updating that sysctl value.  From Marcus Huewe.

9) Fix endian bugs in ibmvnic driver, from Thomas Falcon.

Please pull, thanks a lot!

The following changes since commit 1ee18329fae936089c6c599250ae92482ff2b81f:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-02-10 14:44:49 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 75224c93fa985f4a6fb983f53208f5c5aa555fbf:

  ibmvnic: Fix endian errors in error reporting output (2017-02-15 14:48:31 -0500)

----------------------------------------------------------------
Alexei Starovoitov (1):
      bpf: introduce BPF_F_ALLOW_OVERRIDE flag

Anssi Hannula (2):
      net: xilinx_emaclite: fix receive buffer overflow
      net: xilinx_emaclite: fix freezes due to unordered I/O

Arnaldo Carvalho de Melo (1):
      MAINTAINERS: Remove old e-mail address

David S. Miller (2):
      Merge branch 'rhashtable-allocation-failure-during-insertion'
      Merge branch 'ipv6-v4mapped'

Dmitry V. Levin (1):
      uapi: fix linux/if_pppol2tp.h userspace compilation errors

Eric Dumazet (3):
      net/llc: avoid BUG_ON() in skb_orphan()
      packet: fix races in fanout_add()
      tcp: tcp_probe: use spin_lock_bh()

Herbert Xu (3):
      gfs2: Use rhashtable walk interface in glock_hash_walk
      tipc: Fix tipc_sk_reinit race conditions
      rhashtable: Add nested tables

Ivan Khoronzhuk (1):
      net: ethernet: ti: cpsw: fix cpsw assignment in resume

Jonathan T. Leighton (2):
      ipv6: Inhibit IPv4-mapped src address on the wire.
      ipv6: Handle IPv4-mapped src to in6addr_any dst.

Marcus Huewe (1):
      net: neigh: Fix netevent NETEVENT_DELAY_PROBE_TIME_UPDATE notification

Mart van Santen (1):
      xen-netback: vif counters from int/long to u64

Nathan Fontenot (2):
      ibmvnic: Initialize completion variables before starting work
      ibmvnic: Call napi_disable instead of napi_enable in failure path

Or Gerlitz (1):
      net/mlx5e: Disable preemption when doing TC statistics upcall

Ralf Baechle (1):
      NET: Fix /proc/net/arp for AX.25

Rui Sousa (1):
      net: fec: fix multicast filtering hardware setup

Stephen Rothwell (1):
      bpf: kernel header files need to be copied into the tools directory

Thomas Falcon (3):
      ibmvnic: Fix initial MTU settings
      ibmvnic: Fix endian error when requesting device capabilities
      ibmvnic: Fix endian errors in error reporting output

WANG Cong (1):
      kcm: fix a null pointer dereference in kcm_sendmsg()

 CREDITS                                         |   5 +-
 MAINTAINERS                                     |  15 ++--
 drivers/net/ethernet/freescale/fec_main.c       |  23 +++---
 drivers/net/ethernet/ibm/ibmvnic.c              |  43 +++++-----
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c |   4 +
 drivers/net/ethernet/ti/cpsw.c                  |   2 +-
 drivers/net/ethernet/xilinx/xilinx_emaclite.c   | 126 ++++++++++++++++-------------
 drivers/net/xen-netback/common.h                |   8 +-
 drivers/net/xen-netback/interface.c             |   8 +-
 fs/gfs2/glock.c                                 |  28 ++++---
 include/linux/bpf-cgroup.h                      |  13 ++-
 include/linux/rhashtable.h                      |  78 +++++++++++++-----
 include/uapi/linux/bpf.h                        |   7 ++
 include/uapi/linux/l2tp.h                       |   7 +-
 kernel/bpf/cgroup.c                             |  59 +++++++++++---
 kernel/bpf/syscall.c                            |  20 +++--
 kernel/cgroup.c                                 |   9 ++-
 lib/rhashtable.c                                | 270 +++++++++++++++++++++++++++++++++++++++++++++++++------------
 net/core/neighbour.c                            |   3 +-
 net/ipv4/arp.c                                  |  12 +--
 net/ipv4/tcp_probe.c                            |   4 +-
 net/ipv6/datagram.c                             |  14 ++--
 net/ipv6/ip6_output.c                           |   3 +
 net/ipv6/tcp_ipv6.c                             |  11 ++-
 net/ipv6/udp.c                                  |   4 +
 net/kcm/kcmsock.c                               |   6 +-
 net/llc/llc_conn.c                              |   3 +
 net/llc/llc_sap.c                               |   3 +
 net/packet/af_packet.c                          |  55 +++++++------
 net/tipc/net.c                                  |   4 +
 net/tipc/socket.c                               |  30 ++++---
 samples/bpf/test_cgrp2_attach.c                 |   2 +-
 samples/bpf/test_cgrp2_attach2.c                |  68 +++++++++++++++-
 samples/bpf/test_cgrp2_sock.c                   |   2 +-
 samples/bpf/test_cgrp2_sock2.c                  |   2 +-
 tools/include/uapi/linux/bpf.h                  |   7 ++
 tools/lib/bpf/bpf.c                             |   4 +-
 tools/lib/bpf/bpf.h                             |   3 +-
 38 files changed, 671 insertions(+), 294 deletions(-)
