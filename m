From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: alignment faults in 3.6
Date: Fri, 12 Oct 2012 12:07:50 +0100
Message-ID: <20121012110750.GE21164@n2100.arm.linux.org.uk>
References: <20121005082439.GF4625@n2100.arm.linux.org.uk> <AE90C24D6B3A694183C094C60CF0A2F6026B703E@saturn3.aculab.com> <yw1xtxu1nfsn.fsf@unicorn.mansr.com> <201210120811.43290.arnd@arndb.de> <20121012090321.GA21164@n2100.arm.linux.org.uk> <yw1xhaq0nefg.fsf@unicorn.mansr.com>
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
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:51029 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751598Ab2JLLII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 07:08:08 -0400
Content-Disposition: inline
In-Reply-To: <yw1xhaq0nefg.fsf@unicorn.mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 12, 2012 at 12:00:03PM +0100, M=E5ns Rullg=E5rd wrote:
> Russell King - ARM Linux <linux@arm.linux.org.uk> writes:
>=20
> > On Fri, Oct 12, 2012 at 08:11:42AM +0000, Arnd Bergmann wrote:
> >> On Thursday 11 October 2012, M=E5ns Rullg=E5rd wrote:
> >> > > But, the IP header is expected to be aligned.
> >> >=20
> >> > Everything tells the compiler the struct is perfectly aligned.  =
When the
> >> > buggy driver passes a misaligned pointer, bad things happen.
> >>=20
> >> Would it be appropriate to add a WARN_ON_ONCE() in the alignment f=
ault path
> >> then?
>=20
> I think that's an excellent idea.

Well, I get the last word here and it's no.

> >> If all alignment faults in the kernel are caused by broken drivers=
,
> >> that would at least give us some hope of finding those drivers whi=
le
> >> at the same time not causing much overhead in the case where we ne=
ed
> >> to do the fixup in the meantime.
> >
> > No.  It is my understanding that various IP option processing can a=
lso
> > cause the alignment fault handler to be invoked, even when the pack=
et is
> > properly aligned, and then there's jffs2/mtd which also relies upon
> > alignment faults being fixed up.
>=20
> As far as I'm concerned, this is all hearsay, and I've only ever hear=
d
> it from you.  Why can't you let those who care fix these bugs instead=
?

You know, I'm giving you the benefit of my _knowledge_ which has been
built over the course of the last 20 years.  I've been in these
discussions with networking people before.  I ended up having to develo=
p
the alignment fault handler because of those discussions.  And oh look,
Eric confirmed that the networking code isn't going to get "fixed" as
you were demanding, which is exactly what I said.

I've been in discussions with MTD people over these issues before, I've
discussed this with David Woodhouse when it came up in JFFS2.  I *KNOW*
these things.

You can call it hearsay if you wish, but it seems to be more accurate
than your wild outlandish and pathetic statements.
