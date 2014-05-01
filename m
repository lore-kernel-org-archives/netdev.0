From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 01/15] net: qdisc: use rcu prefix and silence sparse
 warnings
Date: Thu, 01 May 2014 08:20:20 -0700
Message-ID: <53626634.60306@gmail.com>
References: <20140430163250.9021.21199.stgit@nitbit.x32>   <20140430163504.9021.12828.stgit@nitbit.x32>  <1398877228.29914.177.camel@edumazet-glaptop2.roam.corp.google.com>  <5361785B.6000604@gmail.com> <1398900557.29914.187.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:39338 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751721AbaEAPUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 11:20:38 -0400
Received: by mail-oa0-f45.google.com with SMTP id eb12so3769555oac.32
        for <netdev@vger.kernel.org>; Thu, 01 May 2014 08:20:38 -0700 (PDT)
In-Reply-To: <1398900557.29914.187.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/30/2014 04:29 PM, Eric Dumazet wrote:
> On Wed, 2014-04-30 at 15:25 -0700, John Fastabend wrote:
>
>> It looks like it except for qdisc_watchdog() which needs an
>> rcu_read_lock() if I'm not mistaken/
>>
>> static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
>> {
>> 	struct qdisc_watchdog *wd = container_of(timer, struct 		
>> 						 qdisc_watchdog,
>> 						 timer);
>>
>> 	rcu_read_lock();
>> 	qdisc_unthrottled(wd->qdisc);
>> 	__netif_schedule(qdisc_root(wd->qdisc));
>> 	rcu_read_unlock();
>>
>> 	return HRTIMER_NORESTART;
>> }
>>
>
> Normally, HRTIMER handlers are run under softirq.
>

Right, so I'll change the qdisc_root() usage to rcu_dereference_rtnl().

> Anyway you could simply use following on your builds
>
> CONFIG_PROVE_RCU=y
>

I've been doing this although I haven't checked the output on this
series for a bit and I missed a few places that need to be wrapped
with rtnl_dereference() in the tcf_* code.

Thanks!

>
>


-- 
John Fastabend         Intel Corporation
