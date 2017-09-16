From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 16 Sep 2017 09:29:32 -0700 (PDT)
Message-ID: <20170916.092932.1950525306161349359.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix hotplug deadlock in hv_netvsc, from Stephen Hemminger.

2) Fix double-free in rmnet driver, from Dan Carpenter.

3) INET connection socket layer can double put request sockets,
   fix from Eric Dumazet.

4) Don't match collect metadata-mode tunnels if the device is down,
   from Haishuang Yan.

5) Do not perform TSO6/GSO on ipv6 packets with extensions headers in
   be2net driver, from Suresh Reddy.

6) Fix scaling error in gen_estimator, from Eric Dumazet.

7) Fix 64-bit statistics deadlock in systemport driver, from Florian
   Fainelli.

8) Fix use-after-free in sctp_sock_dump, from Xin Long.

9) Reject invalid BPF_END instructions in verifier, from Edward Cree.

Please pull, thanks a lot!

The following changes since commit ad9a19d003703ae06a6e8efc64cf26a939d9e84d:

  Merge tag 'nfsd-4.14' of git://linux-nfs.org/~bfields/linux (2017-09-09 13:31:49 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 8e29f97979c300406c21994986bdfcdb67fe4ff7:

  mlxsw: spectrum_router: Only handle IPv4 and IPv6 events (2017-09-16 09:21:43 -0700)

----------------------------------------------------------------
Arkadi Sharshevsky (1):
      mlxsw: spectrum: Fix EEPROM access in case of SFP/SFP+

Arnd Bergmann (2):
      w90p910_ether: include linux/interrupt.h
      net: vrf: avoid gcc-4.6 warning

Christophe JAILLET (1):
      openvswitch: Fix an error handling path in 'ovs_nla_init_match_and_action()'

Colin Ian King (1):
      tg3: clean up redundant initialization of tnapi

Cong Wang (3):
      net_sched: get rid of tcfa_rcu
      net_sched: fix reference counting of tc filter chain
      net_sched: carefully handle tcf_block_put()

Dan Carpenter (2):
      net: qualcomm: rmnet: Fix a double free
      sctp: potential read out of bounds in sctp_ulpevent_type_enabled()

David Ahern (1):
      net: ipv4: fix l3slave check for index returned in IP_PKTINFO

David Lebrun (1):
      ipv6: sr: remove duplicate routing header type check

David S. Miller (2):
      Merge branch 'net_sched-fix-filter-chain-reference-counting'
      Merge branch 'nfp-card-init'

Edward Cree (1):
      bpf/verifier: reject BPF_ALU64|BPF_END

Eric Dumazet (4):
      tcp/dccp: remove reqsk_put() from inet_child_forget()
      net_sched: gen_estimator: fix scaling error in bytes/packets samples
      tcp: update skb->skb_mstamp more carefully
      tcp: fix data delivery rate

Florian Fainelli (1):
      net: systemport: Fix 64-bit stats deadlock

Geert Uytterhoeven (1):
      net: smsc911x: Quieten netif during suspend

Haishuang Yan (2):
      ip_tunnel: fix ip tunnel lookup in collect_md mode
      ip6_tunnel: fix ip6 tunnel lookup in collect_md mode

Himanshu Jha (1):
      qed: remove unnecessary call to memset

Ido Schimmel (1):
      mlxsw: spectrum_router: Only handle IPv4 and IPv6 events

Jakub Kicinski (2):
      nfp: wait for board state before talking to the NSP
      nfp: wait for the NSP resource to appear on boot

Jesper Dangaard Brouer (1):
      xdp: implement xdp_redirect_map for generic XDP

Jiri Pirko (1):
      net: sched: fix use-after-free in tcf_action_destroy and tcf_del_walker

Josh Hunt (1):
      net/sched: fix pointer check in gen_handle

Kosuke Tatsukawa (1):
      net: bonding: Fix transmit load balancing in balance-alb mode if specified by sysfs

Nikolay Aleksandrov (1):
      net: bonding: fix tlb_dynamic_lb default value

Nisar Sayed (1):
      smsc95xx: Configure pause time to 0xffff when tx flow control enabled

Pavel Machek (1):
      Documentation: link in networking docs

Pieter Jansen van Vuuren (1):
      nfp: add whitelist of supported flow dissector

Sergei Shtylyov (1):
      MAINTAINERS: review Renesas DT bindings as well

Stephen Hemminger (3):
      hv_netvsc: fix deadlock on hotplug
      hv_netvsc: avoid unnecessary wakeups on subchannel creation
      netvsc: increase default receive buffer size

Suresh Reddy (1):
      be2net: fix TSO6/GSO issue causing TX-stall on Lancer/BEx

Tobias Klauser (1):
      tls: make tls_sw_free_resources static

Xin Long (2):
      sctp: fix an use-after-free issue in sctp_sock_dump
      sctp: do not mark sk dumped when inet_sctp_diag_fill returns err

Yonghong Song (1):
      perf/bpf: fix a clang compilation issue

Yuval Mintz (1):
      mlxsw: spectrum: Prevent mirred-related crash on removal

 Documentation/networking/filter.txt                       |   2 +-
 MAINTAINERS                                               |   2 ++
 drivers/net/bonding/bond_main.c                           |  17 ++++++-------
 drivers/net/bonding/bond_options.c                        |   3 +++
 drivers/net/ethernet/broadcom/bcmsysport.c                |   3 ---
 drivers/net/ethernet/broadcom/tg3.c                       |   4 ++--
 drivers/net/ethernet/emulex/benet/be.h                    |   8 +++++++
 drivers/net/ethernet/emulex/benet/be_main.c               |  14 +++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c            |  38 +++++++++++++++++++----------
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c     |   3 ++-
 drivers/net/ethernet/netronome/nfp/flower/offload.c       |  13 ++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_main.c             |  47 ++++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c         |  23 ------------------
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h          |   2 ++
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_resource.c |  45 ++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/nuvoton/w90p910_ether.c              |   1 +
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c                |   1 -
 drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c      |  10 ++++----
 drivers/net/ethernet/smsc/smsc911x.c                      |  15 +++++++++++-
 drivers/net/hyperv/hyperv_net.h                           |   3 +++
 drivers/net/hyperv/netvsc.c                               |   3 +++
 drivers/net/hyperv/netvsc_drv.c                           |  13 ++++------
 drivers/net/hyperv/rndis_filter.c                         | 126 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++------------------------------
 drivers/net/usb/smsc95xx.c                                |  11 ++++-----
 drivers/net/vrf.c                                         |   6 ++---
 include/linux/syscalls.h                                  |   2 ++
 include/net/act_api.h                                     |   2 --
 include/net/sctp/sctp.h                                   |   3 ++-
 include/net/sctp/ulpevent.h                               |   6 ++++-
 include/trace/events/xdp.h                                |   4 ++--
 kernel/bpf/verifier.c                                     |   3 ++-
 kernel/trace/trace_syscalls.c                             |   2 +-
 net/core/filter.c                                         |  38 +++++++++++++++++++----------
 net/core/gen_estimator.c                                  |   4 ++--
 net/ipv4/inet_connection_sock.c                           |   2 +-
 net/ipv4/ip_sockglue.c                                    |   8 +++++--
 net/ipv4/ip_tunnel.c                                      |   2 +-
 net/ipv4/tcp_output.c                                     |  24 +++++++++++--------
 net/ipv6/ip6_tunnel.c                                     |   2 +-
 net/ipv6/seg6_local.c                                     |   4 ----
 net/openvswitch/datapath.c                                |   3 ++-
 net/sched/act_api.c                                       |  23 +++++++++---------
 net/sched/cls_api.c                                       |  63 ++++++++++++++++++++++++++++++------------------
 net/sched/cls_rsvp.h                                      |   2 +-
 net/sctp/sctp_diag.c                                      |  33 +++++++------------------
 net/sctp/socket.c                                         |  40 +++++++++++++++++++------------
 net/tls/tls_sw.c                                          |   2 +-
 tools/testing/selftests/bpf/test_verifier.c               |  16 +++++++++++++
 48 files changed, 467 insertions(+), 234 deletions(-)
