From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next-2.6 PATCH 2/5] ixgbe: drop support for UDP in RSS hash
 generation
Date: Tue, 20 Jul 2010 09:11:50 -0700
Message-ID: <4C45CAC6.1050006@intel.com>
References: <20100719235831.14112.14175.stgit@localhost.localdomain>	 <20100719235925.14112.65890.stgit@localhost.localdomain> <1279607980.2458.82.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"bphilips@novell.com" <bphilips@novell.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35844 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753840Ab0GTQMD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jul 2010 12:12:03 -0400
In-Reply-To: <1279607980.2458.82.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le lundi 19 juillet 2010 =C3=A0 16:59 -0700, Jeff Kirsher a =C3=A9cri=
t :
>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>>
>> This change removes UDP from the supported protocols for RSS hashing=
=2E  The
>> reason for removing this protocol is because IP fragmentation was ca=
using a
>> network flow to be broken into two streams, one for fragmented, and =
one for
>> non-fragmented and this in turn was causing out-of-order issues.
>>
>=20
> Jeff, does it mean all UDP packets are going to be delivered to a sin=
gle
> queue ?
>=20
> This would be a serious regression.
>=20
> Many UDP applications try hard to not use fragments.=20
>=20
> They are going to pay the price because some application :
> - Use big segments, fragmented.
> - Is subject to OOO artifacts.
>=20
> We would like some clarifications please :)
>=20
>=20
>=20

The packets will still be hashed on source and destination IPv4/IPv6=20
addresses.  The change just drops reading the UDP source/destination=20
ports since in the case of fragmented packets they are not available an=
d=20
as such were being parsed as IPv4/IPv6 packets.  By making this change=20
the queue selection is consistent between all packets in the UDP stream=
=2E

The only regression I would expect to see would be in testing between=20
two fixed systems since the IP addresses of the two systems would be=20
fixed and so running multiple flows between the two would yield the sam=
e=20
  RSS hash for multiple UDP streams.  As long as multiple ip addresses=20
are used  you should see multiple RSS hashes generated and as such the=20
load should still be distributed.

Thanks,

Alex
