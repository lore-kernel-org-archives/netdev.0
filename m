From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take5 0/4] kevent: Generic event handling mechanism.
Date: Wed, 9 Aug 2006 11:00:57 +0400
Message-ID: <20060809070057.GA25675@2ka.mipt.ru>
References: <20060808.225230.104030885.davem@davemloft.net> <20060809061159.GA5979@2ka.mipt.ru> <20060809062515.GA23527@2ka.mipt.ru> <20060808.233156.74748104.davem@davemloft.net> <20060809064923.GB7154@2ka.mipt.ru> <44D9874E.4020402@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, zach.brown@oracle.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:43221 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1030563AbWHIHEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 03:04:37 -0400
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <44D9874E.4020402@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 08, 2006 at 11:57:18PM -0700, Ulrich Drepper (drepper@redha=
t.com) wrote:
> Evgeniy Polyakov wrote:
> > Question with kevents removal from syscall stays open until Ulrich
> > accepts or declines mapped buffer implementation.
>=20
> It was my idea in the first place to use the ring buffer.  I'm sure
> others had the same idea but that's what I presented.  So, I see no
> reason you should delay making this change because of me.

I did it already :)
So I'm waiting for you to decide if it is what you want, or it should b=
e
implemented in a different way.

> The only important thing is that we need to get a useful semantics fo=
r
> fork and exec.  For fork, it must be possible to "dequeue" entries fr=
om
> the ring buffer in a thread-safe way.  For exec (where a file descrip=
tor
> might survive) we likely need a mechanism to mmap the ring buffer onl=
y
> based on the file descriptor.  I'm not sure about this, though.

Since reading of events from tha mapped ring can be unlimited and they
are supposed to be removed only by syscall (but not copy them), and
syscall itself is thread safe, there should be no problems with fork
case.

> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View, CA =E2=9D=96
>=20



--=20
	Evgeniy Polyakov
