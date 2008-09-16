From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: sys_paccept: disable paccept() until API design is resolved
Date: Tue, 16 Sep 2008 16:17:25 -0700
Message-ID: <48D03E85.9030808@redhat.com>
References: <48CFA10D.2010106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Davide Libenzi <davidel@xmailserver.org>,
	Alan Cox <alan@redhat.com>, Jakub Jelinek <jakub@redhat.com>,
	lkml <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	Roland McGrath <roland@redhat.com>,
	Oleg Nesterov <oleg@tv-sign.ru>, Christoph Hellwig <hch@lst.de>
To: Michael Kerrisk <mtk.manpages@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33568 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752371AbYIPXVH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2008 19:21:07 -0400
In-Reply-To: <48CFA10D.2010106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Michael Kerrisk wrote:
> The patch below disables the new sys_paccept() for now.  Please
> apply for 2.6.27-rc, so that we do not release this API into
> the wild before a conclusion has been reached about its design.

There is no reason for that.


> The reasons for disabling paccept() are as follows:
>=20
> * The API is more complex than needed.  There is AFAICS no demonstrat=
ed
>   use case that the sigset argument of this syscall serves that
>   couldn't equally be served by the use of pselect/ppoll/epoll_pwait =
+

It would unnecessarily require programs to be changed.  I've explained
that programs cannot efficiently use accept() and poll() when multiple
threads are involved.  This means in these situations you'll find a
single thread handling only the accept() calls.


> * The use of a sigset argument is not consistent with other I/O APIs
>   that can block on a single file descriptor (e.g., read(), recv(),
>   connect()).

This is because none of the other interfaces had (so far) be revised.
With this flawed argumentation you'd prevent any program ever to be mad=
e.


> * The behavior of paccept() when interrupted by a signal is IMO
>   strange:

You use your own opinion as the deciding factor?  The behavior differs
from other uses but is consistent with the accept() behavior.


> I believe that instead, a simpler API, consistent with Ulrich's
> other recent additions, is preferable:
>=20
> accept4(int fd, struct sockaddr *sa, socklen_t *salen, ind flags);

The signal set wasn't actually my idea.  See:

http://marc.info/?l=3Dlinux-kernel&m=3D120909788728078&w=3D2


> At this point, I am hoping we either will get a counter-argument
> from Ulrich about why we really do need paccept()'s sigset argument,
> or that he will resubmit the original accept4() patch.

I have explained the need already. you just chose to ignore it.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iEYEARECAAYFAkjQPoQACgkQ2ijCOnn/RHTNZwCfaXdw5Yhy/chAUMqR2kZE8Rsm
wzUAnA7PtvODGyAMeahl44+mqasqGS1U
=3DGh2E
-----END PGP SIGNATURE-----
