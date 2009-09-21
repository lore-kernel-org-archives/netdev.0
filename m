From: Simon Holm =?ISO-8859-1?Q?Th=F8gersen?= <odie@cs.aau.dk>
Subject: Re: [PANIC] pktgen panic on load
Date: Mon, 21 Sep 2009 20:49:20 +0200
Message-ID: <1253558960.5955.36.camel@odie>
References: <1253486747.17792.9.camel@jbrandeb-mobl2>
	 <20090920213507.73cdc786@nehalam> <1253547857.2810.6.camel@odie>
	 <20090921095451.5ce95767@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.cs.aau.dk ([130.225.194.6]:49940 "EHLO smtp.cs.aau.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752377AbZIUSto (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2009 14:49:44 -0400
In-Reply-To: <20090921095451.5ce95767@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > > just got this today after cloning Linus' tree, please let me kn=
ow if you
> > > > want .config or full dmesg
> > >=20
> > > config would help (hrt, nohz, preempt, ...), and was it just on m=
odule load?
> > > or had you started it sending?
> >=20
> > I have the similar trace below on a simple 'modprobe pktgen'. I've
> > attached my config for v2.6.31-6456-g78f28b7.

>=20
> Could you do a git bisect, although pktgen changed recently, the chan=
ges were
> not related to the thread initialization, so I suspect something outs=
ide
> the scope of networking (ie scheduler, vm, etc)

Seems like this was fixed by commit 3f04e8c ("sched: Re-add lost
cpu_allowed check to sched_fair.c::select_task_rq_fair()") according to
Ingo [1]. Indeed, using Linus' current tree works for me.

[1] http://marc.info/?l=3Dlinux-netdev&m=3D125355156524237&w=3D2


Simon Holm Th=C3=B8gersen

