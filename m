From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netchannels: netchannel vs. socket. 2:0.
Date: Fri, 9 Jun 2006 09:09:45 +0400
Message-ID: <20060609050945.GC11653@2ka.mipt.ru>
References: <20060608171555.GA10273@2ka.mipt.ru> <200606090100.24827.hhh@imada.sdu.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:59829 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S965200AbWFIFKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2006 01:10:02 -0400
To: Hans Henrik Happe <hhh@imada.sdu.dk>
Content-Disposition: inline
In-Reply-To: <200606090100.24827.hhh@imada.sdu.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 09, 2006 at 01:00:24AM +0200, Hans Henrik Happe (hhh@imada.=
sdu.dk) wrote:
> On Thursday 08 June 2006 19:15, you wrote:
> > After some enhancements made for netchannel subsystem I'm pleased t=
o
> > announce, that netchannel subsystem outperforms existing layered de=
sign
> > both in CPU usage and network speed.
> >=20
> > Well, after such pretentious introduction I want to cool things dow=
n.
> > CPU usage is about 1-2% less for netchannels and network performanc=
e is
> > about 1-2 MB higher and sometimes exceeds 84 MB/sec which, I think,=
=20
> > is maximum for given network setup (e1000 receive, r8169 send, 1500=
 MTU).
>=20
> I have followed your work closely and have wondered how it affects la=
tency?
> I have somewhat limited knowledge about TCP and how the kernel handle=
s it, but=20
> I guess the path from NIC to userspace hasn't increased. What about s=
yscall=20
> overhead caused by userspace TCP processing?

Path from NIC to userspace was decreased in that way that there are les=
s
number of context switches, much smaller amount of work being done in
softirq (I have not modified driver and still use NAPI), less cache
thrashing due to work ping-ponging and less number of locks.
Number of syscalls is still the same - either one recv() or one
netchannel_control() to read the same block of data.

But since existing socket code is used, gain is not that big, since
sockets are locked, although they should not, skbs are requeued, ACKs
are scheduled, although all that could be changed.

At least receiving part of the netchannel TCP processing could be
different. And my thoughts move in that direction.

> H=C2=B3 =20

--=20
	Evgeniy Polyakov
