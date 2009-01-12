From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: RFC: Network privilege separation.
Date: Mon, 12 Jan 2009 22:15:27 +0200
Message-ID: <200901122215.27842.rdenis@simphalempin.com>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <200901122147.57731.rdenis@simphalempin.com> <20090112201435.GC23848@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Valdis.Kletnieks@vt.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Michael Stone <michael@laptop.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:60314 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750780AbZALUPc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 15:15:32 -0500
In-Reply-To: <20090112201435.GC23848@one.firstfloor.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 12 janvier 2009 22:14:35 Andi Kleen, vous avez =E9crit=A0:
> > Expanding the heap,
>
> That's a problem agreed  Ok you can just always use very
> bss arrays sized for the worst case.
>
> > Getting timestamps.
>
> At least on 64bit that's done in ring 3 only with a vsyscall.
>
> > Waiting on futexes,
> > catching signals, polling file descriptors. Seeking, doing vectoriz=
ed
> > I/O. Cloning.
>
> That all can be done by the frontend reading/feeding
> data into the pipe. But it shouldn't directly access the user data
> to be immune against attacks.

What's the point of writing a parser (that could also have bugs) when t=
he=20
kernel can do it? One could argue that shared futexes could be dangerou=
s, but=20
not the rest?

> > Codecs don't like to read/write raw video through a pipe...
>
> I don't think that's given. It would need some restructuring,
> but I think the end result would be likely worth it.

A normal DVD would be over 30 megabytes per seconds once decoded, just =
for the=20
video. And remember vmsplice() is not allowed by SECCOMP. Media players=
 have=20
assembly-coded memory copy optimizations (like the kernel) for some rea=
son.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
