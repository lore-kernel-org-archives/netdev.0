From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 0/2] Introduce possible_net_t
Date: Wed, 11 Mar 2015 23:03:13 -0500
Message-ID: <87oany7tha.fsf_-_@x220.int.ebiederm.org>
References: <20150311.215553.1544350193194225837.davem@davemloft.net>
	<1426128863.11398.135.camel@edumazet-glaptop2.roam.corp.google.com>
	<1426130872.11398.141.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150311.232940.1345045254716776224.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, salo@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:40672 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149AbbCLEGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 00:06:54 -0400
In-Reply-To: <20150311.232940.1345045254716776224.davem@davemloft.net> (David
	Miller's message of "Wed, 11 Mar 2015 23:29:40 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The current usage of write_pnet and read_pnet is a little laborious and
error prone as you only notice if you failed to include them if are
compiling with network namespaces enabled.

possible_net_t remedies that by using a type that is 0 bytes when
network namespaces are disabled and can only be read and written to with
read_pnet and write_pnet.

Aka less work and safer for the same effect.

I kill hold_net and release_net first as are they are haven't been used
since 2008 and are noise at the points where write_pnet and read_pnet
are used.

I have folded in Eric Dumazets suggestions to improve the killing of
hold_net and release net.  And respon.  I had to respin anyway as
there was enough changes elsewhere in the tree the previous version
of these patches did not quite apply cleanly.

Eric W. Biederman (2):
      net: Kill hold_net release_net
      net: Introduce possible_net_t

 include/linux/netdevice.h            |  9 ++-----
 include/net/cfg80211.h               |  4 +--
 include/net/fib_rules.h              |  9 +------
 include/net/genetlink.h              |  4 +--
 include/net/inet_hashtables.h        |  4 +--
 include/net/ip_vs.h                  |  8 +++---
 include/net/neighbour.h              |  8 ++----
 include/net/net_namespace.h          | 52 +++++++++---------------------------
 include/net/netfilter/nf_conntrack.h |  5 ++--
 include/net/sock.h                   |  6 ++---
 include/net/xfrm.h                   |  8 ++----
 net/9p/trans_fd.c                    |  4 +--
 net/core/dev.c                       |  2 --
 net/core/fib_rules.c                 | 17 +++---------
 net/core/neighbour.c                 |  9 ++-----
 net/core/net_namespace.c             | 11 --------
 net/core/sock.c                      |  1 -
 net/ipv4/fib_semantics.c             |  3 +--
 net/ipv4/inet_hashtables.c           |  3 +--
 net/ipv4/inet_timewait_sock.c        |  3 +--
 net/ipv4/ipmr.c                      |  4 +--
 net/ipv6/addrlabel.c                 | 11 ++------
 net/ipv6/ip6_flowlabel.c             |  3 +--
 net/ipv6/ip6mr.c                     |  4 +--
 net/openvswitch/datapath.c           |  4 +--
 net/openvswitch/datapath.h           |  4 +--
 net/packet/internal.h                |  4 +--
 27 files changed, 49 insertions(+), 155 deletions(-)
