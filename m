From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [Patch net-next] tcp: add a tracepoint for tcp_retransmit_skb()
Date: Tue, 10 Oct 2017 19:56:09 -0700
Message-ID: <20171011025606.tzts5wgys5hn52p2@ast-mbp>
References: <20171010053547.21162-1-xiyou.wangcong@gmail.com>
 <20171010173821.6djxyvrggvaivqec@ast-mbp.dhcp.thefacebook.com>
 <87po9ull5u.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Brendan Gregg <brendan.d.gregg@gmail.com>,
        Song Liu <songliubraving@fb.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35482 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752099AbdJKC4M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 22:56:12 -0400
Received: by mail-pg0-f65.google.com with SMTP id l24so501606pgu.2
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 19:56:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <87po9ull5u.fsf@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 10, 2017 at 11:58:53PM +0200, Hannes Frederic Sowa wrote:
> Alexei Starovoitov <alexei.starovoitov@gmail.com> writes:
> 
> > On Mon, Oct 09, 2017 at 10:35:47PM -0700, Cong Wang wrote:
> 
> [...]
> 
> >> +		trace_tcp_retransmit_skb(sk, skb, segs);
> >
> > I'm happy to see new tracepoints being added to tcp stack, but I'm concerned
> > with practical usability of them.
> > Like the above tracepoint definition makes it not very useful from bpf point of view,
> > since 'sk' pointer is not recored by as part of the tracepoint.
> > In bpf/tracing world we prefer tracepoints to have raw pointers recorded
> > in TP_STRUCT__entry() and _not_ printed in TP_printk()
> > (since pointers are useless for userspace).
> 
> Ack.
> 
> Also could the TP_printk also use the socket cookies so they can get
> associated with netlink dumps and as such also be associated to user
> space processes? It could help against races while trying to associate
> the socket with a process. ss already supports dumping those cookies
> with -e.

makes sense to me.

> The corresponding commit would be:
> 
> commit 33cf7c90fe2f97afb1cadaa0cfb782cb9d1b9ee2
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Wed Mar 11 18:53:14 2015 -0700
> 
>     net: add real socket cookies
> 
> Right now they only get set when needed but as Eric already mentioned in
> his commit log, this could be refined.

actually we hit that too for completely different tracing use case.
Indeed would be good to generate socket cookie unconditionally
for all sockets. I don't think there is any harm.
