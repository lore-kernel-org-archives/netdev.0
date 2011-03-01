From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: txqueuelen has wrong units; should be time
Date: Tue, 01 Mar 2011 08:26:21 +0100
Message-ID: <1298964381.2676.58.camel@edumazet-laptop>
References: <20110228165501.GC2515@tuxdriver.com>
	 <AANLkTinj5szpStmA+fZ1xggdyTS+sd8Y9jXaYquDNEjs@mail.gmail.com>
	 <AANLkTinFZu5AgfhO6PoA7C1NTGSfD8HH0KXq_o-mHEJF@mail.gmail.com>
	 <20110228.201852.193726064.davem@davemloft.net>
	 <AANLkTi=eDQh9Kvr9N_dTC5Cnbcfb+DbO-6tLxkZiEp9v@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, johnwheffner@gmail.com,
	linville@tuxdriver.com, jussi.kivilinna@mbnet.fi, swmike@swm.pp.se,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Albert Cahalan <acahalan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=eDQh9Kvr9N_dTC5Cnbcfb+DbO-6tLxkZiEp9v@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 01 mars 2011 =C3=A0 01:54 -0500, Albert Cahalan a =C3=A9crit :
> On Mon, Feb 28, 2011 at 11:18 PM, David Miller <davem@davemloft.net> =
wrote:
> > From: Albert Cahalan <acahalan@gmail.com>
> > Date: Mon, 28 Feb 2011 23:11:13 -0500
> >
> >> It sounds like you need a callback or similar, so that TCP can be
> >> informed later that the drop has occurred.
> >
> > By that point we could have already sent an entire RTT's worth
> > of data, or more.
> >
> > It needs to be synchronous, otherwise performance suffers.
>=20
> Ouch. OTOH, the current situation: performance suffers.
>=20
> In case it makes you feel any better, consider two cases
> where synchronous feedback is already impossible.
> One is when you're routing packets that merely pass through.
> The other is when some other box is doing that to you.
> Either way, packets go bye-bye and nobody tells TCP.

So in a hurry we decide to drop packets blindly because kernel took the
cpu to perform an urgent task ?

Bufferbloat is a configuration/tuning problem, not a "everything must b=
e
redone" problem. We add new qdiscs (CHOKe, SFB, QFQ, ...) and let admin=
s
do their job. Problem is most admins are unaware of the problems, and
only buy more bandwidth.

And no, there is no "generic" solution, unless you have a lab with two
machines back to back (private link) and a known workload.

We might need some changes (including new APIs).

ECN is a forward step. Blindly dropping packets before ever sending the=
m
is a step backward.

We should allow some trafic spikes, or many applications will stop
working. Unless all applications are fixed, we are stuck.

Only if the queue stay loaded a long time (yet another parameter) we ca=
n
try to drop packets.
