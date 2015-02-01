From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net] net: sched: fix panic in rate estimators
Date: Sat, 31 Jan 2015 20:45:02 -0800
Message-ID: <54CDAF4E.7040402@gmail.com>
References: <1422581412.21689.53.camel@edumazet-glaptop2.roam.corp.google.com> <20150131.175520.1521332119325954392.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:62390 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751581AbbBAEpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2015 23:45:14 -0500
Received: by mail-oi0-f47.google.com with SMTP id a141so40215179oig.6
        for <netdev@vger.kernel.org>; Sat, 31 Jan 2015 20:45:13 -0800 (PST)
In-Reply-To: <20150131.175520.1521332119325954392.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/31/2015 05:55 PM, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 29 Jan 2015 17:30:12 -0800
>
>> From: Eric Dumazet <edumazet@google.com>
>>
>> Doing the following commands on a non idle network device
>> panics the box instantly, because cpu_bstats gets overwritten
>> by stats.
>>
>> tc qdisc add dev eth0 root <your_favorite_qdisc>
>> ... some traffic (one packet is enough) ...
>> tc qdisc replace dev eth0 root est 1sec 4sec <your_favorite_qdisc>
>   ...
>> Lets play safe and not use an union : percpu 'pointers' are mostly read
>> anyway, and we have typically few qdiscs per host.
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Cc: John Fastabend <john.fastabend@gmail.com>
>> Fixes: 22e0f8b9322c ("net: sched: make bstats per cpu and estimator RCU safe")
>
> Applied and queued up for -stable, thanks Eric.
>

Thanks Eric, looks like my "replace" test scripts never sent traffic
before the replace call.

Also I haven't seen any RCU splats in awhile so I'll send out a patch
to drop the qdisc_lock on ing_filter shortly.

-- 
John Fastabend         Intel Corporation
