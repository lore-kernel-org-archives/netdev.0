From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC Patch net-next] net_sched: make classifying lockless on
 ingress
Date: Sat, 21 Dec 2013 17:11:46 -0500
Message-ID: <52B61222.8080000@mojatatu.com>
References: <1387582105-1789-1-git-send-email-xiyou.wangcong@gmail.com> <1387583344.19078.475.camel@edumazet-glaptop2.roam.corp.google.com> <CAM_iQpWLTL-PmiNz8k7Kv9KcHsFTennATKgbwQWXX2FN8vdxjg@mail.gmail.com> <1387584529.19078.482.camel@edumazet-glaptop2.roam.corp.google.com> <CAM_iQpXYpKE6zAAjFjzAW5KN=u7+C1gapz-bvkmVNFsNi+Jqmw@mail.gmail.com> <52B4FDD1.10608@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: John Fastabend <john.r.fastabend@intel.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:38646 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192Ab3LUWLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Dec 2013 17:11:49 -0500
Received: by mail-ig0-f176.google.com with SMTP id k19so18222403igc.3
        for <netdev@vger.kernel.org>; Sat, 21 Dec 2013 14:11:49 -0800 (PST)
In-Reply-To: <52B4FDD1.10608@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/13 21:32, John Fastabend wrote:

> If you only steal the prequeue piece then you don't solve the lock
> contention part so I don't think it helps. At which point I suspect
> you might as well use one of the existing qdiscs not designed for
> multiqueue nics.
>

Indeed.


> Yeah well I imagined I would write a rate limiting qdisc to use
> this infrastructure. Jamal hinted at using a systolic processes
> for this. But I work on this when I have time and have been
> busy the last few months with other things unfortunately.

The main problem is you cant avoid locks once you have sharing across
multiple processors. You could try to improve certain things, but
you'll be doing that at the expense of certain use cases; and for
a general purpose OS, it gets hard.
a) netdev: All qdiscs are attached to a netdev. netdevs are shared
across cpus that is if you want the goodies they come with.
If we can ease that, then we may improve the parallelization.
At one point, in a discussion with Eric, it seemed he was heading
towards a per-netdev-ingress-per-cpu (sort of what  multiqueu does for
transmit). Then you can make certain things like netdev stats loosely 
synchronous and rcu would make a lot of sense.
b) graphs of flows and actions are shareable across netdevs and
cpus. Just choose not to share and you can optimize your use case
(at the expense of missing out the sharing features). IOW, this becomes
a config option.

cheers,
jamal
