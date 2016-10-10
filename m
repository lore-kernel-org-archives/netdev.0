From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net] net: add recursion limit to GRO
Date: Mon, 10 Oct 2016 18:20:35 +0200
Message-ID: <20161010162035.GA7422@bistromath.localdomain>
References: <8fb8ec65c178b4d37951c4538dedc880eef068d4.1476106975.git.sd@queasysnail.net>
 <1476108236.28155.299.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jiri Benc <jbenc@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34772 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752307AbcJJQUk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Oct 2016 12:20:40 -0400
Content-Disposition: inline
In-Reply-To: <1476108236.28155.299.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

2016-10-10, 07:03:56 -0700, Eric Dumazet wrote:
> On Mon, 2016-10-10 at 15:43 +0200, Sabrina Dubroca wrote:
> > Currently, GRO can do unlimited recursion through the gro_receive
> > handlers.  This was fixed for tunneling protocols by limiting tunnel GRO
> > to one level with encap_mark, but both VLAN and TEB still have this
> > problem.  Thus, the kernel is vulnerable to a stack overflow, if we
> > receive a packet composed entirely of VLAN headers.
> > 
> > This patch adds a recursion counter to the GRO layer to prevent stack
> > overflow.  When a gro_receive function hits the recursion limit, GRO is
> > aborted for this skb and it is processed normally.
> > 
> > Thanks to Vladimír Beneš <vbenes@redhat.com> for the initial bug report.
> 
> 
> Hi Sabrina
> 
> Have you considered using a per cpu counter ?
>
> It might be cheaper than using a 4-bit field in skb.

I thought about it, but this looked a bit simpler. I can try some
benchmarking tomorrow.


> Really this counter does not need to be stored in skb. GRO already uses
> way too much space in skb->cb[]

For net-next I'm working on turning GRO into a loop, which would
eliminate these few bits.


> Also please add appropriate unlikely() clauses, since most GRO traffic
> is not trying to kill hosts ;)

Right. I'll send a v2 with this later.


Thanks,

-- 
Sabrina
