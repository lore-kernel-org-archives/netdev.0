From: mtk-lists@gmx.net
Subject: Re: shutdown() and SHUT_RD on TCP sockets - broken?
Date: Tue, 8 Jul 2003 18:09:14 +0200 (MEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <27084.1057680554@www6.gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

There was no response to the note below.  Is netdev the right place to=20
raise this subject?

Cheers

Michael

------- Forwarded message follows -------
Date sent:      	Tue, 1 Jul 2003 13:23:49 +0200 (MEST)
From:           	mtk-lists@gmx.net
To:             	netdev@oss.sgi.com
BCC to:         	michael.kerrisk@gmx.net
Subject:        	shutdown() and SHUT_RD on TCP sockets - broken?

Hello,

I've done quite some searching, but have so far not found an answer
to the question of why does the behaviour described below occur on=20
Linux...

According to SUSv3, if we perform a shutdown(fd, SHUT_RD) on a socket, th=
en
further reads on that socket should be disabled.  In the AF_UNIX domain,
all is fine -- things operate as I expect.  However, for TCP sockets,
things are different (tested on 2.2.14, and 2.4.20):

1. If we perform a read() on the socket and there is no data, then 0
(EOF) is (immediately) returned.  (This is what I expected.)

2. However, the peer can still write() to the socket, and afterwards
we can read() that data from the socket, even though the reading half
of the socket should be shut down.  Instead of this behaviour, I
expected the read() to continue to return 0 as in point 1.  This is what =
we
see for example in FreeBSD 4.8, Tru64 5.1B, and HP/UX 11. =20

I thought that most implementations (other than Linux) did things=20
this way, but I've just now gone and tested things on Solaris 8,=20
and it seems to behave in the same way as Linux.

I've read the relevant source code to confirm the anomalous behaviour
described here.  But, why do things happen in this way on Linux?

3. (A side point.) Looking at Stevens UNPv1, p161, there is a statement
that after a SHUT_RD, "any data for a TCP socket is acknowledged and then
silently discarded".  This implies to me that the sender could keep on
writing to the socket and never block.  However, on Linux, if the peer
keeps sending to a socket, then eventually (the channel is filled and) it
blocks.  I see that this also occurs on FreeBSD 4.8, Tru64 5.1B, HP/UX 11
and Solaris 8.  Have I misunderstood Stevens, or has something changed
since the implementation he described (or was his statement wrong)?  (In
the AF_UNIX domain on Linux, the peer gets SIGPIPE/EPIPE if it keeps
writing after a local SHUT_RD.)

Thanks

Michael

--=20
+++ GMX - Mail, Messaging & more  http://www.gmx.net +++

Jetzt ein- oder umsteigen und USB-Speicheruhr als Pr=E4mie sichern!
