From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH - diffstat only] include/net: Remove extern from
 function prototypes
Date: Tue, 23 Jul 2013 10:58:11 -0700
Message-ID: <1374602291.3387.17.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Function prototypes don't need to be declared
extern in .h files.  It's assumed by the compiler
and is as unnecessary as using auto is when
declaring automatic/local variables in a block.

I ran a script to remove these unnecessary extern
uses from function prototypes in include/net/ as
well as reflow the function arguments to 80 cols.

It's 370KB, far too large to submit at once.

Of course it could be broken into multiple patches
for the various directories/subsystems.

I believe it makes grepping for extern useful as
all the matches are actual variables and structs.

Thoughts?

---

 include/net/act_api.h                          |  60 ++--
 include/net/addrconf.h                         | 151 +++++-----
 include/net/af_rxrpc.h                         |  35 ++-
 include/net/af_unix.h                          |  16 +-
 include/net/arp.h                              |  30 +-
 include/net/ax25.h                             | 215 +++++++-------
 include/net/bluetooth/bluetooth.h              |  16 +-
 include/net/bluetooth/hci_core.h               |  20 +-
 include/net/bluetooth/rfcomm.h                 |   4 +-
 include/net/caif/caif_hsi.h                    |   2 +-
 include/net/cfg80211.h                         |  34 +--
 include/net/checksum.h                         |  10 +-
 include/net/cls_cgroup.h                       |   2 +-
 include/net/compat.h                           |  48 ++--
 include/net/dcbevent.h                         |   6 +-
 include/net/dn.h                               |  20 +-
 include/net/dn_dev.h                           |  30 +-
 include/net/dn_fib.h                           |  46 ++-
 include/net/dn_neigh.h                         |  12 +-
 include/net/dn_nsp.h                           |  49 ++--
 include/net/dn_route.h                         |  13 +-
 include/net/dst.h                              |  22 +-
 include/net/esp.h                              |   2 +-
 include/net/fib_rules.h                        |  19 +-
 include/net/flow.h                             |  10 +-
 include/net/flow_keys.h                        |   2 +-
 include/net/garp.h                             |  28 +-
 include/net/gen_stats.h                        |  52 ++--
 include/net/genetlink.h                        |  20 +-
 include/net/icmp.h                             |  10 +-
 include/net/inet6_connection_sock.h            |  33 ++-
 include/net/inet6_hashtables.h                 |  40 +--
 include/net/inet_common.h                      |  38 +--
 include/net/inet_connection_sock.h             |  80 +++---
 include/net/inet_hashtables.h                  |  70 ++---
 include/net/inet_sock.h                        |   4 +-
 include/net/inet_timewait_sock.h               |  38 +--
 include/net/inetpeer.h                         |  10 +-
 include/net/ip.h                               | 141 ++++-----
 include/net/ip6_fib.h                          |  50 ++--
 include/net/ip6_route.h                        |  93 +++---
 include/net/ip_fib.h                           |  58 ++--
 include/net/ip_vs.h                            | 212 +++++++-------
 include/net/ipv6.h                             | 277 +++++++++---------
 include/net/ipx.h                              |  12 +-
 include/net/irda/ircomm_tty.h                  |  14 +-
 include/net/irda/irda.h                        |  22 +-
 include/net/irda/irlap_event.h                 |   2 +-
 include/net/irda/irlap_frame.h                 |   4 +-
 include/net/iw_handler.h                       |  38 +--
 include/net/lapb.h                             |  52 ++--
 include/net/llc.h                              |  50 ++--
 include/net/llc_c_ac.h                         | 190 ++++++-------
 include/net/llc_c_ev.h                         | 240 ++++++++--------
 include/net/llc_conn.h                         |  38 +--
 include/net/llc_if.h                           |   8 +-
 include/net/llc_pdu.h                          |  30 +-
 include/net/llc_s_ac.h                         |  20 +-
 include/net/llc_s_ev.h                         |  20 +-
 include/net/llc_sap.h                          |  26 +-
 include/net/mac80211.h                         |  10 +-
 include/net/mrp.h                              |  28 +-
 include/net/ndisc.h                            |  56 ++--
 include/net/neighbour.h                        |  98 ++++---
 include/net/net_namespace.h                    |  26 +-
 include/net/netevent.h                         |   6 +-
 include/net/netfilter/ipv4/nf_conntrack_ipv4.h |   6 +-
 include/net/netfilter/ipv4/nf_defrag_ipv4.h    |   2 +-
 include/net/netfilter/ipv6/nf_defrag_ipv6.h    |  10 +-
 include/net/netfilter/nf_conntrack.h           |  56 ++--
 include/net/netfilter/nf_conntrack_acct.h      |   8 +-
 include/net/netfilter/nf_conntrack_core.h      |  32 +--
 include/net/netfilter/nf_conntrack_ecache.h    |  25 +-
 include/net/netfilter/nf_conntrack_extend.h    |   2 +-
 include/net/netfilter/nf_conntrack_helper.h    |  32 ++-
 include/net/netfilter/nf_conntrack_l3proto.h   |  16 +-
 include/net/netfilter/nf_conntrack_l4proto.h   |  24 +-
 include/net/netfilter/nf_conntrack_timeout.h   |   8 +-
 include/net/netfilter/nf_conntrack_timestamp.h |   8 +-
 include/net/netfilter/nf_nat.h                 |  10 +-
 include/net/netfilter/nf_nat_core.h            |  10 +-
 include/net/netfilter/nf_nat_helper.h          |  62 ++--
 include/net/netfilter/nf_nat_l3proto.h         |  26 +-
 include/net/netfilter/nf_nat_l4proto.h         |  31 +-
 include/net/netfilter/nf_queue.h               |   2 +-
 include/net/netfilter/xt_rateest.h             |   4 +-
 include/net/netlink.h                          |  64 ++---
 include/net/netprio_cgroup.h                   |   2 +-
 include/net/netrom.h                           |  90 +++---
 include/net/p8022.h                            |   6 +-
 include/net/ping.h                             |   9 -
 include/net/pkt_cls.h                          |  36 +--
 include/net/pkt_sched.h                        |  40 +--
 include/net/protocol.h                         |  24 +-
 include/net/psnap.h                            |   2 +-
 include/net/raw.h                              |   6 +-
 include/net/rawv6.h                            |   4 +-
 include/net/request_sock.h                     |  12 +-
 include/net/rose.h                             | 113 ++++----
 include/net/route.h                            |  46 +--
 include/net/rtnetlink.h                        |  40 +--
 include/net/sch_generic.h                      |  51 ++--
 include/net/scm.h                              |  10 +-
 include/net/sctp/sctp.h                        |  14 +-
 include/net/secure_seq.h                       |  26 +-
 include/net/snmp.h                             |   2 +-
 include/net/sock.h                             | 240 ++++++++--------
 include/net/stp.h                              |   4 +-
 include/net/tcp.h                              | 380 ++++++++++++-------------
 include/net/udp.h                              |  88 +++---
 include/net/udplite.h                          |   4 +-
 include/net/wext.h                             |  16 +-
 include/net/wimax.h                            |  32 +--
 include/net/x25.h                              | 141 ++++-----
 include/net/xfrm.h                             | 334 +++++++++++-----------
 115 files changed, 2636 insertions(+), 2692 deletions(-)
