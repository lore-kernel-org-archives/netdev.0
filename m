From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 00/17] net subsystem refcount conversions
Date: Thu, 16 Mar 2017 17:28:50 +0200
Message-ID: <1489678147-21404-1-git-send-email-elena.reshetova@intel.com>
Cc: bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
        stephen@networkplumber.org, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series, for core network subsystem components, replaces atomic_t reference
counters with the new refcount_t type and API (see include/linux/refcount.h).
By doing this we prevent intentional or accidental
underflows or overflows that can led to use-after-free vulnerabilities.
These patches contain only generic net pieces. Other changes will be sent separately.

The patches are fully independent and can be cherry-picked separately.
Since we convert all kernel subsystems in the same fashion, resulting
in about 300 patches, we have to group them for sending at least in some
fashion to be manageable. Please excuse the long cc list.

If there are no objections to the patches, please merge them via respective trees.

Elena Reshetova (17):
  net: convert neighbour.refcnt from atomic_t to refcount_t
  net: convert neigh_params.refcnt from atomic_t to refcount_t
  net: convert nf_bridge_info.use from atomic_t to refcount_t
  net: convert sk_buff.users from atomic_t to refcount_t
  net: convert sk_buff_fclones.fclone_ref from atomic_t to refcount_t
  net: convert sock.sk_wmem_alloc from atomic_t to refcount_t
  net: convert sock.sk_refcnt from atomic_t to refcount_t
  net: convert sk_filter.refcnt from atomic_t to refcount_t
  net: convert ip_mc_list.refcnt from atomic_t to refcount_t
  net: convert in_device.refcnt from atomic_t to refcount_t
  net: convert netpoll_info.refcnt from atomic_t to refcount_t
  net: convert unix_address.refcnt from atomic_t to refcount_t
  net: convert fib_rule.refcnt from atomic_t to refcount_t
  net: convert inet_frag_queue.refcnt from atomic_t to refcount_t
  net: convert net.passive from atomic_t to refcount_t
  net: convert netlbl_lsm_cache.refcount from atomic_t to refcount_t
  net: convert packet_fanout.sk_ref from atomic_t to refcount_t

 crypto/algif_aead.c                  |  2 +-
 drivers/atm/fore200e.c               | 12 +-----------
 drivers/atm/he.c                     |  2 +-
 drivers/atm/idt77252.c               |  4 ++--
 drivers/infiniband/hw/nes/nes_cm.c   |  4 ++--
 drivers/isdn/mISDN/socket.c          |  2 +-
 drivers/net/rionet.c                 |  2 +-
 drivers/s390/net/ctcm_main.c         | 26 ++++++++++++------------
 drivers/s390/net/netiucv.c           | 10 +++++-----
 drivers/s390/net/qeth_core_main.c    |  4 ++--
 drivers/scsi/cxgbi/libcxgbi.h        |  2 +-
 include/linux/atmdev.h               |  2 +-
 include/linux/filter.h               |  3 ++-
 include/linux/igmp.h                 |  3 ++-
 include/linux/inetdevice.h           | 11 ++++++-----
 include/linux/netpoll.h              |  3 ++-
 include/linux/skbuff.h               | 16 +++++++--------
 include/net/af_unix.h                |  3 ++-
 include/net/arp.h                    |  2 +-
 include/net/fib_rules.h              |  7 ++++---
 include/net/inet_frag.h              |  4 ++--
 include/net/inet_hashtables.h        |  4 ++--
 include/net/ndisc.h                  |  2 +-
 include/net/neighbour.h              | 15 +++++++-------
 include/net/net_namespace.h          |  3 ++-
 include/net/netfilter/br_netfilter.h |  2 +-
 include/net/netlabel.h               |  8 ++++----
 include/net/request_sock.h           |  9 +++++----
 include/net/sock.h                   | 25 ++++++++++++------------
 net/atm/br2684.c                     |  2 +-
 net/atm/clip.c                       |  8 ++++----
 net/atm/common.c                     | 10 +++++-----
 net/atm/lec.c                        |  4 ++--
 net/atm/mpc.c                        |  4 ++--
 net/atm/pppoatm.c                    |  2 +-
 net/atm/proc.c                       |  2 +-
 net/atm/raw.c                        |  2 +-
 net/atm/signaling.c                  |  2 +-
 net/bluetooth/af_bluetooth.c         |  2 +-
 net/bluetooth/rfcomm/sock.c          |  2 +-
 net/bridge/br_netfilter_hooks.c      |  4 ++--
 net/caif/caif_socket.c               |  2 +-
 net/core/datagram.c                  | 10 +++++-----
 net/core/dev.c                       | 10 +++++-----
 net/core/fib_rules.c                 |  4 ++--
 net/core/filter.c                    |  7 ++++---
 net/core/neighbour.c                 | 22 ++++++++++-----------
 net/core/net-sysfs.c                 |  2 +-
 net/core/net_namespace.c             |  4 ++--
 net/core/netpoll.c                   | 10 +++++-----
 net/core/pktgen.c                    | 16 +++++++--------
 net/core/rtnetlink.c                 |  2 +-
 net/core/skbuff.c                    | 38 ++++++++++++++++++------------------
 net/core/sock.c                      | 30 ++++++++++++++--------------
 net/dccp/ipv6.c                      |  2 +-
 net/decnet/dn_neigh.c                |  2 +-
 net/ipv4/af_inet.c                   |  2 +-
 net/ipv4/cipso_ipv4.c                |  4 ++--
 net/ipv4/devinet.c                   |  2 +-
 net/ipv4/esp4.c                      |  2 +-
 net/ipv4/igmp.c                      | 10 +++++-----
 net/ipv4/inet_connection_sock.c      |  2 +-
 net/ipv4/inet_fragment.c             | 14 ++++++-------
 net/ipv4/inet_hashtables.c           |  4 ++--
 net/ipv4/inet_timewait_sock.c        |  8 ++++----
 net/ipv4/ip_fragment.c               |  2 +-
 net/ipv4/ip_output.c                 |  6 +++---
 net/ipv4/ping.c                      |  4 ++--
 net/ipv4/raw.c                       |  2 +-
 net/ipv4/syncookies.c                |  2 +-
 net/ipv4/tcp.c                       |  4 ++--
 net/ipv4/tcp_fastopen.c              |  2 +-
 net/ipv4/tcp_ipv4.c                  |  4 ++--
 net/ipv4/tcp_offload.c               |  2 +-
 net/ipv4/tcp_output.c                | 13 ++++++------
 net/ipv4/udp.c                       |  6 +++---
 net/ipv4/udp_diag.c                  |  4 ++--
 net/ipv6/calipso.c                   |  4 ++--
 net/ipv6/datagram.c                  |  2 +-
 net/ipv6/esp6.c                      |  2 +-
 net/ipv6/inet6_hashtables.c          |  4 ++--
 net/ipv6/ip6_output.c                |  4 ++--
 net/ipv6/syncookies.c                |  2 +-
 net/ipv6/tcp_ipv6.c                  |  6 +++---
 net/ipv6/udp.c                       |  2 +-
 net/kcm/kcmproc.c                    |  2 +-
 net/key/af_key.c                     |  8 ++++----
 net/l2tp/l2tp_debugfs.c              |  3 +--
 net/llc/llc_conn.c                   |  8 ++++----
 net/llc/llc_sap.c                    |  2 +-
 net/netfilter/xt_TPROXY.c            |  4 ++--
 net/netlink/af_netlink.c             | 14 ++++++-------
 net/packet/af_packet.c               | 14 ++++++-------
 net/packet/internal.h                |  4 +++-
 net/phonet/socket.c                  |  4 ++--
 net/rds/tcp_send.c                   |  2 +-
 net/rxrpc/af_rxrpc.c                 |  6 +++---
 net/rxrpc/skbuff.c                   | 12 ++++++------
 net/sched/em_meta.c                  |  2 +-
 net/sched/sch_atm.c                  |  2 +-
 net/sctp/output.c                    |  2 +-
 net/sctp/outqueue.c                  |  2 +-
 net/sctp/proc.c                      |  2 +-
 net/sctp/socket.c                    |  6 +++---
 net/tipc/socket.c                    |  2 +-
 net/unix/af_unix.c                   | 16 +++++++--------
 106 files changed, 320 insertions(+), 319 deletions(-)

-- 
2.7.4
