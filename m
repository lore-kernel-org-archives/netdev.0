From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: alignment faults in 3.6
Date: Fri, 12 Oct 2012 13:16:28 +0100
Message-ID: <yw1x4nlzopgj.fsf@unicorn.mansr.com>
References: <20121005082439.GF4625@n2100.arm.linux.org.uk>
	<AE90C24D6B3A694183C094C60CF0A2F6026B703E@saturn3.aculab.com>
	<yw1xtxu1nfsn.fsf@unicorn.mansr.com>
	<201210120811.43290.arnd@arndb.de>
	<20121012090321.GA21164@n2100.arm.linux.org.uk>
	<yw1xhaq0nefg.fsf@unicorn.mansr.com>
	<20121012110750.GE21164@n2100.arm.linux.org.uk>
	<yw1x8vbcndlb.fsf@unicorn.mansr.com>
	<20121012114443.GG21164@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>,
	Arnd Bergmann <arnd@arndb.de>,
	linux-arm-kernel@lists.infradead.org,
	David Laight <David.Laight@aculab.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Jon Masters <jonathan@jonmasters.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([78.86.181.103]:52749 "EHLO
	unicorn.mansr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758977Ab2JLMQa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 08:16:30 -0400
In-Reply-To: <20121012114443.GG21164@n2100.arm.linux.org.uk> (Russell King's
	message of "Fri, 12 Oct 2012 12:44:43 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Russell King - ARM Linux <linux@arm.linux.org.uk> writes:

> On Fri, Oct 12, 2012 at 12:18:08PM +0100, M=E5ns Rullg=E5rd wrote:
>> Russell King - ARM Linux <linux@arm.linux.org.uk> writes:
>> > Well, I get the last word here and it's no.
>>=20
>> Sadly, yes.
>
> It's not "sadly" - it's a matter of fact that the kernel does from ti=
me
> to time generate misaligned accesses and they are _not_ bugs.  If the=
y
> were bugs, then the code to fix up misaligned accesses would not have
> been developed, and we'd instead take the fault and panic or somethin=
g
> like that.
>
>> >> >> If all alignment faults in the kernel are caused by broken dri=
vers,
>> >> >> that would at least give us some hope of finding those drivers=
 while
>> >> >> at the same time not causing much overhead in the case where w=
e need
>> >> >> to do the fixup in the meantime.
>> >> >
>> >> > No.  It is my understanding that various IP option processing c=
an also
>> >> > cause the alignment fault handler to be invoked, even when the =
packet is
>> >> > properly aligned, and then there's jffs2/mtd which also relies =
upon
>> >> > alignment faults being fixed up.
>> >>=20
>> >> As far as I'm concerned, this is all hearsay, and I've only ever =
heard
>> >> it from you.  Why can't you let those who care fix these bugs ins=
tead?
>> >
>> > You know, I'm giving you the benefit of my _knowledge_ which has b=
een
>> > built over the course of the last 20 years.
>>=20
>> How proud you sound.  Now could you say something of substance inste=
ad?
>
> You're proving yourself to be idiot?  There, that's substance.
>
>> > I've been in these discussions with networking people before.  I e=
nded
>> > up having to develop the alignment fault handler because of those
>> > discussions.  And oh look, Eric confirmed that the networking code
>> > isn't going to get "fixed" as you were demanding, which is exactly
>> > what I said.
>>=20
>> Funny, I saw him say the exact opposite:
>>=20
>>   So if you find an offender, please report a bug, because I can
>>   guarantee you we will _fix_ it.
>
> No, let's go back.
>
> - You were demanding that the ipv4 header structure should be packed.

I demanded no such thing.

>   I said that wasn't going to happen because the networking people
>   wouldn't allow it, and it seems that's been proven correct.
> - You were demanding that the ipv4 code used the unaligned accessors.

Again, I made no such demand.

>   I said that networking people wouldn't allow it either, and that's
>   also been proven correct.

I did not, in fact, _demand_ anything at all.  What I did say was that
to fix the problem of unaligned access traps the OP was having, the
(driver) code supplying the unaligned pointer should be fixed, or *if
that is not possible* mark the structs __packed.  As it turns out,
fixing the driver is easy, so there is no need to change the structs or
how they are accessed.

> Both these points have been proven correct because Eric has said that=
 the
> core networking code is _not_ going to be changed to suit this.
>
> What Eric _has_ said is that networking people consider packets suppl=
ied
> to the networking layer where the IPv4 header is not aligned on archi=
tectures
> where misaligned accesses are a problem to be a bug in the network dr=
iver,
> not the network code, and proposed a solution.
>
> That's entirely different from all your claims that the core networki=
ng
> code needs fixing to avoid these misaligned accesses.

I never said that.  I said whatever code is responsible for the pointer
should be fixed.  That code turns out to be the driver.

>> > I've been in discussions with MTD people over these issues before,=
 I've
>> > discussed this with David Woodhouse when it came up in JFFS2.  I *=
KNOW*
>> > these things.
>>=20
>> In the same way you "know" the networking people won't fix their cod=
e,
>> despite them _clearly_ stating the opposite?
>
> I'll tell you exactly how I *KNOW* this.  The issue came up because o=
f
> noMMU, which does not have any way to fix up alignment faults.  JFFS2
> passes randomly aligned buffers to the MTD drivers, and the MTD drive=
rs
> assume that they're aligned and they do word accesses on them.

So jffs2 is broken.  Why can't it be fixed?

> See the thread http://lists.arm.linux.org.uk/lurker/thread/20021204.1=
91632.4473796b.en.html

That thread is about detecting misaligned accesses and what to do with
them if they do occur.  I don't see anyone successfully arguing against
fixing the code causing them.

> See: http://lists.arm.linux.org.uk/lurker/message/20020225.195925.02b=
dbd47.en.html

Yes, there seems to be a problem in jffs2.  Or at least there was one 1=
0
years ago.

> and: http://lists.arm.linux.org.uk/lurker/message/20020313.150932.081=
a7592.en.html

Yes, disabling the alignment trap on armv5 is a bad idea.  Nobody has
argued otherwise.

> There's several other threads where it's also discussed.
>
> And while you're there, note the date.  There is nothing recent about=
 this
> issue.  It's well known, and well understood by those who have a gras=
p of
> the issues that alignment faults are a part of normal operation by th=
e
> ARM kernel - and is one of the penalties of being tied into architect=
ure
> independent code.
>
> Compromises have to be sought, and that's the compromise we get to li=
ve
> with.

So because of some ancient history with jffs2, we should deny
present-day developers the tools to quickly identify problems in their
code?  I just _love_ such compromises.

>> > You can call it hearsay if you wish, but it seems to be more accur=
ate
>> > than your wild outlandish and pathetic statements.
>>=20
>> So you're resorting to name-calling.  Not taking that bait.
>
> Sorry?  So what you're saying is that it's fine for you to call my
> comments hearsay, but I'm not allowed to express a view on your comme=
nts.
> How arrogant of you.

Go ahead, pile it on.  I'm not falling into this trap.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
