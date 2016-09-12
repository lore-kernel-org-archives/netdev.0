From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v4 net-next 1/1] net_sched: Introduce skbmod action
Date: Mon, 12 Sep 2016 18:14:50 -0400
Message-ID: <77bca669-9113-3977-ad3c-478091422ff8@mojatatu.com>
References: <1473713206-2450-1-git-send-email-jhs@emojatatu.com>
 <1473717691.18970.82.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, daniel@iogearbox.net,
        john.r.fastabend@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:34976 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753142AbcILWOw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 18:14:52 -0400
Received: by mail-oi0-f67.google.com with SMTP id 2so24459069oif.2
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 15:14:52 -0700 (PDT)
In-Reply-To: <1473717691.18970.82.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-12 06:01 PM, Eric Dumazet wrote:
> On Mon, 2016-09-12 at 16:46 -0400, Jamal Hadi Salim wrote:
>
>> +
>> +static int tcf_skbmod_dump(struct sk_buff *skb, struct tc_action *a,
>> +			   int bind, int ref)
>> +{
>> +	struct tcf_skbmod *d = to_skbmod(a);
>> +	unsigned char *b = skb_tail_pointer(skb);
>> +	struct tcf_skbmod_params  *p = rtnl_dereference(d->skbmod_p);
>> +	struct tc_skbmod opt = {
>> +		.index   = d->tcf_index,
>> +		.refcnt  = d->tcf_refcnt - ref,
>> +		.bindcnt = d->tcf_bindcnt - bind,
>> +		.action  = d->tcf_action,
>> +	};
>> +	struct tcf_t t;
>> +
>> +	rcu_read_lock();
>
> You do not need rcu read lock protection here, RTNL is enough.

I noticed some very weird issues when I took that out.
Running sufficiently large amount of traffic (ping -f is sufficient)
I saw that when i did a dump it took anywhere between 6-15 seconds.
With the read_lock in place response was immediate.
I can go back and run things to verify - but it was very odd.

cheers,
jamal
