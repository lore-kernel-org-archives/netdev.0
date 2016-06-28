From: Jiri Kosina <jikos@kernel.org>
Subject: Re: Deleting child qdisc doesn't reset parent to default qdisc?
Date: Tue, 28 Jun 2016 19:33:09 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1606281929330.6874@cbobk.fhfr.pm>
References: <alpine.LNX.2.00.1604141638230.27368@cbobk.fhfr.pm> <1460646099.10638.44.camel@edumazet-glaptop3.roam.corp.google.com> <20160414151813.GE3715@orbyte.nwl.cc> <alpine.LNX.2.00.1604141807350.27368@cbobk.fhfr.pm> <1460656170.10638.61.camel@edumazet-glaptop3.roam.corp.google.com>
 <5710E1C1.2090209@mojatatu.com> <1460732328.10638.74.camel@edumazet-glaptop3.roam.corp.google.com> <alpine.LNX.2.00.1606281717140.6874@cbobk.fhfr.pm> <CAM_iQpVQZOh7LaCxSH0JXj4iHn0bt0vhZgcpsh8C99gor+ZO0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Phil Sutter <phil@nwl.cc>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33689 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752614AbcF1RdM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 13:33:12 -0400
In-Reply-To: <CAM_iQpVQZOh7LaCxSH0JXj4iHn0bt0vhZgcpsh8C99gor+ZO0A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Jun 2016, Cong Wang wrote:

> > BTW, I've started to actually work on fixing this, and I've noticed that
> > TBF behavior actually violates what's stated in pfifo_fast manpage:
> >
> > ==========
> >         Whenever  an  interface is created, the pfifo_fast qdisc is
> >         automatically used as a queue. If another qdisc is
> >         attached, it preempts the default pfifo_fast, which automatically
> >         returns to function when an  existing  qdisc is detached.
> >
> >         In this sense this qdisc is magic, and unlike other qdiscs.
> > ==========
> 
> It is out of date, now default qdisc can be set to any other qdisc
> via /proc. Also, probably due to historical reasons, we don't have
> a unified default default qdisc, some uses bfifo, some uses pfifo,
> we may break some existing script if we change that.

While I do understand that reasoning, I'd argue that unpredictable and 
unexpected behavior of TBF causing systems with non-working networking is 
much more likely than any userspace having hard dependency on the fact 
that default (*) qdisc for TBF is noop.

(*) where 'default upon creation' != 'default when reset'

Thanks,

-- 
Jiri Kosina
SUSE Labs
