From: David Miller <davem@davemloft.net>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Thu, 11 Jun 2009 04:57:21 -0700 (PDT)
Message-ID: <20090611.045721.05821546.davem@davemloft.net>
References: <15ddcffd0906100318u2a61b7d8g991fe52439e07928@mail.gmail.com>
	<20090610.050122.261415364.davem@davemloft.net>
	<15ddcffd0906110445x25e2b2c5qa8445e0e1b344ef4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rdreier@cisco.com, cl@linux-foundation.org, netdev@vger.kernel.org,
	yosefe@voltaire.com
To: or.gerlitz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48058
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751893AbZFKL5T convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 07:57:19 -0400
In-Reply-To: <15ddcffd0906110445x25e2b2c5qa8445e0e1b344ef4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Or Gerlitz <or.gerlitz@gmail.com>
Date: Thu, 11 Jun 2009 14:45:28 +0300

> On Wed, Jun 10, 2009 at 3:01 PM, David Miller<davem@davemloft.net> wr=
ote:
>> From: Or Gerlitz <or.gerlitz@gmail.com>
>=20
>>> for --unicast-- the same problem [...] will come into play under bo=
th Ethernet and IB,
>>> so the user is limited by the socket buffer len and the neigh unres=
_qlen systcl.
>=20
>> But this generally does not cause problems via ARP, why might that
>> be?  Because resolution is 1) rare 2) quick. =A0Both of which do not
>> apply to this IPoIB case.
>=20
> To be precise, I don't see why ARP resolution is more rare then
> joining to a multicast group on behalf of a sender in IPoIB, they
> both happen on the first and if/when the kernel deletes the
> neighbour.

There are two issues:

1) Ethernet does not have to "resolve" anything for multicast sends.
   Therefore this issue is IPoIB specific.

2) ARP's tend to resolve on the DNS request for the site, or the
   initial connection attempt.  Both of which are single packets,
   easily retransmitted, and the dropping of which does not result in
   losing significant application data.  The multicast case over IPoIB
   does drop tons of actual application data.
