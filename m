From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/2] GENEVE/VXLAN: Enable outer Tx checksum by
 default
Date: Tue, 23 Feb 2016 13:08:26 -0500 (EST)
Message-ID: <20160223.130826.608797488173024832.davem@davemloft.net>
References: <CALx6S34Pt++Kg=cp+v+gGFQGEDy=eNHtFvtBwd1z-1d2ixOn7Q@mail.gmail.com>
	<56CC94D9.4030308@hpe.com>
	<56CC9914.5010506@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rick.jones2@hpe.com, tom@herbertland.com, jesse@kernel.org,
	aduyck@mirantis.com, netdev@vger.kernel.org,
	alexander.duyck@gmail.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39756 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754370AbcBWSIa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 13:08:30 -0500
In-Reply-To: <56CC9914.5010506@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Edward Cree <ecree@solarflare.com>
Date: Tue, 23 Feb 2016 17:38:28 +0000

> On 23/02/16 17:20, Rick Jones wrote:
>> On 02/23/2016 08:47 AM, Tom Herbert wrote:
>>> Right, GRO should probably not coalesce packets with non-zero IP
>>> identifiers due to the loss of information. Besides that, RFC6848 s=
ays
>>> the IP identifier should only be set for fragmentation anyway so th=
ere
>>> shouldn't be any issue and really no need for HW TSO (or LRO) to
>>> support that.
>>
>> You sure that is RFC 6848 "Specifying Civic Address Extensions in th=
e Presence Information Data Format Location Object (PIDF-LO)" ?
> PossiblyRFC 6864 "Updated Specification of the IPv4 ID Field".
>> In whichever RFC that may be, is it a SHOULD or a MUST, and just how=
 many "other" stacks might be setting a non-zero IP ID on fragments wit=
h DF set?
> "The IPv4 ID field MUST NOT be used for purposes other than fragmenta=
tion
>  and reassembly."(=A74.1)
> "Originating sources MAY set the IPv4 ID field of atomic datagrams to=
 any
>  value."(=A74.1)
> "All devices that examine IPv4 headers MUST ignore the IPv4 ID field =
of
>  atomic datagrams."(=A74.1)
> Atomic datagrams are defined by "(DF=3D=3D1)&&(MF=3D=3D0)&&(frag_offs=
et=3D=3D0)" (=A74).
>=20
> So it's OK to coalesce packets with different identifiers, as long as=
 they
> have DFset (and aren't fragmented already).  Also, the RFC takes pain=
s to
> point out that it "does not reserve any IPv4 ID values, including 0, =
as
> distinguished" (=A74.1), so one cannot rely on the ID always being ze=
ro.

Just a reminder that a very long time ago we tried setting the IP ID
field to zero for DF packets, and this broke SLHC because that expects
a monotonically increasing IP ID field.
