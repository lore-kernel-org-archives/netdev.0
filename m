From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v10 3/4] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Mon, 12 Jun 2017 07:16:05 -0400
Message-ID: <fbf09ea1-36ee-69b1-74b0-ac436fff86ad@mojatatu.com>
References: <1497182026-11594-1-git-send-email-jhs@emojatatu.com>
 <1497182026-11594-4-git-send-email-jhs@emojatatu.com>
 <20170611141303.GC1896@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        simon.horman@netronome.com, mrv@mojatatu.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34523 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751737AbdFLLQH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 07:16:07 -0400
Received: by mail-it0-f67.google.com with SMTP id 201so9241446itu.1
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 04:16:07 -0700 (PDT)
In-Reply-To: <20170611141303.GC1896@nanopsycho.orion>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-06-11 10:13 AM, Jiri Pirko wrote:
> Sun, Jun 11, 2017 at 01:53:45PM CEST, jhs@mojatatu.com wrote:
[..]
>> @@ -1168,14 +1185,24 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
>> 	if (a_o == NULL)
>> 		return 0;
>>
>> +	if (tb[TCA_ROOT_FLAGS])
>> +		nla_memcpy(&select_flags, tb[TCA_ROOT_FLAGS],
>> +			   sizeof(select_flags));
> 
> Please introduce a helper for this attr type in patch 1:
> 
> u32 select_flags;
> 
> select_flags = nla_get_flag_bits_values(tb[TCA_ROOT_FLAGS])
> 

This also is not useful.
It happens to be ok for this use case but not for the
general case. i.e.
We need to get the whole struct not just the values
and use the selector to pick what bits are affected.
Example if bit X is set to 1 in selector and bit X in value
is 0, then we set the kernel's bit X to 0.

cheers,
jamal
