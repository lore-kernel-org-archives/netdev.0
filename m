From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH 2/2] net: sched: convert qdisc linked list to hashtable
Date: Fri, 12 Aug 2016 16:36:01 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1608121634520.22028@cbobk.fhfr.pm>
References: <alpine.LNX.2.00.1608101049260.22028@cbobk.fhfr.pm> <alpine.LNX.2.00.1608101054320.22028@cbobk.fhfr.pm> <57ADC6AA.5070506@iogearbox.net> <alpine.LNX.2.00.1608121523020.22028@cbobk.fhfr.pm> <57ADDC8B.9010700@iogearbox.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Phil Sutter <phil@nwl.cc>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57ADDC8B.9010700@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 12 Aug 2016, Daniel Borkmann wrote:

> > I was thinking about something like the patch below (the reasong being 
> > that ->dev would be NULL only in cases of singletonish qdiscs) ... 
> > wouldn't that also fix the issue you're seeing? Have to think it 
> > through a little bit more ..
> 
> Ahh, so this has the same effect as previously observed with the other fix.

Thanks a lot for confirming that this fixes the panic. I still have to 
think a little bit more about this though.

> Perhaps it's just a dumping issue, but to the below clsact, there shouldn't
> be pfifo_fast instances appearing.
> 
> # tc qdisc show dev wlp2s0b1
> qdisc mq 0: root
> qdisc pfifo_fast 0: parent :4 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
> qdisc pfifo_fast 0: parent :3 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
> qdisc pfifo_fast 0: parent :2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
> qdisc pfifo_fast 0: parent :1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
> # tc qdisc add dev wlp2s0b1 clsact
> # tc qdisc show dev wlp2s0b1
> qdisc mq 0: root
> qdisc pfifo_fast 0: parent :4 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
> qdisc pfifo_fast 0: parent :3 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
> qdisc pfifo_fast 0: parent :2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
> qdisc pfifo_fast 0: parent :1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
> qdisc clsact ffff: parent ffff:fff1
> qdisc pfifo_fast 0: parent :4 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
> qdisc pfifo_fast 0: parent :3 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
> qdisc pfifo_fast 0: parent :2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
> qdisc pfifo_fast 0: parent :1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1

Hmm, no immediate idea where those are coming from, we'll have to figure 
it out. The mq device used here has 4 queues, right?

-- 
Jiri Kosina
SUSE Labs
