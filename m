From: igorm@etf.rs
Subject: [PATCH 00/10 net-next] Introduce per interface ipv4 statistics
Date: Fri, 16 Dec 2011 16:25:53 +0100
Message-ID: <1324049163-11207-1-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
Cc: davem@davemloft.net, Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:35776 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759889Ab1LPP0Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Dec 2011 10:26:16 -0500
In-Reply-To: <igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Maravic <igorm@etf.rs>

Hi all,
in this patch series I introduced per interface statistics for ipv4.

I referenced how it was done for ipv6 per interface statistics.
BR
Igor

Igor Maravic (10):
  include: net: netns: mib: Add proc_dir_entry for ipv4 per interface
    stats
  include: net: snmp: Create icmp per device counters and add macros
    for per device stats
  include:linux:inetdevice: Add struct ipv4_devstat and func
    __in_dev_get_rcu_safely
  include:net:ipv6: Moved _DEV* macros
  include:net:ip: Tuned up IP_*_STATS macros for per device statistics
    and added functions for (un)registering per device proc entries
  include:net:icmp: Tuned up ICMP_*_STATS macros for per device
    statistics and changed prototype for icmp_out_count
  net:ipv4:devinet: Add support for alloc/free of per device stats and
    (un)register of per device proc files
  net:ipv4:af_inet: Init proc fs before ip_init
  net:ipv4:proc: Introduce proc files for ipv4 per interface stats
  net: Enable ipv4 per interface statistics

 include/linux/inetdevice.h      |   16 +++++
 include/net/icmp.h              |   37 ++++++++++--
 include/net/ip.h                |   60 +++++++++++++++++--
 include/net/ipv6.h              |   64 ++++-----------------
 include/net/netns/mib.h         |    1 +
 include/net/snmp.h              |   55 ++++++++++++++++++
 net/bridge/br_netfilter.c       |    6 +-
 net/dccp/ipv4.c                 |    9 ++-
 net/ipv4/af_inet.c              |    7 ++-
 net/ipv4/datagram.c             |    2 +-
 net/ipv4/devinet.c              |   75 +++++++++++++++++++++---
 net/ipv4/icmp.c                 |   29 +++++----
 net/ipv4/inet_connection_sock.c |    8 ++-
 net/ipv4/ip_forward.c           |    8 ++-
 net/ipv4/ip_fragment.c          |   43 ++++++++------
 net/ipv4/ip_input.c             |   33 ++++++-----
 net/ipv4/ip_output.c            |   43 ++++++++------
 net/ipv4/ipmr.c                 |    6 +-
 net/ipv4/ping.c                 |    8 +-
 net/ipv4/proc.c                 |  121 +++++++++++++++++++++++++++++++++++++++
 net/ipv4/raw.c                  |    4 +-
 net/ipv4/route.c                |    2 +-
 net/ipv4/tcp_ipv4.c             |    9 ++-
 net/ipv4/udp.c                  |    7 +-
 net/l2tp/l2tp_ip.c              |    6 +-
 net/sctp/input.c                |    4 +-
 net/sctp/output.c               |    2 +-
 27 files changed, 488 insertions(+), 177 deletions(-)

-- 
1.7.5.4
