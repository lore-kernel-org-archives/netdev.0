From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: sys_paccept: disable paccept() until API design is resolved
Date: Wed, 17 Sep 2008 09:50:58 +0300
Message-ID: <200809170950.58844.remi.denis-courmont@nokia.com>
References: <48CFA10D.2010106@gmail.com> <48D03E85.9030808@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Kerrisk <mtk.manpages@googlemail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Davide Libenzi <davidel@xmailserver.org>,
	Alan Cox <alan@redhat.com>, Jakub Jelinek <jakub@redhat.com>,
	lkml <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	Roland McGrath <roland@redhat.com>,
	Oleg Nesterov <oleg@tv-sign.ru>, Christoph Hellwig <hch@lst.de>
To: "ext Ulrich Drepper" <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:37310 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357AbYIQGvn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2008 02:51:43 -0400
In-Reply-To: <48D03E85.9030808@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 17 September 2008 02:17:25 ext Ulrich Drepper, you wrote:
> It would unnecessarily require programs to be changed.  I've explaine=
d
> that programs cannot efficiently use accept() and poll() when multipl=
e
> threads are involved.  This means in these situations you'll find a
> single thread handling only the accept() calls.

Hmm. In a multithreaded program, it makes a lot of sense to use blockin=
g I/O=20
in general - not just blocking accept(). Of course, this assumes that t=
here=20
is only one file descriptor to wait on at a time. This is not necessari=
ly=20
true for I/O, nor is it for accept(). For instance, modern TCP servers =
should=20
have an IPv4 and an IPv6 socket to accept() from...

If the code path is such that only one file descriptor is being waited =
on at a=20
time, then using blocking I/O halves the number of syscalls, and thirds=
 the=20
number of context switch between hardware packet reception, and userlan=
d data=20
deliver (3 to 1).

> > * The use of a sigset argument is not consistent with other I/O API=
s
> >   that can block on a single file descriptor (e.g., read(), recv(),
> >   connect()).
>
> This is because none of the other interfaces had (so far) be revised.
> With this flawed argumentation you'd prevent any program ever to be m=
ade.

Right.

Then again... Why not recommend threaded programs to use sigwait() in a=
=20
dedicated task and give up on the asynchronous signal handlers complete=
ly?

--=20
R=C3=A9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
