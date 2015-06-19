From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/12] Netfilter updates for net-next
Date: Fri, 19 Jun 2015 19:17:37 +0200
Message-ID: <1434734269-4545-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains a final Netfilter pull request for net-next
4.2. This mostly addresses some fallout from the previous pull request, small
netns updates and a couple of new features for nfnetlink_log and the socket
match that didn't get in time for the previous pull request. More specifically
they are:

1) Add security context information to nfnetlink_queue, from Roman Kubiak.

2) Add support to restore the sk_mark into skb->mark through xt_socket,
   from Harout Hedeshian.

3) Force alignment of 16 bytes of per cpu xt_counters, from Eric Dumazet.

4) Rename br_netfilter.c to br_netfilter_hooks.c to prepare split of IPv6 code
   into a separated file.

5) Move the IPv6 code in br_netfilter into a separated file.

6) Remove unused RCV_SKB_FAIL() in nfnetlink_queue and nfetlink_log, from Eric
   Biederman.

7) Two liner to simplify netns logic in em_ipset_match().

8) Add missing includes to net/net_namespace.h to avoid compilation problems
   that result from not including linux/netfilter.h in netns headers.

9) Use a forward declaration instead of including linux/proc_fs.h from
   netns/netfilter.h

10) Add a new linux/netfilter_defs.h to replace the linux/netfilter.h inclusion
    in netns headers.

11) Remove spurious netfilter.h file included in the net tree, also from Eric
    Biederman.

12) Fix x_tables compilation warnings on 32 bits platforms that resulted from
    recent changes in x_tables counters, from Florian Westphal.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 89d256bb69f2596c3a31ac51466eac9e1791c388:

  bpf: disallow bpf tc programs access current->pid,uid (2015-06-15 20:51:20 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to dcb8f5c8139ef945cdfd55900fae265c4dbefc02:

  netfilter: xtables: fix warnings on 32bit platforms (2015-06-18 21:14:33 +0200)

----------------------------------------------------------------
Eric Dumazet (1):
      netfilter: x_tables: align per cpu xt_counter

Eric W Biederman (1):
      netfilter: Remove spurios included of netfilter.h

Eric W. Biederman (2):
      netfilter: Kill unused copies of RCV_SKB_FAIL
      net: sched: Simplify em_ipset_match

Florian Westphal (1):
      netfilter: xtables: fix warnings on 32bit platforms

Harout Hedeshian (1):
      netfilter: xt_socket: add XT_SOCKET_RESTORESKMARK flag

Pablo Neira Ayuso (5):
      netfilter: bridge: rename br_netfilter.c to br_netfilter_hooks.c
      netfilter: bridge: split ipv6 code into separated file
      net: include missing headers in net/net_namespace.h
      netfilter: use forward declaration instead of including linux/proc_fs.h
      netfilter: don't pull include/linux/netfilter.h from netns headers

Roman Kubiak (1):
      netfilter: nfnetlink_queue: add security context information

 drivers/net/hamradio/bpqether.c                    |    1 -
 drivers/net/ppp/pptp.c                             |    2 -
 drivers/net/wan/lapbether.c                        |    1 -
 include/linux/netfilter.h                          |    6 +-
 include/linux/netfilter/x_tables.h                 |   14 +-
 include/linux/netfilter_defs.h                     |    9 +
 include/net/net_namespace.h                        |    2 +
 include/net/netfilter/br_netfilter.h               |   60 +++++
 include/net/netns/netfilter.h                      |    4 +-
 include/net/netns/x_tables.h                       |    2 +-
 include/uapi/linux/netfilter.h                     |    3 +-
 include/uapi/linux/netfilter/nfnetlink_queue.h     |    4 +-
 include/uapi/linux/netfilter/xt_socket.h           |    8 +
 net/ax25/af_ax25.c                                 |    1 -
 net/ax25/ax25_in.c                                 |    1 -
 net/ax25/ax25_ip.c                                 |    1 -
 net/ax25/ax25_out.c                                |    1 -
 net/ax25/ax25_uid.c                                |    1 -
 net/bridge/Makefile                                |    2 +
 .../{br_netfilter.c => br_netfilter_hooks.c}       |  248 +-------------------
 net/bridge/br_netfilter_ipv6.c                     |  245 +++++++++++++++++++
 net/ipv6/output_core.c                             |    1 +
 net/netfilter/nf_synproxy_core.c                   |    1 +
 net/netfilter/nfnetlink_log.c                      |    2 -
 net/netfilter/nfnetlink_queue_core.c               |   37 ++-
 net/netfilter/xt_socket.c                          |   59 ++++-
 net/netrom/nr_route.c                              |    1 -
 net/rose/rose_link.c                               |    1 -
 net/rose/rose_route.c                              |    1 -
 net/sched/em_ipset.c                               |    4 +-
 security/selinux/xfrm.c                            |    3 -
 31 files changed, 444 insertions(+), 282 deletions(-)
 create mode 100644 include/linux/netfilter_defs.h
 rename net/bridge/{br_netfilter.c => br_netfilter_hooks.c} (82%)
 create mode 100644 net/bridge/br_netfilter_ipv6.c
--
To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
