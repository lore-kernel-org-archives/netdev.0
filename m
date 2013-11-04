From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/20] Netfilter/IPVS updates for net-next
Date: Mon,  4 Nov 2013 22:50:22 +0100
Message-ID: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

This is another batch containing Netfilter/IPVS updates for your net-next
tree, they are:

* Six patches to make the ipt_CLUSTERIP target support netnamespace,
  from Gao feng.

* Two cleanups for the nf_conntrack_acct infrastructure, introducing
  a new structure to encapsulate conntrack counters, from Holger
  Eitzenberger.

* Fix missing verdict in SCTP support for IPVS, from Daniel Borkmann.

* Skip checksum recalculation in SCTP support for IPVS, also from
  Daniel Borkmann.

* Fix behavioural change in xt_socket after IP early demux, from
  Florian Westphal.

* Fix bogus large memory allocation in the bitmap port set type in ipset,
  from Jozsef Kadlecsik.

* Fix possible compilation issues in the hash netnet set type in ipset,
  also from Jozsef Kadlecsik.

* Define constants to identify netlink callback data in ipset dumps,
  again from Jozsef Kadlecsik.

* Use sock_gen_put() in xt_socket to replace xt_socket_put_sk,
  from Eric Dumazet.

* Improvements for the SH scheduler in IPVS, from Alexander Frolkin.

* Remove extra delay due to unneeded rcu barrier in IPVS net namespace
  cleanup path, from Julian Anastasov.

* Save some cycles in ip6t_REJECT by skipping checksum validation in
  packets leaving from our stack, from Stanislav Fomichev.

* Fix IPVS_CMD_ATTR_MAX definition in IPVS, larger that required, from
  Julian Anastasov.

You can pull these changes from:

git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

Thanks!

----------------------------------------------------------------

The following changes since commit 58308451e91974267e1f4a618346055342019e02:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next (2013-10-10 15:29:44 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to 4542fa4727f5f83faf9e1f28f35be0b9a2317aec:

  netfilter: ctnetlink: account both directions in one step (2013-11-03 21:49:32 +0100)

----------------------------------------------------------------
Alexander Frolkin (1):
      ipvs: improved SH fallback strategy

Daniel Borkmann (2):
      net: ipvs: sctp: add missing verdict assignments in sctp_conn_schedule
      net: ipvs: sctp: do not recalc sctp csum when ports didn't change

Eric Dumazet (1):
      netfilter: xt_socket: use sock_gen_put()

Florian Westphal (1):
      bridge: netfilter: orphan skb before invoking ip netfilter hooks

Gao feng (6):
      netfilter: ipt_CLUSTERIP: make proc directory per net namespace
      netfilter: ipt_CLUSTERIP: make clusterip_list per net namespace
      netfilter: ipt_CLUSTERIP: make clusterip_lock per net namespace
      netfilter: ipt_CLUSTERIP: add parameter net in clusterip_config_find_get
      netfilter: ipt_CLUSTERIP: create proc entry under proper ipt_CLUSTERIP directory
      netfilter: ipt_CLUSTERIP: use proper net namespace to operate CLUSTERIP

Holger Eitzenberger (2):
      netfilter: introduce nf_conn_acct structure
      netfilter: ctnetlink: account both directions in one step

Jozsef Kadlecsik (3):
      netfilter: ipset: Use netlink callback dump args only
      netfilter: ipset: The unnamed union initialization may lead to compilation error
      netfilter:ipset: Fix memory allocation for bitmap:port

Julian Anastasov (2):
      ipvs: fix the IPVS_CMD_ATTR_MAX definition
      ipvs: avoid rcu_barrier during netns cleanup

Michael Opdenacker (1):
      netfilter: ipset: remove duplicate define

Stanislav Fomichev (1):
      netfilter: ip6t_REJECT: skip checksum verification for outgoing ipv6 packets

 include/linux/netfilter/ipset/ip_set.h       |   10 +++
 include/net/ip_vs.h                          |    6 ++
 include/net/netfilter/nf_conntrack_acct.h    |   10 ++-
 include/net/netfilter/nf_conntrack_extend.h  |    2 +-
 include/uapi/linux/ip_vs.h                   |    2 +-
 net/bridge/br_netfilter.c                    |    2 +
 net/ipv4/netfilter/ipt_CLUSTERIP.c           |  110 ++++++++++++++++++--------
 net/ipv6/netfilter/ip6t_REJECT.c             |    7 +-
 net/netfilter/ipset/ip_set_bitmap_gen.h      |   11 +--
 net/netfilter/ipset/ip_set_bitmap_port.c     |    2 +-
 net/netfilter/ipset/ip_set_core.c            |   70 ++++++++--------
 net/netfilter/ipset/ip_set_hash_gen.h        |   21 ++---
 net/netfilter/ipset/ip_set_hash_netnet.c     |   22 +++---
 net/netfilter/ipset/ip_set_hash_netportnet.c |   22 +++---
 net/netfilter/ipset/ip_set_list_set.c        |   11 +--
 net/netfilter/ipvs/ip_vs_ctl.c               |    6 +-
 net/netfilter/ipvs/ip_vs_lblc.c              |    2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c             |    2 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c        |   48 +++++++++--
 net/netfilter/ipvs/ip_vs_sh.c                |   39 ++++++---
 net/netfilter/nf_conntrack_acct.c            |   12 +--
 net/netfilter/nf_conntrack_core.c            |   16 ++--
 net/netfilter/nf_conntrack_netlink.c         |   51 ++++++------
 net/netfilter/xt_connbytes.c                 |    6 +-
 net/netfilter/xt_socket.c                    |   13 +--
 25 files changed, 305 insertions(+), 198 deletions(-)

