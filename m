From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 3/8] net_sched: mirred: remove action when
 the target device is gone
Date: Wed, 18 Dec 2013 14:50:05 -0500
Message-ID: <52B1FC6D.7040005@mojatatu.com>
References: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com>	<1387167311-14763-4-git-send-email-xiyou.wangcong@gmail.com>	<52B1B1B1.2060501@mojatatu.com> <CAM_iQpUDZa-=H53Csg8476xOL0xP+rn85O8eB1O39-eF_Jo+uw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:55366 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751675Ab3LRTuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 14:50:07 -0500
Received: by mail-ie0-f169.google.com with SMTP id e14so170092iej.28
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 11:50:06 -0800 (PST)
In-Reply-To: <CAM_iQpUDZa-=H53Csg8476xOL0xP+rn85O8eB1O39-eF_Jo+uw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/18/13 13:36, Cong Wang wrote:
> On Wed, Dec 18, 2013 at 6:31 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> On 12/15/13 23:15, Cong Wang wrote:
>>>
>>> When the target device is removed, the mirred action is
>>> still there but with the dev pointer setting to NULL.
>>> This makes the output from 'tc filter' ugly. There is no
>>> reason to keep it.
>>>
>>
>> Sorry - this one i have problems with.
>> actions may be referenced from multiple filters,
>> you cant just delete it (that would leave other users
>> pointing to it dangling). Destroying would eventually
>> delete it when the refcount goes to 0.
>
> How? tcf_action_init() always allocates a new action,
> it doesn't even look for an existing one.
>


tc action blah index 123
tc action filter goo action blah index 123
tc action filter gah action blah index 123

Very useful for example for multiple flows to
share the same policer.


>> [And when we delete actions we send netlink events to announce
>> that]. The proper solution would require i.e tag it as to be
>> deleted and implement some form of garbage collection.
>
> It doesn't worth to have a GC for this...
>
> Even if what you said is true, we should just make a copy
> for each of the filters. I just tried to create two different filters
> with same and different mirred actions, my patch works
> perfectly.
>

A copy wont work. We want sharing.

cheers,
jamal
