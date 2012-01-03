From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: tc filter mask for ACK packets off?
Date: Tue, 03 Jan 2012 07:45:16 -0500
Message-ID: <1325594716.7219.39.camel@denise.theartistscloset.com>
References: <1325385056.4174.51.camel@denise.theartistscloset.com>
	 <21734335.uCtjXOcSpA@alaris>
	 <CAA93jw5NYChp+hKWjOWiw7SnGhNe+REofr2KM-85GnKNVpkw6w@mail.gmail.com>
	 <1325593115.7219.36.camel@denise.theartistscloset.com>
	 <1325593951.2320.40.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Taht <dave.taht@gmail.com>,
	Michal =?UTF-8?Q?Kube=C4=8Dek?= <mkubecek@suse.cz>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:64385 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751574Ab2ACMpz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 07:45:55 -0500
In-Reply-To: <1325593951.2320.40.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-01-03 at 13:32 +0100, Eric Dumazet wrote:
> Le mardi 03 janvier 2012 =C3=A0 07:18 -0500, John A. Sullivan III a =C3=
=A9crit :
> > On Tue, 2012-01-03 at 10:36 +0100, Dave Taht wrote:
> > <snip>
> > > I'd go into more detail, but after what I hope are the final two
> > > fixes to sfq and qfq land in the net-next kernel (after some more
> > > testing), I like to think I have a more valid approach than this
> > > in the works, but that too will require some more development
> > > and testing.
> > >=20
> > > http://www.teklibre.com/~d/bloat/pfifo_fast_vs_sfq_qfq_linear.png
> > >=20
> > <snip>
> > Hmmm . . . certainly shattered my concerns about replacing pfifo_fa=
st
> > with SFQ! Thanks - John
>=20
> Before you do, take the time to read the warning in sfq source :
>=20
>=20
> 	ADVANTAGE:
>=20
> 	- It is very cheap. Both CPU and memory requirements are minimal.
>=20
> 	DRAWBACKS:
>=20
> 	- "Stochastic" -> It is not 100% fair.
> 	When hash collisions occur, several flows are considered as one.
>=20
> 	- "Round-robin" -> It introduces larger delays than virtual clock
> 	based schemes, and should not be used for isolating interactive
> 	traffic	from non-interactive. It means, that this scheduler
> 	should be used as leaf of CBQ or P3, which put interactive traffic
> 	to higher priority band.
>=20
>=20
> SFQ (as a direct replacement of dev root qdisc) is fine if most of yo=
ur trafic
> is of same kind/priority.
>=20
>=20
>=20
Yes, I suppose I should have been more specific, replacing pfifo_fast
when I am using something else to prioritize and shape my traffic like
HFSC.  Hmm . . . although I still wonder about iSCSI SANs . . .   Thank=
s
- John
