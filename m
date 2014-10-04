From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH v1 2/2] net: sched: replace ematch calls to use struct
 net
Date: Fri, 03 Oct 2014 17:19:19 -0700
Message-ID: <542F3D07.6090008@intel.com>
References: <20141003054558.20925.67091.stgit@nitbit.x32>	<20141003054624.20925.28150.stgit@nitbit.x32> <CAHA+R7PWrAk1+ds8SNytf0dABwcSQYqSAvK9dTN44kQqRiq4Rw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Cong Wang <cwang@twopensource.com>,
	John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:10616 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756462AbaJDAUD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 20:20:03 -0400
In-Reply-To: <CAHA+R7PWrAk1+ds8SNytf0dABwcSQYqSAvK9dTN44kQqRiq4Rw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/2014 03:40 PM, Cong Wang wrote:
> On Thu, Oct 2, 2014 at 10:46 PM, John Fastabend
> <john.fastabend@gmail.com> wrote:
>> diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
>> index 81ddfa6..f37e4fb 100644
>> --- a/net/sched/cls_basic.c
>> +++ b/net/sched/cls_basic.c
>> @@ -32,7 +32,7 @@ struct basic_filter {
>>         struct tcf_exts         exts;
>>         struct tcf_ematch_tree  ematches;
>>         struct tcf_result       res;
>> -       struct tcf_proto        *tp;
>> +       struct net              *net;
>>         struct list_head        link;
>>         struct rcu_head         rcu;
>>  };
> 
> I guess storing this net pointer to struct tcf_ematch_tree is better,
> since it is only used by ematch?

Sure, that is fine. It is used by em_ipset and three classifiers. It
does simplify the API slightly if its in tcf_ematch, I guess. So I'll 
move it there.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
