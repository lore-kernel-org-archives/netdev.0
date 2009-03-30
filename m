From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2927 tcp_ack+0xd55/0x1991()
Date: Mon, 30 Mar 2009 18:40:36 +0200
Message-ID: <20090330164035.GA2652@gentoox2.trippelsdorf.de>
References: <20090327211202.GA10014@gentoox2.trippelsdorf.de> <Pine.LNX.4.64.0903280031080.5904@wrl-59.cs.helsinki.fi> <20090328045056.GA2394@gentoox2.trippelsdorf.de> <Pine.LNX.4.64.0903280930440.6696@wrl-59.cs.helsinki.fi> <20090328095514.GA2599@gentoox2.trippelsdorf.de> <Pine.LNX.4.64.0903301155150.30150@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, corbet@lwn.net
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out-41.synserver.de ([217.119.50.41]:1082 "HELO
	smtp-out-41.synserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752289AbZC3Qkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 12:40:43 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0903301155150.30150@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 30, 2009 at 07:01:22PM +0300, Ilpo J=E4rvinen wrote:
> On Sat, 28 Mar 2009, Markus Trippelsdorf wrote:
>=20
> > On Sat, Mar 28, 2009 at 10:29:58AM +0200, Ilpo J=E4rvinen wrote:
> > > On Sat, 28 Mar 2009, Markus Trippelsdorf wrote:
> > >=20
> > > > On Sat, Mar 28, 2009 at 01:05:09AM +0200, Ilpo J=E4rvinen wrote=
:
> > > > > On Fri, 27 Mar 2009, Markus Trippelsdorf wrote:
> > > > >=20
> > > > > > I'm running the latest git kernel (2.6.29-03321-gbe0ea69) a=
nd I've got
> > > > > > this warning twice in the last few hours.:
>=20
> > > > > > The machine hangs afterwards.
> > > > >=20
> > > > > Is it really related to the warning for sure? I find it hard =
to=20
> > > > > believe...
> > > >=20
> > > > The machine is normally running stable for days. Switching back=
 to 2.6.29
> > > > solves the problem...
> > >=20
> > > Sure, but does is hang right after printing that warning or much =
later on,
> > > e.g., one minute is already a very long time for the crash to be =
related=20
> > > to that warning... Even 5 seconds is a long time but I'd immediat=
ely say=20
> > > it's not related then :-).
> >=20
> > I really can't tell you. In both occurrences of the warning the mac=
hine
> > was already unusable when I noticed. I then rebooted and the last e=
ntry
> > in the logs was that warning.
>=20
> ...And, let me guess, you're in X and therefore unable to catch a fin=
al=20
> oops if any would be printed? It would be nice to get around that as =
well,=20
> either use serial/netconsole or hang in text mode while waiting for t=
he=20
> crash (should be too hard if you are able to setup the workload first=
=20
> and then switch away from X and if reproducing takes about an hour)..=
=2E

OK, I will try this later.

>=20
> Arguably the presence of that warning at both times is somewhat alarm=
ing.

Make that four times:

kernel # for i in log*; cat $i | grep "tcp_input";
Mar 27 19:57:40 [kernel] WARNING: at net/ipv4/tcp_input.c:2927 tcp_ack+=
0xd55/0x1991()
Mar 27 21:37:00 [kernel] WARNING: at net/ipv4/tcp_input.c:2927 tcp_ack+=
0xd55/0x1991()
Mar 28 18:41:03 [kernel] WARNING: at net/ipv4/tcp_input.c:2927 tcp_ack+=
0xd55/0x1994()
Mar 29 11:32:26 [kernel] WARNING: at net/ipv4/tcp_input.c:2927 tcp_ack+=
0xd5b/0x19a9()

The symptoms are always the same...

Another observation is that all four WARNINGs involve only one of my
two networks adapters, namely skge (build into my mobo). The other one
(r8169) never occurs in the call trace.

I will also try to reproduce the WARNING with Jon's patch applied.

--=20
Markus
