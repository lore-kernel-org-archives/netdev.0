From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH 2/2] net: sched: convert qdisc linked list to hashtable
Date: Tue, 16 Aug 2016 01:27:17 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1608160122420.22028@cbobk.fhfr.pm>
References: <alpine.LNX.2.00.1608101049260.22028@cbobk.fhfr.pm> <alpine.LNX.2.00.1608101054320.22028@cbobk.fhfr.pm> <57ADC6AA.5070506@iogearbox.net> <alpine.LNX.2.00.1608121523020.22028@cbobk.fhfr.pm>
 <CAM_iQpVD_+M7ehSxRRs6tRTfDWAzOp2hHLmSecguXq9YHYw5ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Phil Sutter <phil@nwl.cc>, David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpVD_+M7ehSxRRs6tRTfDWAzOp2hHLmSecguXq9YHYw5ag@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 13 Aug 2016, Cong Wang wrote:

> > How about we actually extend a little bit the TCQ_F_BUILTIN special case
> > test in qdisc_match_from_root()?
> >
> > After the change, the only way how qdisc_dev() could be NULL should be a
> > TCQ_F_BUILTIN case, right?
> >
> > I was thinking about something like the patch below (the reasong being
> > that ->dev would be NULL only in cases of singletonish qdiscs) ...
> > wouldn't that also fix the issue you're seeing? Have to think it through a
> > little bit more ..
> 
> I think this is probably why we never show noop qdisc in dump. 

Well, partially. A lot of 'default' qdiscs are omitted in a not really 
uniform and deterministic way. That's actually the primary point of this 
whole effort -- to get rid of the hidden qdiscs entirely.

> So I think we should relax the singleton rule for noop_qdisc, to save 
> some code for noop_qdisc case and also for dumping noop_qdisc.

Completely moving away from singleton qdiscs is one of the possibilities, 
but OTOH I think that my special-casing of !qdisc_dev(root) in 
qdisc_match_from_root() is correct handling of singletons. I've been 
completely off the grid for the past three days, but I plan to submit this 
as a proper followup fix tomorrow if noone has any objections.

> I will try to work on a patch tomorrow.

What still needs to be looked into are the duplicate clsact entries for 
multiqueue.

Thanks,

-- 
Jiri Kosina
SUSE Labs
