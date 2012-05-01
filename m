From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH v2 00/17] netfilter: add namespace support for netfilter protos
Date: Tue, 01 May 2012 11:47:45 -0700
Message-ID: <m1zk9rwxf2.fsf@fess.ebiederm.org>
References: <1335519484-6089-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, serge.hallyn@canonical.com,
	dlezcano@fr.ibm.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1335519484-6089-1-git-send-email-gaofeng@cn.fujitsu.com> (Gao
	feng's message of "Fri, 27 Apr 2012 17:37:47 +0800")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gao feng <gaofeng@cn.fujitsu.com> writes:

> Currently the sysctl of netfilter proto is not isolated, so when
> changing proto's sysctl in container will cause the host's sysctl
> be changed too. it's not expected.
>
> This patch set adds the namespace support for netfilter protos.
>
> impletement four pernet_operations to register sysctl and initial
> pernet data for proto.
>
> -ipv4_net_ops is used to register tcp4(compat),
>  udp4(compat),icmp(compat),ipv4(compat).
> -ipv6_net_ops is used to register tcp6,udp6 and icmpv6.
> -sctp_net_ops is used to register sctp4(compat) and sctp6.
> -udplite_net_ops is used to register udplite4 and udplite6
>
> extern l[3,4]proto (sysctl) register functions to make them support
> namespace.
>
> finailly add namespace support for cttimeout.

I am a bit out of it this week so I could not look at these patches
in the detail that I would like.  However skimming through it looks
like you addressed your review comments, and the changes look like
the kind of changes I would expect from something like this.

I assume you have tested to make certain your code actually works.

So on that basis for the patchset:
Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Anyone else want to chime in or does everyone else figure
that this code is ready to be merged and no additional comments
are necessary?

Eric


> Gao feng (17):
>   netfilter: add struct nf_proto_net for register l4proto sysctl
>   netfilter: add namespace support for l4proto
>   netfilter: add namespace support for l3proto
>   netfilter: add namespace support for l4proto_generic
>   netfilter: add namespace support for l4proto_tcp
>   netfilter: add namespace support for l4proto_udp
>   netfilter: add namespace support for l4proto_icmp
>   netfilter: add namespace support for l4proto_icmpv6
>   netfilter: add namespace support for l3proto_ipv4
>   netfilter: add namespace support for l3proto_ipv6
>   netfilter: add namespace support for l4proto_sctp
>   netfilter: add namespace support for l4proto_udplite
>   netfilter: adjust l4proto_dccp to the nf_conntrack_l4proto_register
>   netfilter: adjust l4proto_gre4 to the nf_conntrack_l4proto_register
>   netfilter: cleanup sysctl for l4proto and l3proto
>   netfilter: add namespace support for cttimeout
>   netfilter: cttimeout use pernet data of l4proto
>
>  include/net/netfilter/nf_conntrack_l3proto.h   |   11 +-
>  include/net/netfilter/nf_conntrack_l4proto.h   |   32 ++-
>  include/net/netns/conntrack.h                  |   55 ++++
>  net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  127 ++++++---
>  net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |   55 +++-
>  net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   88 ++++--
>  net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   38 ++-
>  net/netfilter/nf_conntrack_core.c              |    7 +-
>  net/netfilter/nf_conntrack_proto.c             |  390 ++++++++++++++----------
>  net/netfilter/nf_conntrack_proto_dccp.c        |  141 +++++----
>  net/netfilter/nf_conntrack_proto_generic.c     |   69 ++++-
>  net/netfilter/nf_conntrack_proto_gre.c         |   66 +++--
>  net/netfilter/nf_conntrack_proto_sctp.c        |  157 +++++++---
>  net/netfilter/nf_conntrack_proto_tcp.c         |  136 ++++++---
>  net/netfilter/nf_conntrack_proto_udp.c         |   90 ++++--
>  net/netfilter/nf_conntrack_proto_udplite.c     |  125 ++++++--
>  net/netfilter/nfnetlink_cttimeout.c            |   13 +-
>  17 files changed, 1068 insertions(+), 532 deletions(-)
