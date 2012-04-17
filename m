From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 00/12] add namespace support for netfilter protos
Date: Tue, 17 Apr 2012 10:52:09 +0200
Message-ID: <20120417085209.GA2100@1984>
References: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, serge.hallyn@canonical.com,
	dlezcano@fr.ibm.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Gao,

On Tue, Apr 17, 2012 at 10:56:11AM +0800, Gao feng wrote:
> Currently the sysctl of netfilter proto is not isolated, so when 
> changing proto's sysctl in container will cause the host's sysctl 
> be changed too. it's not expected.
> 
> This patch set adds the namespace support for netfilter protos.
> 
> impletement four pernet_operations to register sysctl,and disable 
> register sysctl when protos are registered.

This indeed needs to be fixed, but this patchset has several
deficiencies. I'll spot them in follow-up emails.

> nf_conntrack_net_proto_ipv4_ops is used to register tcp4(compat),
> udp4(compat),icmp(compat),ipv4(compat).
> nf_conntrack_net_proto_ipv6_ops is used to register tcp6,udp6 and 
> icmpv6.
> nf_conntrack_net_proto_sctp_ops is used to register sctp4(compat) 
> and sctp6.
> nf_conntrack_net_proto_udplite_ops is used to register udplite4
> and udplite6
> 
> these operations will be registered when module be loaded.
> 
> And this will break the cttimeout, because timeout_nlattr_to_obj
> function use the orig timeout(such as tcp_timeouts) to set timeouts.
> 
> I will fix this in my next patch.

No way.

You cannot leave the repository in broken / inconsistent state because
you are not making things good.

Please, hang on until this patchset is fixed to send more patches.
