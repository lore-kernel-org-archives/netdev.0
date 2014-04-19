From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net] sched, cls: check if we could overwrite actions when
 changing a filter
Date: Sat, 19 Apr 2014 07:10:59 -0400
Message-ID: <535259C3.10404@mojatatu.com>
References: <1397605563-29756-1-git-send-email-xiyou.wangcong@gmail.com>	<534E77D0.8000307@mojatatu.com>	<CAM_iQpXRVZ8_keaL-8OkmRVguA29bnTPS2ZHZ0j2SSeB6A=1jQ@mail.gmail.com>	<534FBFF0.3020606@mojatatu.com>	<CAM_iQpVqQbXcm0gGxe_JMURPtGYH+iOi8UGgvis5je6g9zbiKQ@mail.gmail.com>	<53513619.5060202@mojatatu.com> <CAM_iQpX13QBbGnsKfD1oL6t331-=wRWFU_0ktdtgngpfE1Z6nA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:59377 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077AbaDSLLU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Apr 2014 07:11:20 -0400
Received: by mail-ig0-f172.google.com with SMTP id hn18so339421igb.5
        for <netdev@vger.kernel.org>; Sat, 19 Apr 2014 04:11:20 -0700 (PDT)
In-Reply-To: <CAM_iQpX13QBbGnsKfD1oL6t331-=wRWFU_0ktdtgngpfE1Z6nA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/18/14 13:18, Cong Wang wrote:

> In this case, all the statements inside if (icmp) {} are actions, right?
> Sorry, I still fail to see why not allowing to change them *together*?
>

Yes, thats what i am saying as well. Maybe we were agreeing all along.

> IOW, what's wrong with changing if (icmp) { A } to if (icmp) { B } ?
> where A and B could be any complex combination of actions.
> RTNL lock guarantees this is transactional.
>

RTNL is one dimension. The other is the datapath processing.
You need to make sure that packets still flow correctly during the
change over.
My suggestion was you add the new rule first with a lower priority
so that it is never used as long as the current one is in place.
You then do a delete of the old one. RCU grace period passes
where current packets are processed then the new rule takes effect.
You dont have to follow that suggestion as long as you achieve the
goal.

> Users are responsible to ensure the logic of A or B is correct, not
> the kernel. Kernel should allow even a wrong combination,
> since there is no way to check the correctness in kernel.
>

I'd be happy with that.

> I never mean to only add or remove one of them inside, although
> my specific case is just for appending, my patch should allow to
> overwrite all the actions together.
>

Well - then go nuts and put out a patch.
Replace _all or none_ is a reasonable approach.


> It is not a corner case, it is a very basic functionality we need:
>
> We mirror icmp packets to every vethX device, when one of them
> is gone, we just remove the action; when a new one comes up,
> we append an action. So simple...
>

This is where my problem was Cong - you have a simple use case and i was
hoping that you dont base that for a generic solution. If you only
have one action, then no problem in deleting/adding it. But if you
have a group of actions then you delete/add the whole group.

cheers,
jamal
