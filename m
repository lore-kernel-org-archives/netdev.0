From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/12] netfilter updates for net-next
Date: Mon,  1 Jul 2013 01:54:29 +0200
Message-ID: <1372636481-3705-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following batch contains Netfilter/IPVS updates for net-next,
they are:

* Enforce policy to several nfnetlink subsystem, from Daniel
  Borkmann.

* Use xt_socket to match the third packet (to perform simplistic
  socket-based stateful filtering), from Eric Dumazet.

* Avoid large timeout for picked up from the middle TCP flows,
  from Florian Westphal.

* Exclude IPVS from struct net if IPVS is disabled and removal
  of unnecessary included header file, from JunweiZhang.

* Release SCTP connection immediately under load, to mimic current
  TCP behaviour, from Julian Anastasov.

* Replace and enhance SCTP state machine, from Julian Anastasov.

* Add tweak to reduce sync traffic in the presence of persistence,
  also from Julian Anastasov.

* Add tweak for the IPVS SH scheduler not to reject connections
  directed to a server, choose a new one instead, from Alexander
  Frolkin.

* Add support for sloppy TCP and SCTP modes, that creates state
  information on any packet, not only initial handshake packets,
  from Alexander Frolkin.

Please, consider pulling this batch from:

git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

Thanks!

----------------------------------------------------------------

The following changes since commit fedaf4ffc224a194e2d13a3ec2abe5df0bc94258:

  ndisc: Convert use of typedef ctl_table to struct ctl_table (2013-06-19 23:18:07 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to 496e4ae7dc944faa1721bfda7e9d834d5611a874:

  netfilter: nf_queue: add NFQA_SKB_CSUM_NOTVERIFIED info flag (2013-06-30 18:15:48 +0200)

----------------------------------------------------------------
Alexander Frolkin (2):
      ipvs: sloppy TCP and SCTP
      ipvs: SH fallback and L4 hashing

Daniel Borkmann (1):
      netfilter: check return code from nla_parse_tested

Eric Dumazet (1):
      netfilter: xt_socket: add XT_SOCKET_NOWILDCARD flag

Florian Westphal (2):
      netfilter: nf_conntrack: avoid large timeout for mid-stream pickup
      netfilter: nf_queue: add NFQA_SKB_CSUM_NOTVERIFIED info flag

Julian Anastasov (4):
      ipvs: provide iph to schedulers
      ipvs: replace the SCTP state machine
      ipvs: drop SCTP connections depending on state
      ipvs: add sync_persist_mode flag

JunweiZhang (2):
      kernel: remove unnecessary head file
      netns: exclude ipvs from struct net when IPVS disabled

 Documentation/networking/ipvs-sysctl.txt       |   13 +
 include/net/ip_vs.h                            |   84 ++-
 include/net/net_namespace.h                    |    2 +
 include/uapi/linux/ip_vs.h                     |    6 +
 include/uapi/linux/netfilter/nfnetlink_queue.h |    2 +
 include/uapi/linux/netfilter/xt_socket.h       |    7 +
 kernel/sysctl_binary.c                         |    1 -
 net/netfilter/ipvs/ip_vs_conn.c                |   12 +
 net/netfilter/ipvs/ip_vs_core.c                |    4 +-
 net/netfilter/ipvs/ip_vs_ctl.c                 |   21 +
 net/netfilter/ipvs/ip_vs_dh.c                  |   10 +-
 net/netfilter/ipvs/ip_vs_lblc.c                |   12 +-
 net/netfilter/ipvs/ip_vs_lblcr.c               |   12 +-
 net/netfilter/ipvs/ip_vs_lc.c                  |    3 +-
 net/netfilter/ipvs/ip_vs_nq.c                  |    3 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c          |  860 +++++-------------------
 net/netfilter/ipvs/ip_vs_proto_tcp.c           |   14 +-
 net/netfilter/ipvs/ip_vs_rr.c                  |    3 +-
 net/netfilter/ipvs/ip_vs_sed.c                 |    3 +-
 net/netfilter/ipvs/ip_vs_sh.c                  |  108 ++-
 net/netfilter/ipvs/ip_vs_sync.c                |   19 +-
 net/netfilter/ipvs/ip_vs_wlc.c                 |    3 +-
 net/netfilter/ipvs/ip_vs_wrr.c                 |    3 +-
 net/netfilter/nf_conntrack_netlink.c           |   30 +-
 net/netfilter/nf_conntrack_proto_tcp.c         |    6 +
 net/netfilter/nfnetlink_cthelper.c             |   16 +-
 net/netfilter/nfnetlink_cttimeout.c            |    6 +-
 net/netfilter/nfnetlink_queue_core.c           |   16 +-
 net/netfilter/xt_socket.c                      |   70 +-
 29 files changed, 529 insertions(+), 820 deletions(-)

