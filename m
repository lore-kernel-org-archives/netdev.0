From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 02/10] net: sched: introduce tcf block
 infractructure
Date: Tue, 16 May 2017 08:52:31 -0400
Message-ID: <b0ec3fa5-8746-0c1f-27e8-cb8960c7d01f@mojatatu.com>
References: <20170515083857.3615-1-jiri@resnulli.us>
 <20170515083857.3615-3-jiri@resnulli.us>
 <33ea772b-d35b-ae08-4137-b63185c2f590@mojatatu.com>
 <20170516122326.GK1939@nanopsycho.orion>
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
Received: from mail-io0-f194.google.com ([209.85.223.194]:32891 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751219AbdEPMwe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 08:52:34 -0400
Received: by mail-io0-f194.google.com with SMTP id m4so14331639ioe.0
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 05:52:34 -0700 (PDT)
In-Reply-To: <20170516122326.GK1939@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-05-16 08:23 AM, Jiri Pirko wrote:
> Tue, May 16, 2017 at 02:07:25PM CEST, jhs@mojatatu.com wrote:
>>
>> Jiri,
>>
>> I am sorry i am tied up elsewhere but will respond in chunks.
>>
>> On 17-05-15 04:38 AM, Jiri Pirko wrote:
>>
>>
>>>  static inline void qdisc_cb_private_validate(const struct sk_buff *skb, int sz)
>>>  {
>>>  	struct qdisc_skb_cb *qcb;
>>
>>
>>> +int tcf_block_get(struct tcf_block **p_block,
>>> +		  struct tcf_proto __rcu **p_filter_chain)
>>> +{
>>> +	struct tcf_block *block = kzalloc(sizeof(*block), GFP_KERNEL);
>>> +
>>> +	if (!block)
>>> +		return -ENOMEM;
>>> +	block->p_filter_chain = p_filter_chain;
>>> +	*p_block = block;
>>> +	return 0;
>>> +}
>>
>> tcf_block_get() sounds odd. tcf_block_create()?
>
> I used get/put because I plan to allow sharing of block between qdiscs
> in future. Then there will be a refcount.
>

Ok, I guess I should read further into the patches..


>>> -static struct tcf_proto __rcu **atm_tc_find_tcf(struct Qdisc *sch,
>>> -						unsigned long cl)
>>> +static struct tcf_block *atm_tc_tcf_block(struct Qdisc *sch, unsigned long cl)
>>
>> Any reason you removed the verb "find" from all these calls?
>> eg above: better to have atm_tc_tcf_block_find()?
>
> Yeah, I was thinking about it. The thing is, the callback does not do
> any lookup so "find" is not accurate. Also without "find" this is
> shorter so I decided for this naming variant.
>

They do select some chain - at least that was the intent.
Are you not planning to use this to pick a chain in a block?

cheers,
jamal
