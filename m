From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: cleanup of cwnd initialization in
 tcp_init_metrics()
Date: Thu, 23 Dec 2010 10:14:23 +0100
Message-ID: <1293095663.7789.3.camel@edumazet-laptop>
References: <alpine.LNX.2.00.1012221938030.16569@pobox.suse.cz>
	 <1293092671.2679.44.camel@edumazet-laptop>
	 <alpine.LNX.2.00.1012231002310.16569@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Vojtech Pavlik <vojtech@suse.cz>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1012231002310.16569@pobox.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 23 d=C3=A9cembre 2010 =C3=A0 10:03 +0100, Jiri Kosina a =C3=A9=
crit :
> On Thu, 23 Dec 2010, Eric Dumazet wrote:
>=20
> > Le mercredi 22 d=C3=A9cembre 2010 =C3=A0 19:39 +0100, Jiri Kosina a=
 =C3=A9crit :
> > > Commit 86bcebafc5e7f5 ("tcp: fix >2 iw selection") fixed a case w=
hen=20
> > > congestion window initialization has been mistakenly omitted by=20
> > > introducing cwnd label and putting backwards jump from the end of=
 the=20
> > > function.
> > >=20
> > > This makes the code unnecessarily tricky to read and understand o=
n a first=20
> > > sight.
> > >=20
> > > Shuffle the code around a little bit to make it more obvious.
> >=20
> > Well in fine you have
> >=20
> > 	if (inet_csk(sk)->icsk_rto < TCP_TIMEOUT_INIT && !tp->rx_opt.saw_t=
stamp)
> > 		goto reset;
> > 	goto out;
> > reset:
> >=20
> > Is that really more obvious ? ;)
>=20
> To me it seems much more obvious than goto from the very end of the=20
> function somewhere into the middle and returning from there, but=20
> definitely a matter of personal taste.
>=20

You dont understand what I said. Please read again.

To me I prefer you _finish_ the cleanup so that we have :

	if (some condition) {
reset:
	}

out:

You remove two "goto" in the process.

Is that clear now ?
