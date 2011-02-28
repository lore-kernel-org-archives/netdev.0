From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: txqueuelen has wrong units; should be time
Date: Mon, 28 Feb 2011 18:18:23 +0100
Message-ID: <1298913503.2941.718.camel@edumazet-laptop>
References: <AANLkTimd5GQwtUFP2fD_An=M8ajBD8DJpzxQJezv8fB8@mail.gmail.com>
	 <alpine.DEB.1.10.1102270758580.11974@uplift.swm.pp.se>
	 <1298793252.8726.45.camel@edumazet-laptop>
	 <AANLkTinyE10wtM_xJsufT_3s3hvti7CN+9nyqScWa6SA@mail.gmail.com>
	 <20110227125540.40754c5y78j9u2m8@hayate.sektori.org>
	 <1298837273.8726.128.camel@edumazet-laptop>
	 <20110228161115.GB2515@tuxdriver.com>
	 <1298911694.2941.639.camel@edumazet-laptop>
	 <20110228165501.GC2515@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Albert Cahalan <acahalan@gmail.com>,
	Mikael Abrahamsson <swmike@swm.pp.se>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110228165501.GC2515@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 28 f=C3=A9vrier 2011 =C3=A0 11:55 -0500, John W. Linville a =C3=
=A9crit :
> On Mon, Feb 28, 2011 at 05:48:14PM +0100, Eric Dumazet wrote:
> > Le lundi 28 f=C3=A9vrier 2011 =C3=A0 11:11 -0500, John W. Linville =
a =C3=A9crit :
> > > On Sun, Feb 27, 2011 at 09:07:53PM +0100, Eric Dumazet wrote:
> > >=20
> > > > Qdisc should return to caller a good indication packet is queue=
d or
> > > > dropped at enqueue() time... not later (aka : never)
> > > >=20
> > > > Accepting a packet at t0, and dropping it later at t0+limit wit=
hout
> > > > giving any indication to caller is a problem.
> > >=20
> > > Can you elaborate on what problem this causes?  Is it any worse t=
han
> > > if the packet is dropped at some later hop?
> > >=20
> > > Is there any API that could report the drop to the sender (at
> > > least a local one) without having to wait for the ack timeout?
> > > Should there be?
> > >=20
> >=20
> > Not all protocols have ACKS ;)
> >=20
> > dev_queue_xmit() returns an error code, some callers use it.
>=20
> Well, OK -- I agree it is best if you can return the status at
> enqueue time.  The question becomes whether or not a dropped frame
> is worse than living with high latency.  The answer, of course, still
> seems to be a bit subjective.  But, if the admin has determined that
> a link should be low latency...?
>=20

If the latency problem could be solved by an admin choice, it probably
would be there already.

Point is qdisc layer is able to immediately return an error code to
caller, if qdisc handlers properly done. This can help applications to
immediately react to congestion notifications.

Some applications, even running on a "low latency link" can afford a
long delay for their packets. Should we introduce a socket API to give
the upper bound for the limit, or share a global 'per qdisc' limit ?
