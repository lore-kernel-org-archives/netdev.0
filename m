From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 00/51] netfilter updates for net-next
Date: Sat, 6 Apr 2013 16:14:54 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1304061612270.1627@ja.ssi.bg>
References: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-891585646-1365254095=:1627"
Cc: netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:37522 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422889Ab3DFNOs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Apr 2013 09:14:48 -0400
In-Reply-To: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-891585646-1365254095=:1627
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Sat, 6 Apr 2013, Pablo Neira Ayuso wrote:

> Hi David,
> 
> The following patchset contains Netfilter and IPVS updates for
> your net-next tree, most relevantly they are:
> 
> * Add net namespace support to NFLOG, ULOG and ebt_ulog and NFQUEUE.
>   The LOG and ebt_log target has been also adapted, but they still
>   depend on the syslog netnamespace that seems to be missing, from
>   Gao Feng.
> 
> * Don't lose indications of congestion in IPv6 fragmentation handling,
>   from Hannes Frederic Sowa.i
> 
> * IPVS conversion to use RCU, including some code consolidation patches
>   and optimizations, also some from Julian Anastasov.
> 
> * cpu fanout support for NFQUEUE, from Holger Eitzenberger.
> 
> * Better error reporting to userspace when dropping packets from
>   all our _*_[xfrm|route]_me_harder functions, from Patrick McHardy.
> 
> You can pull these changes from:
> 
> git://1984.lsi.us.es/nf-next master
> 
> Thanks!
> 
> Gao feng (10):
>   netfilter: use IS_ENABLE to replace if defined in TRACE target
>   netfilter: make /proc/net/netfilter pernet
>   netfilter: nf_log: prepare net namespace support for loggers
>   netfilter: ebt_log: add net namespace support for ebt_log
>   netfilter: xt_LOG: add net namespace support for xt_LOG
>   netfilter: ebt_ulog: add net namespace support for ebt_ulog
>   netfilter: ipt_ULOG: add net namespace support for ipt_ULOG
>   netfilter: nfnetlink_log: add net namespace support for nfnetlink_log
>   netfilter: enable per netns support for nf_loggers
>   netfilter: nfnetlink_queue: add net namespace support for nfnetlink_queue
> 
> Hannes Frederic Sowa (1):
>   netfilter: implement RFC3168 5.3 (ecn protection) for ipv6 fragmentation handling
> 
> Julian Anastasov (33):

	Is the "net: add skb_dst_set_noref_force" change
missing here?

>   ipvs: avoid routing by TOS for real server
>   ipvs: prefer NETDEV_DOWN event to free cached dsts
>   ipvs: convert the IP_VS_XMIT macros to functions
>   ipvs: rename functions related to dst_cache reset
>   ipvs: no need to reroute anymore on DNAT over loopback
>   ipvs: do not use skb_share_check
>   ipvs: consolidate all dst checks on transmit in one place
>   ipvs: optimize dst usage for real server
>   ipvs: convert app locks
>   ipvs: remove rs_lock by using RCU
>   ipvs: convert locks used in persistence engines
>   ipvs: convert connection locking
>   ipvs: reorder keys in connection structure
>   ipvs: avoid kmem_cache_zalloc in ip_vs_conn_new
>   ipvs: change ip_vs_sched_lock to mutex
>   ipvs: preparations for using rcu in schedulers
>   ipvs: add ip_vs_dest_hold and ip_vs_dest_put
>   ipvs: convert dh scheduler to rcu
>   ipvs: convert lblc scheduler to rcu
>   ipvs: convert lblcr scheduler to rcu
>   ipvs: convert lc scheduler to rcu
>   ipvs: convert nq scheduler to rcu
>   ipvs: convert rr scheduler to rcu
>   ipvs: convert sed scheduler to rcu
>   ipvs: convert sh scheduler to rcu
>   ipvs: convert wlc scheduler to rcu
>   ipvs: convert wrr scheduler to rcu
>   ipvs: reorganize dest trash
>   ipvs: do not expect result from done_service
>   ipvs: convert sched_lock to spin lock
>   ipvs: convert dests to rcu
>   ipvs: convert services to rcu
>   ipvs: do not disable bh for long time
> 
> Michal Kubeček (1):
>   netfilter: fix struct ip6t_frag field description
> 
> Pablo Neira Ayuso (1):
>   netfilter: remove unneeded variable proc_net_netfilter
> 
> Patrick McHardy (3):
>   netfilter: ipv4: propagate routing errors from ip_route_me_harder()
>   netfilter: ipv6: propagate routing errors from ip6_route_me_harder()
>   netfilter: nat: propagate errors from xfrm_me_harder()
> 
> holger@eitzenberger.org (2):
>   netfilter: xt_NFQUEUE: introduce CPU fanout
>   netfilter: xt_NFQUEUE: coalesce IPv4 and IPv6 hashing
> 
>  include/linux/netfilter.h                      |    5 -
>  include/net/ip_vs.h                            |  130 ++-
>  include/net/net_namespace.h                    |    2 +
>  include/net/netfilter/nf_log.h                 |   14 +-
>  include/net/netns/netfilter.h                  |   18 +
>  include/uapi/linux/netfilter/xt_NFQUEUE.h      |    9 +
>  include/uapi/linux/netfilter_ipv6/ip6t_frag.h  |    4 +-
>  net/bridge/netfilter/ebt_log.c                 |   44 +-
>  net/bridge/netfilter/ebt_nflog.c               |    5 +-
>  net/bridge/netfilter/ebt_ulog.c                |  125 ++-
>  net/ipv4/ip_output.c                           |    3 +-
>  net/ipv4/netfilter.c                           |    8 +-
>  net/ipv4/netfilter/ip_tables.c                 |    9 +-
>  net/ipv4/netfilter/ipt_ULOG.c                  |  129 ++-
>  net/ipv4/netfilter/iptable_mangle.c            |    9 +-
>  net/ipv4/netfilter/iptable_nat.c               |   23 +-
>  net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    8 +-
>  net/ipv6/netfilter.c                           |    6 +-
>  net/ipv6/netfilter/ip6_tables.c                |    3 +-
>  net/ipv6/netfilter/ip6table_mangle.c           |    9 +-
>  net/ipv6/netfilter/ip6table_nat.c              |   23 +-
>  net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    7 +-
>  net/ipv6/netfilter/nf_conntrack_reasm.c        |   22 +-
>  net/netfilter/core.c                           |   29 +-
>  net/netfilter/ipvs/ip_vs_app.c                 |   31 +-
>  net/netfilter/ipvs/ip_vs_conn.c                |  306 +++----
>  net/netfilter/ipvs/ip_vs_core.c                |   73 +-
>  net/netfilter/ipvs/ip_vs_ctl.c                 |  641 +++++++--------
>  net/netfilter/ipvs/ip_vs_dh.c                  |   86 +-
>  net/netfilter/ipvs/ip_vs_ftp.c                 |    4 +
>  net/netfilter/ipvs/ip_vs_lblc.c                |  115 +--
>  net/netfilter/ipvs/ip_vs_lblcr.c               |  190 +++--
>  net/netfilter/ipvs/ip_vs_lc.c                  |    3 +-
>  net/netfilter/ipvs/ip_vs_nq.c                  |    3 +-
>  net/netfilter/ipvs/ip_vs_pe.c                  |   55 +-
>  net/netfilter/ipvs/ip_vs_pe_sip.c              |    1 +
>  net/netfilter/ipvs/ip_vs_proto_sctp.c          |   36 +-
>  net/netfilter/ipvs/ip_vs_proto_tcp.c           |   40 +-
>  net/netfilter/ipvs/ip_vs_proto_udp.c           |   33 +-
>  net/netfilter/ipvs/ip_vs_rr.c                  |   64 +-
>  net/netfilter/ipvs/ip_vs_sched.c               |   63 +-
>  net/netfilter/ipvs/ip_vs_sed.c                 |    5 +-
>  net/netfilter/ipvs/ip_vs_sh.c                  |   86 +-
>  net/netfilter/ipvs/ip_vs_sync.c                |   35 +-
>  net/netfilter/ipvs/ip_vs_wlc.c                 |    5 +-
>  net/netfilter/ipvs/ip_vs_wrr.c                 |  176 ++--
>  net/netfilter/ipvs/ip_vs_xmit.c                | 1050 ++++++++++--------------
>  net/netfilter/nf_conntrack_helper.c            |    2 +-
>  net/netfilter/nf_conntrack_proto_dccp.c        |    9 +-
>  net/netfilter/nf_conntrack_proto_tcp.c         |   18 +-
>  net/netfilter/nf_conntrack_proto_udp.c         |    6 +-
>  net/netfilter/nf_conntrack_proto_udplite.c     |    8 +-
>  net/netfilter/nf_log.c                         |  206 +++--
>  net/netfilter/nf_nat_core.c                    |    9 +-
>  net/netfilter/nfnetlink_log.c                  |  182 ++--
>  net/netfilter/nfnetlink_queue_core.c           |  173 ++--
>  net/netfilter/xt_LOG.c                         |   52 +-
>  net/netfilter/xt_NFQUEUE.c                     |   63 +-
>  net/netfilter/xt_osf.c                         |    6 +-
>  59 files changed, 2451 insertions(+), 2028 deletions(-)
>  create mode 100644 include/net/netns/netfilter.h
> 
> -- 
> 1.7.10.4

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-891585646-1365254095=:1627--
