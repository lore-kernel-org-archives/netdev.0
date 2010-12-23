From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] tcp: cleanup of cwnd initialization in
 tcp_init_metrics()
Date: Thu, 23 Dec 2010 10:03:18 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1012231002310.16569@pobox.suse.cz>
References: <alpine.LNX.2.00.1012221938030.16569@pobox.suse.cz> <1293092671.2679.44.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Vojtech Pavlik <vojtech@suse.cz>,
	=?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293092671.2679.44.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 23 Dec 2010, Eric Dumazet wrote:

> Le mercredi 22 d=C3=A9cembre 2010 =C3=A0 19:39 +0100, Jiri Kosina a =C3=
=A9crit :
> > Commit 86bcebafc5e7f5 ("tcp: fix >2 iw selection") fixed a case whe=
n=20
> > congestion window initialization has been mistakenly omitted by=20
> > introducing cwnd label and putting backwards jump from the end of t=
he=20
> > function.
> >=20
> > This makes the code unnecessarily tricky to read and understand on =
a first=20
> > sight.
> >=20
> > Shuffle the code around a little bit to make it more obvious.
>=20
> Well in fine you have
>=20
> 	if (inet_csk(sk)->icsk_rto < TCP_TIMEOUT_INIT && !tp->rx_opt.saw_tst=
amp)
> 		goto reset;
> 	goto out;
> reset:
>=20
> Is that really more obvious ? ;)

To me it seems much more obvious than goto from the very end of the=20
function somewhere into the middle and returning from there, but=20
definitely a matter of personal taste.

--=20
Jiri Kosina
SUSE Labs, Novell Inc.
