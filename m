From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH 1/2] net: sched: make default fifo qdiscs appear in the
 dump
Date: Mon, 6 Mar 2017 12:03:38 +0100 (CET)
Message-ID: <alpine.LSU.2.20.1703061158500.31814@cbobk.fhfr.pm>
References: <alpine.LSU.2.20.1702252226530.24579@cbobk.fhfr.pm> <20170301.132144.1380602514921591101.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
        jhs@mojatatu.com, phil@nwl.cc, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47068 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753044AbdCFLGL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Mar 2017 06:06:11 -0500
In-Reply-To: <20170301.132144.1380602514921591101.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Mar 2017, David Miller wrote:

> > @@ -1066,6 +1066,7 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
> >  				      &pfifo_qdisc_ops, classid);
> >  	if (cl->qdisc == NULL)
> >  		cl->qdisc = &noop_qdisc;
> > +	qdisc_hash_add(cl->qdisc, true);
> >  	INIT_LIST_HEAD(&cl->children);
> >  	cl->vt_tree = RB_ROOT;
> >  	cl->cf_tree = RB_ROOT;
> > @@ -1425,6 +1426,7 @@ hfsc_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
> >  					  sch->handle);
> >  	if (q->root.qdisc == NULL)
> >  		q->root.qdisc = &noop_qdisc;
> > +	qdisc_hash_add(q->root.qdisc, true);
> >  	INIT_LIST_HEAD(&q->root.children);
> >  	q->root.vt_tree = RB_ROOT;
> >  	q->root.cf_tree = RB_ROOT;
> 
> I'm not so sure it is legal is potentially pass &noop_qdisc into qdisc_hash_add().

Ah, right you are, thanks. The complete fix is not super trivial, as it 
needs some more surgery to tc_dump_qdisc_root(), tc_dump_tclass_root() and 
qdisc_match_from_root() (see 69012ae42 for some details).

There are two options:

- this gets fixed in two phases, in first everything *but* noop qdisc gets 
  dumped (in the "give me everything" dump) and later we finalize it by
  teaching the above functions about noop_qdisc as well

- I extend this patchset to handle noop qdisc from the very beginning; 
  I am unlikely to find time for this during coming weeks though. But OTOH
  this whole thing is very low priority anyway

What do you think?

Thanks,

-- 
Jiri Kosina
SUSE Labs
