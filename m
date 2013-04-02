From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] cbq: incorrect processing of high limits
Date: Tue, 02 Apr 2013 14:30:54 -0400 (EDT)
Message-ID: <20130402.143054.1460998027326004295.davem@davemloft.net>
References: <5159852C.8060003@parallels.com>
	<1364833476.5113.157.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vvs@parallels.com, netdev@vger.kernel.org, kuznet@parallels.com,
	jhs@mojatatu.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45042 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757676Ab3DBSa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 14:30:57 -0400
In-Reply-To: <1364833476.5113.157.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 01 Apr 2013 09:24:36 -0700

> On Mon, 2013-04-01 at 17:01 +0400, Vasily Averin wrote:
>> currently cbq works incorrectly for limits > 10% real link bandwidth,
>> and practically does not work for limits > 50% real link bandwidth.
>> Below are results of experiments taken on 1 Gbit link
>> 
>>  In shaper | Actual Result
>> -----------+---------------
>>   100M     | 108 Mbps
>>   200M     | 244 Mbps
>>   300M     | 412 Mbps
>>   500M     | 893 Mbps
>> 
>> This happen because of q->now changes incorrectly in cbq_dequeue():
>> when it is called before real end of packet transmitting,
>> L2T is greater than real time delay, q_now gets an extra boost
>> but never compensate it.
>> 
>> To fix this problem we prevent change of q->now until its synchronization
>> with real time.
>> 
>> Signed-off-by: Vasily Averin <vvs@openvz.org>
>> Reviewed-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
 ...
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
