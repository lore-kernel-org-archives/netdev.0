From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: alignment faults in 3.6
Date: Thu, 11 Oct 2012 14:32:55 +0100
Message-ID: <yw1x626hp20o.fsf@unicorn.mansr.com>
References: <20121005082439.GF4625@n2100.arm.linux.org.uk>
	<20121011103257.GO4625@n2100.arm.linux.org.uk>
	<1349952574.21172.8604.camel@edumazet-glaptop>
	<201210111228.25995.arnd@arndb.de>
	<1349959248.21172.8970.camel@edumazet-glaptop>
	<5076C78E.1020408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	linux-arm-kernel@lists.infradead.org,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Jon Masters <jonathan@jonmasters.org>, netdev@vger.kernel.org,
	=?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>,
	David Laight <David.Laight@aculab.com>
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([78.86.181.103]:38738 "EHLO
	unicorn.mansr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997Ab2JKNc5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 09:32:57 -0400
In-Reply-To: <5076C78E.1020408@gmail.com> (Rob Herring's message of "Thu, 11
	Oct 2012 08:20:14 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rob Herring <robherring2@gmail.com> writes:

> On 10/11/2012 07:40 AM, Eric Dumazet wrote:
>> On Thu, 2012-10-11 at 12:28 +0000, Arnd Bergmann wrote:
>>=20
>>>
>>> Rob Herring as the original reporter has dropped off the Cc list, a=
dding
>>> him back.
>>>
>>> I assume that the calxeda xgmac driver is the culprit then. It uses
>>> netdev_alloc_skb() rather than netdev_alloc_skb_ip_align() in
>>> xgmac_rx_refill but it is not clear whether it does so intentionall=
y
>>> or by accident.
>
> This in fact does work and eliminates the unaligned traps. However, n=
ot
> all h/w can do IP aligned DMA (i.MX FEC for example), so I still thin=
k
> this is a questionable optimization by the compiler. We're saving 1 l=
oad
> instruction here for data that is likely already in the cache. It may=
 be
> legal per the ABI, but the downside of this optimization is much grea=
ter
> than the upside.

The compiler is working *exactly* as it should.  Merging the loads save=
s
cycles *and* code size.  Many of these added up can make a real differe=
nce.

When writing code, you must follow all the rules, whether you like them
or not.  Without rules, the compiler would be very limited in the
optimisations it could perform.

Unfortunately, new optimisations occasionally uncover broken code
violating some constraint or other.  When this happens, the correct
course of action is to fix the code, not cripple the compiler.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
