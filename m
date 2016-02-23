From: Edward Cree <ecree@solarflare.com>
Subject: Re: [net-next PATCH 0/2] GENEVE/VXLAN: Enable outer Tx checksum by
 default
Date: Tue, 23 Feb 2016 17:38:28 +0000
Message-ID: <56CC9914.5010506@solarflare.com>
References: <20160219191806.15687.37621.stgit@localhost.localdomain>
 <CAEh+42jHjEqjEyN3-OopZK2hAowh4LGKSgZWgSe9+W1zdezpZA@mail.gmail.com>
 <CAMt9YRrOxCmJbrftixdJTXZcySZ_mARqCT6C=4-Nqv_ZJKnTwA@mail.gmail.com>
 <CAEh+42hStEh=5z8KBic0hmEZNti4tjahySjjv7kU3YUes_R4Zg@mail.gmail.com>
 <CALx6S351KYGFFLi08cX=DFCucZtGJLoMJGvFAW1_H-cRXZ0rQg@mail.gmail.com>
 <CAEh+42hEVQOFaFk7BW=wZ-gb9HCfYqbr7Q600gbm1q1Oz+yZcA@mail.gmail.com>
 <CALx6S36EyzjWKi_iK_uAVcCceFnZe3QmLcw7BBejKuB79Uo7PA@mail.gmail.com>
 <CAEh+42hzkW6i+M52iDAyFtCBfxcJJmsZOiNdqd-DqYrN5isMBw@mail.gmail.com>
 <56CC7848.2000704@solarflare.com>
 <CALx6S34Pt++Kg=cp+v+gGFQGEDy=eNHtFvtBwd1z-1d2ixOn7Q@mail.gmail.com>
 <56CC94D9.4030308@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Gross <jesse@kernel.org>, Alex Duyck <aduyck@mirantis.com>,
	"Linux Kernel Network Developers" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Rick Jones <rick.jones2@hpe.com>, Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:23409 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752114AbcBWR4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 12:56:52 -0500
In-Reply-To: <56CC94D9.4030308@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/02/16 17:20, Rick Jones wrote:
> On 02/23/2016 08:47 AM, Tom Herbert wrote:
>> Right, GRO should probably not coalesce packets with non-zero IP
>> identifiers due to the loss of information. Besides that, RFC6848 sa=
ys
>> the IP identifier should only be set for fragmentation anyway so the=
re
>> shouldn't be any issue and really no need for HW TSO (or LRO) to
>> support that.
>
> You sure that is RFC 6848 "Specifying Civic Address Extensions in the=
 Presence Information Data Format Location Object (PIDF-LO)" ?
PossiblyRFC 6864 "Updated Specification of the IPv4 ID Field".
> In whichever RFC that may be, is it a SHOULD or a MUST, and just how =
many "other" stacks might be setting a non-zero IP ID on fragments with=
 DF set?
"The IPv4 ID field MUST NOT be used for purposes other than fragmentati=
on
 and reassembly."(=C2=A74.1)
"Originating sources MAY set the IPv4 ID field of atomic datagrams to a=
ny
 value."(=C2=A74.1)
"All devices that examine IPv4 headers MUST ignore the IPv4 ID field of
 atomic datagrams."(=C2=A74.1)
Atomic datagrams are defined by "(DF=3D=3D1)&&(MF=3D=3D0)&&(frag_offset=
=3D=3D0)" (=C2=A74).

So it's OK to coalesce packets with different identifiers, as long as t=
hey
have DFset (and aren't fragmented already).  Also, the RFC takes pains =
to
point out that it "does not reserve any IPv4 ID values, including 0, as
distinguished" (=C2=A74.1), so one cannot rely on the ID always being z=
ero.
