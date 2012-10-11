From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: alignment faults in 3.6
Date: Thu, 11 Oct 2012 11:20:10 +0100
Message-ID: <yw1xlifdpaxx.fsf@unicorn.mansr.com>
References: <506E1762.3010601@gmail.com>
	<CANLjY-no-L9=LRCvCetC5XCHicOoSWOfRZmUd7itAiUHWBhAyw@mail.gmail.com>
	<CAG5Tg6Wuybruc31x1eh6mFafsg=7cOgYLgpZUBuJUo75ap3osQ@mail.gmail.com>
	<506E3E58.80703@gmail.com>
	<CAG5Tg6V0Vj9HTy3=AU-q+Qa3DuJs6R1Kw+3uOWU_jOGfkgyXzw@mail.gmail.com>
	<20121005071216.GD4625@n2100.arm.linux.org.uk>
	<CAG5Tg6VciuxJ=k+fatzLugcehF54mGNOLHpUwdMX99oCnAVg8Q@mail.gmail.com>
	<20121005082439.GF4625@n2100.arm.linux.org.uk>
	<506ED18C.3010009@gmail.com>
	<20121005140556.GQ4625@n2100.arm.linux.org.uk>
	<506EEFBB.3060705@gmail.com> <507619FA.6080001@jonmasters.org>
	<yw1xtxu1pwtv.fsf@unicorn.mansr.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B7038@saturn3.aculab.com>
	<yw1xpq4ppcju.fsf@unicorn.mansr.com>
	<1349949638.21172.8445.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Jon Masters <jonathan@jonmasters.org>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([78.86.181.103]:33996 "EHLO
	unicorn.mansr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755258Ab2JKKUL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 06:20:11 -0400
In-Reply-To: <1349949638.21172.8445.camel@edumazet-glaptop> (Eric Dumazet's
	message of "Thu, 11 Oct 2012 12:00:38 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Thu, 2012-10-11 at 10:45 +0100, M=E5ns Rullg=E5rd wrote:
>> "David Laight" <David.Laight@ACULAB.COM> writes:
>>=20
>> >> -----Original Message-----
>> >> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kern=
el.org] On Behalf Of M=E5ns Rullg=E5rd
>> >> Sent: 11 October 2012 03:27
>> >> To: Jon Masters
>> >> Cc: linux-arm-kernel@lists.infradead.org; netdev@vger.kernel.org
>> >> Subject: Re: alignment faults in 3.6
>> >>=20
>> >> Jon Masters <jonathan@jonmasters.org> writes:
>> >>=20
>> >> > Hi everyone,
>> >> >
>> >> > On 10/05/2012 10:33 AM, Rob Herring wrote:
>> >> >> On 10/05/2012 09:05 AM, Russell King - ARM Linux wrote:
>> >> >>> On Fri, Oct 05, 2012 at 07:24:44AM -0500, Rob Herring wrote:
>> >> >>>> On 10/05/2012 03:24 AM, Russell King - ARM Linux wrote:
>> >> >>>>> Does it matter?  I'm just relaying the argument against add=
ing __packed
>> >> >>>>> which was used before we were forced (by the networking fol=
k) to implement
>> >> >>>>> the alignment fault handler.
>> >> >>>>
>> >> >>>> It doesn't really matter what will be accepted or not as add=
ing __packed
>> >> >>>> to struct iphdr doesn't fix the problem anyway.=20
>> > ...
>> >> There are exactly two possible solutions:
>> >>=20
>> >> 1. Change the networking code so those structs are always aligned=
=2E  This
>> >>    might not be (easily) possible.
>> >> 2. Mark the structs __packed and fix any typecasts like the ones =
seen in
>> >>    this thread.  This will have an adverse effect in cases where =
the
>> >>    structs are in fact aligned.
>> >>=20
>> >> Both solutions lie squarely in the networking code.  It's time to
>> >> involve that list, or we'll never get anywhere.
>> >
>> > It might be enough to use __attribute__((aligned(2))) on some stru=
cture
>> > members (actually does 'ldm' need 8 byte alignment?? - in which ca=
se
>> > aligned(4) is enough).
>>=20
>> The aligned attribute can only increase alignment.
>
> I have no idea what is the problem,=20
>
> -ENOTENOUGHCONTEXT

The thread starts here:
http://marc.info/?l=3Dlinux-arm-kernel&m=3D134939228120020

Summary: a pointer to "struct iphdr" is not 4-byte aligned as required
by the ARM ABI rules, and this causes traps to the unaligned access
fault handler.  A recent change makes the kernel print "scheduling whil=
e
atomic" warnings on some of these traps, which may or may not be
benign.  Either way, this is bad for performance and should be fixed on=
e
way or another.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
