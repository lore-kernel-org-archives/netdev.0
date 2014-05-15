From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 01/15] net: qdisc: use rcu prefix and silence sparse
 warnings
Date: Thu, 15 May 2014 14:11:45 -0700
Message-ID: <53752D91.5040904@gmail.com>
References: <20140430163250.9021.21199.stgit@nitbit.x32> <20140430163504.9021.12828.stgit@nitbit.x32> <5373C660.7030301@gmail.com> <20140515204148.GP4570@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, Cong Wang <xiyou.wangcong@gmail.com>,
	jhs@mojatatu.com, netdev@vger.kernel.org, davem@davemloft.net
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:43244 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755538AbaEOVL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 17:11:58 -0400
Received: by mail-ob0-f180.google.com with SMTP id va2so1920523obc.25
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 14:11:58 -0700 (PDT)
In-Reply-To: <20140515204148.GP4570@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/15/2014 01:41 PM, Paul E. McKenney wrote:
> On Wed, May 14, 2014 at 12:39:12PM -0700, John Fastabend wrote:
>> On 04/30/2014 09:35 AM, John Fastabend wrote:
>>> Add __rcu notation to qdisc handling by doing this we can make
>>> smatch output more legible. And anyways some of the cases should
>>> be using rcu_dereference() see qdisc_all_tx_empty(),
>>> qdisc_tx_chainging(), and so on.
>>>
>>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>>> ---
>>
>> Now I'm trying to resolve the lingering sparse errors/warnings and I
>> have one that I'm not sure about. Maybe someone has some insight,
>>
>> net/sched/sch_generic.c:694:9: error: bad constant expression
>> net/sched/sch_generic.c:694:9: error: cannot size expression
>> net/sched/sch_generic.c:751:9: error: bad constant expression
>> net/sched/sch_generic.c:751:9: error: cannot size expression
>> net/sched/sch_generic.c:800:17: error: bad constant expression
>> net/sched/sch_generic.c:800:17: error: cannot size expression
>> net/sched/sch_generic.c:886:9: error: bad constant expression
>> net/sched/sch_generic.c:886:9: error: cannot size expression
>> net/sched/sch_generic.c:908:17: error: bad constant expression
>> net/sched/sch_generic.c:908:17: error: cannot size expression
>
> There is some compiletime_assert_atomic_type() bustage that causes
> errors like this.  There should be a fix on its way in.  Try making
> compiletime_assert_atomic_type() be an empty macro, and if that works,
> help is on the way.
>
> 							Thanx, Paul

OK the empty macro fixed the sparse errors I have. I'll pull in the
fix when I see it.

Thanks,
John


-- 
John Fastabend         Intel Corporation
