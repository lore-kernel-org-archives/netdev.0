From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: speedup tcp_fixup_rcvbuf()
Date: Thu, 16 May 2013 15:20:06 -0700 (PDT)
Message-ID: <20130516.152006.741790547799409001.davem@davemloft.net>
References: <1368681955.3301.11.camel@edumazet-glaptop>
	<CADVnQy=uV85jypjHkVDBf1-BVrq5mx3juqAhyebG2p8zSpPm1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, ycheng@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55907 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752598Ab3EPWUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 18:20:07 -0400
In-Reply-To: <CADVnQy=uV85jypjHkVDBf1-BVrq5mx3juqAhyebG2p8zSpPm1w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Thu, 16 May 2013 11:23:03 -0400

> On Thu, May 16, 2013 at 1:25 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> tcp_fixup_rcvbuf() contains a loop to estimate initial socket
>> rcv space needed for a given mss. With large MTU (like 64K on lo),
>> we can loop ~500 times and consume a lot of cpu cycles.
>>
>> perf top of 200 concurrent netperf -t TCP_CRR
>>
>> 5.62%  netperf  [kernel.kallsyms]  [k] tcp_init_buffer_space
>> 1.71%  netperf  [kernel.kallsyms]  [k] _raw_spin_lock
>> 1.55%  netperf  [kernel.kallsyms]  [k] kmem_cache_free
>> 1.51%  netperf  [kernel.kallsyms]  [k] tcp_transmit_skb
>> 1.50%  netperf  [kernel.kallsyms]  [k] tcp_ack
>>
>> Lets use a 100% factor, and remove the loop.
>>
>> 100% is needed anyway for tcp_adv_win_scale=1
>> default value, and is also the maximum factor.
>>
>> Refs: commit b49960a05e32
>>       ("tcp: change tcp_adv_win_scale and tcp_rmem[2]")
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
 ...
> Acked-by: Neal Cardwell <ncardwell@google.com>

Applied.
