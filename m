From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: alignment faults in 3.6
Date: Fri, 12 Oct 2012 10:03:21 +0100
Message-ID: <20121012090321.GA21164@n2100.arm.linux.org.uk>
References: <20121005082439.GF4625@n2100.arm.linux.org.uk> <AE90C24D6B3A694183C094C60CF0A2F6026B703E@saturn3.aculab.com> <yw1xtxu1nfsn.fsf@unicorn.mansr.com> <201210120811.43290.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org,
	=?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>,
	David Laight <David.Laight@aculab.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Jon Masters <jonathan@jonmasters.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:50925 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756902Ab2JLJDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 05:03:42 -0400
Content-Disposition: inline
In-Reply-To: <201210120811.43290.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 12, 2012 at 08:11:42AM +0000, Arnd Bergmann wrote:
> On Thursday 11 October 2012, M=E5ns Rullg=E5rd wrote:
> > > But, the IP header is expected to be aligned.
> >=20
> > Everything tells the compiler the struct is perfectly aligned.  Whe=
n the
> > buggy driver passes a misaligned pointer, bad things happen.
>=20
> Would it be appropriate to add a WARN_ON_ONCE() in the alignment faul=
t path
> then? If all alignment faults in the kernel are caused by broken driv=
ers,
> that would at least give us some hope of finding those drivers while =
at the
> same time not causing much overhead in the case where we need to do t=
he
> fixup in the meantime.

No.  It is my understanding that various IP option processing can also
cause the alignment fault handler to be invoked, even when the packet i=
s
properly aligned, and then there's jffs2/mtd which also relies upon
alignment faults being fixed up.
