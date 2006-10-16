From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take19 1/4] kevent: Core files.
Date: Mon, 16 Oct 2006 11:33:49 +0400
Message-ID: <20061016073348.GB17735@2ka.mipt.ru>
References: <11587449471424@2ka.mipt.ru> <200610051245.03880.dada1@cosmosbay.com> <20061005105536.GA4838@2ka.mipt.ru> <200610051409.31826.dada1@cosmosbay.com> <20061005123715.GA7475@2ka.mipt.ru> <4532C2C5.6080908@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Ulrich Drepper <drepper@gmail.com>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:36581 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1161081AbWJPHed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 03:34:33 -0400
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <4532C2C5.6080908@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 15, 2006 at 04:22:45PM -0700, Ulrich Drepper (drepper@redha=
t.com) wrote:
> Evgeniy Polyakov wrote:
> >Existing design does not allow overflow.
>=20
> And I've pointed out a number of times that this is not practical at=20
> best.  There are event sources which can create events which cannot b=
e=20
> coalesced into one single event as it would be required with your des=
ign.
>=20
> Signals are one example, specifically realtime signals.  If we do not=
=20
> want the design to be limited from the start this approach has to be=20
> thought over.

The whole idea of mmap buffer seems to be broken, since those who asked
for creation do not like existing design and do not show theirs...

According to signals and possibility to overflow in existing ring buffe=
r
implementation.
You seems to not checked the code - each event can be marked as ready=20
only one time, which means only one copy and so on.
It was done _specially_. And it is not limitation, but "new" approach.
Queue of the same signals or any other events has fundamental flawness
(as any other ring buffer implementation, which has queue size)  -
it's size of the queue and extremely bad case of the overflow.
So, the same event may not be ready several times. Any design which
allows to create infinite number of events generated for the same case
is broken, since consumer can be in situation, when it can not handle
that flow. That is why poll() returns only POLLIN when data is ready in
network stack, but is not trying to generate some kind of a signal for=20
each byte/packet/MTU/MSS received.
RT signals have design problems, and I will not repeate the same error
with similar limits in kevent.

> >>So zap mmap() support completely, since it is not usable at all. We=
 wont=20
> >>discuss on it.
> >
> >Initial implementation did not have it.
> >But I was requested to do it, and it is ready now.
> >No one likes it, but no one provides an alternative implementation.
> >We are stuck.
>=20
> We need the mapped ring buffer.  The current design (before it was=20
> removed) was broken but this does not mean it shouldn't be implemente=
d.=20
>  We just need more time to figure out how to implement it correctly.

In the latest patchset it was removed. I'm waiting for your code.

Mmap implementation can be added separately, since it does not affect
kevent core.

> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View,=20
> CA =E2=9D=96

--=20
	Evgeniy Polyakov
