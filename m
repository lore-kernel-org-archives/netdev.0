From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net] udp: preserve skb->dst if required for IP options
 processing
Date: Tue, 18 Jul 2017 09:50:14 +0200
Message-ID: <1500364214.2538.2.camel@redhat.com>
References: <1500275043.5566.1.camel@edumazet-glaptop3.roam.corp.google.com>
         <a72faa05ed7b5ede6467096121ad6cee1fee229d.1500325067.git.pabeni@redhat.com>
         <1500326770.5566.26.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55207 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751334AbdGRHuR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Jul 2017 03:50:17 -0400
In-Reply-To: <1500326770.5566.26.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-07-17 at 14:26 -0700, Eric Dumazet wrote:
> On Mon, 2017-07-17 at 22:59 +0200, Paolo Abeni wrote:
> > Eric noticed that in udp_recvmsg() we still need to access
> > skb->dst while processing the IP options.
> > Since commit 0a463c78d25b ("udp: avoid a cache miss on dequeue")
> > skb->dst is no more available at recvmsg() time and bad things
> > will happen if we enter the relevant code path.
> > 
> > This commit address the issue, avoid clearing skb->dst if
> > any IP options are present into the relevant skb.
> > Since the IP CB is contained in the first skb cacheline, we can
> > test it to decide to leverage the consume_stateless_skb()
> > optimization, without measurable additional cost in the faster
> > path.
> > 
> > Fixes: b65ac44674dd ("udp: try to avoid 2 cache miss on dequeue")
> 
> Strange.... I thought bug was coming from
> commit 0a463c78d25b ("udp: avoid a cache miss on dequeue")

You are right - and I was wrong with this tag.
> 
> Please also add original reporter, from syzkaller team.
> 
> Reported-by: Andrey Konovalov <andreyknvl@google.com>

I'll resubmit soon a v2 with the update tags. I'm not sure if I must or
must not retain your ack ?

BTW I think that __ip_options_echo() also needs to access skb->dev, via
fib_compute_spec_dst(), and perhaps another patch is needed. I'll look
at that today.

Thanks,

Paolo
