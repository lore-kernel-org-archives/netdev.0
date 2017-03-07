From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH 1/2] net: sched: make default fifo qdiscs appear in the
 dump
Date: Tue, 7 Mar 2017 10:59:36 +0100 (CET)
Message-ID: <alpine.LSU.2.20.1703071057300.31814@cbobk.fhfr.pm>
References: <alpine.LSU.2.20.1702252226530.24579@cbobk.fhfr.pm> <20170301.132144.1380602514921591101.davem@davemloft.net> <alpine.LSU.2.20.1703061158500.31814@cbobk.fhfr.pm> <20170306.103555.1351381782582641603.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
        jhs@mojatatu.com, phil@nwl.cc, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:52430 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752681AbdCGKBu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Mar 2017 05:01:50 -0500
In-Reply-To: <20170306.103555.1351381782582641603.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 6 Mar 2017, David Miller wrote:

> > Ah, right you are, thanks. The complete fix is not super trivial, as it 
> > needs some more surgery to tc_dump_qdisc_root(), tc_dump_tclass_root() and 
> > qdisc_match_from_root() (see 69012ae42 for some details).
> > 
> > There are two options:
> > 
> > - this gets fixed in two phases, in first everything *but* noop qdisc gets 
> >   dumped (in the "give me everything" dump) and later we finalize it by
> >   teaching the above functions about noop_qdisc as well
> > 
> > - I extend this patchset to handle noop qdisc from the very beginning; 
> >   I am unlikely to find time for this during coming weeks though. But OTOH
> >   this whole thing is very low priority anyway
> > 
> > What do you think?
> 
> I'm not too hot on this whole idea because the only way you can emit
> the noop_qdisc is to "dup" it by allocating a new qdisc so that you
> can link it in.  This has two downsides:
> 
> 1) Extra overhead and memory usage
> 
> 2) All of the simple checks against &noop_qdisc might not be
>    so simply any more.

Fully agreed.

I'd be inclined to just live with the fact that noop qdisc would never 
ever be visible in the dump. I think that in this particular case this can 
be easily justified, as the behavior is consistent with what is seen in 
the dump ("nothing happens to the packets"). All other cases will be 
covered.

If there are no objections to this, I'll send out v2 shortly.

Thanks,

-- 
Jiri Kosina
SUSE Labs
