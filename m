From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: txqueuelen has wrong units; should be time
Date: Tue, 01 Mar 2011 21:14:39 +0100
Message-ID: <1299010479.2930.1.camel@edumazet-laptop>
References: <20110228165501.GC2515@tuxdriver.com>
	 <AANLkTinj5szpStmA+fZ1xggdyTS+sd8Y9jXaYquDNEjs@mail.gmail.com>
	 <AANLkTinFZu5AgfhO6PoA7C1NTGSfD8HH0KXq_o-mHEJF@mail.gmail.com>
	 <20110228.201852.193726064.davem@davemloft.net>
	 <AANLkTi=eDQh9Kvr9N_dTC5Cnbcfb+DbO-6tLxkZiEp9v@mail.gmail.com>
	 <1298964381.2676.58.camel@edumazet-laptop>
	 <AANLkTimWMZHVQSHEUPuQgFXxNg85dEOesqhZE=e6x8kb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, johnwheffner@gmail.com,
	linville@tuxdriver.com, jussi.kivilinna@mbnet.fi, swmike@swm.pp.se,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Albert Cahalan <acahalan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimWMZHVQSHEUPuQgFXxNg85dEOesqhZE=e6x8kb@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 01 mars 2011 =C3=A0 14:37 -0500, Albert Cahalan a =C3=A9crit :
> On Tue, Mar 1, 2011 at 2:26 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> > Le mardi 01 mars 2011 =C3=A0 01:54 -0500, Albert Cahalan a =C3=A9cr=
it :
> >> On Mon, Feb 28, 2011 at 11:18 PM, David Miller <davem@davemloft.ne=
t> wrote:
> >> > From: Albert Cahalan <acahalan@gmail.com>
>=20
> >> >> It sounds like you need a callback or similar, so that TCP can =
be
> >> >> informed later that the drop has occurred.
> >> >
> >> > By that point we could have already sent an entire RTT's worth
> >> > of data, or more.
> >> >
> >> > It needs to be synchronous, otherwise performance suffers.
> >>
> >> Ouch. OTOH, the current situation: performance suffers.
> >>
> >> In case it makes you feel any better, consider two cases
> >> where synchronous feedback is already impossible.
> >> One is when you're routing packets that merely pass through.
> >> The other is when some other box is doing that to you.
> >> Either way, packets go bye-bye and nobody tells TCP.
> >
> > So in a hurry we decide to drop packets blindly because kernel took=
 the
> > cpu to perform an urgent task ?
>=20
> Yes. If the system can't handle the load, it needs to fess up.
>=20
> > Bufferbloat is a configuration/tuning problem, not a "everything mu=
st be
> > redone" problem. We add new qdiscs (CHOKe, SFB, QFQ, ...) and let a=
dmins
> > do their job. Problem is most admins are unaware of the problems, a=
nd
> > only buy more bandwidth.
>=20
> We could at least do as well as Windows. >:-)
>=20
> You can not expect some random Linux user to tune things
> every time the link changes speed or the app mix changes.
> What person NOT ON THIS MAILING LIST is going to mess
> with their qdisc when they connect to a new access point
> or switch from running Skype to running Netflix? Heck, how
> many have any awareness of what a qdisk even is? Linux
> networking needs to be excellent for people with no clue.
>=20
> > We might need some changes (including new APIs).
>=20
> If an app can't specify latency, adding the ability could
> be nice. Still, stuff needs to JUST WORK more of the time.
>=20
> > ECN is a forward step. Blindly dropping packets before ever sending=
 them
> > is a step backward.
>=20
> Last I knew, ECN defaulted to a setting of "2" which means
> it is only used in response. Perhaps it's time to change that.
> It's been a while, with defective firewalls being replaced
> by faster hardware.
>=20
> > We should allow some trafic spikes, or many applications will stop
> > working. Unless all applications are fixed, we are stuck.
>=20
> Such applications would stop working...
>=20
> 1. across a switch
> 2. across an older router
>=20
> We certainly should allow some traffic spikes. 1 to 10 ms of
> traffic ought to do nicely. Hundreds or thousands of ms is
> getting way beyond "spike".

OK.
