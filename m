From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC Patch net-next] net_sched: make classifying lockless on
 ingress
Date: Sun, 22 Dec 2013 11:01:06 -0500
Message-ID: <52B70CC2.9080805@mojatatu.com>
References: <1387582105-1789-1-git-send-email-xiyou.wangcong@gmail.com> <1387583344.19078.475.camel@edumazet-glaptop2.roam.corp.google.com> <CAM_iQpWLTL-PmiNz8k7Kv9KcHsFTennATKgbwQWXX2FN8vdxjg@mail.gmail.com> <1387584529.19078.482.camel@edumazet-glaptop2.roam.corp.google.com> <CAM_iQpXYpKE6zAAjFjzAW5KN=u7+C1gapz-bvkmVNFsNi+Jqmw@mail.gmail.com> <52B4FDD1.10608@intel.com> <52B61222.8080000@mojatatu.com> <52B61FA3.9050904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:62007 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752697Ab3LVQBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 11:01:09 -0500
Received: by mail-ig0-f177.google.com with SMTP id uy17so11374443igb.4
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 08:01:09 -0800 (PST)
In-Reply-To: <52B61FA3.9050904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/13 18:09, John Fastabend wrote:

>
> I solved this by making them per CPU and synchronizing when I hit
> an operation that required sync'ing them. Going forward if folks
> have the time to write SMP aware qdisc's that work with eventually
> consistent counters that would be great.
>

I think what you describe is reasonable as well. Need to weigh pro/con
of both.

> You could make this fully generic by having a classifer to match
> the cpu id and then forwarding the skb to a qdisc based on the
> cpu_id.
>

Indeed. More a "generic stateless metadata" classifier which may
look at more than just cpu id to make the systolic decision.
Probably at pre-enqueu that you had.
I would assume the amount of config update on such a table would be
very very minimal - so RCU would do well.
If someone wants more deeper lookup, then a tc classifier would make
more sense. But by default the generic stateless classifier maybe
sufficient.

> Then per-netdev-ingress-per-cpu is really just a configured policy.
> If we wanted to make it the default configuration that would be
> fine.
>

Perhaps thats just defensive talk on my part when people say "qdiscs
are slow". No - netdevs are slow. Rephrase: Netdevs are shared across
CPUs, you MUST lock. Locks create cache misses etc.
As an example, I dont know why something like RPS could not have 
benefited from the rich classifier-action if someone wanted it to.
So there may still be need for per-netdev-ingress-per-cpu.

cheers,
jamal
