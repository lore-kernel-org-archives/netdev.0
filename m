From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: introduce dev_consume_skb_any()
Date: Thu, 05 Dec 2013 06:45:34 -0800
Message-ID: <1386254734.30495.186.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com>
	 <1386105850.30495.38.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJZOPZ+vnqLpdjS0TNdxDa4CNTzzfqp1=Ftjf86Fd5Lb+QdSzw@mail.gmail.com>
	 <20131203.165034.1085515763685633822.davem@davemloft.net>
	 <1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJZOPZ+bkvg4G6qzY6YmMui9-KmGmpHyFCJUD2xsFLOXm12rgA@mail.gmail.com>
	 <1386115199.30495.44.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1386247508.30495.180.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131205141346.GB14095@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:65181 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752266Ab3LEOpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 09:45:36 -0500
Received: by mail-pd0-f180.google.com with SMTP id q10so24717946pdj.39
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 06:45:35 -0800 (PST)
In-Reply-To: <20131205141346.GB14095@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-05 at 15:13 +0100, Hannes Frederic Sowa wrote:
> On Thu, Dec 05, 2013 at 04:45:08AM -0800, Eric Dumazet wrote:
> > -		local_irq_save(flags);
> > -		sd = &__get_cpu_var(softnet_data);
> > -		skb->next = sd->completion_queue;
> > -		sd->completion_queue = skb;
> > -		raise_softirq_irqoff(NET_TX_SOFTIRQ);
> > -		local_irq_restore(flags);
> > +	if (likely(atomic_read(&skb->users) == 1)) {
> > +		smp_rmb();
> 
> Could you give me a hint why this barrier is needed? IMHO the volatile
> access in atomic_read should get rid of the control dependency so I
> don't see a need for this barrier. Without the volatile access a
> compiler-barrier would still suffice, I guess?

Please take a look at kfree_skb() implementation.

If you think a comment is needed there, please feel free to add it.
