From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Mon, 26 May 2008 18:23:28 +0200
Message-ID: <20080526162328.GA9089@elte.hu>
References: <20080526115628.GA31316@elte.hu> <Pine.LNX.4.64.0805261550340.16829@wrl-59.cs.helsinki.fi> <20080526135940.GB24870@elte.hu> <20080526141252.GA31352@elte.hu> <Pine.LNX.4.64.0805261745010.16829@wrl-59.cs.helsinki.fi>
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
Received: from mx3.mail.elte.hu ([157.181.1.138]:51366 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753712AbYEZQXw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2008 12:23:52 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805261745010.16829@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi> wrote:

> On Mon, 26 May 2008, Ingo Molnar wrote:
>=20
> > there's a hung distcc task on the system, waiting for socket action=
=20
> > forever:
> >=20
> >   [root@europe ~]# strace -fp 19578
> >   Process 19578 attached - interrupt to quit
> >   select(5, NULL, [4], [4], {82, 90000} <unfinished ...>
>=20
> Hmm, readfds is NULL isn't it?!? Are you sure you straced the right=20
> process?

yes, i'm stracing the task that is hung unexpectedly.

> > disturbing that task via strace did not change the state of the=20
> > socket - and that's not unexpected as it's a select(). [TCP state=20
> > might be affected if strace impacted a recvmsg or a sendmsg wait=20
> > directly.]
>=20
> I fail to understand this paragraph due to excessive negation... :-)

i mean, sometimes a TCP connection can get 'unstuck' if you strace a=20
task - that is because the TCP related syscall the task sits in gets=20
interrupted. But in this case it's select() which doesnt explicitly tak=
e=20
the socket, doesnt do any tcp_push_pending_frames() processing, etc. -=20
it just its on the socket waitqueue AFAICS. And that's expected.

	Ingo
