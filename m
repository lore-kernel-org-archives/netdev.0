From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH v2 00/17] netfilter: add namespace support for netfilter
 protos
Date: Tue, 08 May 2012 08:53:56 +0800
Message-ID: <4FA86EA4.6000903@cn.fujitsu.com>
References: <1335519484-6089-1-git-send-email-gaofeng@cn.fujitsu.com> <20120507231955.GA5716@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:26500 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755631Ab2EHAx0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2012 20:53:26 -0400
In-Reply-To: <20120507231955.GA5716@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,Pablo

=E4=BA=8E 2012=E5=B9=B405=E6=9C=8808=E6=97=A5 07:19, Pablo Neira Ayuso =
=E5=86=99=E9=81=93:
> Hi,
>=20
> On Fri, Apr 27, 2012 at 05:37:47PM +0800, Gao feng wrote:
>> Currently the sysctl of netfilter proto is not isolated, so when
>> changing proto's sysctl in container will cause the host's sysctl
>> be changed too. it's not expected.
>>
>> This patch set adds the namespace support for netfilter protos.
>>
>> impletement four pernet_operations to register sysctl and initial
>> pernet data for proto.
>>
>> -ipv4_net_ops is used to register tcp4(compat),
>>  udp4(compat),icmp(compat),ipv4(compat).
>> -ipv6_net_ops is used to register tcp6,udp6 and icmpv6.
>> -sctp_net_ops is used to register sctp4(compat) and sctp6.
>> -udplite_net_ops is used to register udplite4 and udplite6
>>
>> extern l[3,4]proto (sysctl) register functions to make them support
>> namespace.
>>
>> finailly add namespace support for cttimeout.
>>
>> Gao feng (17):
>>   netfilter: add struct nf_proto_net for register l4proto sysctl
>>   netfilter: add namespace support for l4proto
>>   netfilter: add namespace support for l3proto
>>   netfilter: add namespace support for l4proto_generic
>>   netfilter: add namespace support for l4proto_tcp
>>   netfilter: add namespace support for l4proto_udp
>>   netfilter: add namespace support for l4proto_icmp
>>   netfilter: add namespace support for l4proto_icmpv6
>>   netfilter: add namespace support for l3proto_ipv4
>>   netfilter: add namespace support for l3proto_ipv6
>>   netfilter: add namespace support for l4proto_sctp
>>   netfilter: add namespace support for l4proto_udplite
>>   netfilter: adjust l4proto_dccp to the nf_conntrack_l4proto_registe=
r
>>   netfilter: adjust l4proto_gre4 to the nf_conntrack_l4proto_registe=
r
>>   netfilter: cleanup sysctl for l4proto and l3proto
>>   netfilter: add namespace support for cttimeout
>>   netfilter: cttimeout use pernet data of l4proto
>=20
> I've been having a look at this patchset several times since last
> week. The logic that it follows to split changes into patches is not
> correct. This breaks the compilation of my tree since patch 2 until
> the entire patchset is applied.
>=20
> This has to start by one patch that adds the basic infrastructure to
> register the layer 3 and 4 conntrack timeout per-net support and it
> prepares the per-protocol per-net support. This implies to
> propagate the minimal set of changes to make sure it compiles, ie.
> modify clients to use the new interface to register init_net.
>=20
> Then, follow-up per-protocol patches that use the new infrastructure
> implement the per-protocol support. All this without breaking the
> compilation of my tree between patches.

Okay,I will fix this as you said,and do you have some comments about
the logic of this patchset?

>=20
> I'm all for fixing the existing unfinished container support for
> Netfilter, but this needs to be done appropriately.

I'm happy to see this.

> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-d=
evel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
