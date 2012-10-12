From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: alignment faults in 3.6
Date: Fri, 12 Oct 2012 12:44:43 +0100
Message-ID: <20121012114443.GG21164@n2100.arm.linux.org.uk>
References: <20121005082439.GF4625@n2100.arm.linux.org.uk> <AE90C24D6B3A694183C094C60CF0A2F6026B703E@saturn3.aculab.com> <yw1xtxu1nfsn.fsf@unicorn.mansr.com> <201210120811.43290.arnd@arndb.de> <20121012090321.GA21164@n2100.arm.linux.org.uk> <yw1xhaq0nefg.fsf@unicorn.mansr.com> <20121012110750.GE21164@n2100.arm.linux.org.uk> <yw1x8vbcndlb.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnd Bergmann <arnd@arndb.de>,
	linux-arm-kernel@lists.infradead.org,
	David Laight <David.Laight@aculab.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Jon Masters <jonathan@jonmasters.org>
To: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:51066 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758980Ab2JLLpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 07:45:05 -0400
Content-Disposition: inline
In-Reply-To: <yw1x8vbcndlb.fsf@unicorn.mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 12, 2012 at 12:18:08PM +0100, M=E5ns Rullg=E5rd wrote:
> Russell King - ARM Linux <linux@arm.linux.org.uk> writes:
> > Well, I get the last word here and it's no.
>=20
> Sadly, yes.

It's not "sadly" - it's a matter of fact that the kernel does from time
to time generate misaligned accesses and they are _not_ bugs.  If they
were bugs, then the code to fix up misaligned accesses would not have
been developed, and we'd instead take the fault and panic or something
like that.

> >> >> If all alignment faults in the kernel are caused by broken driv=
ers,
> >> >> that would at least give us some hope of finding those drivers =
while
> >> >> at the same time not causing much overhead in the case where we=
 need
> >> >> to do the fixup in the meantime.
> >> >
> >> > No.  It is my understanding that various IP option processing ca=
n also
> >> > cause the alignment fault handler to be invoked, even when the p=
acket is
> >> > properly aligned, and then there's jffs2/mtd which also relies u=
pon
> >> > alignment faults being fixed up.
> >>=20
> >> As far as I'm concerned, this is all hearsay, and I've only ever h=
eard
> >> it from you.  Why can't you let those who care fix these bugs inst=
ead?
> >
> > You know, I'm giving you the benefit of my _knowledge_ which has be=
en
> > built over the course of the last 20 years.
>=20
> How proud you sound.  Now could you say something of substance instea=
d?

You're proving yourself to be idiot?  There, that's substance.

> > I've been in these discussions with networking people before.  I en=
ded
> > up having to develop the alignment fault handler because of those
> > discussions.  And oh look, Eric confirmed that the networking code
> > isn't going to get "fixed" as you were demanding, which is exactly
> > what I said.
>=20
> Funny, I saw him say the exact opposite:
>=20
>   So if you find an offender, please report a bug, because I can
>   guarantee you we will _fix_ it.

No, let's go back.

- You were demanding that the ipv4 header structure should be packed.
  I said that wasn't going to happen because the networking people
  wouldn't allow it, and it seems that's been proven correct.
- You were demanding that the ipv4 code used the unaligned accessors.
  I said that networking people wouldn't allow it either, and that's
  also been proven correct.

Both these points have been proven correct because Eric has said that t=
he
core networking code is _not_ going to be changed to suit this.

What Eric _has_ said is that networking people consider packets supplie=
d
to the networking layer where the IPv4 header is not aligned on archite=
ctures
where misaligned accesses are a problem to be a bug in the network driv=
er,
not the network code, and proposed a solution.

That's entirely different from all your claims that the core networking
code needs fixing to avoid these misaligned accesses.

> > I've been in discussions with MTD people over these issues before, =
I've
> > discussed this with David Woodhouse when it came up in JFFS2.  I *K=
NOW*
> > these things.
>=20
> In the same way you "know" the networking people won't fix their code=
,
> despite them _clearly_ stating the opposite?

I'll tell you exactly how I *KNOW* this.  The issue came up because of
noMMU, which does not have any way to fix up alignment faults.  JFFS2
passes randomly aligned buffers to the MTD drivers, and the MTD drivers
assume that they're aligned and they do word accesses on them.

See the thread http://lists.arm.linux.org.uk/lurker/thread/20021204.191=
632.4473796b.en.html

See: http://lists.arm.linux.org.uk/lurker/message/20020225.195925.02bdb=
d47.en.html
and: http://lists.arm.linux.org.uk/lurker/message/20020313.150932.081a7=
592.en.html

There's several other threads where it's also discussed.

And while you're there, note the date.  There is nothing recent about t=
his
issue.  It's well known, and well understood by those who have a grasp =
of
the issues that alignment faults are a part of normal operation by the
ARM kernel - and is one of the penalties of being tied into architectur=
e
independent code.

Compromises have to be sought, and that's the compromise we get to live
with.

> > You can call it hearsay if you wish, but it seems to be more accura=
te
> > than your wild outlandish and pathetic statements.
>=20
> So you're resorting to name-calling.  Not taking that bait.

Sorry?  So what you're saying is that it's fine for you to call my
comments hearsay, but I'm not allowed to express a view on your comment=
s.
How arrogant of you.
