From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH v2 1/2] net: sched: make default fifo qdiscs appear in
 the dump
Date: Wed, 8 Mar 2017 16:21:36 +0100 (CET)
Message-ID: <alpine.LSU.2.20.1703081619220.31814@cbobk.fhfr.pm>
References: <alpine.LSU.2.20.1703081302240.31814@cbobk.fhfr.pm> <1488986279.28631.1.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Phil Sutter <phil@nwl.cc>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1488986279.28631.1.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 8 Mar 2017, Eric Dumazet wrote:

> > +++ b/net/sched/sch_qfq.c
> > @@ -494,6 +494,8 @@ static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
> >  			goto destroy_class;
> >  	}
> >  
> > +	if (cl->qdisc != &noop_qdisc)
> > +		qdisc_hash_add(cl->qdisc, true);
> 
> 
> Please move the test in qdisc_hash_add() instead of copy/pasting it all
> over the places ?

Well, qdisc_hash_add() has a WARN_ON() (inherited from what 
qdisc_list_add() used to do) for that particular case to catch cases where 
singleton qdisc would make it there from other places by mistake. By 
putting this test there we'll effectively giving up on this warning should 
it ever point to a bug.

Thanks,

-- 
Jiri Kosina
SUSE Labs
