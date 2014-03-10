From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RCU PATCH 07/14] net: sched: RCU cls_route
Date: Mon, 10 Mar 2014 12:36:14 -0700
Message-ID: <531E142E.1050203@gmail.com>
References: <20140310170008.3011.73599.stgit@nitbit.x32>  <20140310170610.3011.72548.stgit@nitbit.x32> <1394473516.3607.48.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:50734 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752771AbaCJTg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 15:36:57 -0400
Received: by mail-ob0-f179.google.com with SMTP id va2so7494567obc.38
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 12:36:56 -0700 (PDT)
In-Reply-To: <1394473516.3607.48.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/10/2014 10:45 AM, Eric Dumazet wrote:
> On Mon, 2014-03-10 at 10:06 -0700, John Fastabend wrote:
>> RCUify the route classifier. For now however spinlock's are used to
>> protect fastmap cache.
>>
>> The issue here is the fastmap may be read by one CPU while the
>> cache is being updated by another. An array of pointers could be
>> one possible solution.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---

[...]

>> -route4_reset_fastmap(struct Qdisc *q, struct route4_head *head, u32 id)
>> +route4_reset_fastmap(struct route4_head *head)
>>   {
>> -	spinlock_t *root_lock = qdisc_root_sleeping_lock(q);
>> -
>> -	spin_lock_bh(root_lock);
>> +	spin_lock(&fastmap_lock);
>
> Dont you need spin_lock_bh() ?


Right this should be _bh. Thanks.


-- 
John Fastabend         Intel Corporation
