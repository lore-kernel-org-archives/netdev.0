From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH net] net: neighbour: add neighbour dead check for neigh_timer_handler()
Date: Thu, 05 Dec 2013 08:32:00 +0800
Message-ID: <529FC980.8020101@cn.fujitsu.com>
References: <529DE13D.2070509@huawei.com>	<529E9579.7090201@cn.fujitsu.com>			<529EA9CF.2090008@huawei.com>		 <20131203.232122.852236751455974887.davem@davemloft.net>		 <529EC95A.5080908@huawei.com>	 <1386138457.30495.86.camel@edumazet-glaptop2.roam.corp.google.com>	 <529EF30A.4050609@huawei.com> <1386170645.30495.108.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
	joe@perches.com, vfalico@redhat.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:34642 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756259Ab3LEAaz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Dec 2013 19:30:55 -0500
In-Reply-To: <1386170645.30495.108.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/2013 11:24 PM, Eric Dumazet wrote:
> On Wed, 2013-12-04 at 17:16 +0800, Ding Tianhong wrote:
>>>> 						base->running_timer = neigh->timer;
>>>> 						neigh_timer_handler() => at this time, refcnt is 2;
>>>>
>>>> user->	neigh_changeaddr()
>>>> 	neigh_flush_dev();
>>>> 	neigh_del_imer, refcnt dec to 1;
>>>
>>> Nope : del_timer() would return 0 here, so we do not decrement refcnt.
>>>
>>
>> The first call for del_timer() will return 1, because the timer->entry.next is not NULL,
>> then in the neigh_destroy, the del_timer() again will return 0 because timer->entry.next is NULL. 
> 
> Again no. You are very mistaken.
> 
> del_timer() return code is not a hint. Its a precise meaning.
> 
> It cannot return 1 if the timer function is running or is about to run.
> 
> If you believe there is  bug in del_timer(), fix it ;)
> 
> 

Yes, you are right, __run_timers did this job.
So We still don't know what's the root reason.
