From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2 00/17] netfilter: add namespace support for
 netfilter protos
Date: Tue, 8 May 2012 01:19:55 +0200
Message-ID: <20120507231955.GA5716@1984>
References: <1335519484-6089-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1335519484-6089-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Fri, Apr 27, 2012 at 05:37:47PM +0800, Gao feng wrote:
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
>
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

I've been having a look at this patchset several times since last
week. The logic that it follows to split changes into patches is not
correct. This breaks the compilation of my tree since patch 2 until
the entire patchset is applied.

This has to start by one patch that adds the basic infrastructure to
register the layer 3 and 4 conntrack timeout per-net support and it
prepares the per-protocol per-net support. This implies to
propagate the minimal set of changes to make sure it compiles, ie.
modify clients to use the new interface to register init_net.

Then, follow-up per-protocol patches that use the new infrastructure
implement the per-protocol support. All this without breaking the
compilation of my tree between patches.

I'm all for fixing the existing unfinished container support for
Netfilter, but this needs to be done appropriately.
