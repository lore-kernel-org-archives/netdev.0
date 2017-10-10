From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Patch net-next] tcp: add a tracepoint for tcp_retransmit_skb()
Date: Tue, 10 Oct 2017 23:58:53 +0200
Message-ID: <87po9ull5u.fsf@stressinduktion.org>
References: <20171010053547.21162-1-xiyou.wangcong@gmail.com>
        <20171010173821.6djxyvrggvaivqec@ast-mbp.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Brendan Gregg <brendan.d.gregg@gmail.com>,
        Song Liu <songliubraving@fb.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:33339 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756534AbdJJV64 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 17:58:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexei Starovoitov <alexei.starovoitov@gmail.com> writes:

> On Mon, Oct 09, 2017 at 10:35:47PM -0700, Cong Wang wrote:

[...]

>> +		trace_tcp_retransmit_skb(sk, skb, segs);
>
> I'm happy to see new tracepoints being added to tcp stack, but I'm concerned
> with practical usability of them.
> Like the above tracepoint definition makes it not very useful from bpf point of view,
> since 'sk' pointer is not recored by as part of the tracepoint.
> In bpf/tracing world we prefer tracepoints to have raw pointers recorded
> in TP_STRUCT__entry() and _not_ printed in TP_printk()
> (since pointers are useless for userspace).

Ack.

Also could the TP_printk also use the socket cookies so they can get
associated with netlink dumps and as such also be associated to user
space processes? It could help against races while trying to associate
the socket with a process. ss already supports dumping those cookies
with -e.

The corresponding commit would be:

commit 33cf7c90fe2f97afb1cadaa0cfb782cb9d1b9ee2
Author: Eric Dumazet <edumazet@google.com>
Date:   Wed Mar 11 18:53:14 2015 -0700

    net: add real socket cookies

Right now they only get set when needed but as Eric already mentioned in
his commit log, this could be refined.

[...]
