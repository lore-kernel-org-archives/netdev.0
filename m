From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: gen_estimator: use 64 bits intermediate
	counters for bps
Date: Tue, 19 May 2009 07:42:47 +0000
Message-ID: <20090519074247.GB4210@ff.dom.local>
References: <20090516141430.GB3013@ami.dom.local> <4A118F98.60101@cosmosbay.com> <20090518172349.GA2755@ami.dom.local> <20090518.145233.212710505.davem@davemloft.net> <4A11F67B.3050805@cosmosbay.com> <20090519070252.GA4210@ff.dom.local> <4A126058.7030605@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, vexwek@gmail.com,
	netdev@vger.kernel.org, kaber@trash.net, devik@cdi.cz
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:57556 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751723AbZESHm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 03:42:57 -0400
Received: by yx-out-2324.google.com with SMTP id 3so2306721yxj.1
        for <netdev@vger.kernel.org>; Tue, 19 May 2009 00:42:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A126058.7030605@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2009 at 09:31:36AM +0200, Eric Dumazet wrote:
> Jarek Poplawski a =E9crit :
> > On Tue, May 19, 2009 at 01:59:55AM +0200, Eric Dumazet wrote:
> > ...
> >> diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
> > ...
> >> -		e->avbps +=3D ((long)rate - (long)e->avbps) >> e->ewma_log;
> >> +		e->avbps +=3D ((s64)(brate - e->avbps)) >> e->ewma_log;
> >=20
> > Btw., I'm a bit concerned about the syntax here: isn't such shiftin=
g
> > of signed ints implementation dependant?
> >=20
>=20
> You are right Jarek, I very often forget to never ever use signed qua=
ntities
> at all ! (But also note original code has same undefined behavior)

Sure, I've meant the original code including 5 lines below.

> Apparently gcc does the *right* thing on x86_32, but we probably want=
 something
> stronger here. I could not find gcc documentation statement on right =
shifts of=20
> negative values.

I guess gcc and most of others do this "right"; but it looks
"unkosher" anyway.

Jarek P.
