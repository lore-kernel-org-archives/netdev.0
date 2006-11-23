From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Thu, 23 Nov 2006 15:22:25 +0300
Message-ID: <20061123122225.GD20294@2ka.mipt.ru>
References: <4560F07B.10608@redhat.com> <20061120082500.GA25467@2ka.mipt.ru> <4562102B.5010503@redhat.com> <20061121095302.GA15210@2ka.mipt.ru> <45633049.2000209@redhat.com> <20061121174334.GA25518@2ka.mipt.ru> <4563FD53.7030307@redhat.com> <20061122120933.GA32681@2ka.mipt.ru> <20061122121516.GA7229@2ka.mipt.ru> <4564CE00.9030904@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Alexander Viro <aviro@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:28838 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1757358AbWKWMZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Nov 2006 07:25:22 -0500
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <4564CE00.9030904@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 22, 2006 at 02:24:00PM -0800, Ulrich Drepper (drepper@redha=
t.com) wrote:
> Evgeniy Polyakov wrote:
> >On Wed, Nov 22, 2006 at 03:09:34PM +0300, Evgeniy Polyakov=20
> >(johnpol@2ka.mipt.ru) wrote:
> >>Ok, to solve the problem in the way which should be good for both I
> >>decided to implement additional syscall which will allow to mark an=
y
> >>event as ready and thus wake up appropriate threads. If userspace w=
ill
> >>request zero events to be marked as ready, syscall will just
> >>interrupt/wakeup one of the listeners parked in syscall.
>=20
> I'll wait for the new code drop to comment.

I posted it.
=20
> >Btw, what about putting aditional multiplexer into add/remove/modify
> >switch? There will be logical 'ready' addon?
>=20
> Is it needed?  Usually this is done with a *_wait call with a timeout=
 of=20
> zero.  That code path might have to be optimized but it should alread=
y=20
> be there.

It does not allow to mark events as ready.
And current interfaces wake up when either timeout is zero (in this cas=
e
thread itself does not sleep and can process events), or when there is
_new_ work - since there is no _new_ work, when thread awakened to
process it was killed, kernel does not think that something is wrong.

> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View,=20
> CA =E2=9D=96

--=20
	Evgeniy Polyakov
