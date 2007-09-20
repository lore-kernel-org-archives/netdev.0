From: Joe Perches <joe@perches.com>
Subject: [PATCH - net-2.6.24 1/2] Introduce and use print_ip
Date: Wed, 19 Sep 2007 23:53:37 -0700
Message-ID: <1190271217.26101.93.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2604 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751695AbXITGxj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 02:53:39 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This removes the uses of NIPQUAD and HIPQUAD in
drivers/net and net

IPV4 Use:

	DECLARE_IP_BUF(ipbuf);
	__be32 addr;
	print_ip(ipbuf, addr)

Signed-off-by:  Joe Perches <joe@perches.com>

please pull from:
git pull http://repo.or.cz/r/linux-2.6/trivial-mods.git print_ipv4

stats for print_ipv4:

--

 drivers/net/bonding/bond_main.c                |   35 +++++++-----
 drivers/net/bonding/bond_sysfs.c               |   31 ++++++-----
 include/linux/ip.h                             |    8 +++
 include/net/ip_vs.h                            |   36 +++++++------
 include/net/sctp/sctp.h                        |    5 +-
 net/atm/clip.c                                 |    5 +-
 net/atm/mpc.c                                  |   28 ++++++----
 net/atm/mpoa_caches.c                          |   20 +++++---
 net/bridge/netfilter/ebt_log.c                 |   21 ++++----
 net/core/netpoll.c                             |   15 +++--
 net/core/utils.c                               |   14 +++++
 net/dccp/ipv4.c                                |   10 ++--
 net/dccp/probe.c                               |   14 +++--
 net/ipv4/af_inet.c                             |    8 ++-
 net/ipv4/arp.c                                 |    9 ++--
 net/ipv4/fib_trie.c                            |    7 ++-
 net/ipv4/icmp.c                                |   26 +++++----
 net/ipv4/ip_fragment.c                         |    5 +-
 net/ipv4/ip_input.c                            |    8 ++-
 net/ipv4/ipcomp.c                              |    5 +-
 net/ipv4/ipconfig.c                            |   46 +++++++++-------
 net/ipv4/ipvs/ip_vs_conn.c                     |   63 ++++++++++++++--------
 net/ipv4/ipvs/ip_vs_core.c                     |   51 +++++++++++-------
 net/ipv4/ipvs/ip_vs_ctl.c                      |   35 +++++++-----
 net/ipv4/ipvs/ip_vs_dh.c                       |   10 ++--
 net/ipv4/ipvs/ip_vs_ftp.c                      |   19 ++++---
 net/ipv4/ipvs/ip_vs_lblc.c                     |   14 +++--
 net/ipv4/ipvs/ip_vs_lblcr.c                    |   34 +++++++-----
 net/ipv4/ipvs/ip_vs_lc.c                       |    5 +-
 net/ipv4/ipvs/ip_vs_nq.c                       |    5 +-
 net/ipv4/ipvs/ip_vs_proto.c                    |   20 ++++---
 net/ipv4/ipvs/ip_vs_proto_ah.c                 |   24 +++++---
 net/ipv4/ipvs/ip_vs_proto_esp.c                |   24 +++++---
 net/ipv4/ipvs/ip_vs_proto_tcp.c                |   20 ++++---
 net/ipv4/ipvs/ip_vs_proto_udp.c                |   10 ++--
 net/ipv4/ipvs/ip_vs_rr.c                       |    5 +-
 net/ipv4/ipvs/ip_vs_sed.c                      |    5 +-
 net/ipv4/ipvs/ip_vs_sh.c                       |   10 ++--
 net/ipv4/ipvs/ip_vs_sync.c                     |    5 +-
 net/ipv4/ipvs/ip_vs_wlc.c                      |    5 +-
 net/ipv4/ipvs/ip_vs_wrr.c                      |    5 +-
 net/ipv4/ipvs/ip_vs_xmit.c                     |   16 +++---
 net/ipv4/netfilter/arp_tables.c                |   20 ++++---
 net/ipv4/netfilter/ip_tables.c                 |   19 ++++---
 net/ipv4/netfilter/ipt_CLUSTERIP.c             |   16 +++---
 net/ipv4/netfilter/ipt_LOG.c                   |   10 ++--
 net/ipv4/netfilter/ipt_SAME.c                  |   21 +++++---
 net/ipv4/netfilter/ipt_iprange.c               |   21 ++++----
 net/ipv4/netfilter/ipt_recent.c                |    5 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   20 ++++---
 net/ipv4/netfilter/nf_nat_ftp.c                |    3 +-
 net/ipv4/netfilter/nf_nat_h323.c               |   68 ++++++++++++++---------
 net/ipv4/netfilter/nf_nat_irc.c                |    5 +-
 net/ipv4/netfilter/nf_nat_rule.c               |   16 ++++--
 net/ipv4/netfilter/nf_nat_sip.c                |   12 +++--
 net/ipv4/netfilter/nf_nat_snmp_basic.c         |   13 +++--
 net/ipv4/route.c                               |   58 +++++++++++++--------
 net/ipv4/tcp_input.c                           |    5 +-
 net/ipv4/tcp_ipv4.c                            |   25 +++++----
 net/ipv4/tcp_probe.c                           |    8 ++-
 net/ipv4/tcp_timer.c                           |    5 +-
 net/ipv4/udp.c                                 |   14 +++--
 net/ipv6/netfilter/ip6t_LOG.c                  |    9 ++-
 net/netfilter/nf_conntrack_ftp.c               |   10 ++--
 net/netfilter/nf_conntrack_irc.c               |   18 ++++---
 net/netfilter/xt_hashlimit.c                   |   10 ++--
 net/rxrpc/af_rxrpc.c                           |    7 ++-
 net/rxrpc/ar-error.c                           |    5 +-
 net/rxrpc/ar-local.c                           |   19 ++++---
 net/rxrpc/ar-peer.c                            |    9 ++--
 net/rxrpc/ar-proc.c                            |   23 +++++---
 net/rxrpc/ar-transport.c                       |   17 ++++--
 net/rxrpc/rxkad.c                              |    4 +-
 net/sctp/protocol.c                            |   26 ++++++---
 net/sctp/sm_statefuns.c                        |    6 +-
 net/sunrpc/clnt.c                              |    6 ++-
 net/sunrpc/rpcb_clnt.c                         |    8 ++-
 net/sunrpc/svcsock.c                           |   16 ++++--
 net/sunrpc/xprtsock.c                          |   15 +++--
 net/xfrm/xfrm_policy.c                         |    9 ++-
 82 files changed, 805 insertions(+), 525 deletions(-)


