From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: alignment faults in 3.6
Date: Thu, 11 Oct 2012 17:18:16 +0100
Message-ID: <yw1xtxu1nfsn.fsf@unicorn.mansr.com>
References: <20121005082439.GF4625@n2100.arm.linux.org.uk>
	<20121011103257.GO4625@n2100.arm.linux.org.uk>
	<1349952574.21172.8604.camel@edumazet-glaptop>
	<201210111228.25995.arnd@arndb.de>
	<1349959248.21172.8970.camel@edumazet-glaptop>
	<5076C78E.1020408@gmail.com>
	<1349963227.21172.9188.camel@edumazet-glaptop>
	<5076E472.8030703@gmail.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B703E@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rob Herring" <robherring2@gmail.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"Arnd Bergmann" <arnd@arndb.de>,
	<linux-arm-kernel@lists.infradead.org>,
	"Russell King - ARM Linux" <linux@arm.linux.org.uk>,
	"Jon Masters" <jonathan@jonmasters.org>, <netdev@vger.kernel.org>,
	=?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
To: "David Laight" <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([78.86.181.103]:43106 "EHLO
	unicorn.mansr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756632Ab2JKQSS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 12:18:18 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B703E@saturn3.aculab.com>
	(David Laight's message of "Thu, 11 Oct 2012 16:39:38 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"David Laight" <David.Laight@ACULAB.COM> writes:

>> Not exactly. It is asked to to perform 2 32-bit loads which are comb=
ined
>> into a single ldm (load multiple) which cannot handle unaligned
>> accesses. Here's a simple example that does the same thing:
>>=20
>> void test(char * buf)
>> {
>> 	printf("%d, %d\n", *((unsigned int *)&buf[0]), *((unsigned int *)&b=
uf[4]));
>> }
>
> Have you actually looked at what an ARM processor traditionally did
> with misaligned memory reads?
> While useful, it probably wasn't what was intended.
>
> Actually, and IIRC, some very recent ARM cpus will do the 'expected'
> thing for single-word loads from misaligned addesses.

What various CPUs do with unaligned accesses is not the issue here.  Th=
e
casts in the code above act as a promise to the compiler that the
address is in fact properly align for the pointer type.

> However they almost certainly won't for ldm/stm.
>
> The 'ldm' optimisation for adjacent memory loads is also dubious.

There is nothing whatsoever dubious about the compiler using the most
efficient instruction sequence to accomplish what the code asks for.

> On at least some ARMs it is very slow (might only be strongarms).

The compiler will pick instructions suitable for the CPU you specify.

>> So I guess the only ABI legal unaligned access is in a packed struct=
=2E
>
> Correct. And you mustn't try casting the address, the compiler is
> allowed to remember where it came from.
> (This causes a lot of grief...)

It is only a problem when you try to outsmart the compiler.

> If you are targeting the ARM cpu that can do misaligned transfers,
> then gcc should generate single instructions for misaligned structure
> members, and never do the 'ldm' optimisations.

That is exactly how gcc works.

> But, the IP header is expected to be aligned.

Everything tells the compiler the struct is perfectly aligned.  When th=
e
buggy driver passes a misaligned pointer, bad things happen.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
