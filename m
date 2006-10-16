From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take19 0/4] kevent: Generic event handling mechanism.
Date: Mon, 16 Oct 2006 02:59:48 -0700
Message-ID: <45335814.6000903@redhat.com>
References: <20060927150957.GA18116@2ka.mipt.ru> <a36005b50610032150x8233feqe556fd93bcb5dc73@mail.gmail.com> <20061004045527.GB32267@2ka.mipt.ru> <452363C5.1020505@redhat.com> <20061004074821.GA22688@2ka.mipt.ru> <4523ED6C.9080902@redhat.com> <20061005090214.GB1015@2ka.mipt.ru> <45251A83.9060901@redhat.com> <20061006083620.GA28009@2ka.mipt.ru> <4532B99B.9030403@redhat.com> <20061016072321.GA17735@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ulrich Drepper <drepper@gmail.com>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030337AbWJPKAh@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061016072321.GA17735@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> One can set number of events before the syscall and do not remove the=
m
> after syscall. It can be updated if there is need for that.

Nobody doubts that it is possible.  But it is

a) potentially much expensive

and

b) an alien concept

to have the signal mask to set during the wait call implicitly.=20
Conceptually it doesn't even make sense.  This is no event to wait for.=
=20
  It a parameter for the specific wait call, just like the timeout.  An=
d=20
I fortunately haven't seen you proposing to pass the timeout value=20
implicitly.


>> Not good enough?  It does exactly what it is supposed to do.  What c=
an=20
>> there be "not good enough"?
>=20
> Not to move signals into special case of events. If poll() can not wo=
rk
> with them it does not mean, that they need to be specified as additio=
nal
> syscall parameter, instead change poll() to work with them, which can=
 be
> easily done with kevents.

You still seem to be completely missing the point.  The signal mask is=20
no event to wait for.  It has nothing to do with this that ppoll() take=
s=20
the signal mask as a parameter.  The signal mask is a parameter for the=
=20
wait call just like the timeout, not more and not less.


> Do not mix warm and soft - waiting for some period is not equal to
> syscall timeout. Waiting is possible with timer kevent user (although
> only relative timeout, can be changed to support both, not a big
> problem).

That's what I'm saying all the time.  Of course it can be supported.=20
But for this the timeout parameter must be a timespec pointer.  Whateve=
r=20
you could possibly mean by "do not mix warm and soft" I cannot possibly=
=20
imagine.  Fact is that both relative and absolute timeouts are useful.=20
And that for absolute timeouts the change of the clock has to be taken=20
into account.


> I'm quite sure that absolute timeouts are very usefull, but not as in
> the case of waiting for syscall completeness. In any way, kevent can =
be
> extended to support absolute timeouts in it's timer notifications.

That's not the same.  If you argue that then the syscall should have no=
=20
timeout parameter at all.  Fact is that setting up a timer is not for=20
free.  Since the timeout is used all the time having a timeout paramete=
r=20
is the right answer.  And if you do this then do it right just like=20
every other syscall other than poll: use a timespec object.  This gives=
=20
flexibility without measurable cost.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
