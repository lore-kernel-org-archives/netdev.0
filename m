From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 04/10] net: sched: replace nprio by a bool to
 make the function more readable
Date: Tue, 16 May 2017 08:56:22 -0400
Message-ID: <6442bd7c-18dd-b4b8-b968-347e847b68b5@mojatatu.com>
References: <20170515083857.3615-1-jiri@resnulli.us>
 <20170515083857.3615-5-jiri@resnulli.us>
 <0553194d-9d76-bb39-4b29-c3c734a6ff44@mojatatu.com>
 <20170516122532.GL1939@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        xiyou.wangcong@gmail.com, dsa@cumulusnetworks.com,
        edumazet@google.com, stephen@networkplumber.org,
        daniel@iogearbox.net, alexander.h.duyck@intel.com,
        simon.horman@netronome.com, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33038 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752173AbdEPM4Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 08:56:24 -0400
Received: by mail-it0-f68.google.com with SMTP id l145so14000412ita.0
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 05:56:24 -0700 (PDT)
In-Reply-To: <20170516122532.GL1939@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-05-16 08:25 AM, Jiri Pirko wrote:
> Tue, May 16, 2017 at 02:09:25PM CEST, jhs@mojatatu.com wrote:
>> On 17-05-15 04:38 AM, Jiri Pirko wrote:
>>
>>> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
>>> index 88ec1a1..0e49e6e 100644
>>> --- a/net/sched/cls_api.c
>>> +++ b/net/sched/cls_api.c
>>> @@ -271,7 +271,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
>>>  	struct tcmsg *t;
>>>  	u32 protocol;
>>>  	u32 prio;
>>> -	u32 nprio;
>>> +	bool prio_allocate;
>>
>> prio_allocated? (past tense seems more sensible)
>
> No, it actually tell if the prio should be allocated:
>
>                 if (prio_allocate)
>                         prio = tcf_auto_prio(tcf_chain_tp_prev(&chain_info));
>
> I believe it is accurate.
>

Your mileage may vary, this chunk:
===
  			if (n->nlmsg_flags & NLM_F_CREATE) {
  				prio = TC_H_MAKE(0x80000000U, 0U);
+				prio_allocate = true;
  				break;
  			}

in which prio is used subsequently before the chunk you refer to
allocates implies the prio is already allocated.
Your call really.

I will review more later.

cheers,
jamal

cheers,
jamal
