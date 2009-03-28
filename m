From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2927 tcp_ack+0xd55/0x1991()
Date: Sat, 28 Mar 2009 05:50:56 +0100
Message-ID: <20090328045056.GA2394@gentoox2.trippelsdorf.de>
References: <20090327211202.GA10014@gentoox2.trippelsdorf.de> <Pine.LNX.4.64.0903280031080.5904@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out-44.synserver.de ([217.119.50.44]:1050 "HELO
	smtp-out-44.synserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751535AbZC1EvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2009 00:51:01 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0903280031080.5904@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 28, 2009 at 01:05:09AM +0200, Ilpo J=E4rvinen wrote:
> On Fri, 27 Mar 2009, Markus Trippelsdorf wrote:
>=20
> > I'm running the latest git kernel (2.6.29-03321-gbe0ea69) and I've =
got
> > this warning twice in the last few hours.:
>=20
> What did you run previously?

2.6.29

>=20
> > Mar 27 21:37:00 [kernel] ------------[ cut here ]------------
> > Mar 27 21:37:00 [kernel] WARNING: at net/ipv4/tcp_input.c:2927 tcp_=
ack+0xd55/0x1991()
>=20
> This one may or may not be a new one... Starting from the point when =
the=20
> warning was added it has been seen and some of those miscounts got tr=
acked=20
> down but there is still something remaining (and that has been the st=
ate=20
> for couple of version already). It seems to require some particularly=
 hard=20
> to reproduce network behavior people usually hit once in a lifetime.=20
> However, those miscount alone should not cause crashes, stalled TCP a=
t=20
> worst but even that is quite unlikely to happen if fackets_out was no=
t=20
> counted right.

The only unusual thing in my setup is that I use two Internet providers
at the same time:

# ip route show
192.168.1.0/24 dev eth1  proto kernel  scope link  src 192.168.1.2
192.168.0.0/24 dev eth0  proto kernel  scope link  src 192.168.0.2
127.0.0.0/8 via 127.0.0.1 dev lo
default equalize
        nexthop via 192.168.1.1  dev eth1 weight 10
        nexthop via 192.168.0.1  dev eth0 weight 1

>=20
> > The machine hangs afterwards.
>=20
> Is it really related to the warning for sure? I find it hard to=20
> believe...

The machine is normally running stable for days. Switching back to 2.6.=
29
solves the problem...

>=20
> We even fixed that miscount for you when the warning was printed out =
(and=20
> the miscount alone wouldn't be able to cause crash anyway). Obviously=
=20
> there could something that got broken but reading through all post 2.=
6.29=20
> tcp material doesn't reveal anything particularly suspicious or even=20
> tricky... Only one thing that is remotely related to the warning that=
 gets=20
> printed out is d3d2ae454501a4dec360995649e1b002a2ad90c5 but even that=
 has=20
> very strong foundation as it does not have any potential to introduce=
=20
> stale references, rest of the effects would be just stalled tcp conne=
ction=20
> at worst.
>=20
> Please add some debugging things, at least lockdep (CONFIG_PROVE_LOCK=
ING)=20
> and soft lockup detector (CONFIG_DETECT_SOFTLOCKUP) to find out if we=
 can=20
> get some info about the actual place of hang, some other debug things=
=20
> might also end up being useful.

Ok, will try this later today and report back. (It takes ~1 hour to
reproduce the problem with a big torrent download).

--=20
Markus
