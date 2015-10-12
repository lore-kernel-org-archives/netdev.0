From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 0/3] net: unix: fix use-after-free
Date: Mon, 12 Oct 2015 06:36:19 -0700
Message-ID: <1444656979.27760.161.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1444363559.git.jbaron@akamai.com>
	 <20151011.045557.2164838188213641141.davem@davemloft.net>
	 <87pp0ki6xh.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jbaron@akamai.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	minipli@googlemail.com, normalperson@yhbt.net,
	viro@zeniv.linux.org.uk, davidel@xmailserver.org,
	dave@stgolabs.net, olivier@mauras.ch, pageexec@freemail.hu,
	torvalds@linux-foundation.org, peterz@infradead.org,
	joe@perches.com
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87pp0ki6xh.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-10-12 at 13:54 +0100, Rainer Weikusat wrote:
> David Miller <davem@davemloft.net> writes:
> > From: Jason Baron <jbaron@akamai.com>
> > Date: Fri,  9 Oct 2015 00:15:59 -0400
> >
> >> These patches are against mainline, I can re-base to net-next, ple=
ase
> >> let me know.
> >>=20
> >> They have been tested against: https://lkml.org/lkml/2015/9/13/195=
,
> >> which causes the use-after-free quite quickly and here:
> >> https://lkml.org/lkml/2015/10/2/693.
> >
> > I'd like to understand how patches that don't even compile can be
> > "tested"?
> >
> > net/unix/af_unix.c: In function =E2=80=98unix_dgram_writable=E2=80=99=
:
> > net/unix/af_unix.c:2480:3: error: =E2=80=98other_full=E2=80=99 unde=
clared (first use in this function)
> > net/unix/af_unix.c:2480:3: note: each undeclared identifier is repo=
rted only once for each function it appears in
> >
> > Could you explain how that works, I'm having a hard time understand=
ing
> > this?
>=20
> This is basicallly a workaround for the problem that it's not possibl=
e
> to tell epoll to let go of a certain wait queue: Instead of registeri=
ng
> the peer_wait queue via sock_poll_wait, a wait_queue_t under control =
of
> the af_unix.c code is linked onto it which relays a wake up on the
> peer_wait queue to the 'ordinary' wait queue associated with the poll=
ed
> socket via custom wake function. But (at least the code I looked it) =
it
> enqueues a unix socket on connect which has certain side effects (in
> particular, /dev/log will have a seriously large wait queue of entire=
ly
> uninterested peers) and in many cases, this is simply not necessary, =
as
> the additional peer_wait event is only interesting in case a peer of =
a
> fan-in socket (like /dev/log) happens to be waiting for writeabilty v=
ia
> poll/ select/ epoll/ ...
>=20
> Since the wait queue handling code is now under control of the af_uni=
x.c
> code, it can remove itself from the peer_wait queue prior to dropping
> its reference to a peer on disconnect or on detecting a dead peer in
> unix_dgram_sendmsg.
> --

Okay, but David was asking how the patch was supposed to be tested, and
applied, if it does not compile.

A patch is not only showing the idea, but must be ready for inclusion.

Please ?
