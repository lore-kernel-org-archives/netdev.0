From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Thu, 23 Nov 2006 12:34:50 -0800
Message-ID: <456605EA.5060601@redhat.com>
References: <4560F07B.10608@redhat.com> <20061120082500.GA25467@2ka.mipt.ru> <4562102B.5010503@redhat.com> <20061121095302.GA15210@2ka.mipt.ru> <45633049.2000209@redhat.com> <20061121174334.GA25518@2ka.mipt.ru> <4563FD53.7030307@redhat.com> <20061122120933.GA32681@2ka.mipt.ru> <20061122121516.GA7229@2ka.mipt.ru> <4564CE00.9030904@redhat.com> <20061123122225.GD20294@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
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
Received: from mx1.redhat.com ([66.187.233.31]:51942 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1757459AbWKWUgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Nov 2006 15:36:05 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061123122225.GD20294@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
>>> Btw, what about putting aditional multiplexer into add/remove/modif=
y
>>> switch? There will be logical 'ready' addon?
>> Is it needed?  Usually this is done with a *_wait call with a timeou=
t of=20
>> zero.  That code path might have to be optimized but it should alrea=
dy=20
>> be there.
>=20
> It does not allow to mark events as ready.
> And current interfaces wake up when either timeout is zero (in this c=
ase
> thread itself does not sleep and can process events), or when there i=
s
> _new_ work - since there is no _new_ work, when thread awakened to
> process it was killed, kernel does not think that something is wrong.

Rather than mark an existing entry as ready, how about a call to inject=
=20
a new ready event?

This would be useful to implement functionality at userlevel and still=20
use an event queue to announce the availability.  Without this type of=20
functionality we'd need to use indirect notification via signal or pipe=
=20
or something like that.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
