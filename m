From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tc filter mask for ACK packets off?
Date: Tue, 03 Jan 2012 13:32:31 +0100
Message-ID: <1325593951.2320.40.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1325385056.4174.51.camel@denise.theartistscloset.com>
	 <21734335.uCtjXOcSpA@alaris>
	 <CAA93jw5NYChp+hKWjOWiw7SnGhNe+REofr2KM-85GnKNVpkw6w@mail.gmail.com>
	 <1325593115.7219.36.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Taht <dave.taht@gmail.com>,
	Michal =?UTF-8?Q?Kube=C4=8Dek?= <mkubecek@suse.cz>,
	netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:43036 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752572Ab2ACMck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 07:32:40 -0500
Received: by lahd3 with SMTP id d3so3694312lah.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 04:32:37 -0800 (PST)
In-Reply-To: <1325593115.7219.36.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 03 janvier 2012 =C3=A0 07:18 -0500, John A. Sullivan III a =C3=
=A9crit :
> On Tue, 2012-01-03 at 10:36 +0100, Dave Taht wrote:
> <snip>
> > I'd go into more detail, but after what I hope are the final two
> > fixes to sfq and qfq land in the net-next kernel (after some more
> > testing), I like to think I have a more valid approach than this
> > in the works, but that too will require some more development
> > and testing.
> >=20
> > http://www.teklibre.com/~d/bloat/pfifo_fast_vs_sfq_qfq_linear.png
> >=20
> <snip>
> Hmmm . . . certainly shattered my concerns about replacing pfifo_fast
> with SFQ! Thanks - John

Before you do, take the time to read the warning in sfq source :


	ADVANTAGE:

	- It is very cheap. Both CPU and memory requirements are minimal.

	DRAWBACKS:

	- "Stochastic" -> It is not 100% fair.
	When hash collisions occur, several flows are considered as one.

	- "Round-robin" -> It introduces larger delays than virtual clock
	based schemes, and should not be used for isolating interactive
	traffic	from non-interactive. It means, that this scheduler
	should be used as leaf of CBQ or P3, which put interactive traffic
	to higher priority band.


SFQ (as a direct replacement of dev root qdisc) is fine if most of your=
 trafic
is of same kind/priority.
