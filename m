From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 3/8] net_sched: mirred: remove action when
 the target device is gone
Date: Wed, 18 Dec 2013 13:50:46 -0500 (EST)
Message-ID: <20131218.135046.1384071193262360018.davem@davemloft.net>
References: <1387167311-14763-4-git-send-email-xiyou.wangcong@gmail.com>
	<52B1B1B1.2060501@mojatatu.com>
	<CAM_iQpUDZa-=H53Csg8476xOL0xP+rn85O8eB1O39-eF_Jo+uw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754754Ab3LRSut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 13:50:49 -0500
In-Reply-To: <CAM_iQpUDZa-=H53Csg8476xOL0xP+rn85O8eB1O39-eF_Jo+uw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 18 Dec 2013 10:36:06 -0800

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

Indeed, I think Jamal is confusing how he intended the code to work
vs. how it actually does :-)
