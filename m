From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Fri, 24 Nov 2006 13:58:56 +0300
Message-ID: <20061124105856.GE13600@2ka.mipt.ru>
References: <4562102B.5010503@redhat.com> <20061121095302.GA15210@2ka.mipt.ru> <45633049.2000209@redhat.com> <20061121174334.GA25518@2ka.mipt.ru> <4563FD53.7030307@redhat.com> <20061122120933.GA32681@2ka.mipt.ru> <20061122121516.GA7229@2ka.mipt.ru> <4564CE00.9030904@redhat.com> <20061123122225.GD20294@2ka.mipt.ru> <456605EA.5060601@redhat.com>
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757593AbWKXLAq@vger.kernel.org>
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <456605EA.5060601@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 23, 2006 at 12:34:50PM -0800, Ulrich Drepper (drepper@redha=
t.com) wrote:
> Evgeniy Polyakov wrote:
> >>>Btw, what about putting aditional multiplexer into add/remove/modi=
fy
> >>>switch? There will be logical 'ready' addon?
> >>Is it needed?  Usually this is done with a *_wait call with a timeo=
ut of=20
> >>zero.  That code path might have to be optimized but it should alre=
ady=20
> >>be there.
> >
> >It does not allow to mark events as ready.
> >And current interfaces wake up when either timeout is zero (in this =
case
> >thread itself does not sleep and can process events), or when there =
is
> >_new_ work - since there is no _new_ work, when thread awakened to
> >process it was killed, kernel does not think that something is wrong=
=2E
>=20
> Rather than mark an existing entry as ready, how about a call to inje=
ct=20
> a new ready event?
>=20
> This would be useful to implement functionality at userlevel and stil=
l=20
> use an event queue to announce the availability.  Without this type o=
f=20
> functionality we'd need to use indirect notification via signal or pi=
pe=20
> or something like that.

With provided patch it is possible to wakeup 'for-free' - just call
kevent_ctl(ready) with zero number of ready events, so thread will be
awakened if it was in poll(kevent_fd), kevent_wait() or
kevent_get_events().

> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View,=20
> CA =E2=9D=96

--=20
	Evgeniy Polyakov
