From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC Patch net-next] net_sched: make classifying lockless on
 ingress
Date: Fri, 20 Dec 2013 18:32:49 -0800
Message-ID: <52B4FDD1.10608@intel.com>
References: <1387582105-1789-1-git-send-email-xiyou.wangcong@gmail.com> <1387583344.19078.475.camel@edumazet-glaptop2.roam.corp.google.com> <CAM_iQpWLTL-PmiNz8k7Kv9KcHsFTennATKgbwQWXX2FN8vdxjg@mail.gmail.com> <1387584529.19078.482.camel@edumazet-glaptop2.roam.corp.google.com> <CAM_iQpXYpKE6zAAjFjzAW5KN=u7+C1gapz-bvkmVNFsNi+Jqmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59229 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752114Ab3LUCdG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Dec 2013 21:33:06 -0500
In-Reply-To: <CAM_iQpXYpKE6zAAjFjzAW5KN=u7+C1gapz-bvkmVNFsNi+Jqmw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/2013 4:24 PM, Cong Wang wrote:
> On Fri, Dec 20, 2013 at 4:08 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Fri, 2013-12-20 at 15:57 -0800, Cong Wang wrote:
>>
>>> Just push the lock down to ->enqueue() ? Since ingress qdisc is classless
>>> and its ->dequeue() is nop.
>>
>>
>> https://github.com/jrfastab/Linux-Kernel-QOS
>>
>> https://github.com/jrfastab/Linux-Kernel-QOS/commit/67746f95acd77cf15d7ce34f644b76058ce19813
>>
>
> It's a nice idea to introduce a ->prequeue().
>
> And so brave to play with RCU on singly linked list... maybe I can
> just steal the ->prequeue() piece. John? :-D

If you only steal the prequeue piece then you don't solve the lock
contention part so I don't think it helps. At which point I suspect
you might as well use one of the existing qdiscs not designed for
multiqueue nics.

>
> BTW, the last commit is about 5 months ago...

Yeah well I imagined I would write a rate limiting qdisc to use
this infrastructure. Jamal hinted at using a systolic processes
for this. But I work on this when I have time and have been
busy the last few months with other things unfortunately.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
