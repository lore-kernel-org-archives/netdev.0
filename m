From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: gen_estimator: use 64 bits intermediate
	counters for bps
Date: Tue, 19 May 2009 07:57:15 +0000
Message-ID: <20090519075715.GC4210@ff.dom.local>
References: <20090516141430.GB3013@ami.dom.local> <4A118F98.60101@cosmosbay.com> <20090518172349.GA2755@ami.dom.local> <20090518.145233.212710505.davem@davemloft.net> <4A11F67B.3050805@cosmosbay.com> <20090519070252.GA4210@ff.dom.local> <4A126058.7030605@cosmosbay.com> <20090519074247.GB4210@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, vexwek@gmail.com,
	netdev@vger.kernel.org, kaber@trash.net, devik@cdi.cz
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:8227 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320AbZESH5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 03:57:22 -0400
Received: by yw-out-2324.google.com with SMTP id 5so2307343ywb.1
        for <netdev@vger.kernel.org>; Tue, 19 May 2009 00:57:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090519074247.GB4210@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2009 at 07:42:47AM +0000, Jarek Poplawski wrote:
> On Tue, May 19, 2009 at 09:31:36AM +0200, Eric Dumazet wrote:
> > Jarek Poplawski a =E9crit :
> > > On Tue, May 19, 2009 at 01:59:55AM +0200, Eric Dumazet wrote:
> > > ...
> > >> diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
> > > ...
> > >> -		e->avbps +=3D ((long)rate - (long)e->avbps) >> e->ewma_log;
> > >> +		e->avbps +=3D ((s64)(brate - e->avbps)) >> e->ewma_log;
> > >=20
> > > Btw., I'm a bit concerned about the syntax here: isn't such shift=
ing
> > > of signed ints implementation dependant?
> > >=20
> >=20
> > You are right Jarek, I very often forget to never ever use signed q=
uantities
> > at all ! (But also note original code has same undefined behavior)
>=20
> Sure, I've meant the original code including 5 lines below.
>=20
> > Apparently gcc does the *right* thing on x86_32, but we probably wa=
nt something
> > stronger here. I could not find gcc documentation statement on righ=
t shifts of=20
> > negative values.
>=20
> I guess gcc and most of others do this "right"; but it looks
> "unkosher" anyway.

I might have missed your point here, but would it be so costly to do
these shifts separately here?

Jarek P.
