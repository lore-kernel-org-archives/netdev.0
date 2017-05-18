From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 18 May 2017 14:03:38 -0400 (EDT)
Message-ID: <20170518.140338.223032782995347354.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Don't allow negative TCP reordering values, from Soheil Hassas Yeganeh.

2) Don't overflow while parsing ipv6 header options, from Craig Gallek.

3) Handle more cleanly the case where an individual route entry during
   a dump will not fit into the allocated netlink SKB, from David Ahern.

4) Add missing CONFIG_INET dependency for mlx5e, from Arnd Bergmann.

5) Allow neighbour updates to converge more quickly via gratuitous
   ARPs, from Ihar Hrachyshka.

6) Fix compile error from CONFIG_INET is disabled, from Eric Dumazet.

7) Fix use after free in x25 protocol init, from Lin Zhang.

8) Valid VLAN pvid ranges passed into br_validate(), from Tobias
   Jungel.

9) NULL out address lists in child sockets in SCTP, this is similar
   to the fix we made for inet connection sockets last week. From
   Eric Dumazet.

10) Fix NULL deref in mlxsw driver, from Ido Schimmel.

Please pull, thanks a lot!

The following changes since commit a95cfad947d5f40cfbf9ad3019575aac1d8ac7a6:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-05-15 15:50:49 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to c0e01eac7ada785fdeaea1ae5476ec1cf3b00374:

  mlxsw: spectrum: Avoid possible NULL pointer dereference (2017-05-18 11:27:21 -0400)

----------------------------------------------------------------
Arkadi Sharshevsky (2):
      mlxsw: spectrum_dpipe: Fix incorrect entry index
      mlxsw: spectrum_router: Fix rif counter freeing routine

Arnd Bergmann (1):
      mlx5e: add CONFIG_INET dependency

Bjørn Mork (1):
      qmi_wwan: add another Lenovo EM74xx device ID

Christoph Hellwig (1):
      net/smc: Add warning about remote memory exposure

Craig Gallek (1):
      ipv6: Prevent overrun when parsing v6 header options

Daniel Borkmann (1):
      bpf: adjust verifier heuristics

David Ahern (1):
      net: Improve handling of failures on link and route dumps

David S. Miller (3):
      Merge branch 'bnxt_en-DCBX-fixes'
      ipv6: Check ip6_find_1stfragopt() return value properly.
      Merge branch 'mlxsw-fixes'

Eric Dumazet (2):
      net: fix compile error in skb_orphan_partial()
      sctp: do not inherit ipv6_{mc|ac|fl}_list from parent

Ganesh Goudar (1):
      cxgb4: update latest firmware version supported

Geert Uytterhoeven (2):
      sh_eth: Use platform device for printing before register_netdev()
      sh_eth: Do not print an error message for probe deferral

Greentime Hu (1):
      net: ethernet: faraday: To support device tree usage.

Ido Schimmel (1):
      mlxsw: spectrum: Avoid possible NULL pointer dereference

Ihar Hrachyshka (2):
      arp: honour gratuitous ARP _replies_
      neighbour: update neigh timestamps iff update is effective

Michael Chan (2):
      bnxt_en: Call bnxt_dcb_init() after getting firmware DCBX configuration.
      bnxt_en: Check status of firmware DCBX agent before setting DCB_CAP_DCBX_HOST.

Paolo Abeni (1):
      udp: make *udp*_queue_rcv_skb() functions static

Soheil Hassas Yeganeh (1):
      tcp: eliminate negative reordering in tcp_clean_rtx_queue

Thomas Winter (1):
      ipmr: vrf: Find VIFs using the actual device

Tobias Jungel (1):
      bridge: netlink: check vlan_default_pvid range

Ursula Braun (1):
      smc: switch to usage of IB_PD_UNSAFE_GLOBAL_RKEY

Yonghong Song (1):
      selftests/bpf: fix broken build due to types.h

linzhang (1):
      net: x25: fix one potential use-after-free issue

 drivers/net/ethernet/broadcom/bnxt/bnxt.c                |  3 +--
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c            |  6 ++++--
 drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h        |  6 +++---
 drivers/net/ethernet/faraday/ftmac100.c                  |  7 +++++++
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig          |  2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c     |  3 ++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c    |  3 +++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c |  6 ++----
 drivers/net/ethernet/renesas/sh_eth.c                    |  3 ++-
 drivers/net/usb/qmi_wwan.c                               |  2 ++
 include/net/x25.h                                        |  4 ++--
 kernel/bpf/verifier.c                                    | 12 +++++++++++-
 net/bridge/br_netlink.c                                  |  7 +++++++
 net/core/neighbour.c                                     | 14 ++++++++++----
 net/core/rtnetlink.c                                     | 36 ++++++++++++++++++++++++------------
 net/core/sock.c                                          |  3 ---
 net/ipv4/arp.c                                           | 16 ++++++++++++++--
 net/ipv4/fib_frontend.c                                  | 15 +++++++++++----
 net/ipv4/fib_trie.c                                      | 26 ++++++++++++++------------
 net/ipv4/ipmr.c                                          | 18 ++++++++++++++++--
 net/ipv4/tcp_input.c                                     |  2 +-
 net/ipv4/udp.c                                           |  4 ++--
 net/ipv4/udp_impl.h                                      |  1 -
 net/ipv6/ip6_offload.c                                   |  7 ++++---
 net/ipv6/ip6_output.c                                    |  5 ++++-
 net/ipv6/output_core.c                                   | 14 ++++++++------
 net/ipv6/udp.c                                           |  4 ++--
 net/ipv6/udp_impl.h                                      |  1 -
 net/ipv6/udp_offload.c                                   |  6 +++++-
 net/sctp/ipv6.c                                          |  3 +++
 net/smc/Kconfig                                          |  4 ++++
 net/smc/smc_clc.c                                        |  4 ++--
 net/smc/smc_core.c                                       | 16 +++-------------
 net/smc/smc_core.h                                       |  2 +-
 net/smc/smc_ib.c                                         | 21 ++-------------------
 net/smc/smc_ib.h                                         |  2 --
 net/x25/af_x25.c                                         | 24 ++++++++++++++++--------
 net/x25/sysctl_net_x25.c                                 |  5 ++++-
 tools/testing/selftests/bpf/include/uapi/linux/types.h   | 16 ++++++++++++++++
 tools/testing/selftests/bpf/test_pkt_access.c            |  1 +
 40 files changed, 214 insertions(+), 120 deletions(-)
