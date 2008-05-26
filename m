From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Mon, 26 May 2008 15:59:40 +0200
Message-ID: <20080526135940.GB24870@elte.hu>
References: <20080526115628.GA31316@elte.hu> <Pine.LNX.4.64.0805261550340.16829@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:44438 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752654AbYEZOAN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2008 10:00:13 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805261550340.16829@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi> wrote:

> > in terms of debugging there's not much i can do i'm afraid. It's no=
t=20
> > possible to get a tcpdump of this incident, given the extreme amoun=
t=20
> > of load these testboxes handle.
>=20
> ...but you can still tcpdump that particular flow once the situation=20
> is discovered to see if TCP still tries to do something, no? One need=
s=20
> to tcpdump couple of minutes at minimum. Also please get /proc/net/tc=
p=20
> for that flow around the same time.

ok, will try those.

> > One clue (which might or might not matter) is that distcc is one of=
=20
> > the very few applications that makes use of sendfile().
>=20
> Can you please try with /proc/sys/net/ipv4/tcp_frto set to zero thoug=
h=20
> recv-q symptom seems weird would it be related to that (but there wer=
e=20
> some recent fixes to FRTO and retrans_stamp change could have some=20
> significance here)?
>=20
> Other than that, nothing since -rc1 seems suspicious to me (though I=20
> hardly understand every part of networking).

ok, i will first wait for it to trigger on a box and will do the tcpdum=
p=20
session (and /proc/net/tcp output), then i'll continue the tests with=20
this done in the rc.local:

  echo 0 > /proc/sys/net/ipv4/tcp_frto

and will see whether the hung connections still occur. The cycle of=20
testing will be very slow i suspect.

	Ingo
