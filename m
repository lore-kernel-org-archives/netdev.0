From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] udp: preserve skb->dst if required for IP options
 processing
Date: Mon, 17 Jul 2017 14:35:58 -0700
Message-ID: <1500327358.5566.30.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1500275043.5566.1.camel@edumazet-glaptop3.roam.corp.google.com>
         <a72faa05ed7b5ede6467096121ad6cee1fee229d.1500325067.git.pabeni@redhat.com>
         <1500327006.5566.29.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33439 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751335AbdGQVgB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 17:36:01 -0400
Received: by mail-wr0-f195.google.com with SMTP id 40so296795wrw.0
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 14:36:00 -0700 (PDT)
In-Reply-To: <1500327006.5566.29.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-07-17 at 14:30 -0700, Eric Dumazet wrote:
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
> 
> Also the problem was not skb->dst at all, but fact that 
> skb->head can not be freed if IP options need later to be fetched.
> 
> ( __ip_options_echo() -> 
>    sptr = skb_network_header(skb);
> 
> ... -> use after free


Oh well, I read again the whole thing, and it seems you are right.

Acked-by: Eric Dumazet <edumazet@google.com>
