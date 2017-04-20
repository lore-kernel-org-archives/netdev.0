From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v5 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Thu, 20 Apr 2017 13:39:54 -0400
Message-ID: <9c5e4039-c4ea-616a-173b-8af2e80e1f19@mojatatu.com>
References: <1492693582-26810-1-git-send-email-jhs@emojatatu.com>
 <1492693582-26810-2-git-send-email-jhs@emojatatu.com>
 <1492704598.22296.43.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, xiyou.wangcong@gmail.com,
        netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35097 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S944667AbdDTRj5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 13:39:57 -0400
Received: by mail-io0-f194.google.com with SMTP id d203so18818246iof.2
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 10:39:57 -0700 (PDT)
In-Reply-To: <1492704598.22296.43.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-20 12:09 PM, Eric Dumazet wrote:
> On Thu, 2017-04-20 at 09:06 -0400, Jamal Hadi Salim wrote:
>
>>  	nest = nla_nest_start(skb, TCA_ACT_TAB);
>>  	if (nest == NULL)
>> @@ -1113,6 +1136,8 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
>>  	if (ret > 0) {
>>  		nla_nest_end(skb, nest);
>>  		ret = skb->len;
>> +		memcpy(nla_data(count_attr), &cb->args[1], sizeof(u32));
>
> This will not work on BigEndian 64bit hosts, since cb->args[1] is bigger
> than 32bit.
>

Ok, thanks.
I will assign to a 32 bit var first then memcpy in the next iteration
(tomorrow).

cheers,
jamal
