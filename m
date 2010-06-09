From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: pkt_sched: gen_estimator: more fuel for Jarek and Changli
Date: Wed, 9 Jun 2010 08:14:15 +0000
Message-ID: <20100609081415.GA7308@ff.dom.local>
References: <20100608121546.GA9392@ff.dom.local> <1276000052.2475.307.camel@edumazet-laptop> <20100608124052.GB9392@ff.dom.local> <4C0E9A2E.9080109@gmail.com> <1276026329.2439.2.camel@edumazet-laptop> <20100608202405.GA3496@del.dom.local> <1276030354.2439.8.camel@edumazet-laptop> <1276063997.2439.650.camel@edumazet-laptop> <20100609065134.GA6679@ff.dom.local> <1276068964.2442.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:55668 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755829Ab0FIIOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 04:14:19 -0400
Received: by fg-out-1718.google.com with SMTP id d23so2363188fga.1
        for <netdev@vger.kernel.org>; Wed, 09 Jun 2010 01:14:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1276068964.2442.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 09, 2010 at 09:36:04AM +0200, Eric Dumazet wrote:
> Le mercredi 09 juin 2010 ?? 06:51 +0000, Jarek Poplawski a =E9crit :
> > On Wed, Jun 09, 2010 at 08:13:17AM +0200, Eric Dumazet wrote:
> > >=20
> > > With un-modified kernel, I ran following scripts on my machine
> >=20
> > Why not modified with your other patch quite obviously needed by
> > rateest?:
> >=20
>=20
> First patch is obvious, but I cooked same script to trigger both bugs=
,
> because you needed some evidences.
>=20
> > > [PATCH net-2.6] pkt_sched: gen_estimator: add a new lock
> > >=20
> > > gen_kill_estimator() / gen_new_estimator() is not always called w=
ith
> > > RTNL held.
> >=20
> > Btw, I agree with Changli that adding RTNL to rateest (if possible)=
,
> > and doing the RTNL replacement later, seems more proper.
> >=20
>=20
> I wont be the guy adding RTNL to netfilter, thats for sure. That woul=
d
> be a step backward.=20
> Sometimes, the 'obvious' fix is also a dumb one.
> Do you really think I didnt had this idea too ?
>=20
> xt_RATEEST is an unfortunate domain intersection (netfilter / sched).
>=20
> We can solve this using a fine grained lock, instead of interesting
> lockdep issues, yet to be discovered.
>=20
> You can submit your patch, but I wont Ack it, I'll Nack it for all th=
ese
> reasons.

I'm not going to submit my patch. The reason for using the RTNL is
the current gen_estimator API. If rateest were done properly it would
have to use it, and I'm astonished Patrick missed it, since it took
place just around this API fix (with Patrick's part) with the patch I
mentioned:
http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commit;h=3D0929c2dd83317813425b937fbc0041013b8685ff

So, the best would be to get Patrick's opinion. Otherwise, of course
your patch is the next alternative.

>=20
> Why dont we remove all locks we have 'because we can use RTNL and be
> with it' ?
>=20
> qdisc_mod_lock could be removed quite instantly, qdisc_base could be
> protected by RTNL... And so on...
>=20

Yes, but it should be done independently from fixing bugs.

Jarek P.
