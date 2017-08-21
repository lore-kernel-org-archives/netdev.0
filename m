From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 20 Aug 2017 21:53:27 -0700 (PDT)
Message-ID: <20170820.215327.2022031066206784428.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50852 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750850AbdHUExa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 00:53:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Fix IGMP handling wrt VRF, from David Ahern.

2) Fix timer access to freed object in dccp, from Eric Dumazet.

3) Use kmalloc_array() in ptr_ring to avoid overflow cases which
   are triggerable by userspace.  Also from Eric Dumazet.

4) Fix infinite loop in unmapping cleanup of nfp driver, from Colin
   Ian King.

5) Correct datagram peek handling of empty SKBs, from Matthew Dawson.

6) Fix use after free in TIPC, from Eric Dumazet.

7) When replacing a route in ipv6 we need to reset the round robin
   pointer, from Wei Wang.

8) Fix bug in pci_find_pcie_root_port() which was unearthed by the
   relaxed ordering changes, from Thierry Redding.  I made sure to get
   an explicit ACK from Bjorn this time around :-)

Please pull, thanks a lot!

The following changes since commit 510c8a899caf095cb13d09d203573deef15db2fe:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-08-15 18:52:28 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net 

for you to fetch changes up to 348a4002729ccab8b888b38cbc099efa2f2a2036:

  ipv6: repair fib6 tree in failure case (2017-08-20 20:06:56 -0700)

----------------------------------------------------------------
Alexander Potapenko (1):
      sctp: fully initialize the IPv6 address in sctp_v6_to_addr()

Chris Packham (1):
      switchdev: documentation: minor typo fixes

Colin Ian King (3):
      nfp: fix infinite loop on umapping cleanup
      netxen: fix incorrect loop counter decrement
      irda: do not leak initialized list.dev to userspace

Daniel Borkmann (2):
      bpf, doc: improve sysctl knob description
      bpf, doc: also add s390x as arch to sysctl description

David Ahern (1):
      net: igmp: Use ingress interface rather than vrf device

David Howells (1):
      rxrpc: Fix oops when discarding a preallocated service call

Eric Dumazet (5):
      dccp: defer ccid_hc_tx_delete() at dismantle time
      ptr_ring: use kmalloc_array()
      ipv4: better IP_MAX_MTU enforcement
      tun: handle register_netdevice() failures properly
      tipc: fix use-after-free

Eric Leblond (1):
      tools lib bpf: improve warning

Huy Nguyen (1):
      net/mlx4_core: Enable 4K UAR if SRIOV module parameter is not enabled

Jiri Pirko (1):
      net: sched: fix p_filter_chain check in tcf_chain_flush

Konstantin Khlebnikov (1):
      net_sched: fix order of queue length updates in qdisc_replace()

Liping Zhang (1):
      openvswitch: fix skb_panic due to the incorrect actions attrlen

Matthew Dawson (1):
      datagram: When peeking datagrams with offset < 0 don't skip empty skbs

Michael Ellerman (1):
      bpf: Update sysctl documentation to list all supported architectures

Neal Cardwell (1):
      tcp: when rearming RTO, if RTO time is in past then fire RTO ASAP

Roopa Prabhu (1):
      net: check and errout if res->fi is NULL when RTM_F_FIB_MATCH is set

Thierry Reding (1):
      PCI: Allow PCI express root ports to find themselves

Wei Wang (2):
      ipv6: reset fn->rr_ptr when replacing route
      ipv6: repair fib6 tree in failure case

Xin Long (1):
      net: sched: fix NULL pointer dereference when action calls some targets

 Documentation/networking/switchdev.txt              |  4 ++--
 Documentation/sysctl/net.txt                        | 47 ++++++++++++++++++++++++++++++++++++-----------
 drivers/net/ethernet/mellanox/mlx4/main.c           |  4 ++--
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c |  3 +--
 drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c  |  2 +-
 drivers/net/tun.c                                   |  3 +++
 drivers/pci/pci.c                                   |  9 ++++-----
 include/linux/ptr_ring.h                            |  9 +++++----
 include/linux/skb_array.h                           |  3 ++-
 include/net/ip.h                                    |  4 ++--
 include/net/sch_generic.h                           |  5 ++++-
 include/net/sock.h                                  |  4 +---
 net/core/datagram.c                                 | 12 +++++++++---
 net/dccp/proto.c                                    | 14 ++++++++++++--
 net/ipv4/igmp.c                                     | 10 +++++++++-
 net/ipv4/route.c                                    | 13 ++++++++++---
 net/ipv4/tcp_input.c                                |  3 +--
 net/ipv4/udp.c                                      |  3 ++-
 net/ipv6/ip6_fib.c                                  | 28 +++++++++++++++-------------
 net/ipv6/udp.c                                      |  3 ++-
 net/irda/af_irda.c                                  |  2 +-
 net/openvswitch/actions.c                           |  1 +
 net/openvswitch/datapath.c                          |  7 ++++---
 net/openvswitch/datapath.h                          |  2 ++
 net/rxrpc/call_accept.c                             |  1 +
 net/sched/act_ipt.c                                 |  2 ++
 net/sched/cls_api.c                                 |  2 +-
 net/sctp/ipv6.c                                     |  2 ++
 net/tipc/netlink_compat.c                           |  6 ++++--
 net/unix/af_unix.c                                  |  5 +----
 tools/lib/bpf/libbpf.c                              |  3 ++-
 31 files changed, 144 insertions(+), 72 deletions(-)
